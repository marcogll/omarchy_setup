# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
source ~/.local/share/omarchy/default/bash/rc

# =============================================================================
# --- AGENTE SSH PERSISTENTE (INICIO AUTOMÁTICO) ---
# Se inicia si GNOME Keyring NO configuró el agente ($SSH_AUTH_SOCK está vacío).
# =============================================================================
if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AGENT_DIR="$HOME/.ssh/agent"
    mkdir -p "$SSH_AGENT_DIR" 2>/dev/null
    SSH_ENV="$SSH_AGENT_DIR/env"
    
    start_agent() {
        echo "🔑 Iniciando ssh-agent persistente..."
        ssh-agent > "$SSH_ENV"
        chmod 600 "$SSH_ENV"
        . "$SSH_ENV" > /dev/null
    }
    
    if [ -f "$SSH_ENV" ]; then
        . "$SSH_ENV" > /dev/null
        ps -p $SSH_AGENT_PID > /dev/null 2>&1 || start_agent
    else
        start_agent
    fi
    
    # Bucle para añadir claves automáticamente.
    if [ -d "$HOME/.ssh" ]; then
        for key in "$HOME/.ssh"/*; do
            if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]] && \
               [[ ! "$key" =~ known_hosts ]] && [[ ! "$key" =~ authorized_keys ]] && \
               [[ ! "$key" =~ config ]] && [[ ! "$key" =~ agent ]]; then
                
                if ssh-keygen -l -f "$key" &>/dev/null; then
                    local key_fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
                    
                    if ! ssh-add -l 2>/dev/null | grep -q "$key_fingerprint"; then
                        if ssh-add "$key" 2>/dev/null; then
                            echo "✅ Clave SSH agregada: $(basename $key)"
                        fi
                    fi
                fi
            fi
        done
    fi
fi
# =============================================================================


# OMARCHY: AUTO-LAUNCH ZSH
# Lanzar Zsh automáticamente si no estamos ya en Zsh
if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh &>/dev/null; then
    # Inicializar Homebrew si existe antes de cambiar de shell
    if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    exec zsh
fi

. "$HOME/.local/share/../bin/env"
