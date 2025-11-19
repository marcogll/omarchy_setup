#!/usr/bin/env bash
# ===============================================================
# mouse_cursor.sh - Instala y configura el tema de cursor Bibata
# ===============================================================
#
# Este módulo automatiza la descarga, instalación y configuración
# del tema de cursor "Bibata-Modern-Ice".
#
# Funciones principales:
#   - Descarga el tema de cursor desde su repositorio de GitHub.
#   - Lo instala en el directorio ~/.icons del usuario.
#   - Configura el cursor para Hyprland, modificando el fichero
#     `~/.config/hypr/envs.conf`.
#   - Configura el cursor para aplicaciones GTK a través de `gsettings`.
#
# Dependencias: curl, tar, gsettings (parte de glib2).
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# ---------------------------------------------------------------
# check_cursor_deps()
# ---------------------------------------------------------------
# Verifica que las dependencias necesarias para este módulo estén
# instaladas.
# ---------------------------------------------------------------
check_cursor_deps() {
    local missing_deps=0
    for cmd in curl tar gsettings; do
        if ! command_exists "$cmd"; then
            log_error "El comando '$cmd' es necesario pero no está instalado."
            ((missing_deps++))
        fi
    done
    return $missing_deps
}

# ---------------------------------------------------------------
# install_mouse_cursor()
# ---------------------------------------------------------------
# Orquesta todo el proceso de instalación y configuración del cursor.
# ---------------------------------------------------------------
install_mouse_cursor() {
    log_step "Instalación del Tema de Cursor (Bibata-Modern-Ice)"

    if ! check_cursor_deps; then
        return 1
    fi

    # --- Variables de Configuración ---
    local CURSOR_THEME='Bibata-Modern-Ice'
    local CURSOR_SIZE=24
    local HYPR_CONFIG_DIR="$HOME/.config/hypr"
    local ENVS_FILE="${HYPR_CONFIG_DIR}/envs.conf"
    local DOWNLOAD_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.tar.xz"
    local ARCHIVE_NAME="Bibata-Modern-Ice.tar.xz"

    # --- 1. Descarga e Instalación ---
    log_info "Descargando e instalando el tema de cursor..."
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d -p "/tmp" cursor_setup_XXXXXX)
    trap 'rm -rf "${TEMP_DIR}"' EXIT # Limpieza automática al salir

    if ! curl -sL "$DOWNLOAD_URL" -o "${TEMP_DIR}/${ARCHIVE_NAME}"; then
        log_error "No se pudo descargar el tema de cursor desde $DOWNLOAD_URL"
        return 1
    fi

    tar -xJf "${TEMP_DIR}/${ARCHIVE_NAME}" -C "${TEMP_DIR}"
    mkdir -p "$HOME/.icons"

    # Asegura una instalación limpia eliminando la versión anterior si existe.
    if [[ -d "${TEMP_DIR}/${CURSOR_THEME}" ]]; then
        rm -rf "$HOME/.icons/${CURSOR_THEME}"
        if ! mv "${TEMP_DIR}/${CURSOR_THEME}" "$HOME/.icons/"; then
            log_error "No se pudo mover el tema del cursor a ~/.icons/"
            return 1
        fi
        log_success "Tema de cursor instalado en ~/.icons/"
    else
        log_error "El directorio del tema '${CURSOR_THEME}' no se encontró en el archivo descargado."
        return 1
    fi

    # --- 2. Configuración para Hyprland ---
    log_info "Configurando el cursor para Hyprland..."
    mkdir -p "$HYPR_CONFIG_DIR"
    touch "$ENVS_FILE"

    # Elimina configuraciones de cursor anteriores para evitar duplicados.
    sed -i '/^env = HYPRCURSOR_THEME/d' "$ENVS_FILE"
    sed -i '/^env = HYPRCURSOR_SIZE/d' "$ENVS_FILE"
    sed -i '/^env = XCURSOR_THEME/d' "$ENVS_FILE"
    sed -i '/^env = XCURSOR_SIZE/d' "$ENVS_FILE"

    # Añade las nuevas variables de entorno.
    echo -e "\n# Configuración del Tema de Cursor (gestionado por Omarchy Setup)" >> "$ENVS_FILE"
    echo "env = HYPRCURSOR_THEME,$CURSOR_THEME" >> "$ENVS_FILE"
    echo "env = HYPRCURSOR_SIZE,$CURSOR_SIZE" >> "$ENVS_FILE"
    echo "env = XCURSOR_THEME,$CURSOR_THEME" >> "$ENVS_FILE"
    echo "env = XCURSOR_SIZE,$CURSOR_SIZE" >> "$ENVS_FILE"
    log_success "Variables de entorno para el cursor añadidas a $ENVS_FILE."

    # --- 3. Configuración para Aplicaciones GTK ---
    log_info "Configurando el cursor para aplicaciones GTK..."
    if gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" && \
       gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"; then
        log_success "Configuración de GSettings para GTK aplicada correctamente."
    else
        log_error "No se pudo aplicar la configuración de GSettings para GTK."
        return 1
    fi

    log_success "La configuración del cursor ha finalizado."
    log_warning "Para que todos los cambios surtan efecto, por favor, cierra sesión y vuelve a iniciarla."
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mouse_cursor "$@"
fi
