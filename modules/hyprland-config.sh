#!/usr/bin/env bash
# ===============================================================
# hyprland-config.sh - Instala la configuración personalizada de Hyprland
# ===============================================================
#
# Este módulo se encarga de instalar una configuración personalizada
# para el gestor de ventanas Hyprland.
#
# Funciones principales:
#   - Realiza una copia de seguridad de la configuración existente de
#     Hyprland en ~/.config/hypr.
#   - Copia la nueva configuración desde la carpeta `hypr_config`
#     del repositorio a ~/.config/hypr.
#   - Establece un tema de iconos por defecto, utilizando para ello
#     funciones del módulo `icon_manager.sh`.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Se carga el módulo `icon_manager.sh` para poder utilizar su
# función `set_default_icon_theme`.
source "${SCRIPT_DIR}/icon_manager.sh"

run_module_main() {
    log_step "Instalación de la Configuración de Hyprland"

    # --- 1. Copia de Archivos de Configuración ---
    # La configuración que se va a instalar debe estar en una carpeta
    # llamada `hypr_config` en la raíz del repositorio.
    local source_dir="${SCRIPT_DIR}/../hypr_config"
    local dest_dir="$HOME/.config/hypr"

    if [[ ! -d "$source_dir" ]]; then
        log_error "No se encontró el directorio de configuración 'hypr_config'."
        log_info "Asegúrate de que la carpeta con tu configuración de Hyprland exista en la raíz del repositorio."
        return 1
    fi

    # Se crea una copia de seguridad de la configuración existente antes de sobrescribirla.
    # Se utiliza la función `backup_file` definida en `common.sh`.
    if ! backup_file "$dest_dir"; then
        return 1
    fi

    log_info "Copiando la configuración de Hyprland a ${dest_dir}..."
    # Se usa `rsync` para una copia eficiente que muestra el progreso.
    if ! rsync -a --info=progress2 "$source_dir/" "$dest_dir/"; then
        log_error "No se pudo copiar la configuración de Hyprland."
        return 1
    fi

    # --- 2. Establecimiento del Tema de Iconos ---
    log_info "Estableciendo el tema de iconos por defecto (Tela Nord)..."
    # Llama a una función del módulo `icon_manager.sh`.
    if ! set_default_icon_theme; then
        log_warning "No se pudo establecer el tema de iconos por defecto."
        # No es un error fatal, la configuración principal ya se copió.
    fi

    log_success "La configuración de Hyprland se ha instalado correctamente."
    log_warning "Para que los cambios se apliquen, por favor, cierra sesión y vuelve a iniciarla."
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
