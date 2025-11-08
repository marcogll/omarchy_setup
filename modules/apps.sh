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

install_apps() {
    log_step "Instalación de Aplicaciones"
    
    # Paquetes base esenciales
    log_info "Instalando herramientas base..."
    sudo pacman -S --noconfirm --needed \
        git curl wget base-devel unzip \
        neofetch htop fastfetch btop \
        vim nano tmux \
        xdg-utils xdg-user-dirs stow || {
        log_error "Error al instalar herramientas base"
        return 1
    }

    # Instalar Homebrew
    install_homebrew
    
    # Aplicaciones multimedia
    log_info "Instalando aplicaciones multimedia..."
    sudo pacman -S --noconfirm --needed \
        vlc vlc-plugins-all libdvdcss \
        audacity inkscape \
        ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly \
        yt-dlp || {
        log_warning "Algunos paquetes multimedia no se pudieron instalar"
    }
    
    # Configurar VLC como reproductor predeterminado
    log_info "Configurando VLC como reproductor predeterminado..."
    xdg-mime default vlc.desktop audio/mpeg 2>/dev/null || true
    xdg-mime default vlc.desktop audio/mp4 2>/dev/null || true
    xdg-mime default vlc.desktop audio/x-wav 2>/dev/null || true
    xdg-mime default vlc.desktop video/mp4 2>/dev/null || true
    xdg-mime default vlc.desktop video/x-matroska 2>/dev/null || true
    xdg-mime default vlc.desktop video/x-msvideo 2>/dev/null || true
    xdg-mime default vlc.desktop video/x-ms-wmv 2>/dev/null || true
    xdg-mime default vlc.desktop video/webm 2>/dev/null || true
    
    # Aplicaciones de red y transferencia de archivos
    log_info "Instalando aplicaciones de red..."
    sudo pacman -S --noconfirm --needed \
        filezilla telegram-desktop scrcpy || {
        log_warning "Algunos paquetes de red no se pudieron instalar"
    }
    
    # Flatpak
    log_info "Instalando Flatpak..."
    sudo pacman -S --noconfirm --needed flatpak || {
        log_warning "Flatpak no se pudo instalar"
    }
    
    # Drivers y codecs para Intel Iris Xe
    log_info "Instalando drivers y codecs para Intel Iris Xe..."
    
    # Instalar headers del kernel si son necesarios
    KVER="$(uname -r)"
    if [[ ! -d "/usr/lib/modules/${KVER}/build" ]]; then
        log_info "Instalando headers de kernel..."
        sudo pacman -S --noconfirm --needed linux-headers || {
            log_warning "No se pudieron instalar headers de kernel"
        }
    fi
    
    # Drivers de gráficos Intel
    log_info "Instalando drivers de gráficos Intel..."
    sudo pacman -S --noconfirm --needed \
        mesa vulkan-intel \
        lib32-mesa lib32-vulkan-intel || {
        log_warning "Algunos drivers de gráficos no se pudieron instalar"
    }
    
    # Drivers de video y hardware acceleration
    log_info "Instalando drivers de video Intel (VA-API/VDPAU)..."
    sudo pacman -S --noconfirm --needed \
        intel-media-driver \
        libva-utils \
        libvdpau-va-gl \
        libva-mesa-driver || {
        log_warning "Algunos drivers de video no se pudieron instalar"
    }
    
    # OpenCL para Intel
    log_info "Instalando soporte OpenCL para Intel..."
    sudo pacman -S --noconfirm --needed \
        ocl-icd \
        libclc \
        clinfo || {
        log_warning "Algunos paquetes OpenCL no se pudieron instalar"
    }
    
    # Verificar e instalar helper AUR si es necesario
    AUR_HELPER=$(ensure_aur_helper)
    
    # Intel Compute Runtime desde AUR (necesario para OpenCL en Intel)
    log_info "Instalando Intel Compute Runtime desde AUR..."
    if [ "$AUR_HELPER" = "yay" ]; then
        yay -S --noconfirm intel-compute-runtime || {
            log_warning "No se pudo instalar intel-compute-runtime desde AUR"
        }
    elif [ "$AUR_HELPER" = "paru" ]; then
        paru -S --noconfirm intel-compute-runtime || {
            log_warning "No se pudo instalar intel-compute-runtime desde AUR"
        }
    fi
    
    # Configurar OpenCL para Intel
    if [[ ! -f /etc/OpenCL/vendors/intel.icd ]] && [[ -f /usr/lib/intel-opencl/libigdrcl.so ]]; then
        log_info "Configurando OpenCL para Intel..."
        sudo mkdir -p /etc/OpenCL/vendors
        echo "/usr/lib/intel-opencl/libigdrcl.so" | sudo tee /etc/OpenCL/vendors/intel.icd >/dev/null
    fi
    
    # Actualizar cache de librerías
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
    
    # Aplicaciones desde AUR
    log_info "Instalando aplicaciones desde AUR..."
    AUR_PACKAGES=(
        "visual-studio-code-bin"
        "cursor-bin"
        "keyd"
        "fragments"
        "logiops"
        "ltunify"
        "teamviewer"
    )
    
    for pkg in "${AUR_PACKAGES[@]}"; do
        log_info "Instalando ${pkg}..."
        if [ "$AUR_HELPER" = "yay" ]; then
            yay -S --noconfirm "$pkg" || {
                log_warning "No se pudo instalar ${pkg} desde AUR"
            }
        elif [ "$AUR_HELPER" = "paru" ]; then
            paru -S --noconfirm "$pkg" || {
                log_warning "No se pudo instalar ${pkg} desde AUR"
            }
        fi
    done
    
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
    install_apps "$@"
fi
