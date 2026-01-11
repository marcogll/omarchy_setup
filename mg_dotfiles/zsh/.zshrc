# =============================================================================
#             CONFIGURACIÓN ZSH - Marco Gallegos v3.5 (CORREGIDO)
# =============================================================================

# --- PATH --------------------------------------------------------------------
typeset -U PATH path
path=(
  $HOME/.local/bin     # Scripts y binarios instalados por el usuario.
  $HOME/bin            # Directorio personal de binarios.
  $HOME/.npm-global/bin # Paquetes de Node.js instalados globalmente.
  $HOME/AppImages      # Aplicaciones en formato AppImage.
  $HOME/go/bin         # Binarios de Go.
  $path                # Rutas del sistema existentes.
)

# --- Oh My Zsh ---------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Oh My Posh gestiona el prompt.

# Lista de plugins de Oh My Zsh a cargar.
plugins=(
  git sudo history colorize
  docker docker-compose
  npm node python pip golang
  copypath copyfile
)

export ZSH_DISABLE_COMPFIX=true
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Carga Oh My Zsh.
[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Carga los plugins de resaltado de sintaxis y autosugerencias.
[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  [ -r "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  [ -r "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# --- Oh My Posh --------------------------------------------------------------
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f ~/.poshthemes/catppuccin_frappe.omp.json ]; then
    eval "$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin_frappe.omp.json)"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi

# --- Go ----------------------------------------------------------------------
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# --- NVM (Node Version Manager) - COMENTADO ----------------------------------
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- Python ------------------------------------------------------------------
alias pip='pip3'
alias python='python3'

venv() {
  case "$1" in
    create) python -m venv .venv && echo "✅ Entorno virtual creado en ./.venv" ;;
    on|activate)
      if [ -f ".venv/bin/activate" ]; then
        . .venv/bin/activate
        echo "🟢 Entorno virtual activado"
      else
        echo "❌ Entorno virtual no encontrado en ./.venv"
      fi
      ;;
    off|deactivate)
      if command -v deactivate &>/dev/null; then
        deactivate 2>/dev/null
        echo "🔴 Entorno virtual desactivado"
      else
        echo "🤷 No hay un entorno virtual activo para desactivar"
      fi
      ;;
    *) echo "Uso: venv [create|on|off|activate|deactivate]" ;;
  esac
}

# --- Aliases -----------------------------------------------------------------

# Generales
alias cls='clear'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Información del sistema
alias ff='fastfetch'
alias nf='fastfetch'

# Gestión de paquetes en Arch Linux
alias pacu='sudo pacman -Syu'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'
alias pacs='pacman -Ss'
alias yayu='yay -Syu' # Requiere yay
alias yayi='yay -S'   # Requiere yay

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gfa='git fetch --all'
alias gfr='git fetch origin'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'
gac(){ git add . && git commit -m "$1"; }

# Docker
docker compose version >/dev/null 2>&1 && alias dc='docker compose' || alias dc='docker-compose'
alias d='docker'
alias dps='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'

# NPM
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'

# Python
alias py='python'
alias pir='pip install -r requirements.txt'
alias pipi='pip install'
alias pipf='pip freeze > requirements.txt'

# ZeroTier
alias zt='sudo zerotier-cli'
alias ztstatus='sudo zerotier-cli listnetworks'
alias ztinfo='sudo zerotier-cli info'

# Utilidades
alias clima='curl wttr.in/Saltillo'

# --- IA y ChatGPT (COMENTADO) ------------------------------------------------
# alias chat='chatgpt-cli'
# alias chat-q='chatgpt-cli -q'
# alias chat-c='chatgpt-cli --continue'
# alias chat-code='chatgpt-cli --code'

# --- Funciones ---------------------------------------------------------------

