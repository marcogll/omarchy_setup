#!/usr/bin/env bash
#
# Módulo para configurar Zsh, Oh My Zsh, Oh My Posh y dependencias.
#

# Asegurarse de que las funciones comunes están cargadas
SCRIPT_DIR_MODULE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR_MODULE}/common.sh" ]]; then
    source "${SCRIPT_DIR_MODULE}/common.sh"
else
    echo "Error: common.sh no encontrado."
    exit 1
fi

install_zsh() {
    log_step "Configuración Completa de Zsh"

    # --- 1. Instalar paquetes necesarios desde Pacman ---
    log_info "Instalando Zsh y herramientas esenciales..."
    local pkgs=(
        zsh 
        zsh-completions 
        zsh-syntax-highlighting 
        zsh-autosuggestions
        oh-my-posh          # Para el prompt
        zoxide              # Navegación inteligente
        fastfetch           # Información del sistema
        yt-dlp              # Descarga de videos/audio
        nerd-fonts          # Paquete de fuentes con iconos
        unrar p7zip lsof    # Dependencias para funciones en .zshrc
    )
    for pkg in "${pkgs[@]}"; do
        check_and_install_pkg "$pkg"
    done

    # --- 2. Instalar Oh My Zsh (si no existe) ---
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Instalando Oh My Zsh..."
        # Usar RUNZSH=no para evitar que inicie un nuevo shell y CHSH=no para no cambiar el shell aún
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
        if [[ $? -ne 0 ]]; then
            log_error "Falló la instalación de Oh My Zsh."
            return 1
        fi
    else
        log_info "Oh My Zsh ya está instalado."
    fi

    # --- 3. Descargar y configurar el .zshrc personalizado ---
    log_info "Descargando configuración .zshrc desde el repositorio..."
    # Crear copia de seguridad antes de sobrescribir
    backup_file "$HOME/.zshrc" || return 1

    if curl -fsSL "${REPO_BASE}/.zshrc" -o "$HOME/.zshrc.omarchy-tmp" && [[ -s "$HOME/.zshrc.omarchy-tmp" ]]; then
        mv "$HOME/.zshrc.omarchy-tmp" "$HOME/.zshrc"
        log_success "Archivo .zshrc actualizado."
    else
        log_error "No se pudo descargar el archivo .zshrc."
        return 1
    fi

    # --- 4. Descargar el tema de Oh My Posh ---
    log_info "Configurando tema de Oh My Posh (Catppuccin Frappe)..."
    local posh_themes_dir="$HOME/.poshthemes"
    local theme_file="$posh_themes_dir/catppuccin_frappe.omp.json"
    mkdir -p "$posh_themes_dir"
    
    if curl -fsSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json" -o "$theme_file"; then
        log_success "Tema Catppuccin Frappe descargado en $theme_file"
    else
        log_error "No se pudo descargar el tema de Oh My Posh."
        # No retornamos error, el .zshrc tiene un fallback
    fi

    # --- 5. Cambiar el shell por defecto a Zsh para el usuario actual ---
    if [[ "$(basename "$SHELL")" != "zsh" ]]; then
        log_info "Cambiando el shell por defecto a Zsh..."
        # chsh requiere la contraseña del usuario
        if chsh -s "$(which zsh)"; then
            log_success "Shell cambiado a Zsh. El cambio será efectivo en el próximo inicio de sesión."
        else
            log_error "No se pudo cambiar el shell. Por favor, ejecute 'chsh -s $(which zsh)' manualmente."
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
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "exec zsh" "$HOME/.bashrc"; then
        log_info "Configurando .bashrc para iniciar Zsh automáticamente..."
        echo "$bashrc_zsh_loader" >> "$HOME/.bashrc"
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

    return 0
}