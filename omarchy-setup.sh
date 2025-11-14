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

# Función para mostrar el menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🌀 Omarchy Setup Script — Configuración Modular${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Selecciona las opciones que deseas instalar:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 📦 Instalar Aplicaciones (VS Code, VLC, drivers, etc.)"
    echo -e "  ${GREEN}2)${NC} 🐚 Configurar Zsh (shell, plugins, config)"
    echo -e "  ${GREEN}3)${NC} 🐳 Instalar Docker y Portainer"
    echo -e "  ${GREEN}4)${NC} 🌐 Instalar ZeroTier"
    echo -e "  ${GREEN}5)${NC} 🖨️  Configurar Impresoras (CUPS)"
    echo -e "  ${GREEN}6)${NC} 🖱️ Instalar Tema de Cursor (Bibata)"
    echo -e "  ${GREEN}7)${NC} 🎨 Gestionar Temas de Iconos (Papirus, Tela, etc.)"
    echo -e "  ${GREEN}8)${NC} 🎬 Instalar DaVinci Resolve (Intel Edition)"
    echo -e "  ${GREEN}9)${NC} 🔄 Actualizar Sistema"
    echo -e "  ${GREEN}C)${NC} 🧹 Limpiar Paquetes Huérfanos"
    echo -e "  ${GREEN}A)${NC} ✅ Instalar Todo (opciones 1-6)"
    echo -e "  ${GREEN}0)${NC} 🚪 Salir"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${BOLD}Selecciona opción [0-9]: ${NC}"
}

# Función para ejecutar módulo
run_module() {
    local module_name=$1
    local module_file="${MODULES_DIR}/${module_name}.sh"
    
    if [[ ! -f "${module_file}" ]]; then
        log_error "Módulo ${module_name} no encontrado"
        return 1
    fi
    
    # Exportar REPO_BASE para que los módulos lo puedan usar
    export REPO_BASE
    
    # Cargar y ejecutar el módulo
    source "${module_file}"
    
    case "${module_name}" in
        "apps")
            install_apps
            ;;
        "zsh-config")
            install_zsh
            ;;
        "docker")
            install_docker
            ;;
        "zerotier")
            install_zerotier
            ;;
        "printer")
            install_printer
            ;;
        "mouse_cursor")
            install_mouse_cursor
            ;;
        "davinci-resolve")
            install_davinci_resolve
            ;;
        "icon_manager")
            bash "${module_file}"
            ;;
        *)
            log_error "Función no definida para el módulo ${module_name}"
            return 1
            ;;
    esac
}

# Función para instalar todo
install_all() {
    log_step "Instalación Completa de Omarchy"
    
    local modules=("apps" "zsh-config" "docker" "zerotier" "printer" "mouse_cursor")
    local failed=()
    
    for module in "${modules[@]}"; do
        log_info "Procesando módulo: ${module}"
        if run_module "${module}"; then
            log_success "Módulo ${module} completado"
        else
            log_error "Error en el módulo ${module}"
            failed+=("${module}")
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
        
        case "${choice}" in
            1)
                start_spinner "Instalando aplicaciones..."
                run_module "apps"
                stop_spinner $? "Módulo de aplicaciones finalizado."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            2)
                start_spinner "Configurando Zsh..."
                run_module "zsh-config"
                stop_spinner $? "Configuración de Zsh finalizada."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                start_spinner "Instalando Docker..."
                run_module "docker"
                stop_spinner $? "Instalación de Docker finalizada."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                start_spinner "Instalando ZeroTier..."
                run_module "zerotier"
                stop_spinner $? "Instalación de ZeroTier finalizada."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                start_spinner "Configurando impresoras..."
                run_module "printer"
                stop_spinner $? "Configuración de impresoras finalizada."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                start_spinner "Instalando tema de cursor..."
                run_module "mouse_cursor"
                stop_spinner $? "Tema de cursor instalado."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                # Este módulo es interactivo, no usamos spinner aquí
                run_module "icon_manager"
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                log_warning "DaVinci Resolve requiere el ZIP de instalación en ~/Downloads/"
                echo -ne "${BOLD}¿Continuar con la instalación? [s/N]: ${NC} "
                read -r confirm
                if [[ "${confirm}" =~ ^[SsYy]$ ]]; then
                    # El spinner se maneja dentro del módulo de DaVinci
                    run_module "davinci-resolve"
                else
                    log_info "Instalación cancelada"
                fi
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            9)
                start_spinner "Actualizando el sistema..."
                update_system
                stop_spinner $? "Sistema actualizado."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            C)
                start_spinner "Limpiando paquetes huérfanos..."
                cleanup_orphans
                stop_spinner $? "Limpieza finalizada."
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            A)
                echo -ne "${BOLD}¿Instalar todas las opciones (1-6)? [s/N]: ${NC} "
                read -r confirm
                if [[ "${confirm}" =~ ^[Ss]$ ]]; then
                    install_all
                else
                    log_info "Instalación cancelada"
                fi
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            0)
                log_info "Saliendo..."
                exit 0
                ;;
            *)
                log_error "Opción inválida. Presiona Enter para continuar..."
                read -r
                ;;
        esac
    done
}

# Ejecutar función principal
main "$@"
