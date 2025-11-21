#!/usr/bin/env bash
#
# Módulo para copiar plantillas de documentos al directorio ~/Templates.
#

SCRIPT_DIR_MODULE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_ROOT="$(cd "${SCRIPT_DIR_MODULE}/.." && pwd)"

if [[ -f "${SCRIPT_DIR_MODULE}/common.sh" ]]; then
    source "${SCRIPT_DIR_MODULE}/common.sh"
else
    echo "Error: common.sh no encontrado."
    exit 1
fi

install_doc_templates() {
    log_step "Copiando plantillas de documentos"

    local src_dir="${SCRIPT_DIR_ROOT}/doc_templates"
    if [[ ! -d "$src_dir" ]]; then
        log_error "El directorio de plantillas no existe: ${src_dir}"
        return 1
    fi

    local target_user="${SUDO_USER:-$USER}"
    local target_home="$HOME"
    if [[ -n "${SUDO_USER:-}" ]]; then
        target_home="$(getent passwd "$target_user" 2>/dev/null | cut -d: -f6)"
        if [[ -z "$target_home" ]]; then
            target_home="$(eval echo "~${target_user}")"
        fi
    fi
    target_home="${target_home:-$HOME}"

    local dest_dir="${target_home}/Templates"
    if [[ ! -d "$dest_dir" ]]; then
        log_info "Creando directorio ${dest_dir}..."
        if ! mkdir -p "$dest_dir"; then
            log_error "No se pudo crear el directorio destino."
            return 1
        fi
    fi

    if ! cp -a "${src_dir}/." "$dest_dir/"; then
        log_error "No se pudieron copiar las plantillas a ${dest_dir}"
        return 1
    fi

    log_success "Plantillas copiadas a ${dest_dir}"
}
