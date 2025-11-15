#!/usr/bin/env bash
# ===============================================================
# common.sh - Funciones comunes para los módulos
# ===============================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Funciones de logging
log_info() {
    echo -e "${BLUE}▶${NC} ${BOLD}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✓${NC} ${GREEN}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} ${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}✗${NC} ${RED}$1${NC}"
}

log_step() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Función para crear una copia de seguridad de un archivo o directorio
# Uso: backup_file "/ruta/al/archivo"
backup_file() {
    local path_to_backup="$1"
    if [[ -e "$path_to_backup" ]]; then
        local backup_path="${path_to_backup}.bak_$(date +%F_%T)"
        log_warning "Se encontró un archivo existente en '${path_to_backup}'."
        log_info "Creando copia de seguridad en: ${backup_path}"
        if mv "$path_to_backup" "$backup_path"; then
            log_success "Copia de seguridad creada."
        else
            log_error "No se pudo crear la copia de seguridad. Abortando para evitar pérdida de datos."
            return 1
        fi
    fi
    return 0
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar e instalar un paquete con pacman
# Uso: check_and_install_pkg "nombre-del-paquete"
check_and_install_pkg() {
    local pkg_name="$1"
    # pacman -T es una forma de verificar sin instalar, pero no funciona bien con grupos.
    # pacman -Q es más fiable para paquetes individuales.
    if ! pacman -Q "$pkg_name" &>/dev/null; then
        log_info "Instalando ${pkg_name}..."
        sudo pacman -S --noconfirm --needed "$pkg_name" || log_warning "No se pudo instalar ${pkg_name}."
    else
        log_info "${pkg_name} ya está instalado."
    fi
}


# Función para instalar helper AUR si no existe
ensure_aur_helper() {
    if command_exists yay; then
        echo "yay"
        return 0
    elif command_exists paru; then
        echo "paru"
        return 0
    else
        log_warning "No se detectó yay ni paru. Instalando yay..."
        cd /tmp
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -si --noconfirm
        echo "yay"
        return 0
    fi
}

# Función para actualizar sistema
update_system() {
    log_step "Actualizando sistema"
    log_info "Sincronizando repositorios y actualizando paquetes..."
    sudo pacman -Syu --noconfirm
    log_success "Sistema actualizado"
}

# Función para limpiar paquetes huérfanos
cleanup_orphans() {
    log_step "Limpieza de paquetes huérfanos"
    log_info "Buscando paquetes huérfanos..."
    sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
    log_success "Limpieza completada"
}
