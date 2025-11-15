#!/usr/bin/env bash
# ===============================================================
# apps.sh - Instalación de aplicaciones esenciales
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_homebrew() {
    log_step "Instalación de Homebrew (Linuxbrew)"
    
    if command_exists brew; then
        log_success "Homebrew ya está instalado."
        return 0
    fi
    
    log_info "Instalando Homebrew..."
    # Instalar de forma no interactiva
    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_success "Homebrew instalado correctamente."
    else
        log_error "Falló la instalación de Homebrew."
        return 1
    fi
}

run_module_main() {
    log_step "Instalación de Aplicaciones"

    # --- Definición de Paquetes ---
    local PACMAN_BASE=(
        git curl wget base-devel unzip htop fastfetch btop
        vim nano tmux xdg-utils xdg-user-dirs stow
    )
    local PACMAN_MULTIMEDIA=(
        vlc vlc-plugins-all libdvdcss audacity inkscape
        ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly
        yt-dlp
    )
    local PACMAN_NETWORK=(
        filezilla telegram-desktop scrcpy speedtest-cli
    )
    local PACMAN_INTEL_GFX=(
        mesa vulkan-intel lib32-mesa lib32-vulkan-intel
    )
    local PACMAN_INTEL_VIDEO=(
        intel-media-driver libva-utils libvdpau-va-gl libva-mesa-driver
    )
    local PACMAN_OPENCL=(
        ocl-icd libclc clinfo
    )
    local AUR_PACKAGES=(
        "visual-studio-code-bin" "cursor-bin" "keyd" "fragments"
        "logiops" "ltunify" "teamviewer" "intel-compute-runtime"
    )

    log_info "Actualizando el sistema para evitar conflictos de dependencias..."
    sudo pacman -Syu --noconfirm || {
        log_warning "No se pudo completar la actualización del sistema. Pueden ocurrir errores de dependencias."
        # Continuamos de todos modos, pero con una advertencia.
    }

    log_info "Instalando herramientas base..."
    sudo pacman -S --noconfirm --needed "${PACMAN_BASE[@]}" || {
        log_error "Error al instalar herramientas base"
        return 1
    }

    # Instalar Homebrew
    install_homebrew

    log_info "Instalando aplicaciones multimedia..."
    sudo pacman -S --noconfirm --needed "${PACMAN_MULTIMEDIA[@]}" || {
        log_warning "Algunos paquetes multimedia no se pudieron instalar"
    }

    log_info "Configurando VLC como reproductor predeterminado..."
    local mime_types=("audio/mpeg" "audio/mp4" "audio/x-wav" "video/mp4" "video/x-matroska" "video/x-msvideo" "video/x-ms-wmv" "video/webm")
    for type in "${mime_types[@]}"; do
        xdg-mime default vlc.desktop "$type" 2>/dev/null || true
    done

    log_info "Instalando aplicaciones de red..."
    sudo pacman -S --noconfirm --needed "${PACMAN_NETWORK[@]}" || {
        log_warning "Algunos paquetes de red no se pudieron instalar"
    }
    
    # Flatpak
    log_info "Instalando Flatpak..."
    sudo pacman -S --noconfirm --needed flatpak || {
        log_warning "Flatpak no se pudo instalar"
    }

    log_info "Instalando drivers y codecs para Intel Iris Xe..."

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

    if [[ ! -f /etc/OpenCL/vendors/intel.icd ]] && [[ -f /usr/lib/intel-opencl/libigdrcl.so ]]; then
        log_info "Configurando OpenCL para Intel..."
        sudo mkdir -p /etc/OpenCL/vendors
        echo "/usr/lib/intel-opencl/libigdrcl.so" | sudo tee /etc/OpenCL/vendors/intel.icd >/dev/null
    fi

    sudo ldconfig || true
    
    # Verificar instalación de drivers
    log_info "Verificando drivers Intel instalados..."
    if command_exists vainfo; then
        log_info "Información de VA-API:"
        vainfo 2>/dev/null | head -5 || true
    fi
    
    if command_exists clinfo; then
        log_info "Información de OpenCL:"
        clinfo 2>/dev/null | grep -E "Platform Name|Device Name" || true
    fi
    
    log_info "Instalando aplicaciones desde AUR..."
    log_warning "Este paso puede tardar varios minutos; qt5-webengine y teamviewer descargan y compilan bastante."
    if ! aur_install_packages "${AUR_PACKAGES[@]}"; then
        log_warning "Algunas aplicaciones de AUR no se pudieron instalar automáticamente."
    fi
    
    # Configurar servicios
    log_info "Configurando servicios..."
    
    # Habilitar keyd si está instalado
    if command_exists keyd; then
        log_info "Habilitando servicio keyd..."
        sudo systemctl enable keyd.service 2>/dev/null || true
        sudo systemctl start keyd.service 2>/dev/null || true
    fi
    
    # Habilitar logiops si está instalado
    if command_exists logiops; then
        log_info "Habilitando servicio logiops..."
        sudo systemctl enable logiops.service 2>/dev/null || true
        sudo systemctl start logiops.service 2>/dev/null || true
    fi
    
    # Habilitar TeamViewer daemon si está instalado
    if command_exists teamviewer; then
        log_info "Habilitando servicio TeamViewer..."
        sudo systemctl enable teamviewerd.service 2>/dev/null || true
        sudo systemctl start teamviewerd.service 2>/dev/null || true
        log_success "TeamViewer daemon habilitado e iniciado"
    fi
    
    log_success "Aplicaciones instaladas correctamente"
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
