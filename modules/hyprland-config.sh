#!/usr/bin/env bash
# ===============================================================
# hyprland-config.sh - Instala la configuración personalizada de Hyprland
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Cargar el gestor de iconos para usar sus funciones
source "${SCRIPT_DIR}/icon_manager.sh"

run_module_main() {
    log_step "Instalación de Configuración de Hyprland"

    # --- 1. Copiar archivos de configuración ---
    # La configuración de Hyprland debe estar en una carpeta 'hypr' en la raíz del repo
    local source_dir="${SCRIPT_DIR}/../hypr"
    local dest_dir="$HOME/.config/hypr"

    if [[ ! -d "$source_dir" ]]; then
        log_error "No se encontró el directorio de configuración 'hypr' en la raíz del repositorio."
        log_info "Asegúrate de que la carpeta con tu configuración se llame 'hypr'."
        return 1
    fi

    # Crear copia de seguridad si ya existe una configuración
    if [[ -d "$dest_dir" ]]; then
        local backup_dir="${dest_dir}.bak_$(date +%F_%T)"
        log_warning "Configuración de Hyprland existente encontrada."
        log_info "Creando copia de seguridad en: ${backup_dir}"
        if mv "$dest_dir" "$backup_dir"; then
            log_success "Copia de seguridad creada."
        else
            log_error "No se pudo crear la copia de seguridad. Abortando."
            return 1
        fi
    fi

    log_info "Copiando la configuración de Hyprland a ${dest_dir}..."
    # Usamos rsync para una copia eficiente
    rsync -a --info=progress2 "$source_dir/" "$dest_dir/"

    # --- 2. Establecer el tema de iconos por defecto ---
    log_info "Estableciendo el tema de iconos por defecto (Tela Nord)..."
    # Llamamos a la función específica de icon_manager.sh
    set_default_icon_theme

    log_success "Configuración de Hyprland instalada correctamente."
    log_warning "Por favor, cierra sesión y vuelve a iniciarla para aplicar los cambios."
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi