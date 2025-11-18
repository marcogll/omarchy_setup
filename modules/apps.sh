#!/usr/bin/env bash
# ===============================================================
# apps.sh - Instalación de aplicaciones esenciales
# ===============================================================
#
# Este módulo se encarga de instalar y configurar una amplia gama
# de aplicaciones y herramientas de sistema.
#
# Funciones principales:
#   - Instala Homebrew (Linuxbrew) para gestionar paquetes adicionales.
#   - Instala paquetes desde los repositorios de Arch (pacman) y desde AUR.
#   - Organiza los paquetes por categorías (base, multimedia, red, etc.).
#   - Configura drivers para gráficos Intel Iris Xe.
#   - Configura GNOME Keyring para la gestión de contraseñas y claves SSH.
#   - Habilita servicios del sistema para aplicaciones como keyd, logiops y TeamViewer.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# ---------------------------------------------------------------
# ensure_homebrew_env()
# ---------------------------------------------------------------
# Asegura que el entorno de Homebrew esté configurado correctamente.
#
# Esta función realiza dos tareas principales:
#   1. Carga Homebrew en la sesión de shell actual para que el comando `brew`
#      esté disponible inmediatamente después de la instalación.
#   2. Añade la línea de inicialización de Homebrew a los ficheros de
#      perfil del usuario (`.profile` y `.zprofile`) para que `brew`
#      esté disponible en futuras sesiones de terminal.
#
# Parámetros:
#   $1 - Ruta al ejecutable de brew.
# ---------------------------------------------------------------
ensure_homebrew_env() {
    local brew_bin="$1"
    if [[ ! -x "$brew_bin" ]]; then
        return 1
    fi

    # Evalúa `shellenv` para que el resto del módulo pueda usar `brew`
    # sin necesidad de reiniciar la shell.
    eval "$("$brew_bin" shellenv)" || return 1

    local shell_snippet='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    local -a appended=()
    local -a rc_targets=("${HOME}/.profile")

    # Si el usuario utiliza Zsh, añade también la configuración a .zprofile.
    if [[ -n "${SHELL:-}" && "$(basename "${SHELL}")" == "zsh" ]]; then
        rc_targets+=("${HOME}/.zprofile")
    fi

    for rc_file in "${rc_targets[@]}"; do
        if [[ -f "$rc_file" ]] && grep -Fq "$shell_snippet" "$rc_file"; then
            continue
        fi
        {
            echo ""
            echo "# Configuración añadida por Omarchy Setup para inicializar Homebrew"
            echo "$shell_snippet"
        } >> "$rc_file"
        appended+=("$rc_file")
    done

    if [[ ${#appended[@]} -gt 0 ]]; then
        log_info "Se añadió la inicialización de Homebrew a: ${appended[*]}."
    fi

    return 0
}

# ---------------------------------------------------------------
# install_homebrew()
# ---------------------------------------------------------------
# Instala Homebrew (conocido como Linuxbrew en Linux).
#
# Comprueba si Homebrew ya está instalado. Si no lo está, descarga y
# ejecuta el script de instalación oficial de forma no interactiva.
# Después de la instalación, llama a `ensure_homebrew_env` para
# configurar el entorno de shell.
# ---------------------------------------------------------------
install_homebrew() {
    log_step "Instalación de Homebrew (Linuxbrew)"
    
    local brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
    if command_exists brew; then
        brew_path="$(command -v brew)"
    fi

    if command_exists brew || [[ -x "$brew_path" ]]; then
        log_success "Homebrew ya está instalado."
        ensure_homebrew_env "${brew_path}" || true
        return 0
    fi
    
    log_info "Instalando Homebrew..."
    # Instala de forma no interactiva para evitar prompts.
    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_success "Homebrew instalado correctamente."
        ensure_homebrew_env "${brew_path}" || log_warning "Homebrew se instaló pero no se pudo configurar la shell automáticamente."
    else
        log_error "Falló la instalación de Homebrew."
        return 1
    fi
}

# ---------------------------------------------------------------
# run_module_main()
# ---------------------------------------------------------------
# Función principal del módulo de instalación de aplicaciones.
#
# Ejecuta una secuencia de tareas para instalar y configurar
# aplicaciones esenciales del sistema.
# ---------------------------------------------------------------
run_module_main() {
    log_step "Instalación de Aplicaciones"

    # --- Definición de Paquetes ---
    # Paquetes base para el sistema y desarrollo.
    local PACMAN_BASE=(
        git curl wget base-devel unzip htop fastfetch btop
        vim nano tmux xdg-utils xdg-user-dirs stow
        gnome-keyring libsecret seahorse openssh rsync
    )
    # Paquetes para reproducción y edición multimedia.
    local PACMAN_MULTIMEDIA=(
        vlc vlc-plugins-all libdvdcss audacity inkscape
        ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly
        yt-dlp
    )
    # Aplicaciones de red y conectividad.
    local PACMAN_NETWORK=(
        filezilla telegram-desktop scrcpy speedtest-cli
    )
    # Drivers para gráficos Intel (Mesa y Vulkan).
    local PACMAN_INTEL_GFX=(
        mesa vulkan-intel lib32-mesa lib32-vulkan-intel
    )
    # Drivers para aceleración de vídeo por hardware en Intel (VA-API).
    local PACMAN_INTEL_VIDEO=(
        intel-media-driver libva-utils libvdpau-va-gl libva-mesa-driver
    )
    # Soporte para computación GPGPU con OpenCL.
    local PACMAN_OPENCL=(
        ocl-icd libclc clinfo
    )
    # Paquetes a instalar desde el Arch User Repository (AUR).
    local AUR_PACKAGES=(
        "visual-studio-code-bin" "cursor-bin" "keyd" "fragments"
        "logiops" "ltunify" "teamviewer" "intel-compute-runtime"
    )

    # --- Instalación de Paquetes ---
    log_info "Actualizando el sistema para evitar conflictos de dependencias..."
    sudo pacman -Syu --noconfirm || {
        log_warning "No se pudo completar la actualización del sistema. Pueden ocurrir errores de dependencias."
    }

    log_info "Instalando herramientas base..."
    sudo pacman -S --noconfirm --needed "${PACMAN_BASE[@]}" || {
        log_error "Error al instalar herramientas base"
        return 1
    }

    # Instalar Homebrew si no está presente.
    install_homebrew

    log_info "Instalando aplicaciones multimedia..."
    sudo pacman -S --noconfirm --needed "${PACMAN_MULTIMEDIA[@]}" || {
        log_warning "Algunos paquetes multimedia no se pudieron instalar"
    }

    # Configura VLC como el reproductor por defecto para los tipos de archivo más comunes.
    log_info "Configurando VLC como reproductor predeterminado..."
    local mime_types=("audio/mpeg" "audio/mp4" "audio/x-wav" "video/mp4" "video/x-matroska" "video/x-msvideo" "video/x-ms-wmv" "video/webm")
    for type in "${mime_types[@]}"; do
        xdg-mime default vlc.desktop "$type" 2>/dev/null || true
    done

    log_info "Instalando aplicaciones de red..."
    sudo pacman -S --noconfirm --needed "${PACMAN_NETWORK[@]}" || {
        log_warning "Algunos paquetes de red no se pudieron instalar"
    }
    
    log_info "Instalando Flatpak..."
    sudo pacman -S --noconfirm --needed flatpak || {
        log_warning "Flatpak no se pudo instalar"
    }

    # --- Configuración de Drivers Intel ---
    log_info "Instalando drivers y codecs para Intel Iris Xe..."

    # Instala los headers del kernel si son necesarios para compilar módulos.
    KVER="$(uname -r)"
    if [[ ! -d "/usr/lib/modules/${KVER}/build" ]]; then
        log_info "Instalando headers de kernel..."
        sudo pacman -S --noconfirm --needed linux-headers || {
            log_warning "No se pudieron instalar headers de kernel"
        }
    fi

    log_info "Instalando drivers de gráficos Intel..."
    sudo pacman -S --noconfirm --needed "${PACMAN_INTEL_GFX[@]}" || {
        log_warning "Algunos drivers de gráficos no se pudieron instalar"
    }

    log_info "Instalando drivers de video Intel (VA-API/VDPAU)..."
    sudo pacman -S --noconfirm --needed "${PACMAN_INTEL_VIDEO[@]}" || {
        log_warning "Algunos drivers de video no se pudieron instalar"
    }

    log_info "Instalando soporte OpenCL para Intel..."
    sudo pacman -S --noconfirm --needed "${PACMAN_OPENCL[@]}" || {
        log_warning "Algunos paquetes OpenCL no se pudieron instalar"
    }

    # Crea el fichero de configuración de OpenCL para los drivers de Intel.
    if [[ ! -f /etc/OpenCL/vendors/intel.icd ]] && [[ -f /usr/lib/intel-opencl/libigdrcl.so ]]; then
        log_info "Configurando OpenCL para Intel..."
        sudo mkdir -p /etc/OpenCL/vendors
        echo "/usr/lib/intel-opencl/libigdrcl.so" | sudo tee /etc/OpenCL/vendors/intel.icd >/dev/null
    fi

    # Actualiza la caché de librerías compartidas.
    sudo ldconfig || true
    
    # --- Verificación de Drivers ---
    log_info "Verificando drivers Intel instalados..."
    if command_exists vainfo; then
        log_info "Información de VA-API:"
        vainfo 2>/dev/null | head -5 || true
    fi
    
    if command_exists clinfo; then
        log_info "Información de OpenCL:"
        clinfo 2>/dev/null | grep -E "Platform Name|Device Name" || true
    fi
    
    # --- Instalación desde AUR ---
    log_info "Instalando aplicaciones desde AUR..."
    log_warning "Este paso puede tardar varios minutos; qt5-webengine y teamviewer descargan y compilan bastante."
    if ! aur_install_packages "${AUR_PACKAGES[@]}"; then
        log_warning "Algunas aplicaciones de AUR no se pudieron instalar automáticamente."
    fi
    
    # --- Configuración de Servicios ---
    log_info "Configurando servicios del sistema..."
    
    # Configura GNOME Keyring para que actúe como agente de credenciales y SSH.
    log_info "Configurando GNOME Keyring como agente de credenciales..."
    mkdir -p "${HOME}/.config/environment.d"
    cat <<'EOF' > "${HOME}/.config/environment.d/10-gnome-keyring.conf"
SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
EOF
    # Habilita el servicio de GNOME Keyring para el usuario actual.
    if systemctl --user enable --now gnome-keyring-daemon.socket gnome-keyring-daemon.service >/dev/null 2>&1; then
        log_success "GNOME Keyring listo para gestionar contraseñas y claves SSH."
    else
        log_warning "No se pudo habilitar gnome-keyring-daemon en systemd de usuario. Verifica que tu sesión use systemd (--user)."
    fi

    # Inicia el daemon de GNOME Keyring en la sesión actual para que `ssh-add` funcione.
    if command_exists gnome-keyring-daemon; then
        local keyring_eval
        keyring_eval="$(gnome-keyring-daemon --start --components=secrets,ssh 2>/dev/null)" || keyring_eval=""
        if [[ -n "$keyring_eval" ]]; then
            eval "$keyring_eval"
        fi
    fi
    local keyring_socket="/run/user/$UID/keyring/ssh"
    if [[ -S "$keyring_socket" ]]; then
        export SSH_AUTH_SOCK="$keyring_socket"
    fi
    log_info "Vuelve a iniciar sesión para que las variables de entorno del keyring se apliquen."
    
    # Busca claves SSH en ~/.ssh y las añade al agente de GNOME Keyring.
    if command_exists ssh-add; then
        local ssh_dir="${HOME}/.ssh"
        if [[ -d "$ssh_dir" ]]; then
            # Encuentra todas las claves privadas válidas.
            mapfile -t ssh_private_keys < <(
                find "$ssh_dir" -maxdepth 1 -type f -perm -u=r \
                    ! -name "*.pub" ! -name "*-cert.pub" ! -name "known_hosts" \
                    ! -name "known_hosts.*" ! -name "authorized_keys" ! -name "config" \
                    ! -name "*.old" ! -name "agent" ! -name "*.bak" 2>/dev/null
            )
            if [[ ${#ssh_private_keys[@]} -gt 0 ]]; then
                log_info "Agregando claves SSH detectadas al keyring (se solicitará la passphrase si aplica)..."
                for key_path in "${ssh_private_keys[@]}"; do
                    if [[ ! -r "$key_path" ]]; then
                        log_warning "No se puede leer la clave $(basename "$key_path"); revísala manualmente."
                        continue
                    fi
                    # Intenta añadir la clave al agente.
                    if ssh-keygen -y -f "$key_path" >/dev/null 2>&1; then
                        log_info "Registrando clave $(basename "$key_path")..."
                        local spinner_was_active=0
                        if [[ ${SPINNER_ACTIVE:-0} -eq 1 ]]; then spinner_was_active=1; fi
                        if declare -F pause_spinner >/dev/null; then pause_spinner; fi

                        if SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add "$key_path"; then
                            log_success "Clave $(basename "$key_path") añadida al keyring."
                        else
                            log_warning "No se pudo añadir la clave $(basename "$key_path")."
                        fi

                        if (( spinner_was_active )) && declare -F resume_spinner >/dev/null; then resume_spinner; fi
                    else
                        log_warning "La clave $(basename "$key_path") parece inválida. Se omite."
                    fi
                done
            else
                log_info "No se encontraron claves privadas SSH en ${ssh_dir}."
            fi
        else
            log_info "No se detectó el directorio ~/.ssh; omitiendo carga de claves."
        fi
    else
        log_warning "ssh-add no está disponible; no se pueden registrar claves en el keyring."
    fi
    
    # Habilita los servicios de las aplicaciones instaladas.
    if command_exists keyd; then
        log_info "Habilitando servicio keyd..."
        sudo systemctl enable --now keyd.service 2>/dev/null || true
    fi
    
    if command_exists logiops; then
        log_info "Habilitando servicio logiops..."
        sudo systemctl enable --now logiops.service 2>/dev/null || true
    fi
    
    if command_exists teamviewer; then
        log_info "Habilitando servicio TeamViewer..."
        sudo systemctl enable --now teamviewerd.service 2>/dev/null || true
        log_success "TeamViewer daemon habilitado e iniciado"
    fi
    
    log_success "Aplicaciones instaladas correctamente"
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
