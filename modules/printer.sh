#!/usr/bin/env bash
# ===============================================================
# printer.sh - Configuración de impresoras (CUPS)
# ===============================================================
#
# Este módulo instala y configura el sistema de impresión CUPS
# (Common Unix Printing System) en Arch Linux.
#
# Funciones principales:
#   - Instala CUPS, filtros de impresión y drivers genéricos.
#   - Instala Avahi para la detección automática de impresoras en red.
#   - Instala drivers específicos para impresoras Epson desde AUR.
#   - Habilita y arranca los servicios de CUPS y Avahi.
#   - Añade al usuario al grupo `lp` para permitir la administración
#     de impresoras.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_printer() {
    log_step "Configuración de Impresoras (CUPS)"

    local target_user="${SUDO_USER:-$USER}"

    # --- 1. Instalación de Paquetes Base ---
    log_info "Instalando CUPS y paquetes base de impresión..."
    # Paquetes:
    #   - cups, cups-pdf, cups-filters: El núcleo de CUPS.
    #   - ghostscript, gsfonts: Para interpretar PostScript.
    #   - gutenprint, foomatic-*: Drivers de impresión genéricos.
    #   - system-config-printer: Herramienta gráfica de configuración.
    #   - avahi, nss-mdns: Para descubrir impresoras en la red.
    local base_pkgs=(
        cups cups-pdf cups-filters ghostscript gsfonts gutenprint
        foomatic-db-engine foomatic-db foomatic-db-ppds
        foomatic-db-nonfree foomatic-db-nonfree-ppds
        system-config-printer avahi nss-mdns
    )

    if ! sudo pacman -S --noconfirm --needed "${base_pkgs[@]}"; then
        log_warning "Algunos paquetes base de impresión no pudieron instalarse. El servicio podría no funcionar."
    fi

    # --- 2. Instalación de Drivers de AUR ---
    log_info "Instalando drivers para impresoras Epson (desde AUR)..."
    # Drivers específicos para modelos de inyección de tinta de Epson.
    local aur_drivers=("epson-inkjet-printer-escpr" "epson-inkjet-printer-escpr2" "epson-printer-utility")
    if ! aur_install_packages "${aur_drivers[@]}"; then
        log_warning "No se pudieron instalar todos los drivers de Epson desde AUR. Revisa los mensajes de error."
    fi

    # --- 3. Habilitación de Servicios ---
    log_info "Habilitando y arrancando los servicios de impresión..."
    local services=("cups.service" "avahi-daemon.service")
    for svc in "${services[@]}"; do
        if ! sudo systemctl is-enabled "$svc" &>/dev/null; then
            sudo systemctl enable "$svc"
            log_success "Servicio ${svc} habilitado."
        fi
        if ! sudo systemctl is-active "$svc" &>/dev/null; then
            sudo systemctl start "$svc"
            log_success "Servicio ${svc} iniciado."
        fi
    done

    # --- 4. Configuración de Permisos de Usuario ---
    # El usuario debe pertenecer al grupo `lp` para administrar impresoras.
    if ! id -nG "$target_user" | grep -qw lp; then
        log_info "Agregando al usuario '${target_user}' al grupo 'lp' para administrar impresoras..."
        sudo usermod -aG lp "$target_user"
        log_warning "Para que este cambio de grupo tenga efecto, es necesario cerrar sesión y volver a iniciarla."
    else
        log_info "El usuario '${target_user}' ya pertenece al grupo 'lp'."
    fi

    log_success "La configuración de CUPS ha finalizado."
    log_info "Puedes añadir y gestionar tus impresoras desde la interfaz web de CUPS en http://localhost:631"
    log_info "o utilizando la herramienta gráfica 'system-config-printer'."

    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_printer "$@"
fi