# Lanza la aplicación Antigravity o abre su directorio.
antigravity() {
  local app_path="$HOME/.antigravity/antigravity"
  local app_dir="$HOME/.antigravity"

  if [ "$1" = "." ]; then
    echo "🚀 Iniciando Antigravity en el directorio actual..."
    "$app_path" . --password-store="gnome-libsecret" >/dev/null 2>&1 &
  else
    echo "🚀 Iniciando Antigravity..."
    "$app_path" --password-store="gnome-libsecret" >/dev/null 2>&1 &
  fi
}


# Crea un directorio y se mueve a él.
mkcd(){ mkdir -p "$1" && cd "$1"; }

# Extrae cualquier tipo de archivo comprimido.
extract(){
  [ ! -f "$1" ] && echo "No es un archivo" && return 1
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar e "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "No se puede extraer '$1': formato no reconocido." ;;
  esac
}

# Mata el proceso que esté usando un puerto específico.
killport(){
  [ $# -eq 0 ] && echo "Uso: killport <puerto>" && return 1
  local pid=$(lsof -ti:"$1" 2>/dev/null)
  [ -n "$pid" ] && kill -9 "$pid" && echo "✅ Proceso en puerto $1 eliminado (PID: $pid)" || echo "🤷 No se encontró ningún proceso en el puerto $1"
}

# Inicia un servidor HTTP simple en el directorio actual.
serve(){ python -m http.server "${1:-8000}"; }

# Carga el archivo de ayuda si existe
[ -f ~/.zshrc.help ] && source ~/.zshrc.help


# --- yt-dlp (Descargador de vídeos) ------------------------------------------
export YTDLP_DIR="$HOME/Videos/YouTube"
mkdir -p "$YTDLP_DIR"/{Music,Videos} 2>/dev/null

ytm() {
  case "$1" in
    -h|--help|'')
      echo "🎵 ytm <URL|búsqueda> - Descarga audio (MP3 320kbps) a $YTDLP_DIR/Music/"
      echo "Ejemplos:"
      echo "  ytm https://youtu.be/dQw4w9WgXcQ"
      echo "  ytm 'Never Gonna Give You Up'"
      return 0
      ;;
  esac

  if ! command -v yt-dlp &>/dev/null; then
    echo "❌ yt-dlp no está instalado. Por favor, instálalo para usar esta función."
    return 1
  fi
  
  local out="$YTDLP_DIR/Music/%(title).180s.%(ext)s"
  local opts=(
    --extract-audio --audio-format mp3 --audio-quality 320K
    --embed-metadata --embed-thumbnail --convert-thumbnails jpg
    --no-playlist --retries 10 --fragment-retries 10
    --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
    --extractor-args "youtube:player_client=android,web"
    --progress --newline -o "$out"
  )
  
  if [[ "$1" == http* ]]; then
    echo "📥 Descargando audio..."
    yt-dlp "${opts[@]}" "$@"
  else
    echo "🔍 Buscando: $*"
    yt-dlp "${opts[@]}" "ytsearch1:$*"
  fi
  
  [ $? -eq 0 ] && echo "✅ Audio descargado en: $YTDLP_DIR/Music/" || echo "❌ Falló la descarga de audio."
}

