#!/usr/bin/env bash
# ===============================================================
# 🌀 Omarchy Setup Script — Configuración modular para Arch Linux
# ===============================================================

set -u

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
REPO_BASE="https://raw.githubusercontent.com/marcogll/omarchy_setup/main"

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

# Cargar funciones comunes
source "${MODULES_DIR}/common.sh"

# Asegurar que los módulos son ejecutables (para ejecución individual)
log_info "Verificando permisos de los módulos..."
chmod +x "${MODULES_DIR}"/*.sh 2>/dev/null || true

# --- Funciones de UI Mejorada (Spinner y Barra de Progreso) ---

SPINNER_PID=

# Inicia una animación de spinner en segundo plano
# Uso: start_spinner "Mensaje..."
start_spinner() {
    (
        local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        while :; do
            for (( i=0; i<${#chars}; i++ )); do
                echo -ne "${CYAN}${chars:$i:1}${NC} $1\r"
                sleep 0.1
            done
        done
    ) &
    SPINNER_PID=$!
    # Ocultar cursor
    tput civis
}

# Detiene el spinner y muestra un mensaje de finalización
# Uso: stop_spinner $? "Mensaje de éxito" "Mensaje de error"
stop_spinner() {
    local exit_code=$1
    local success_msg=$2
    local error_msg=${3:-"Ocurrió un error"}
    
    if [[ -n "$SPINNER_PID" ]] && kill -0 "$SPINNER_PID" 2>/dev/null; then
        kill "$SPINNER_PID" &>/dev/null
        wait "$SPINNER_PID" &>/dev/null
    fi
    
    # Limpiar la línea del spinner
    echo -ne "\r\033[K"
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$success_msg"
    else
        log_error "$error_msg"
    fi
    # Restaurar cursor
    tput cnorm
    SPINNER_PID=
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
    ["3"]="docker;install_docker;🐳 Instalar Docker y Portainer;bg"
    ["4"]="zerotier;install_zerotier;🌐 Instalar ZeroTier VPN;bg"
    ["5"]="printer;install_printer;🖨️  Configurar Impresoras (CUPS);bg"
    ["6"]="mouse_cursor;install_mouse_cursor;🖱️ Instalar Tema de Cursor (Bibata);bg"
    ["7"]="icon_manager;run_module_main;🎨 Gestionar Temas de Iconos (Papirus, Tela, etc.);fg"
    ["8"]="davinci-resolve;install_davinci_resolve;🎬 Instalar DaVinci Resolve (Intel Edition);fg"
    ["H"]="hyprland-config;run_module_main;🎨 Instalar Configuración de Hyprland;bg"
    ["F"]="disk-format;run_module_main;💾 Formatear un Disco (FAT32, exFAT, NTFS, ext4);fg"
)

# Módulos a incluir en la opción "Instalar Todo"
INSTALL_ALL_CHOICES=("1" "2" "3" "4" "5" "6")

# Función para mostrar el menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🌀 Omarchy Setup Script — Configuración Modular${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Selecciona las opciones que deseas instalar:${NC}"
    echo ""
    # Generar menú dinámicamente
    for key in "${!MODULES[@]}"; do
        IFS=';' read -r _ _ description _ <<< "${MODULES[$key]}"
        # Asegurarse de que las claves numéricas se ordenen correctamente
        echo -e "  ${GREEN}${key})${NC} ${description}"
    done | sort -V

    echo -e "  ${GREEN}A)${NC} ✅ Instalar Todo (opciones 1, 2, 3, 4, 5, 6)"
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

# Función para instalar todo
install_all() {
    log_step "Instalación Completa de Omarchy"
    
    local failed=()
    
    for choice in "${INSTALL_ALL_CHOICES[@]}"; do
        IFS=';' read -r module_file _ description _ <<< "${MODULES[$choice]}"
        log_info "Ejecutando: ${description}"
        if run_module "${choice}"; then
            log_success "Módulo ${module_file} completado"
        else
            log_error "Error en el módulo ${module_file}"
            failed+=("${module_file}")
        fi
        echo ""
    done
    
    if [[ ${#failed[@]} -eq 0 ]]; then
        log_success "Todas las instalaciones se completaron correctamente"
    else
        log_warning "Algunos módulos fallaron: ${failed[*]}"
    fi
}

# Función principal
main() {
    # Limpieza al salir: detener el spinner y restaurar el cursor
    trap 'stop_spinner 1 "Script interrumpido." >/dev/null 2>&1; exit 1' INT TERM
    # Limpieza final al salir normalmente
    trap 'tput cnorm' EXIT

    # Verificar que estamos en Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        log_error "Este script está diseñado para Arch Linux"
        exit 1
    fi
    
    # Verificar permisos de sudo
    if ! sudo -n true 2>/dev/null; then
        log_info "Este script requiere permisos de sudo"
        sudo -v
    fi
    
    # Mantener sudo activo en background
    (while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null) &
    
    # Bucle principal del menú
    # Exportar funciones para que los submódulos las puedan usar
    export -f start_spinner
    export -f stop_spinner

    while true; do
        show_menu
        read -r choice
        choice=$(echo "${choice// /}" | tr '[:lower:]' '[:upper:]') # Eliminar espacios y convertir a mayúsculas
        
        if [[ -v "MODULES[$choice]" ]]; then
            IFS=';' read -r _ _ description type <<< "${MODULES[$choice]}"
            
            # Manejo especial para DaVinci Resolve
            if [[ "$choice" == "8" ]]; then
                log_warning "DaVinci Resolve requiere el ZIP de instalación en ~/Downloads/"
                echo -ne "${BOLD}¿Continuar con la instalación? [s/N]: ${NC} "
                read -r confirm
                if ! [[ "${confirm}" =~ ^[SsYy]$ ]]; then
                    log_info "Instalación cancelada"
                    read -p "Presiona Enter para continuar..."
                    continue
                fi
            fi

            if [[ "$type" == "bg" ]]; then
                spinner_msg="${description#* }..." # "Instalar Apps..."
                start_spinner "Ejecutando: ${spinner_msg}"
                run_module "$choice"
                stop_spinner $? "Módulo '${description}' finalizado."
            else # 'fg'
                run_module "$choice"
            fi

            echo ""
            read -p "Presiona Enter para continuar..."

        elif [[ "$choice" == "A" ]]; then
                echo -ne "${BOLD}¿Instalar todas las opciones (1, 2, 3, 4, 5, 6)? [s/N]: ${NC} "
                read -r confirm
                if [[ "${confirm}" =~ ^[Ss]$ ]]; then
                    install_all
                else
                    log_info "Instalación cancelada"
                fi
                echo ""
                read -p "Presiona Enter para continuar..."
        elif [[ "$choice" == "0" ]]; then
                log_info "Saliendo..."
                exit 0
        else
                log_error "Opción inválida. Presiona Enter para continuar..."
                read -r
        fi
    done
}

# Ejecutar función principal
main "$@"
