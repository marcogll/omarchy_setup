# =============================================================================
#           CONFIGURACIÓN ZSH - Marco Gallegos v3.0
# =============================================================================
#
# Este archivo configura el entorno de la terminal Zsh. Incluye la
# configuración del PATH, la carga de Oh My Zsh, la inicialización de
# Oh My Posh, y una colección de alias y funciones para mejorar la
# productividad.
#
# =============================================================================

# --- PATH --------------------------------------------------------------------
# Define las rutas donde el sistema buscará los programas ejecutables.
# `typeset -U` se asegura de que no haya rutas duplicadas.
typeset -U PATH path
path=(
  $HOME/.local/bin   # Scripts y binarios instalados por el usuario.
  $HOME/bin           # Directorio personal de binarios.
  $HOME/.npm-global/bin # Paquetes de Node.js instalados globalmente.
  $HOME/AppImages     # Aplicaciones en formato AppImage.
  $HOME/go/bin        # Binarios de Go.
  $path               # Rutas del sistema existentes.
)

# --- Oh My Zsh ---------------------------------------------------------------
# Configuración y carga del framework Oh My Zsh.
export ZSH="$HOME/.oh-my-zsh"
# El tema se deja vacío porque Oh My Posh se encargará de gestionar el prompt.
ZSH_THEME=""

# Lista de plugins de Oh My Zsh a cargar.
plugins=(
  git sudo history colorize
  docker docker-compose
  npm node python pip golang
  copypath copyfile
)

