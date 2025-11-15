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
    
    log_success "ZeroTier instalado y servicio iniciado."
    log_info "Tu ID de ZeroTier es: $(sudo zerotier-cli info | awk '{print $3}')"
    echo ""

    read -p "¿Deseas unirte a una red de ZeroTier ahora? [s/N]: " confirm
    if [[ "${confirm}" =~ ^[SsYy]$ ]]; then
        read -p "Introduce el ID de la red de ZeroTier: " network_id
        if [[ -n "$network_id" ]]; then
            log_info "Uniéndote a la red ${network_id}..."
            if sudo zerotier-cli join "$network_id"; then
                log_success "Solicitud enviada para unirse a la red ${network_id}."
                log_warning "Recuerda autorizar este dispositivo en el panel de control de ZeroTier."
            else
                log_error "No se pudo unir a la red ${network_id}."
            fi
        else
            log_warning "No se introdujo ningún ID de red. Operación cancelada."
        fi
    else
        log_info "Operación omitida."
        log_info "Para unirte a una red más tarde, ejecuta:"
        log_info "sudo zerotier-cli join <NETWORK_ID>"
    fi
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zerotier "$@"
fi
