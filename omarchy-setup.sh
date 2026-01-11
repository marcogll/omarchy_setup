#!/usr/bin/env bash
# ===============================================================
# 🌀 Omarchy Setup Script — Configuración modular para Arch Linux
# ===============================================================

set -u

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
REPO_BASE="https://raw.githubusercontent.com/marcogll/omarchy_setup/main"
SUDO_PASSWORD=""

# Verificar que los módulos existen
if [[ ! -d "${MODULES_DIR}" ]] || [[ ! -f "${MODULES_DIR}/common.sh" ]]; then
    echo -e "\033[0;31m✗ Error: Módulos no encontrados\033[0m"
    echo ""
    echo "Este script requiere que los módulos estén presentes localmente."
    echo "Por favor, clona el repositorio completo:"
    echo ""
    echo "  git clone https://github.com/marcogll/omarchy_setup.git"
    echo "  cd omarchy_setup"
    echo "  ./omarchy-setup.sh"
    echo ""
    exit 1
fi

# Verificar mg_dotfiles si se va a usar Zsh o Hyprland
if [[ ! -d "${DOTFILES_DIR:-}" ]]; then
    echo -e "\033[0;33m⚠ Advertencia: mg_dotfiles no encontrado en ${DOTFILES_DIR}\033[0m"
    echo "Opciones 2 (Zsh) y H (Hyprland) requieren mg_dotfiles."
    echo "Ejecuta: git clone https://github.com/marcogll/mg_dotfiles.git ${DOTFILES_DIR}"
    echo ""
fi

# Cargar funciones comunes
source "${MODULES_DIR}/common.sh"

