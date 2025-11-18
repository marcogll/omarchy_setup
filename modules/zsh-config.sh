#!/usr/bin/env bash
# ===============================================================
# zsh-config.sh - Configuración completa de Zsh
# ===============================================================
#
# Este módulo se encarga de transformar la experiencia de la terminal
# mediante la instalación y configuración de Zsh, Oh My Zsh y Oh My Posh.
#
# Funciones principales:
#   - Instala Zsh y un conjunto de herramientas de terminal útiles.
#   - Instala y configura Oh My Posh, incluyendo un tema personalizado.
#   - Instala Oh My Zsh y gestiona sus plugins.
#   - Descarga y aplica un fichero .zshrc preconfigurado.
#   - Cambia el shell por defecto del usuario a Zsh.
#
# ===============================================================

SCRIPT_DIR_MODULE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_ROOT="$(cd "${SCRIPT_DIR_MODULE}/.." && pwd)"
if [[ -f "${SCRIPT_DIR_MODULE}/common.sh" ]]; then
    source "${SCRIPT_DIR_MODULE}/common.sh"
else
    echo "Error: common.sh no encontrado."
    exit 1
fi

# Opciones para `curl` que añaden timeouts y reintentos para robustez.
ZSH_CURL_TIMEOUT_OPTS=(--fail --location --silent --show-error --connect-timeout 10 --max-time 60 --retry 2 --retry-delay 2)

# ---------------------------------------------------------------
# zsh_download_with_timeout(url, destination)
# ---------------------------------------------------------------
# Descarga un fichero desde una URL a un destino local usando `curl`
# con las opciones de timeout y reintentos definidas globalmente.
#
# Parámetros:
#   $1 - URL del fichero a descargar.
#   $2 - Ruta de destino donde se guardará el fichero.
# ---------------------------------------------------------------
zsh_download_with_timeout() {
    local url="$1"
    local dest="$2"
    if curl "${ZSH_CURL_TIMEOUT_OPTS[@]}" -o "$dest" "$url"; then
        return 0
    fi
    return 1
}

