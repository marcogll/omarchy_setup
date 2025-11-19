#!/usr/bin/env bash
# ===============================================================
# zerotier.sh - Configuración de ZeroTier
# ===============================================================
#
# Este módulo se encarga de la instalación y configuración de
# ZeroTier One, un servicio de red virtual que permite conectar
# dispositivos de forma segura a través de internet.
#
# Funciones principales:
#   - Instala el paquete `zerotier-one` desde los repositorios.
#   - Habilita e inicia el servicio de ZeroTier.
#   - Ofrece una opción interactiva para que el usuario pueda unirse
#     a una red de ZeroTier inmediatamente después de la instalación.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_zerotier() {
    log_step "Configuración de ZeroTier"
    
    # --- 1. Instalación de ZeroTier ---
    log_info "Instalando ZeroTier One..."
    if ! aur_install_packages "zerotier-one"; then
        log_error "No se pudo instalar ZeroTier One. Abortando."
        return 1
    fi
    
    # --- 2. Habilitación del Servicio ---
    log_info "Habilitando e iniciando el servicio de ZeroTier..."
    # `enable --now` habilita el servicio para que arranque con el sistema
    # y lo inicia inmediatamente en la sesión actual.
    if ! sudo systemctl enable --now zerotier-one.service; then
        log_error "No se pudo iniciar el servicio de ZeroTier."
        return 1
    fi
    
    log_success "ZeroTier se ha instalado y el servicio está en ejecución."
    log_info "Tu ID de nodo de ZeroTier es: $(sudo zerotier-cli info | awk '{print $3}')"
    echo ""

    # --- 3. Unirse a una Red (Opcional) ---
    read -p "¿Deseas unirte a una red de ZeroTier ahora? [s/N]: " confirm
    if [[ "${confirm}" =~ ^[SsYy]$ ]]; then
        read -p "Introduce el ID de la red de ZeroTier: " network_id
        if [[ -n "$network_id" ]]; then
            log_info "Enviando solicitud para unirse a la red ${network_id}..."
            if sudo zerotier-cli join "$network_id"; then
                log_success "Solicitud enviada correctamente."
                log_warning "Recuerda que debes autorizar este dispositivo en el panel de control de tu red ZeroTier."
            else
                log_error "No se pudo enviar la solicitud para unirse a la red ${network_id}."
            fi
        else
            log_warning "No se introdujo ningún ID de red. Operación cancelada."
        fi
    else
        log_info "Se omitió la unión a una red."
        log_info "Para unirte a una red más tarde, puedes ejecutar el comando:"
        log_info "sudo zerotier-cli join <NETWORK_ID>"
    fi
    
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zerotier "$@"
fi
