#!/usr/bin/env bash
# ===============================================================
# suspend.sh - Activa la opción de suspensión en el menú System
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

run_module_main() {
    log_step "Activación de Opción de Suspensión"

    # Verificar que el comando existe
    if ! command -v omarchy-toggle-suspend &>/dev/null; then
        log_error "El comando 'omarchy-toggle-suspend' no está disponible."
        log_info "Este comando es parte de Omarchy y debe estar instalado."
        return 1
    fi

    # Verificar estado actual del archivo de toggle
    local suspend_file="$HOME/.local/state/omarchy/toggles/suspend-on"
    if [[ -f "$suspend_file" ]]; then
        log_info "La opción de suspensión ya está activa en el menú System."
        log_info "Para desactivarla, puedes ejecutar: omarchy-toggle-suspend"
        return 0
    fi

    # Activar suspensión
    log_info "Activando opción de suspensión en el menú System..."
    if omarchy-toggle-suspend; then
        log_success "Opción de suspensión activada correctamente."
        log_info "Ahora puedes usar Super+Esc para acceder al menú System y seleccionar Suspend."
        return 0
    else
        log_error "Error al activar la opción de suspensión."
        return 1
    fi
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
