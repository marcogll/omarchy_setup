#!/usr/bin/env bash
# ===============================================================
# icon_manager.sh - Gestor de Temas de Iconos para Hyprland
# ===============================================================
#
# Este módulo proporciona una interfaz interactiva para instalar y
# cambiar entre diferentes temas de iconos. Está diseñado para
# integrarse con Hyprland, modificando su fichero de autostart
# para asegurar que la configuración del tema de iconos sea persistente
# entre sesiones.
#
# Dependencias: git, gsettings (parte de glib2).
#
# ===============================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# --- Variables Globales ---
# Ruta al fichero de autostart de Hyprland donde se guardará la configuración.
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"
# Directorio estándar para iconos instalados por el usuario.
ICON_DIR_USER="$HOME/.local/share/icons"

# --- Funciones de Utilidad ---

# ---------------------------------------------------------------
# check_deps()
# ---------------------------------------------------------------
# Verifica que las dependencias necesarias (git y gsettings)
# estén instaladas en el sistema.
# ---------------------------------------------------------------
check_deps() {
    if ! command_exists git; then
        log_error "El comando 'git' no está instalado. Por favor, instálalo para continuar (ej. sudo pacman -S git)."
        return 1
    fi
    if ! command_exists gsettings; then
        log_error "El comando 'gsettings' no está instalado. Es parte de 'glib2' y es esencial."
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------
# apply_theme(theme_name)
# ---------------------------------------------------------------
# Aplica un tema de iconos y lo hace persistente.
#
# Esta función realiza dos acciones:
#   1. Modifica el fichero de autostart de Hyprland (`autostart.conf`)
#      para que el tema se cargue automáticamente en cada inicio de sesión.
#   2. Aplica el tema en la sesión actual usando `gsettings` para
#      que el cambio sea visible de inmediato.
#
# Parámetros:
#   $1 - Nombre exacto del tema de iconos a aplicar.
# ---------------------------------------------------------------
apply_theme() {
    local theme_name="$1"
    log_info "Aplicando el tema de iconos '$theme_name'..."

    mkdir -p "$(dirname "$AUTOSTART_FILE")"
    touch "$AUTOSTART_FILE"

    # Elimina configuraciones anteriores del tema de iconos para evitar duplicados.
    sed -i '/exec-once = gsettings set org.gnome.desktop.interface icon-theme/d' "$AUTOSTART_FILE"

    # Añade un bloque de configuración si no existe.
    if ! grep -Fq "CONFIGURACIÓN DE TEMA DE ICONOS" "$AUTOSTART_FILE"; then
        echo -e "\n# -----------------------------------------------------" >> "$AUTOSTART_FILE"
        echo "# CONFIGURACIÓN DE TEMA DE ICONOS" >> "$AUTOSTART_FILE"
        echo "# -----------------------------------------------------" >> "$AUTOSTART_FILE"
        echo "exec-once = /usr/lib/xdg-desktop-portal-gtk" >> "$AUTOSTART_FILE"
        echo "exec-once = sleep 1" >> "$AUTOSTART_FILE"
    fi
    
    # Añade el comando para establecer el tema seleccionado.
    echo "exec-once = gsettings set org.gnome.desktop.interface icon-theme '$theme_name'" >> "$AUTOSTART_FILE"

    # Aplica el tema en la sesión actual.
    gsettings set org.gnome.desktop.interface icon-theme "$theme_name"

    log_success "¡Tema configurado! Se aplicó en la sesión actual y se guardó en $AUTOSTART_FILE."
}

# --- Funciones de Instalación de Temas ---

# Asegura que el tema base de Papirus esté instalado, ya que otros temas lo usan como base.
ensure_papirus_installed() {
    local temp_dir="$1"
    if [[ ! -d "$ICON_DIR_USER/Papirus-Dark" ]]; then
        log_info "El tema base Papirus no está instalado. Instalándolo ahora..."
        git clone --depth 1 https://github.com/PapirusDevelopment/papirus-icon-theme.git "$temp_dir/papirus"
        "$temp_dir/papirus/install.sh"
    else
        log_info "El tema base Papirus ya está instalado."
    fi
}

# Instala el tema 'Tela-nord-dark', que se usa como predeterminado en la configuración de Hyprland.
set_default_icon_theme() {
    local theme_name="Tela-nord-dark"
    local temp_dir_param="${1:-}"
    log_step "Gestionando el tema de iconos por defecto '$theme_name'"

    if [[ -d "$ICON_DIR_USER/$theme_name" ]]; then
        log_info "El tema '$theme_name' ya está instalado."
    else
        log_info "Instalando el tema '$theme_name'..."
        local temp_dir="${temp_dir_param}"
        [[ -z "$temp_dir" ]] && temp_dir=$(mktemp -d)

        git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme.git "$temp_dir/tela"
        "$temp_dir/tela/install.sh" -c nord

        [[ -z "$temp_dir_param" ]] && rm -rf "$temp_dir"
    fi
    apply_theme "$theme_name"
}

# Instala la versión estándar del tema Papirus.
install_papirus_standard() {
    local theme_name="Papirus-Dark"
    local temp_dir="$1"
    log_step "Gestionando Papirus Icons (Estándar)"
    ensure_papirus_installed "$temp_dir"
    if command_exists papirus-folders; then
        papirus-folders --default --theme "$theme_name"
    fi
    apply_theme "$theme_name"
}

# Instala el tema Candy.
install_candy() {
    local theme_name="Candy"
    local temp_dir="$1"
    log_step "Gestionando Candy Icons"
    if [[ -d "$ICON_DIR_USER/$theme_name" ]]; then
        log_info "El tema ya está instalado."
    else
        log_info "Instalando el tema..."
        git clone --depth 1 https://github.com/EliverLara/candy-icons.git "$temp_dir/candy"
        "$temp_dir/candy/install.sh"
    fi
    apply_theme "$theme_name"
}

# Instala el tema Papirus con colores de la paleta Catppuccin.
install_papirus_catppuccin() {
    local theme_name="Papirus-Dark"
    local catppuccin_flavor="mocha"
    local temp_dir="$1"

    log_step "Gestionando Papirus Icons con colores Catppuccin ($catppuccin_flavor)"
    
    ensure_papirus_installed "$temp_dir"

    log_info "Descargando y aplicando el colorizador Catppuccin..."
    git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$temp_dir/papirus-folders-catppuccin"
    chmod +x "$temp_dir/papirus-folders-catppuccin/papirus-folders"
    
    # Ejecuta el script para cambiar el color de las carpetas.
    "$temp_dir/papirus-folders-catppuccin/papirus-folders" -C "catppuccin-${catppuccin_flavor}" --theme "$theme_name"

    apply_theme "$theme_name"
}

# --- Función Principal (Menú) ---
run_module_main() {
    log_step "Gestor de Temas de Iconos para Hyprland"

    if ! check_deps; then
        return 1
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'rm -rf -- "$temp_dir"' EXIT

    while true; do
        clear
        echo -e "${CYAN}==========================================${NC}"
        echo -e "  ${BOLD}Gestor de Temas de Iconos para Hyprland${NC} "
        echo -e "${CYAN}==========================================${NC}"
        echo "Selecciona el tema que quieres instalar/activar:"
        echo
        echo -e "  ${GREEN}1)${NC} Tela (variante Nord)"
        echo -e "  ${GREEN}2)${NC} Papirus (estándar, oscuro)"
        echo -e "  ${GREEN}3)${NC} Papirus (con colores Catppuccin Mocha)"
        echo -e "  ${GREEN}4)${NC} Candy Icons"
        echo
        echo -e "  ${YELLOW}q)${NC} Volver al menú principal"
        echo
        read -p "Tu elección: " choice

        rm -rf -- "$temp_dir"/*

        case $choice in
            1) set_default_icon_theme "$temp_dir" ;;
            2) install_papirus_standard "$temp_dir" ;;
            3) install_papirus_catppuccin "$temp_dir" ;;
            4) install_candy "$temp_dir" ;;
            [qQ])
                log_info "Volviendo al menú principal."
                break
                ;;
            *) log_error "Opción no válida. Inténtalo de nuevo." ;;
        esac
        if [[ ! "$choice" =~ [qQ] ]]; then
            echo
            read -p "Presiona Enter para continuar..."
        fi
    done
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
