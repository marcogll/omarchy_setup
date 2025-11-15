#!/usr/bin/env bash
# ===============================================================
# printer.sh - Configuración de impresoras (CUPS)
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_printer() {
    log_step "Configuración de Impresoras (CUPS)"
    
    # Instalar CUPS y drivers comunes
    log_info "Instalando CUPS y drivers de impresora..."
    sudo pacman -S --noconfirm --needed \
        cups cups-pdf \
        ghostscript gsfonts \
        gutenprint foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree-ppds foomatic-db-nonfree \
        system-config-printer \
        avahi || {
        log_error "Error al instalar CUPS"
        return 1
    }
    
    # Instalar drivers específicos desde AUR (para Epson)
    log_info "Buscando drivers de Epson en AUR..."
    local AUR_DRIVERS=("epson-inkjet-printer-escpr" "epson-inkjet-printer-escpr2")
    local AUR_HELPER
    AUR_HELPER=$(ensure_aur_helper)

    if [[ -n "$AUR_HELPER" ]]; then
        log_info "Instalando drivers de Epson con ${AUR_HELPER}..."
        "$AUR_HELPER" -S --noconfirm --needed "${AUR_DRIVERS[@]}" || log_warning "No se pudieron instalar todos los drivers de Epson desde AUR."
    else
        log_error "No se encontró un ayudante de AUR (yay, paru). No se pueden instalar los drivers de Epson."
        # No retornamos error, el resto de la configuración puede continuar
    fi

    # Habilitar y iniciar servicios
    log_info "Habilitando servicios de impresora..."
    sudo systemctl enable cups.service
    sudo systemctl enable avahi-daemon.service
    sudo systemctl start cups.service
    sudo systemctl start avahi-daemon.service
    
    # Agregar usuario al grupo lp (si no está ya)
    if ! groups "$USER" | grep -q lp; then
        log_info "Agregando usuario al grupo lp..."
        sudo usermod -aG lp "$USER"
    fi
    
    log_success "CUPS instalado y configurado"
    log_info "Accede a la interfaz web de CUPS en: http://localhost:631"
    log_info "O usa: system-config-printer para configurar impresoras"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_printer "$@"
fi