ytv() {
  case "$1" in
    -h|--help|'')
      echo "🎬 ytv <URL|búsqueda> [calidad] - Descarga video a $YTDLP_DIR/Videos/"
      echo "Calidades disponibles: 1080, 720, 480 (por defecto: mejor disponible MP4)"
      echo "Ejemplos:"
      echo "  ytv https://youtu.be/dQw4w9WgXcQ 1080"
      echo "  ytv 'Rick Astley - Never Gonna Give You Up' 720"
      return 0
      ;;
  esac

  if ! command -v yt-dlp &>/dev/null; then
    echo "❌ yt-dlp no está instalado. Por favor, instálalo para usar esta función."
    return 1
  fi
  
  local quality="${2:-best}"
  local out="$YTDLP_DIR/Videos/%(title).180s.%(ext)s"
  
  local fmt
  case "$quality" in
    1080) fmt='bv*[height<=1080][ext=mp4]+ba/b[height<=1080]' ;;
    720)  fmt='bv*[height<=720][ext=mp4]+ba/b[height<=720]' ;;
    480)  fmt='bv*[height<=480][ext=mp4]+ba/b[height<=480]' ;;
    *)    fmt='bv*[ext=mp4]+ba/b[ext=mp4]/b' ;; # Mejor calidad MP4
  esac
  
  local opts=(
    -f "$fmt" --embed-metadata --embed-thumbnail
    --embed-subs --sub-langs "es.*,en.*" --convert-thumbnails jpg
    --no-playlist --retries 10 --fragment-retries 10
    --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
    --extractor-args "youtube:player_client=android,web"
    --progress --newline -o "$out"
  )
  
  if [[ "$1" == http* ]]; then
    echo "📥 Descargando video..."
    yt-dlp "${opts[@]}" "$1"
  else
    echo "🔍 Buscando: $1"
    yt-dlp "${opts[@]}" "ytsearch1:$1"
  fi
  
  [ $? -eq 0 ] && echo "✅ Video descargado en: $YTDLP_DIR/Videos/" || echo "❌ Falló la descarga de video."
}

ytls() {
  echo "🎵 Últimos 5 audios descargados en Music:"
  ls -1t "$YTDLP_DIR/Music" 2>/dev/null | head -5 | sed 's/^/  /' || echo "  (vacío)"
  echo ""
  echo "🎬 Últimos 5 videos descargados en Videos:"
  ls -1t "$YTDLP_DIR/Videos" 2>/dev/null | head -5 | sed 's/^/  /' || echo "  (vacío)"
}

# --- GNOME Keyring y Agente SSH ----------------------------------------------
# Configuración para que GNOME Keyring gestione las claves SSH.
if [ -n "$DESKTOP_SESSION" ] && command -v gnome-keyring-daemon >/dev/null 2>&1; then
  if ! pgrep -u "$USER" gnome-keyring-daemon > /dev/null 2>&1; then
    eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)" || true
  fi
  export SSH_AUTH_SOCK GPG_AGENT_INFO GNOME_KEYRING_CONTROL GNOME_KEYRING_PID
fi

# EL BLOQUE IF [ -z "$SSH_AUTH_SOCK" ] (FALLBACK) HA SIDO ELIMINADO DE AQUÍ.
# DEBE ESTAR EN TU .bashrc O SCRIPT DE INICIO DE BASH.

# Alias para gestionar el agente SSH.
alias ssh-list='ssh-add -l'
alias ssh-clear='ssh-add -D'
alias ssh-reload='
  ssh-add -D 2>/dev/null
  for key in ~/.ssh/*; do
    if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]] && ssh-keygen -l -f "$key" &>/dev/null; then
      ssh-add "$key" 2>/dev/null && echo "✅ $(basename $key)"
    fi
  done
'
alias ssh-github='ssh -T git@github.com'

# --- zoxide ------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias zz='z -'    # Ir al directorio anterior
  alias zi='zi'    # Modo interactivo
fi

# --- Historial de Zsh --------------------------------------------------------
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE AUTO_CD EXTENDED_GLOB

# Deshabilita el bloqueo de la terminal con CTRL+S.
stty -ixon 2>/dev/null

# Habilita colores en `man` y `less`.
export LESS='-R'

# --- Funciones y Configuraciones Locales -------------------------------------
[ -d "$HOME/.zsh_functions" ] || mkdir -p "$HOME/.zsh_functions"
for func_file in "$HOME/.zsh_functions"/*.zsh(N); do
  source "$func_file"
done

# Carga un archivo de configuración local (~/.zshrc.local) si existe.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# --- mise (Gestor de versiones de herramientas) ------------------------------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  alias mise-list='mise list'
  alias mise-current='mise current'
  alias mise-install='mise install'
  alias mise-use='mise use'
fi

# opencode
export PATH=/home/marco/.opencode/bin:$PATH