# Desactiva la comprobación de seguridad de Oh My Zsh para directorios
# con permisos de escritura para otros usuarios, lo que puede ser molesto.
export ZSH_DISABLE_COMPFIX=true
# Configuración de la caché de autocompletado para mejorar el rendimiento.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
# Hace que el autocompletado no distinga entre mayúsculas y minúsculas.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Habilita colores en el menú de autocompletado.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Carga Oh My Zsh.
[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Carga los plugins de resaltado de sintaxis y autosugerencias.
# Intenta cargar la versión instalada con Oh My Zsh y, si no la encuentra,
# busca la versión instalada en el sistema.
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
# Inicializa Oh My Posh para personalizar el prompt.
if command -v oh-my-posh >/dev/null 2>&1; then
  # Carga el tema Catppuccin Frappe si existe.
  if [ -f ~/.poshthemes/catppuccin_frappe.omp.json ]; then
    eval "$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin_frappe.omp.json)"
  else
    # Si no, carga el tema por defecto.
    eval "$(oh-my-posh init zsh)"
  fi
fi

# --- Go ----------------------------------------------------------------------
# Configura las variables de entorno para el lenguaje de programación Go.
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# --- NVM (Node Version Manager) ----------------------------------------------
# Carga NVM para gestionar múltiples versiones de Node.js.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- Python ------------------------------------------------------------------
# Alias para usar las versiones 3 de python y pip por defecto.
alias pip='pip3'
alias python='python3'

# Función para gestionar entornos virtuales de Python.
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
# Colección de atajos para comandos comunes.

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
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'
gac(){ git add . && git commit -m "$1"; }

# Docker
# Detecta si se usa `docker compose` (nuevo) o `docker-compose` (antiguo).
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

# --- IA y ChatGPT ------------------------------------------------------------
# Alias para un cliente de ChatGPT en la terminal (ej. 'chatgpt-cli').
# Reemplaza 'chatgpt-cli' por el nombre del programa que uses.
#
# alias chat='chatgpt-cli'
# alias chat-q='chatgpt-cli -q' # Para una pregunta rápida sin guardar en el historial.
# alias chat-c='chatgpt-cli --continue' # Para continuar la conversación anterior.
# alias chat-code='chatgpt-cli --code' # Para preguntas de código.

# --- Funciones ---------------------------------------------------------------
# Funciones personalizadas para tareas comunes.

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

# Muestra una lista de todos los alias y funciones personalizadas.
zsh_help() {
  # --- Colores ---
  local C_DEFAULT="\e[0m"
  local C_BOLD="\e[1m"
  local C_TITLE="\e[1;35m" # Bold Magenta
  local C_SECTION="\e[1;34m" # Bold Blue
  local C_CMD="\e[0;32m"   # Green
  local C_DESC="\e[0;37m"  # White
  local C_HL="\e[0;33m"    # Yellow

  # --- Encabezado ---
  echo -e "${C_TITLE}╔═════════════════════════════════════════════════════════╗"
  echo -e "${C_TITLE}║      AYUDA DE LA CONFIGURACIÓN DE ZSH - Comandos      ║"
  echo -e "${C_TITLE}╚═════════════════════════════════════════════════════════╝${C_DEFAULT}"

  # --- Función para imprimir secciones ---
  print_section() {
    echo -e "\n${C_SECTION}--- $1 ---${C_DEFAULT}"
  }

  # --- Función para imprimir comandos ---
  print_command() {
    printf "  ${C_CMD}%-15s ${C_DESC}%s\n${C_DEFAULT}" "$1" "$2"
  }

  # --- Alias Generales ---
  print_section "Alias Generales"
  print_command "cls" "Limpia la pantalla."
  print_command "ll" "Lista archivos en formato largo."
  print_command "la" "Lista todos los archivos (incluyendo ocultos)."
  print_command "l" "Lista archivos en columnas."
  print_command ".." "Sube un nivel en el árbol de directorios."
  print_command "..." "Sube dos niveles."
  print_command "...." "Sube tres niveles."
  print_command "ff / nf" "Muestra información del sistema (fastfetch)."

  # --- Gestión de Paquetes (Arch) ---
  print_section "Gestión de Paquetes (Arch Linux)"
  print_command "pacu" "Actualiza el sistema (pacman)."
  print_command "paci" "Instala un paquete (pacman)."
  print_command "pacr" "Elimina un paquete (pacman)."
  print_command "pacs" "Busca un paquete (pacman)."
  print_command "yayu" "Actualiza el sistema (yay)."
  print_command "yayi" "Instala un paquete (yay)."

  # --- Git ---
  print_section "Git"
  print_command "gs" "git status"
  print_command "ga" "git add"
  print_command "gc" "git commit"
  print_command "gcm" "git commit -m '...'"
  print_command "gac <msg>" "git add . && git commit -m '<msg>'"
  print_command "gp" "git push"
  print_command "gl" "git pull"
  print_command "gd" "git diff"
  print_command "gb" "git branch"
  print_command "gco" "git checkout"
  print_command "gcb" "git checkout -b"
  print_command "glog" "Muestra un log de commits formateado."

  # --- Docker ---
  print_section "Docker"
  print_command "d" "docker"
  print_command "dc" "docker compose"
  print_command "dps" "Muestra todos los contenedores."
  print_command "di" "Muestra todas las imágenes."
  print_command "dex <id>" "Ejecuta una terminal en un contenedor."
  print_command "dlog <id>" "Muestra los logs de un contenedor."

  # --- Python ---
  print_section "Python"
  print_command "py" "python3"
  print_command "pip" "pip3"
  print_command "pipi" "pip install ..."
  print_command "pir" "pip install -r requirements.txt"
  print_command "pipf" "pip freeze > requirements.txt"
  print_command "venv create" "Crea un entorno virtual."
  print_command "venv on" "Activa el entorno virtual."
  print_command "venv off" "Desactiva el entorno virtual."
  print_command "serve [port]" "Inicia un servidor HTTP (puerto 8000 por defecto)."

  # --- Funciones de Utilidad ---
  print_section "Funciones de Utilidad"
  print_command "mkcd <dir>" "Crea un directorio y entra en él."
  print_command "extract <file>" "Extrae cualquier archivo comprimido."
  print_command "killport <port>" "Mata el proceso que usa un puerto."
  print_command "clima" "Muestra el clima de Saltillo."
  print_command "zsh-help" "Muestra esta ayuda."

  # --- Descargas (yt-dlp) ---
  print_section "Descargas (yt-dlp)"
  print_command "ytm <url|bús>" "Descarga audio de YouTube como MP3."
  print_command "ytv <url|bús>" "Descarga video de YouTube como MP4."
  print_command "ytls" "Lista los últimos 5 archivos descargados."

  # --- Agente SSH ---
  print_section "Agente SSH"
  print_command "ssh-list" "Lista las llaves SSH cargadas."
  print_command "ssh-clear" "Elimina todas las llaves del agente."
  print_command "ssh-reload" "Recarga todas las llaves SSH."
  print_command "ssh-github" "Prueba la conexión SSH con GitHub."
  echo ""
}

# Alias para acceder a la función de ayuda.
alias zsh-help='zsh_help'

# --- yt-dlp (Descargador de vídeos) ------------------------------------------
# Funciones mejoradas para descargar audio y video desde YouTube.
export YTDLP_DIR="$HOME/Videos/YouTube"
mkdir -p "$YTDLP_DIR"/{Music,Videos} 2>/dev/null

# Descarga audio en formato MP3.
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

# Descarga vídeo en formato MP4.
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

# Lista los últimos archivos descargados.
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

# Fallback a un agente SSH estándar si GNOME Keyring no está disponible.
if [ -z "$SSH_AUTH_SOCK" ]; then
  export SSH_AGENT_DIR="$HOME/.ssh/agent"
  mkdir -p "$SSH_AGENT_DIR"
  SSH_ENV="$SSH_AGENT_DIR/env"
  
  start_agent() {
    echo "🔑 Iniciando ssh-agent..."
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
  
  if [ -d "$HOME/.ssh" ]; then
    for key in "$HOME/.ssh"/*; do
      if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]] && \
         [[ ! "$key" =~ known_hosts ]] && [[ ! "$key" =~ authorized_keys ]] && \
         [[ ! "$key" =~ config ]] && [[ ! "$key" =~ agent ]]; then
        if ssh-keygen -l -f "$key" &>/dev/null; then
          local key_fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
          if ! ssh-add -l 2>/dev/null | grep -q "$key_fingerprint"; then
            if ssh-add "$key" 2>/dev/null; then
              echo "✅ Llave SSH agregada: $(basename $key)"
            fi
          fi
        fi
      fi
    done
  fi
fi

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
# Reemplazo inteligente de `cd` que recuerda los directorios que visitas.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias zz='z -'   # Ir al directorio anterior
  alias zi='zi'    # Modo interactivo
fi

# --- Historial de Zsh --------------------------------------------------------
# Configuración para un historial de comandos más útil y persistente.
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE AUTO_CD EXTENDED_GLOB

# Deshabilita el bloqueo de la terminal con CTRL+S.
stty -ixon 2>/dev/null

# Habilita colores en `man` y `less`.
export LESS='-R'

# --- Funciones y Configuraciones Locales -------------------------------------
# Carga archivos de funciones personalizadas desde ~/.zsh_functions/
[ -d "$HOME/.zsh_functions" ] || mkdir -p "$HOME/.zsh_functions"
for func_file in "$HOME/.zsh_functions"/*.zsh(N); do
  source "$func_file"
done

# Carga un archivo de configuración local (~/.zshrc.local) si existe.
# Ideal para añadir variables de entorno y configuraciones privadas.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
