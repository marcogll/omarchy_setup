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

    # --- 1. Determinar origen de configuración ---
    # Usar mg_dotfiles
    local source_dir="${DOTFILES_DIR}/omarchy/hypr"
    local dest_dir="$HOME/.config/hypr"

    if [[ ! -d "$source_dir" ]]; then
        log_error "No se encontró la configuración en '${source_dir}'."
        log_info "Asegúrate de tener clonado el repositorio 'mg_dotfiles' en la ruta esperada."
        return 1
    fi

    # Crear copia de seguridad si ya existe una configuración
    if [[ -d "$dest_dir" ]] && [[ ! -L "$dest_dir" ]]; then
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

    log_info "Configurando Hyprland desde ${source_dir}..."
    if [[ "$source_dir" == "${DOTFILES_DIR}/omarchy/hypr" ]]; then
        log_info "Creando enlace simbólico a tus dotfiles personales..."
        ln -sfn "$source_dir" "$dest_dir"
    else
        log_info "Copiando configuración local (rsync)..."
        mkdir -p "$dest_dir"
        rsync -a --info=progress2 "$source_dir/" "$dest_dir/"
    fi

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