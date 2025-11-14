#!/usr/bin/env bash
# ===============================================================
# zsh-config.sh - Configuración de Zsh y shell
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Usar REPO_BASE si está definido, sino usar el valor por defecto
REPO_BASE="${REPO_BASE:-https://raw.githubusercontent.com/marcogll/omarchy_setup/main}"

configure_bashrc_to_launch_zsh() {
    local bashrc_file="$HOME/.bashrc"
    local block_marker="# OMARCHY: AUTO-LAUNCH ZSH"

    if [[ -f "$bashrc_file" ]] && grep -qF "$block_marker" "$bashrc_file"; then
        log_success ".bashrc ya está configurado para lanzar Zsh."
        return 0
    fi

    log_info "Configurando .bashrc para lanzar Zsh automáticamente..."

    # Crear copia de seguridad
    if [[ -f "$bashrc_file" ]]; then
        cp "$bashrc_file" "${bashrc_file}.bak_$(date +%F_%T)"
        log_info "Copia de seguridad de .bashrc creada en ${bashrc_file}.bak_..."
    fi

    # Añadir el bloque de código a .bashrc
    cat >> "$bashrc_file" << 'EOF'

# OMARCHY: AUTO-LAUNCH ZSH
# Lanzar Zsh automáticamente si no estamos ya en Zsh
if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh &>/dev/null; then
    # Inicializar Homebrew si existe antes de cambiar de shell
    if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    exec zsh
fi
EOF
    log_success ".bashrc modificado para iniciar Zsh."
}

install_zsh() {
    log_step "Configuración de Zsh"
    
    # Instalar Zsh y plugins
    log_info "Instalando Zsh y complementos..."
    # El spinner se inicia desde el script principal, aquí solo ejecutamos el comando
    sudo pacman -S --noconfirm --needed \
        zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions || {
        log_error "Error al instalar Zsh"
        return 1
    }
    
    # No es necesario un spinner aquí, es muy rápido
    # Descargar configuración personalizada
    log_info "Descargando configuración de Zsh desde GitHub..."
    if curl -fsSL "${REPO_BASE}/.zshrc" -o ~/.zshrc; then
        # Añadir configuración de Homebrew si está instalado
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            log_info "Añadiendo configuración de Homebrew a .zshrc..."
            echo '' >> ~/.zshrc
            echo '# Homebrew' >> ~/.zshrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        fi
        log_success "Configuración de Zsh descargada"
    else
        log_warning "No se pudo descargar .zshrc desde GitHub"
        log_info "Creando configuración básica de Zsh..."
        cat > ~/.zshrc << 'EOF'
# Zsh básico
autoload -U compinit
compinit

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Aliases útiles
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
EOF
    fi
    
    # Modificar .bashrc para que lance zsh
    configure_bashrc_to_launch_zsh

    log_success "Configuración de Zsh completada"
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zsh "$@"
fi
