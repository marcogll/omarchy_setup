#!/usr/bin/env bash
# ===============================================================
# mouse_cursor.sh - Instala y configura el tema de cursor Bibata
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_mouse_cursor() {
    log_step "Instalación del Tema de Cursor (Bibata-Modern-Ice)"

    # --- Variables ---
    local CURSOR_THEME='Bibata-Modern-Ice'
    local CURSOR_SIZE=24
    local ENVS_FILE="$HOME/.config/hypr/envs.conf"
    local AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"
    local DOWNLOAD_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.tar.xz"
    local ARCHIVE_NAME="Bibata-Modern-Ice.tar.xz"

    # --- Paso 1 y 2: Descargar, Extraer e Instalar ---
    log_info "Descargando e instalando el tema de cursor..."
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d -p "/tmp" cursor_setup_XXXXXX)
    trap 'rm -rf "${TEMP_DIR}"' EXIT # Limpieza automática al salir

    if curl -sL "$DOWNLOAD_URL" -o "${TEMP_DIR}/${ARCHIVE_NAME}"; then
        tar -xJf "${TEMP_DIR}/${ARCHIVE_NAME}" -C "${TEMP_DIR}"
        mkdir -p "$HOME/.icons"
        # Asegurar una instalación limpia eliminando la versión anterior si existe
        if [ -d "${TEMP_DIR}/${CURSOR_THEME}" ]; then
            rm -rf "$HOME/.icons/${CURSOR_THEME}" # Eliminar destino para evitar conflictos
            if mv "${TEMP_DIR}/${CURSOR_THEME}" "$HOME/.icons/"; then
                log_success "Tema de cursor instalado en ~/.icons/"
            else
                log_error "No se pudo mover el tema del cursor a ~/.icons/"
                return 1
            fi
        else
            log_error "El directorio del tema '${CURSOR_THEME}' no se encontró en el archivo."
            return 1
        fi
    else
        log_error "No se pudo descargar el tema de cursor desde $DOWNLOAD_URL"
        return 1
    fi

    # --- Paso 3: Configurar variables de entorno para Hyprland ---
    if [ -f "$ENVS_FILE" ]; then
        log_info "Configurando variables de entorno en $ENVS_FILE..."
        if ! grep -q "HYPRCURSOR_THEME,${CURSOR_THEME}" "$ENVS_FILE"; then
            echo -e "\n# Custom Cursor Theme" >> "$ENVS_FILE"
            echo "env = HYPRCURSOR_THEME,$CURSOR_THEME" >> "$ENVS_FILE"
            echo "env = HYPRCURSOR_SIZE,$CURSOR_SIZE" >> "$ENVS_FILE"
            echo "env = XCURSOR_THEME,$CURSOR_THEME" >> "$ENVS_FILE"
            echo "env = XCURSOR_SIZE,$CURSOR_SIZE" >> "$ENVS_FILE"
            log_success "Variables de cursor añadidas a Hyprland."
        else
            log_info "Las variables de cursor para Hyprland ya parecen estar configuradas."
        fi
    fi

    # --- Paso 4: Configurar GTK ---
    log_info "Configurando el cursor para aplicaciones GTK..."
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"
    log_success "Configuración de GSettings aplicada."

    log_success "¡Configuración del cursor completada!"
    log_warning "Por favor, cierra sesión y vuelve a iniciarla para aplicar los cambios."
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mouse_cursor "$@"
fi