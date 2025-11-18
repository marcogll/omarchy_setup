#!/usr/bin/env bash
# ===============================================================
# common.sh - Funciones y variables comunes para los módulos
# ===============================================================
#
# Este script define un conjunto de funciones y variables de utilidad
# que son compartidas por todos los módulos de instalación. El objetivo
# es estandarizar tareas comunes como mostrar mensajes, manejar
# paquetes, crear copias de seguridad y gestionar el helper de AUR.
#
# No debe ser ejecutado directamente, sino incluido (`source`) por
# otros scripts.
#
# ===============================================================

# --- Definición de Colores ---
# Se definen códigos de escape ANSI para dar formato y color a la
# salida en la terminal, mejorando la legibilidad.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (resetea el formato)
BOLD='\033[1m'

# --- Funciones de Logging ---
# Proporcionan una manera estandarizada de mostrar mensajes al
# usuario, con diferentes niveles de severidad (info, éxito,
# advertencia, error) y formato.

# Función interna para limpiar la línea del spinner si está activo.
_maybe_clear_spinner() {
    if declare -F spinner_clear_line >/dev/null; then
        spinner_clear_line
    fi
}

# Muestra un mensaje informativo.
log_info() {
    _maybe_clear_spinner
    echo -e "${BLUE}▶${NC} ${BOLD}$1${NC}"
}

# Muestra un mensaje de éxito.
log_success() {
    _maybe_clear_spinner
    echo -e "${GREEN}✓${NC} ${GREEN}$1${NC}"
}

# Muestra un mensaje de advertencia.
log_warning() {
    _maybe_clear_spinner
    echo -e "${YELLOW}⚠${NC} ${YELLOW}$1${NC}"
}

# Muestra un mensaje de error.
log_error() {
    _maybe_clear_spinner
    echo -e "${RED}✗${NC} ${RED}$1${NC}"
}

# Muestra un separador visual para marcar el inicio de un paso importante.
log_step() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# --- Funciones de Utilidad ---

# ---------------------------------------------------------------
# backup_file(path)
# ---------------------------------------------------------------
# Crea una copia de seguridad de un archivo o directorio existente.
# Añade una marca de tiempo al nombre del backup para evitar
# sobrescribir copias anteriores.
#
# Parámetros:
#   $1 - Ruta al archivo o directorio a respaldar.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# command_exists(command)
# ---------------------------------------------------------------
# Verifica si un comando está disponible en el PATH del sistema.
#
# Parámetros:
#   $1 - Nombre del comando a verificar.
# ---------------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------
# check_and_install_pkg(package_name)
# ---------------------------------------------------------------
# Comprueba si un paquete ya está instalado con pacman. Si no lo
# está, intenta instalarlo.
#
# Parámetros:
#   $1 - Nombre del paquete a instalar.
# ---------------------------------------------------------------
check_and_install_pkg() {
    local pkg_name="$1"
    if ! pacman -Q "$pkg_name" &>/dev/null; then
        log_info "Instalando ${pkg_name}..."
        if sudo pacman -S --noconfirm --needed "$pkg_name"; then
            return 0
        else
            log_warning "No se pudo instalar ${pkg_name}."
            return 1
        fi
    else
        log_info "${pkg_name} ya está instalado."
    fi
    return 0
}

# ---------------------------------------------------------------
# ensure_aur_helper()
# ---------------------------------------------------------------
# Asegura que un helper de AUR (yay o paru) esté instalado.
# Si no encuentra ninguno, procede a instalar `yay-bin` desde AUR.
# Devuelve el nombre del helper encontrado o instalado.
# ---------------------------------------------------------------
ensure_aur_helper() {
    if command_exists yay; then
        echo "yay"
        return 0
    elif command_exists paru; then
        echo "paru"
        return 0
    else
        log_warning "No se detectó yay ni paru. Instalando yay..."
        # Instala `yay-bin` para evitar compilarlo desde cero, lo que es más rápido.
        cd /tmp
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -si --noconfirm
        echo "yay"
        return 0
    fi
}

# ---------------------------------------------------------------
# aur_install_packages(packages...)
# ---------------------------------------------------------------
# Instala una lista de paquetes desde el AUR.
#
# Utiliza el helper de AUR (yay o paru) que encuentre o instale.
# Pasa los flags necesarios para una instalación no interactiva.
#
# Parámetros:
#   $@ - Lista de nombres de paquetes de AUR a instalar.
# ---------------------------------------------------------------
aur_install_packages() {
    local packages=("$@")
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    local helper="${AUR_HELPER_CMD:-}"
    if [[ -z "$helper" ]]; then
        helper="$(ensure_aur_helper)" || helper=""
    fi

    if [[ -z "$helper" ]]; then
        log_error "No se pudo determinar un helper de AUR disponible."
        return 1
    fi

    local -a base_flags=(--noconfirm --needed)
    AUR_HELPER_CMD="$helper"
    local status=0
    case "$helper" in
        yay)
            "$helper" -S "${base_flags[@]}" \
                --answerdiff None \
                --answerclean All \
                --answeredit None \
                --mflags "--noconfirm" \
                --cleanafter \
                "${packages[@]}"
            status=$?
            ;;
        paru)
            "$helper" -S "${base_flags[@]}" \
                --skipreview \
                --cleanafter \
                --mflags "--noconfirm" \
                "${packages[@]}"
            status=$?
            ;;
        *)
            log_error "Helper AUR desconocido: ${helper}"
            return 1
            ;;
    esac
    return $status
}

# ---------------------------------------------------------------
# update_system()
# ---------------------------------------------------------------
# Sincroniza los repositorios y actualiza todos los paquetes del
# sistema usando `pacman`.
# ---------------------------------------------------------------
update_system() {
    log_step "Actualizando sistema"
    log_info "Sincronizando repositorios y actualizando paquetes..."
    sudo pacman -Syu --noconfirm
    log_success "Sistema actualizado"
}

# ---------------------------------------------------------------
# cleanup_orphans()
# ---------------------------------------------------------------
# Elimina paquetes que fueron instalados como dependencias pero
# que ya no son requeridos por ningún paquete.
# ---------------------------------------------------------------
cleanup_orphans() {
    log_step "Limpieza de paquetes huérfanos"
    log_info "Buscando paquetes huérfanos..."
    # El `|| true` evita que el script falle si no se encuentran huérfanos.
    sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
    log_success "Limpieza completada"
}
