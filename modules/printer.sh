#!/usr/bin/env bash
# ===============================================================
# printer.sh - Configuración de impresoras (CUPS)
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_printer() {
    log_step "Configuración de Impresoras (CUPS)"

    local target_user="${SUDO_USER:-$USER}"

    log_info "Instalando CUPS y paquetes base..."
    local base_pkgs=(
        cups cups-pdf cups-filters
        ghostscript gsfonts
        gutenprint
        foomatic-db-engine foomatic-db foomatic-db-ppds
        foomatic-db-nonfree foomatic-db-nonfree-ppds
        system-config-printer
        avahi nss-mdns
    )
    local pkg_failed=false
    for pkg in "${base_pkgs[@]}"; do
        if ! check_and_install_pkg "$pkg"; then
            pkg_failed=true
        fi
    done
    if [[ "$pkg_failed" == true ]]; then
        log_warning "Algunos paquetes base no pudieron instalarse. Revisa los mensajes anteriores."
    fi

    log_info "Instalando drivers para Epson (ESC/P-R)..."
    local aur_drivers=("epson-inkjet-printer-escpr" "epson-inkjet-printer-escpr2" "epson-printer-utility")
    if ! aur_install_packages "${aur_drivers[@]}"; then
        log_warning "No se pudieron instalar todos los drivers de Epson de forma automática. Revisa 'epson-inkjet-printer-escpr2' y 'epson-printer-utility' manualmente."
    fi

    log_info "Verificando servicios de impresión..."
    local services=("cups.service" "avahi-daemon.service")
    for svc in "${services[@]}"; do
        if sudo systemctl is-enabled "$svc" &>/dev/null; then
            log_info "${svc} ya está habilitado."
        else
            sudo systemctl enable "$svc"
            log_success "${svc} habilitado."
        fi

        if sudo systemctl is-active "$svc" &>/dev/null; then
            log_info "${svc} ya está en ejecución."
        else
            sudo systemctl start "$svc"
            log_success "${svc} iniciado."
        fi
    done

    if ! id -nG "$target_user" | grep -qw lp; then
        log_info "Agregando usuario ${target_user} al grupo lp..."
        sudo usermod -aG lp "$target_user"
    else
        log_info "El usuario ${target_user} ya pertenece al grupo lp."
    fi

    log_success "Dependencias de impresión instaladas."
    log_info "Añade tu impresora Epson L4150 desde http://localhost:631 o con 'system-config-printer'."
    log_info "El módulo no configura impresoras automáticamente; solo deja listas las dependencias."

    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_printer "$@"
fi
