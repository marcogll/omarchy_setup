#!/usr/bin/env bash
# ===============================================================
# zerotier.sh - Configuración de ZeroTier
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_zerotier() {
    log_step "Configuración de ZeroTier"
    
    # Instalar ZeroTier
    log_info "Instalando ZeroTier..."
    sudo pacman -S --noconfirm --needed zerotier-one || {
        log_error "Error al instalar ZeroTier"
        return 1
    }
    
    # Habilitar y iniciar servicio
    log_info "Habilitando servicio de ZeroTier..."
    sudo systemctl enable zerotier-one.service
    sudo systemctl start zerotier-one.service
    
    log_success "ZeroTier instalado y servicio iniciado"
    log_info "Para unirte a una red, ejecuta: sudo zerotier-cli join <NETWORK_ID>"
    log_info "Para ver tu ID de ZeroTier: sudo zerotier-cli info"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zerotier "$@"
fi

