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