# ---------------------------------------------------------------
# install_zsh()
# ---------------------------------------------------------------
# Función principal que orquesta toda la configuración de Zsh.
# ---------------------------------------------------------------
install_zsh() {
    log_step "Configuración Completa de Zsh"

    # Determina el usuario y el directorio home de destino, manejando el caso de `sudo`.
    local target_user="${SUDO_USER:-$USER}"
    local target_home
    if [[ -n "${SUDO_USER:-}" ]]; then
        target_home="$(getent passwd "$target_user" 2>/dev/null | cut -d: -f6)"
    fi
    target_home="${target_home:-$HOME}"

    # --- 1. Instalación de Paquetes ---
    log_info "Instalando Zsh y herramientas de terminal..."
    # Paquetes:
    #   - zsh y plugins: El shell y sus complementos básicos.
    #   - zoxide, fastfetch, yt-dlp: Herramientas que mejoran la productividad
    #     y están integradas en el .zshrc personalizado.
    local pkgs=(
        git zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
        zoxide fastfetch yt-dlp unrar p7zip lsof
    )
    if ! sudo pacman -S --noconfirm --needed "${pkgs[@]}"; then
        log_warning "Algunos paquetes de Zsh no pudieron instalarse."
    fi
    
    # Instala Oh My Posh, con fallback a AUR y luego al script oficial si es necesario.
    if ! command_exists oh-my-posh; then
        log_info "Instalando Oh My Posh..."
        if sudo pacman -S --noconfirm --needed oh-my-posh 2>/dev/null; then
            log_success "Oh My Posh instalado desde los repositorios oficiales."
        elif aur_install_packages "oh-my-posh-bin"; then
            log_success "Oh My Posh instalado desde AUR."
        else
            log_warning "No se pudo instalar Oh My Posh desde pacman ni AUR. Intentando con el script oficial..."
            local omp_installer; omp_installer="$(mktemp)"
            if zsh_download_with_timeout "https://ohmyposh.dev/install.sh" "$omp_installer"; then
                if sudo bash "$omp_installer" -d /usr/local/bin; then
                    log_success "Oh My Posh instalado con el script oficial."
                else
                    log_error "Falló la instalación de Oh My Posh con el script oficial."; rm -f "$omp_installer"; return 1
                fi; rm -f "$omp_installer"
            else
                log_error "No se pudo descargar el instalador de Oh My Posh."; rm -f "${omp_installer:-}"; return 1
            fi
        fi
    else
        log_info "Oh My Posh ya está instalado."
    fi

    # --- 2. Instalación de Oh My Zsh ---
    local target_ohmyzsh_dir="${target_home}/.oh-my-zsh"
    if [[ ! -d "$target_ohmyzsh_dir" ]]; then
        log_info "Instalando Oh My Zsh..."
        local omz_installer; omz_installer="$(mktemp)"
        if zsh_download_with_timeout "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "$omz_installer"; then
            # Se ejecuta de forma no interactiva, sin cambiar el shell aún.
            if ! env HOME="$target_home" RUNZSH=no CHSH=no sh "$omz_installer" --unattended --keep-zshrc; then
                log_error "Falló la instalación de Oh My Zsh."; rm -f "$omz_installer"; return 1
            fi; rm -f "$omz_installer"
        else
            log_error "No se pudo descargar el instalador de Oh My Zsh."; rm -f "${omz_installer:-}"; return 1
        fi
    else
        log_info "Oh My Zsh ya está instalado."
    fi
    
    # --- 3. Gestión de Plugins de Oh My Zsh ---
    # Asegura que los plugins de autocompletado y resaltado de sintaxis estén clonados.
    ensure_omz_plugin() {
        local name="$1" repo="$2"
        local plugin_path="${target_home}/.oh-my-zsh/custom/plugins/${name}"
        if [[ -d "${plugin_path}/.git" ]]; then
            log_info "Actualizando el plugin de Oh My Zsh: ${name}..."
            git -C "$plugin_path" pull --ff-only >/dev/null 2>&1 || true
        elif [[ ! -d "$plugin_path" ]]; then
            log_info "Clonando el plugin de Oh My Zsh: ${name}..."
            git clone --depth 1 "$repo" "$plugin_path" >/dev/null 2>&1
        fi
    }
    ensure_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    ensure_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    # --- 4. Configuración del .zshrc ---
    log_info "Configurando el fichero .zshrc..."
    local tmp_download="${target_home}/.zshrc.omarchy-tmp"
    local source_file=""
    # Intenta descargar el .zshrc desde el repositorio remoto.
    if zsh_download_with_timeout "${REPO_BASE}/.zshrc" "$tmp_download"; then
        source_file="$tmp_download"
    # Si falla, usa la copia local que viene con el script.
    elif [[ -f "${SCRIPT_DIR_ROOT}/.zshrc" ]]; then
        log_warning "No se pudo descargar .zshrc. Se usará la copia local."
        source_file="${SCRIPT_DIR_ROOT}/.zshrc"
    else
        log_error "No se pudo obtener el fichero .zshrc."; return 1
    fi
    # Crea una copia de seguridad y reemplaza el .zshrc existente.
    backup_file "${target_home}/.zshrc" || { rm -f "$tmp_download"; return 1; }
    if ! cp "$source_file" "${target_home}/.zshrc"; then
        log_error "No se pudo actualizar el fichero .zshrc."; rm -f "$tmp_download"; return 1
    fi
    rm -f "$tmp_download"
    log_success ".zshrc actualizado correctamente."

    # --- 5. Configuración del Tema de Oh My Posh ---
    log_info "Configurando el tema de Oh My Posh (Catppuccin Frappe)..."
    local posh_themes_dir="${target_home}/.poshthemes"
    local theme_file="$posh_themes_dir/catppuccin_frappe.omp.json"
    mkdir -p "$posh_themes_dir"
    # Descarga el tema y, si falla, usa la copia local.
    if ! zsh_download_with_timeout "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json" "$theme_file"; then
        if [[ -f "${SCRIPT_DIR_ROOT}/themes/catppuccin_frappe.omp.json" ]]; then
            cp "${SCRIPT_DIR_ROOT}/themes/catppuccin_frappe.omp.json" "$theme_file"
            log_warning "No se pudo descargar el tema. Se usó la copia local."
        else
            log_error "No se pudo obtener el tema de Oh My Posh."
        fi
    fi
    # Genera el fichero de autocompletado para Zsh.
    if command_exists oh-my-posh; then
        local omp_completion_dir="${target_home}/.local/share/zsh/site-functions"
        mkdir -p "$omp_completion_dir"
        oh-my-posh completion zsh > "${omp_completion_dir}/_oh-my-posh" 2>/dev/null || true
    fi
    log_success "Tema de Oh My Posh configurado."

    # --- 6. Cambio de Shell por Defecto ---
    local current_shell; current_shell="$(getent passwd "$target_user" 2>/dev/null | cut -d: -f7)"
    if [[ "$(basename "$current_shell")" != "zsh" ]]; then
        log_info "Cambiando el shell por defecto a Zsh para el usuario '$target_user'..."
        if ! sudo chsh -s "$(command -v zsh)" "$target_user"; then
            log_error "No se pudo cambiar el shell automáticamente."
        else
            log_success "Shell cambiado a Zsh. El cambio será efectivo en el próximo inicio de sesión."
        fi
    fi

    # --- 7. Configuración de .bashrc ---
    # Añade una línea a .bashrc para que las terminales que se abran con Bash
    # ejecuten Zsh automáticamente.
    local bashrc_zsh_loader='if [ -t 1 ]; then exec zsh; fi'
    if [[ -f "${target_home}/.bashrc" ]] && ! grep -q "exec zsh" "${target_home}/.bashrc"; then
        echo -e "\n# Iniciar Zsh automáticamente\n$bashrc_zsh_loader" >> "${target_home}/.bashrc"
    fi

    # --- 8. Mensaje Final ---
    echo ""
    log_warning "¡ACCIÓN REQUERIDA! Para que los iconos del prompt se vean bien:"
    log_info "1. Instala una 'Nerd Font'. La recomendada es Meslo."
    log_info "   Puedes hacerlo con el comando: oh-my-posh font install meslo"
    log_info "2. Configura tu aplicación de terminal para que use la fuente 'MesloLGS NF'."
    log_info "3. Cierra y vuelve a abrir la terminal para aplicar todos los cambios."

    return 0
}
