#!/bin/bash
#
# icon_manager.sh (v2)
#
# Un script de gestión para instalar y cambiar entre diferentes temas de iconos
# en un entorno Hyprland/Omarchy. Incluye temas base y personalizaciones.
#

# --- Variables Globales ---
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"
TEMP_DIR="/tmp/icon_theme_setup"
ICON_DIR_USER="$HOME/.local/share/icons"

# --- Funciones de Utilidad ---

# Función para verificar dependencias
check_deps() {
    if ! command -v git &> /dev/null; then
        echo "Error: git no está instalado. Por favor, instálalo para continuar (ej. sudo pacman -S git)."
        exit 1
    fi
}

# Función para aplicar la configuración de forma persistente
# Argumento 1: Nombre del tema de iconos (ej. 'Tela-nord-dark')
apply_theme() {
    local theme_name="$1"
    echo "Aplicando el tema de iconos '$theme_name'..."

    mkdir -p "$(dirname "$AUTOSTART_FILE")"
    touch "$AUTOSTART_FILE"

    # Eliminar cualquier configuración de icon-theme anterior para evitar conflictos
    sed -i '/exec-once = gsettings set org.gnome.desktop.interface icon-theme/d' "$AUTOSTART_FILE"

    # Añadir el bloque de configuración si no existe
    if ! grep -Fq "CONFIGURACIÓN DE TEMA DE ICONOS" "$AUTOSTART_FILE"; then
        echo -e "\n# -----------------------------------------------------" >> "$AUTOSTART_FILE"
        echo "# CONFIGURACIÓN DE TEMA DE ICONOS" >> "$AUTOSTART_FILE"
        echo "# -----------------------------------------------------" >> "$AUTOSTART_FILE"
        echo "exec-once = /usr/lib/xdg-desktop-portal-gtk" >> "$AUTOSTART_FILE"
        echo "exec-once = sleep 1" >> "$AUTOSTART_FILE"
    fi
    
    # Añadir el comando gsettings para el tema seleccionado
    echo "exec-once = gsettings set org.gnome.desktop.interface icon-theme '$theme_name'" >> "$AUTOSTART_FILE"

    echo "¡Tema configurado! La configuración se ha guardado en $AUTOSTART_FILE"
}

# --- Funciones de Instalación de Temas ---

# Función auxiliar para asegurar que el tema base Papirus esté instalado
ensure_papirus_installed() {
    if [ ! -d "$ICON_DIR_USER/Papirus-Dark" ]; then
        echo "El tema base Papirus no está instalado. Instalándolo ahora..."
        git clone --depth 1 https://github.com/PapirusDevelopment/papirus-icon-theme.git "$TEMP_DIR/papirus"
        "$TEMP_DIR/papirus/install.sh"
    else
        echo "El tema base Papirus ya está instalado."
    fi
}

install_tela_nord() {
    local theme_name="Tela-nord-dark"
    echo "--- Gestionando Tela Nord Icons ---"
    if [ -d "$ICON_DIR_USER/$theme_name" ]; then
        echo "El tema ya está instalado."
    else
        echo "Instalando el tema..."
        git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme.git "$TEMP_DIR/tela"
        "$TEMP_DIR/tela/install.sh" -c nord
    fi
    apply_theme "$theme_name"
}

install_papirus() {
    local theme_name="Papirus-Dark"
    echo "--- Gestionando Papirus Icons (Estándar) ---"
    ensure_papirus_installed
    # Si el usuario quiere el Papirus estándar, restauramos los colores por si acaso
    if [ -f "$ICON_DIR_USER/papirus-folders" ]; then
        "$ICON_DIR_USER/papirus-folders" --default --theme "$theme_name"
    fi
    apply_theme "$theme_name"
}

install_candy() {
    local theme_name="Candy"
    echo "--- Gestionando Candy Icons ---"
    if [ -d "$ICON_DIR_USER/$theme_name" ]; then
        echo "El tema ya está instalado."
    else
        echo "Instalando el tema..."
        git clone --depth 1 https://github.com/EliverLara/candy-icons.git "$TEMP_DIR/candy"
        "$TEMP_DIR/candy/install.sh"
    fi
    apply_theme "$theme_name"
}

install_papirus_catppuccin() {
    local theme_name="Papirus-Dark"
    # Catppuccin tiene 4 variantes: latte, frappe, macchiato, mocha. Usaremos Mocha.
    local catppuccin_flavor="mocha"

    echo "--- Gestionando Papirus Icons con colores Catppuccin ($catppuccin_flavor) ---"
    
    # 1. Asegurarse de que el tema base Papirus exista
    ensure_papirus_installed

    # 2. Descargar y ejecutar el script de personalización
    echo "Descargando y aplicando el colorizador Catppuccin..."
    git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$TEMP_DIR/papirus-folders-catppuccin"
    chmod +x "$TEMP_DIR/papirus-folders-catppuccin/papirus-folders"
    
    # Ejecutar el script para cambiar el color de las carpetas
    "$TEMP_DIR/papirus-folders-catppuccin/papirus-folders" -C "catppuccin-${catppuccin_flavor}" --theme "$theme_name"

    # 3. Aplicar el tema (el nombre sigue siendo Papirus-Dark, pero los iconos han cambiado)
    apply_theme "$theme_name"
}

# --- Función Principal (Menú) ---
main_menu() {
    while true; do
        clear
        echo "=========================================="
        echo "  Gestor de Temas de Iconos para Hyprland "
        echo "=========================================="
        echo "Selecciona el tema que quieres instalar/activar:"
        echo
        echo "  1) Tela (variante Nord)"
        echo "  2) Papirus (estándar, oscuro)"
        echo "  3) Papirus (con colores Catppuccin Mocha)"
        echo "  4) Candy Icons"
        echo
        echo "  q) Salir"
        echo
        read -p "Tu elección: " choice

        # Limpiar directorio temporal antes de cada operación
        rm -rf "$TEMP_DIR"
        mkdir -p "$TEMP_DIR"

        case $choice in
            1) install_tela_nord ;;
            2) install_papirus ;;
            3) install_papirus_catppuccin ;;
            4) install_candy ;;
            [qQ]) break ;;
            *) echo "Opción no válida. Inténtalo de nuevo." ;;
        esac

        echo
        read -p "Presiona Enter para continuar..."
    done
}


# --- Ejecución del Script ---

check_deps
main_menu

# Limpieza final
rm -rf "$TEMP_DIR"
clear
echo "¡Proceso finalizado! Cierra sesión y vuelve a iniciarla para ver los cambios."
exit 0ch