# Asegurar que los módulos son ejecutables (para ejecución individual)
log_info "Verificando permisos de los módulos..."
chmod +x "${MODULES_DIR}"/*.sh 2>/dev/null || true

# --- Funciones de UI Mejorada (Indicador de Progreso) ---

SPINNER_ACTIVE=0
SPINNER_MESSAGE=

pause_spinner() {
    if (( SPINNER_ACTIVE )); then
        SPINNER_ACTIVE=0
    fi
}

resume_spinner() {
    if [[ -n "$SPINNER_MESSAGE" ]]; then
        log_info "$SPINNER_MESSAGE"
        SPINNER_ACTIVE=1
    fi
}

start_spinner() {
    local message="$1"
    pause_spinner
    SPINNER_MESSAGE="$message"
    SPINNER_ACTIVE=1
    log_info "$message"
}

stop_spinner() {
    local exit_code=$1
    local success_msg=$2
    local error_msg=${3:-"Ocurrió un error"}

    pause_spinner

    if [[ $exit_code -eq 0 ]]; then
        log_success "$success_msg"
    else
        log_error "$error_msg"
    fi

    SPINNER_MESSAGE=
}

ensure_sudo_session() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    if [[ -n "${SUDO_PASSWORD:-}" ]]; then
        if printf '%s\n' "$SUDO_PASSWORD" | sudo -S -v >/dev/null 2>&1; then
            return 0
        fi
        SUDO_PASSWORD=""
        log_warning "La contraseña de sudo almacenada no es válida. Se solicitará nuevamente."
    fi

    pause_spinner

    local attempts=0
    while (( attempts < 3 )); do
        if (( attempts == 0 )); then
            log_info "Se requiere autenticación de sudo para continuar."
        else
            log_info "Intenta ingresar la contraseña nuevamente."
        fi
        local password_input=""
        read -s -p "Contraseña de sudo: " password_input
        echo ""

        if [[ -z "$password_input" ]]; then
            log_warning "La contraseña no puede estar vacía."
        elif printf '%s\n' "$password_input" | sudo -S -v >/dev/null 2>&1; then
            SUDO_PASSWORD="$password_input"
            log_success "Sesión de sudo autenticada."
            return 0
        else
            log_error "Contraseña de sudo incorrecta."
        fi

        ((attempts++))
    done

    log_error "No se pudo autenticar con sudo después de varios intentos."
    return 1
}

# --- Definición de Módulos ---
# Clave: Opción del menú
# Valor: "Nombre del Fichero;Función Principal;Descripción;Tipo (bg/fg)"
# Tipo 'bg': Tareas de fondo, usan spinner.
# Tipo 'fg': Tareas interactivas (foreground), no usan spinner.
declare -A MODULES
MODULES=(
    ["1"]="apps;run_module_main;📦 Instalar Aplicaciones (VS Code, VLC, drivers, etc.);bg"
    ["2"]="zsh-config;install_zsh;🐚 Configurar Zsh (shell, plugins, config);bg"
    ["3"]="docker;install_docker;🐳 Instalar Docker y Portainer;fg"
    ["4"]="zerotier;install_zerotier;🌐 Instalar ZeroTier VPN;fg"
    ["5"]="printer;install_printer;🖨️  Configurar Impresoras (CUPS);bg"
    ["6"]="mouse_cursor;install_mouse_cursor;🖱️ Instalar Tema de Cursor (Bibata);bg"
    ["7"]="icon_manager;run_module_main;🎨 Gestionar Temas de Iconos (Papirus, Tela, etc.);fg"
    ["7D"]="icon_manager;set_default_icon_theme;🎨 Instalar Tema de Iconos por Defecto;bg"
    ["S"]="suspend;run_module_main;🌙 Activar Suspensión en Menú System;bg"
    ["K"]="ssh-keyring;sync_ssh_keyring;🔐 Sincronizar claves SSH con GNOME Keyring;fg"
    ["F"]="disk-format;run_module_main;💾 Habilitar Formatos FAT/exFAT/NTFS/ext4;bg"
    ["H"]="hyprland-config;run_module_main;🎨 Instalar Configuración de Hyprland;bg"
    ["T"]="doc_templates;install_doc_templates;📄 Copiar Plantillas de Documentos a ~/Templates;bg"
)

# Generar dinámicamente la lista de módulos para "Instalar Todo"
get_install_all_choices() {
    local choices=()
    for key in $(printf '%s\n' "${!MODULES[@]}" | sort -V); do
        # Excluir el módulo interactivo de iconos (7)
        if [[ "$key" == "7" ]]; then
            continue
        fi
        # Si el módulo 7D existe, añadirlo en lugar del 7
        if [[ "$key" == "7D" ]]; then
            choices+=("7D")
        elif [[ ! "$key" =~ D$ ]]; then # Evitar añadir otros módulos 'D'
            choices+=("$key")
        fi
    done
    # Asegurarse de que el orden sea consistente
    printf '%s\n' "${choices[@]}" | sort -V | xargs
}

# Módulos a incluir en la opción "Instalar Todo"
INSTALL_ALL_CHOICES=($(get_install_all_choices))

# Función para mostrar el menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🌀 Omarchy Setup Script — Configuración Modular${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Selecciona las opciones que deseas instalar:${NC}"
    echo ""
    # Generar menú dinámicamente, excluyendo los módulos "D" (Default)
    for key in $(printf '%s\n' "${!MODULES[@]}" | sort -V); do
        if [[ "$key" =~ D$ ]]; then
            continue
        fi
        IFS=';' read -r _ _ description _ <<< "${MODULES[$key]}"
        echo -e "  ${GREEN}${key})${NC} ${description}"
    done

    local install_all_keys=$(IFS=,; echo "${INSTALL_ALL_CHOICES[*]}")
    echo -e "  ${GREEN}A)${NC} ✅ Instalar Todo (${install_all_keys//,/, })"
    echo -e "  ${GREEN}0)${NC} 🚪 Salir"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${BOLD}Selecciona opción: ${NC}"
}

# Función para ejecutar módulo
run_module() {
    local choice=$1
    IFS=';' read -r module_file func_name description type <<< "${MODULES[$choice]}"

    # Para funciones internas como update_system
    if [[ ! -f "${MODULES_DIR}/${module_file}.sh" && "$(type -t "$func_name")" == "function" ]]; then
        "$func_name"
        return $?
    fi

    local full_path="${MODULES_DIR}/${module_file}.sh"
    if [[ ! -f "$full_path" ]]; then
        log_error "Módulo para la opción '${choice}' (${module_file}.sh) no encontrado."
        return 1
    fi

    # Exportar REPO_BASE para que los módulos lo puedan usar
    export REPO_BASE

    # Cargar y ejecutar el módulo
    source "$full_path"

    if [[ "$(type -t "$func_name")" != "function" ]]; then
        log_error "La función principal '${func_name}' no está definida en '${module_file}.sh'."
        return 1
    fi

    "$func_name"
    return $?
}

# Función para ejecutar un módulo con lógica de reintento
# Intenta ejecutar un módulo. Si falla, lo reintenta una vez más.
# Devuelve 0 si tiene éxito en cualquier intento, 1 si falla en ambos.
run_module_with_retry() {
    local choice=$1
    local max_intentos=2
    local intento_actual=1
    local module_entry="${MODULES[$choice]}"
    local module_type=""
    if [[ -n "$module_entry" ]]; then
        IFS=';' read -r _ _ _ module_type <<< "$module_entry"
    fi
    local tmp_output=""
    if [[ "$module_type" == "bg" ]]; then
        tmp_output="$(mktemp)"
    fi

    while [ $intento_actual -le $max_intentos ]; do
        local estado_salida=0
        if [[ -n "$tmp_output" ]]; then
            run_module "$choice" >"$tmp_output" 2>&1
            estado_salida=$?
            if [[ -s "$tmp_output" ]]; then
                if declare -F pause_spinner >/dev/null; then
                    pause_spinner
                fi
                cat "$tmp_output"
            fi
            : > "$tmp_output"
            if [[ $estado_salida -ne 0 && $intento_actual -lt $max_intentos ]] && declare -F resume_spinner >/dev/null; then
                resume_spinner
            fi
        else
            run_module "$choice"
            estado_salida=$?
        fi

        if [ $estado_salida -eq 0 ]; then
            if [[ -n "$tmp_output" ]]; then
                rm -f "$tmp_output"
            fi
            return 0 # Éxito, salimos de la función
        fi

        log_warning "El módulo falló en el intento $intento_actual (código: $estado_salida)."
        if [ $intento_actual -lt $max_intentos ]; then
            log_info "Reintentando en 3 segundos..."
            sleep 3
        fi
        ((intento_actual++))
    done

    log_error "El módulo falló después de $max_intentos intentos."
    if [[ -n "$tmp_output" ]]; then
        rm -f "$tmp_output"
    fi
    return 1 # Falla definitiva
}

# Función para instalar todo
install_all() {
    log_step "Instalación Completa de Omarchy"

    local failed=()

    # Actualizar el sistema antes de instalar todo
    log_info "Actualizando el sistema antes de la instalación..."
    if ! update_system; then
        log_warning "La actualización del sistema falló. Continuando con la instalación..."
    fi

    for choice in "${INSTALL_ALL_CHOICES[@]}"; do
        IFS=';' read -r module_file _ description type <<< "${MODULES[$choice]}"

        if ! ensure_sudo_session; then
            failed+=("${module_file}")
            continue
        fi
        
        # Separador visual para cada módulo
        echo -e "\n${MAGENTA}────────────────────────────────────────────────────────────${NC}"
        log_step "Iniciando Módulo: ${description}"
        
        # Ejecutar con spinner para tareas de fondo (bg)
        if [[ "$type" == "bg" ]]; then
            start_spinner "Ejecutando: ${description#* }..."
            if run_module_with_retry "${choice}"; then
                stop_spinner 0 "Módulo '${description}' finalizado."
            else
                stop_spinner 1 "Error en el módulo '${description}'."
                failed+=("${module_file}")
            fi
        else # Ejecutar sin spinner para tareas interactivas (fg) y sin reintento
            if ! run_module "${choice}"; then
                log_error "Error en el módulo '${description}'."
                failed+=("${module_file}")
            fi
        fi
        echo ""
    done
    
    if [[ ${#failed[@]} -eq 0 ]]; then
        log_success "Todas las instalaciones se completaron correctamente."
    else
        log_warning "Algunos módulos fallaron: ${failed[*]}"
    fi

    echo ""
    log_step "Pasos Finales Recomendados"
    log_info "Para completar la configuración, por favor, sigue estos pasos:"
    echo "1. ${BOLD}Cierra sesión y vuelve a iniciarla.${NC} Esto es crucial para que se activen servicios como Docker y GNOME Keyring."
    echo "2. ${BOLD}Abre una nueva terminal y ejecuta este script de nuevo.${NC}"
    echo "3. ${BOLD}Selecciona la opción 'K'${NC} para sincronizar tus claves SSH con el agente de GNOME Keyring."
    echo ""
}

# Función principal
main() {
    # Limpieza al salir: detener el spinner y restaurar el cursor
    trap 'stop_spinner 1 "Script interrumpido." >/dev/null 2>&1; unset SUDO_PASSWORD; exit 1' INT TERM
    # Limpieza final al salir normalmente
    trap 'tput cnorm; unset SUDO_PASSWORD' EXIT

    # Verificar que estamos en Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        log_error "Este script está diseñado para Arch Linux"
        exit 1
    fi
    
    # Verificar permisos de sudo
    if ! ensure_sudo_session; then
        log_error "No se pudieron obtener privilegios de sudo. Saliendo."
        exit 1
    fi
    
    # Mantener sudo activo en background
    local parent_pid=$$
    (while true; do
        sudo -n true >/dev/null 2>&1
        sleep 60
        kill -0 "$parent_pid" || exit
    done 2>/dev/null) &
    
    # Bucle principal del menú
    # Exportar funciones para que los submódulos las puedan usar
    export -f start_spinner
    export -f stop_spinner
    export -f pause_spinner
    export -f resume_spinner
    export -f ensure_sudo_session

    while true; do
        show_menu
        read -r choice
        choice=$(echo "${choice// /}" | tr '[:lower:]' '[:upper:]') # Eliminar espacios y convertir a mayúsculas
        
        if [[ -v "MODULES[$choice]" ]]; then
            IFS=';' read -r _ _ description type <<< "${MODULES[$choice]}"
            
            if ! ensure_sudo_session; then
                read -p "Presiona Enter para continuar..."
                continue
            fi

            if [[ "$type" == "bg" ]]; then
                spinner_msg="${description#* }..." # "Instalar Apps..."
                start_spinner "${spinner_msg}"
                if run_module_with_retry "$choice"; then
                    stop_spinner 0 "Módulo '${description}' finalizado."
                else
                    stop_spinner 1 "Error en el módulo '${description}'."
                fi
            else # 'fg'
                log_info "Ejecutando módulo interactivo: ${description}"
                run_module "$choice"
            fi

            echo ""
            if declare -F pause_spinner >/dev/null; then
                pause_spinner
            fi
            read -p "Presiona Enter para continuar..."

        elif [[ "$choice" == "A" ]]; then
                local modules_to_install=$(IFS=,; echo "${INSTALL_ALL_CHOICES[*]}")
                log_warning "La opción 'Instalar Todo' ejecutará los módulos: ${modules_to_install//,/, }."
                echo -ne "${BOLD}¿Confirmas que deseas instalar todas las opciones ahora? [s/N]: ${NC}"
                read -r confirm
                if [[ "${confirm}" =~ ^[SsYy]$ ]]; then
                    install_all
                else
                    log_info "Instalación cancelada"
                fi
                echo ""
                if declare -F pause_spinner >/dev/null; then
                    pause_spinner
                fi
                read -p "Presiona Enter para continuar..."
        elif [[ "$choice" == "0" ]]; then
                log_info "Saliendo..."
                exit 0
        else
                log_error "Opción inválida. Presiona Enter para continuar..."
                if declare -F pause_spinner >/dev/null; then
                    pause_spinner
                fi
                read -r
        fi
    done
}

# Ejecutar función principal

# --- Redirección de logs ---
# Crear el directorio de logs si no existe
mkdir -p "${SCRIPT_DIR}/logs"
# Crear un nombre de archivo de log con la fecha y hora
LOG_FILE="${SCRIPT_DIR}/logs/omarchy-setup-$(date +%F_%H-%M-%S).log"

# Ejecutar la función principal y redirigir toda la salida (stdout y stderr)
# al archivo de log, mientras también se muestra en la terminal.
main "$@" 2>&1 | tee -a "${LOG_FILE}"
