# --- Funciones de Ayuda ------------------------------------------------------
# Muestra una lista detallada de todos los alias y funciones personalizadas.
# Soporta modo interactivo con fzf si está instalado.
zsh_help() {
  # --- Colores ---
  local C_DEFAULT="\e[0m"
  local C_BOLD="\e[1m"
  local C_TITLE="\e[1;35m" # Bold Magenta
  local C_SUBTITLE="\e[1;36m" # Bold Cyan
  local C_SECTION="\e[1;34m" # Bold Blue
  local C_CMD="\e[0;32m"   # Green
  local C_DESC="\e[0;37m"  # White
  local C_NOTE="\e[0;90m"  # Gray

  # --- Componentes de la Ayuda ---
  
  _help_header() {
    clear
    echo -e "${C_TITLE}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "${C_TITLE}║           GUÍA DEL SISTEMA Y CONFIGURACIÓN DE ZSH                  ║"
    echo -e "${C_TITLE}╚════════════════════════════════════════════════════════════════════╝${C_DEFAULT}"
  }

  _help_print_section() { echo -e "\n${C_SECTION}--- $1 ---${C_DEFAULT}"; }
  _help_print_cmd() { printf "  ${C_CMD}%-18s ${C_DESC}%s\n${C_DEFAULT}" "$1" "$2"; }

  _help_nav() {
    _help_print_section "Navegación y Archivos"
    _help_print_cmd ".." "Subir un nivel (cd ..)"
    _help_print_cmd "..." "Subir dos niveles (cd ../..)"
    _help_print_cmd "ll" "Listar con detalles (ls -alF)"
    _help_print_cmd "mkcd <dir>" "Crear directorio y entrar en él"
    _help_print_cmd "z <dir>" "Saltar a directorio (zoxide)"
    _help_print_cmd "zi" "Seleccionar directorio interactivo"
    _help_print_cmd "zz" "Volver al directorio anterior (z -)"
    _help_print_cmd "extract <file>" "Descomprimir (zip, tar, rar...)"
  }

  _help_git() {
    _help_print_section "Git - Flujo de Trabajo"
    _help_print_cmd "gs" "Ver estado (git status)"
    _help_print_cmd "ga" "Añadir cambios (git add)"
    _help_print_cmd "gc" "Guardar cambios (git commit)"
    _help_print_cmd "gcm <msg>" "Guardar con mensaje"
    _help_print_cmd "gac <msg>" "Añadir Y Guardar todo"
    _help_print_cmd "gp" "Subir cambios (git push)"
    _help_print_cmd "gl" "Bajar cambios (git pull)"
    _help_print_cmd "gfa" "Traer todo (git fetch --all)"
    _help_print_cmd "gfr" "Traer origen (git fetch origin)"
  }

  _help_docker() {
    _help_print_section "Docker - Contenedores"
    _help_print_cmd "dps" "Ver contenedores"
    _help_print_cmd "dc" "Docker Compose"
    _help_print_cmd "dex <id>" "Entrar a terminal de contenedor"
    _help_print_cmd "dlog <id>" "Ver logs en tiempo real"
  }

  _help_dev() {
    _help_print_section "Desarrollo"
    _help_print_cmd "py / python" "Ejecuta python3"
    _help_print_cmd "pip" "Ejecuta pip3"
    _help_print_cmd "venv create" "Crea entorno virtual (.venv)"
    _help_print_cmd "venv on" "Activa entorno virtual"
    _help_print_cmd "serve" "Servidor web en puerto 8000"
    _help_print_cmd "nrd" "npm run dev"
  }

  _help_utils() {
    _help_print_section "Utilidades"
    _help_print_cmd "ff / nf" "Info del sistema (Fastfetch)"
    _help_print_cmd "killport <N>" "Matar proceso en puerto N"
    _help_print_cmd "clima" "Ver pronóstico del tiempo"
    _help_print_cmd "ytm <url>" "Descargar música (MP3)"
    _help_print_cmd "ytv <url>" "Descargar video (MP4)"
  }

  _help_all() {
    _help_header
    echo -e "\n${C_SUBTITLE}Resumen del Sistema:${C_DEFAULT}"
    echo -e "  • ${C_BOLD}Framework:${C_DEFAULT} Oh My Zsh"
    echo -e "  • ${C_BOLD}Plugins:${C_DEFAULT}   git, docker, npm, python..."
    _help_nav
    _help_git
    _help_docker
    _help_dev
    _help_utils
    echo -e "\n${C_NOTE}Tip: Usa 'help' sin argumentos para el menú interactivo.${C_DEFAULT}\n"
  }
  
  _wait_for_key() {
    echo ""
    read -k 1 "key?Presiona cualquier tecla para volver..."
  }

  # --- Lógica Principal ---
  if [[ "$1" == "--all" ]]; then
    _help_all
    return 0
  fi

  # Si fzf está instalado, mostrar menú interactivo en bucle
  if command -v fzf >/dev/null 2>&1; then
    while true; do
      local options="Todo\nNavegación\nGit\nDocker\nDesarrollo\nUtilidades\nSalir (q)"
      local selected=$(echo -e "$options" | fzf --ansi --height=40% --layout=reverse --border --prompt="Ayuda > " --header="Selecciona un tema")
      
      case "$selected" in
        "Todo") _help_all; _wait_for_key ;;
        "Navegación") _help_header; _help_nav; _wait_for_key ;;
        "Git") _help_header; _help_git; _wait_for_key ;;
        "Docker") _help_header; _help_docker; _wait_for_key ;;
        "Desarrollo") _help_header; _help_dev; _wait_for_key ;;
        "Utilidades") _help_header; _help_utils; _wait_for_key ;;
        "Salir (q)"|"") break ;;
      esac
    done
  else
    # Fallback si no hay fzf
    _help_all
  fi
}

# Alias para acceder a la función de ayuda.
alias zsh-help='zsh_help'
alias help='zsh_help'
