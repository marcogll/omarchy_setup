#!/usr/bin/env bash
#
# Módulo para configurar Zsh, Oh My Zsh, Oh My Posh y dependencias.
#

# Asegurarse de que las funciones comunes están cargadas
SCRIPT_DIR_MODULE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_ROOT="$(cd "${SCRIPT_DIR_MODULE}/.." && pwd)"
if [[ -f "${SCRIPT_DIR_MODULE}/common.sh" ]]; then
    source "${SCRIPT_DIR_MODULE}/common.sh"
else
    echo "Error: common.sh no encontrado."
    exit 1
fi

# Opciones comunes para curl con timeout moderado y reintentos breves.
ZSH_CURL_TIMEOUT_OPTS=(--fail --location --silent --show-error --connect-timeout 10 --max-time 60 --retry 2 --retry-delay 2)

zsh_download_with_timeout() {
    local url="$1"
    local dest="$2"
    if curl "${ZSH_CURL_TIMEOUT_OPTS[@]}" -o "$dest" "$url"; then
        return 0
    fi
    return 1
}

install_zsh() {
    log_step "Configuración Completa de Zsh"

    local target_user="${SUDO_USER:-$USER}"
    local target_home="$HOME"
    if [[ -n "${SUDO_USER:-}" ]]; then
        target_home="$(getent passwd "$target_user" 2>/dev/null | cut -d: -f6)"
        if [[ -z "$target_home" ]]; then
            target_home="$(eval echo "~${target_user}")"
        fi
    fi
    target_home="${target_home:-$HOME}"

    # --- 1. Instalar paquetes necesarios desde Pacman ---
    log_info "Instalando Zsh y herramientas esenciales..."
    local pkgs=(
        git
        zsh
        zsh-completions
        zsh-syntax-highlighting
        zsh-autosuggestions
        zoxide              # Navegación inteligente
        fastfetch           # Información del sistema
        yt-dlp              # Descarga de videos/audio
        unrar p7zip lsof    # Dependencias para funciones en .zshrc
    )
    for pkg in "${pkgs[@]}"; do
        check_and_install_pkg "$pkg"
    done
    
    # Instalar Oh My Posh con fallback a AUR si es necesario
    if ! command_exists oh-my-posh; then
        log_info "Instalando Oh My Posh..."
        if command_exists pacman && sudo pacman -S --noconfirm --needed oh-my-posh 2>/dev/null; then
            log_success "Oh My Posh instalado desde pacman."
        else
            log_warning "Pacman no pudo instalar oh-my-posh. Intentando con un helper AUR..."
            if aur_install_packages "oh-my-posh-bin"; then
                log_success "Oh My Posh instalado usando helper AUR (${AUR_HELPER_CMD})."
            else
                log_warning "No se pudo instalar Oh My Posh mediante pacman ni AUR."
                log_info "Descargando instalador oficial de Oh My Posh..."
                local omp_installer
                omp_installer="$(mktemp)"
                if [[ -n "$omp_installer" ]] && zsh_download_with_timeout "https://ohmyposh.dev/install.sh" "$omp_installer"; then
                    if sudo bash "$omp_installer" -d /usr/local/bin; then
                        log_success "Oh My Posh instalado usando el script oficial."
                    else
                        log_error "Falló la instalación de Oh My Posh usando el script oficial."
                        rm -f "$omp_installer"
                        return 1
                    fi
                    rm -f "$omp_installer"
                else
                    rm -f "${omp_installer:-}"
                    log_error "No se pudo descargar el instalador oficial de Oh My Posh."
                    return 1
                fi
            fi
        fi
    else
        log_info "Oh My Posh ya está instalado."
    fi

    # --- 2. Instalar Oh My Zsh (si no existe) ---
    local target_ohmyzsh_dir="${target_home}/.oh-my-zsh"
    if [[ ! -d "$target_ohmyzsh_dir" ]]; then
        log_info "Instalando Oh My Zsh..."
        local omz_installer
        omz_installer="$(mktemp)"
        if [[ -z "$omz_installer" ]]; then
            log_error "No se pudo crear un archivo temporal para el instalador de Oh My Zsh."
            return 1
        fi
        if zsh_download_with_timeout "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "$omz_installer"; then
            # Usar RUNZSH=no para evitar que inicie un nuevo shell y CHSH=no para no cambiar el shell aún
            if ! env HOME="$target_home" RUNZSH=no CHSH=no sh "$omz_installer" --unattended --keep-zshrc; then
                rm -f "$omz_installer"
                log_error "Falló la instalación de Oh My Zsh."
                return 1
            fi
        else
            rm -f "$omz_installer"
            log_error "No se pudo descargar el instalador de Oh My Zsh."
            return 1
        fi
        rm -f "$omz_installer"
    else
        log_info "Oh My Zsh ya está instalado."
    fi
    
    # Asegurar plugins personalizados de Oh My Zsh (zsh-autosuggestions, zsh-syntax-highlighting)
    local zsh_custom="${target_ohmyzsh_dir}/custom"
    local zsh_custom_plugins="${zsh_custom}/plugins"
    mkdir -p "$zsh_custom_plugins"

    ensure_omz_plugin() {
        local name="$1"
        local repo="$2"
        local plugin_path="${zsh_custom_plugins}/${name}"

        if [[ -d "${plugin_path}/.git" ]]; then
            log_info "Actualizando plugin ${name}..."
            git -C "$plugin_path" pull --ff-only >/dev/null 2>&1 || true
        elif [[ -d "$plugin_path" ]]; then
            log_info "Plugin ${name} ya existe."
        else
            log_info "Clonando plugin ${name}..."
            if git clone --depth 1 "$repo" "$plugin_path" >/dev/null 2>&1; then
                log_success "Plugin ${name} instalado."
            else
                log_warning "No se pudo clonar ${name}. Se usará la versión de los paquetes del sistema."
            fi
        fi
    }

    ensure_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    ensure_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    # --- 3. Enlazar configuración .zshrc ---
    log_info "Configurando .zshrc..."
    local repo_zshrc_path="${DOTFILES_DIR}/zsh/.zshrc"
    local repo_help_path="${DOTFILES_DIR}/zsh/.zshrc.help"
    local repo_funcs_path="${DOTFILES_DIR}/zsh/.zsh_functions"
    
    if [[ ! -f "$repo_zshrc_path" ]]; then
        log_error "No se encontró .zshrc en '${repo_zshrc_path}'."
        return 1
    fi

    # Crear copia de seguridad antes de proceder
    backup_file "${target_home}/.zshrc" || return 1

    log_success "Enlazando .zshrc desde mg_dotfiles..."
    ln -sf "$repo_zshrc_path" "${target_home}/.zshrc"
    
    # Enlazar también el archivo de ayuda si existe
    if [[ -f "$repo_help_path" ]]; then
        ln -sf "$repo_help_path" "${target_home}/.zshrc.help"
    fi

    # Enlazar funciones si el directorio existe
    if [[ -d "$repo_funcs_path" ]]; then
        mkdir -p "${target_home}/.zsh_functions"
        for func_file in "$repo_funcs_path"/*.zsh; do
            if [[ -f "$func_file" ]]; then
                ln -sf "$func_file" "${target_home}/.zsh_functions/$(basename "$func_file")"
            fi
        done
        log_success "Funciones de Zsh enlazadas."
    fi

    # --- 4. Descargar el tema de Oh My Posh ---
    log_info "Configurando tema de Oh My Posh (Catppuccin Frappe)..."
    local posh_themes_dir="${target_home}/.poshthemes"
    local theme_file="$posh_themes_dir/catppuccin_frappe.omp.json"
    local posh_theme_local="${SCRIPT_DIR_ROOT}/themes/catppuccin_frappe.omp.json"
    mkdir -p "$posh_themes_dir"
    
    if zsh_download_with_timeout "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json" "$theme_file"; then
        chmod 644 "$theme_file" 2>/dev/null || true
        log_success "Tema Catppuccin Frappe descargado en $theme_file"
    else
        rm -f "$theme_file"
        if [[ -f "$posh_theme_local" ]]; then
            if cp "$posh_theme_local" "$theme_file"; then
                chmod 644 "$theme_file" 2>/dev/null || true
                log_warning "No se pudo descargar el tema remoto. Se utilizó la copia incluida en el repositorio."
            else
                log_error "No se pudo copiar la versión local del tema Catppuccin."
            fi
        else
            log_error "No se pudo descargar el tema de Oh My Posh y no hay copia local disponible."
            # No retornamos error, el .zshrc tiene un fallback
        fi
    fi

    if command_exists oh-my-posh; then
        local omp_completion_dir="${target_home}/.local/share/zsh/site-functions"
        mkdir -p "$omp_completion_dir"
        if oh-my-posh completion zsh > "${omp_completion_dir}/_oh-my-posh" 2>/dev/null; then
            log_success "Autocompletado de Oh My Posh actualizado."
        fi
    fi

    # --- 5. Cambiar el shell por defecto a Zsh para el usuario actual ---
    local current_shell
    current_shell="$(getent passwd "$target_user" 2>/dev/null | cut -d: -f7)"
    current_shell="${current_shell:-$SHELL}"
    if [[ "$(basename "$current_shell")" != "zsh" ]]; then
        log_info "Cambiando el shell por defecto a Zsh..."
        local zsh_path
        zsh_path="$(command -v zsh)"
        if [[ -z "$zsh_path" ]]; then
            log_error "No se encontró la ruta de Zsh. Aborta el cambio de shell."
        elif sudo -n chsh -s "$zsh_path" "$target_user"; then
            log_success "Shell cambiado a Zsh. El cambio será efectivo en el próximo inicio de sesión."
        else
            log_error "No se pudo cambiar el shell automáticamente. Ejecuta 'sudo chsh -s \"$zsh_path\" $target_user' manualmente."
        fi
    else
        log_info "Zsh ya es el shell por defecto."
    fi

    # --- 6. Configurar .bashrc para lanzar Zsh (para sesiones no interactivas) ---
    local bashrc_zsh_loader='
# Launch Zsh
if [ -t 1 ]; then
  exec zsh
fi'
    if [[ -f "${target_home}/.bashrc" ]] && ! grep -q "exec zsh" "${target_home}/.bashrc"; then
        log_info "Configurando .bashrc para iniciar Zsh automáticamente..."
        echo "$bashrc_zsh_loader" >> "${target_home}/.bashrc"
    else
        log_info ".bashrc ya está configurado para lanzar Zsh."
    fi

    # --- 7. Mensaje final ---
    echo ""
    log_warning "¡IMPORTANTE! Para que los iconos se vean bien, debes configurar tu terminal:"
    log_info "1. Abre las Preferencias de tu terminal."
    log_info "2. Ve a la sección de Perfil -> Apariencia/Texto."
    log_info "3. Cambia la fuente a una 'Nerd Font' (ej: FiraCode Nerd Font, MesloLGS NF)."
    log_info "4. Cierra y vuelve a abrir la terminal para ver todos los cambios."
    log_warning "Recuerda instalar manualmente una Nerd Font; el script no instala fuentes."

    return 0
}
