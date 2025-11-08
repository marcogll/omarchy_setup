#!/usr/bin/env bash
# ===============================================================
# zsh-config.sh - Configuración de Zsh y shell
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Usar REPO_BASE si está definido, sino usar el valor por defecto
REPO_BASE="${REPO_BASE:-https://raw.githubusercontent.com/marcogll/omarchy_setup/main}"

install_zsh() {
    log_step "Configuración de Zsh"
    
    # Instalar Zsh y plugins
    log_info "Instalando Zsh y complementos..."
    sudo pacman -S --noconfirm --needed \
        zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions || {
        log_error "Error al instalar Zsh"
        return 1
    }
    
    # Descargar configuración personalizada
    log_info "Descargando configuración de Zsh desde GitHub..."
    if curl -fsSL "${REPO_BASE}/.zshrc" -o ~/.zshrc; then
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
    
    # Configurar Zsh como shell predeterminada
    if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
        log_info "Configurando Zsh como shell predeterminada..."
        if chsh -s /bin/zsh 2>/dev/null || chsh -s /usr/bin/zsh 2>/dev/null; then
            log_success "Zsh configurado como shell predeterminada"
            log_warning "Los cambios surtirán efecto en la próxima sesión"
        else
            log_warning "No se pudo cambiar la shell. Ejecuta manualmente: chsh -s /bin/zsh"
        fi
    else
        log_success "Zsh ya es la shell predeterminada"
    fi
    
    log_success "Configuración de Zsh completada"
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zsh "$@"
fi
