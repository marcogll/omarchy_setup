#!/usr/bin/env bash
# ===============================================================
# davinci-resolve.sh - Instalador de DaVinci Resolve (Intel Edition)
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Función para mostrar una barra de progreso
# Uso: show_progress TOTAL_ITEMS CURRENT_ITEM "Mensaje"
show_progress() {
    local total=$1
    local current=$2
    local msg=$3
    local percent=$((current * 100 / total))
    local completed_len=$((percent / 2))
    local bar=""
    for ((i=0; i<completed_len; i++)); do bar+="="; done
    local empty_len=$((50 - completed_len))
    for ((i=0; i<empty_len; i++)); do bar+=" "; done
    
    # Asegurarse de que el cursor esté al principio de la línea y la limpie
    echo -ne "\r\033[K"
    # Imprimir la barra de progreso
    echo -ne "  ${GREEN}[${bar}]${NC} ${percent}% - ${msg} (${current}/${total})"

    if [[ $current -eq $total ]]; then
        echo "" # Nueva línea al final
    fi
}

install_davinci_resolve() {
    log_step "Instalación de DaVinci Resolve (Intel Edition)"
    
    # Comprobar que el ZIP está en Downloads
    ZIP_DIR="${HOME}/Downloads"
    RESOLVE_ZIP="$(ls -1t "${ZIP_DIR}"/DaVinci_Resolve*_Linux.zip 2>/dev/null | head -n1 || true)"
    
    if [[ -z "${RESOLVE_ZIP}" ]]; then
        log_error "No se encontró ningún ZIP de DaVinci Resolve en ${ZIP_DIR}."
        log_info "Ve al sitio de descargas de Blackmagic Design:"
        log_info "https://www.blackmagicdesign.com/support/"
        log_info "Descarga el archivo Linux ZIP y colócalo en ${ZIP_DIR}"
        return 1
    fi
    
    log_info "Usando ZIP: ${RESOLVE_ZIP}"
    
    start_spinner "Instalando dependencias básicas..."
    # Instalación de paquetes básicos
    sudo pacman -S --needed --noconfirm \
        unzip patchelf libarchive xdg-user-dirs desktop-file-utils \
        file gtk-update-icon-cache rsync clinfo qt5-base qt5-svg qt5-x11extras \
        libpng libtiff libcurl &> /dev/null
    stop_spinner $? "Dependencias básicas instaladas."
    
    # Configurar OpenCL / Intel GPU
    log_info "Configurando runtime OpenCL de Intel y drivers de video..."
    
    # Eliminar posibles paquetes NVIDIA conflictivos
    if pacman -Qi nvidia &>/dev/null; then
        log_warning "Quitando paquetes NVIDIA para evitar conflictos..."
        sudo pacman -Rns --noconfirm nvidia nvidia-utils nvidia-settings opencl-nvidia || true
    fi
    
    start_spinner "Instalando headers del kernel (si es necesario)..."
    # Instalar headers del kernel si son necesarios
    KVER="$(uname -r)"
    if [[ ! -d "/usr/lib/modules/${KVER}/build" ]]; then
        log_info "Instalando headers de kernel..."
        sudo pacman -S --needed --noconfirm linux-headers linux-zen-headers &> /dev/null
    fi
    stop_spinner $? "Headers del kernel verificados."
    
    # Instalar runtime OpenCL (compute runtime), desde AUR si es necesario
    if ! pacman -Qi intel-compute-runtime &>/dev/null; then
        start_spinner "Instalando intel-compute-runtime desde AUR..."
        log_info "Instalando intel-compute-runtime (puede venir del AUR)..."
        AUR_HELPER=$(ensure_aur_helper)
        if [ "$AUR_HELPER" = "yay" ]; then
            yay -S --noconfirm intel-compute-runtime || {
                log_error "No se pudo instalar intel-compute-runtime"
                return 1
            }
        elif [ "$AUR_HELPER" = "paru" ]; then
            paru -S --noconfirm intel-compute-runtime || {
                log_error "No se pudo instalar intel-compute-runtime"
                return 1
            }
        else
            if ! sudo pacman -S --needed --noconfirm intel-compute-runtime; then
                log_error "No se pudo instalar intel-compute-runtime desde pacman."
                log_error "Asegúrate de tener un helper AUR como yay o paru"
                return 1
            fi
        fi
        stop_spinner $? "intel-compute-runtime instalado."
    fi
    
    start_spinner "Instalando paquetes de video y OpenCL..."
    # Instalar otros paquetes Intel / VA-API / OpenCL
    sudo pacman -S --needed --noconfirm \
        intel-media-driver \
        ocl-icd \
        libxcrypt-compat \
        ffmpeg \
        glu \
        gtk2 \
        fuse2 \
        libva-utils libvdpau-va-gl &> /dev/null
    stop_spinner $? "Paquetes de video instalados."
    
    # Asegurar el archivo ICD para OpenCL de Intel
    if [[ ! -f /etc/OpenCL/vendors/intel.icd ]]; then
        log_info "Creando vendor file de OpenCL para Intel..."
        sudo mkdir -p /etc/OpenCL/vendors
        echo "/usr/lib/intel-opencl/libigdrcl.so" | sudo tee /etc/OpenCL/vendors/intel.icd >/dev/null
    fi
    
    # Crear enlace /etc/pki/tls si es necesario
    if [[ ! -e /etc/pki/tls ]]; then
        log_info "Creando enlace /etc/pki/tls → /etc/ssl"
        sudo mkdir -p /etc/pki
        sudo ln -sf /etc/ssl /etc/pki/tls
    fi
    
    sudo ldconfig || true
    
    # Verificaciones
    log_info "Verificando OpenCL instalado..."
    clinfo | grep -E "Platform Name|Device Name" || true
    
    log_info "Verificando soporte de decodificación VA-API para H264 / HEVC..."
    vainfo | grep -E "H264|HEVC" || true
    
    start_spinner "Extrayendo DaVinci Resolve del ZIP (puede tardar)..."
    NEEDED_GB=10
    FREE_KB=$(df --output=avail -k "${ZIP_DIR}" | tail -n1)
    FREE_GB=$((FREE_KB / 1024 / 1024))
    if (( FREE_GB < NEEDED_GB )); then
        log_error "No hay suficiente espacio libre en ${ZIP_DIR}: ${FREE_GB} GiB < ${NEEDED_GB} GiB"
        return 1
    fi
    
    WORKDIR="$(mktemp -d -p "${ZIP_DIR}" .resolve-extract-XXXXXXXX)"
    trap 'rm -rf "${WORKDIR}"' EXIT
    unzip -q "${RESOLVE_ZIP}" -d "${WORKDIR}" 
    stop_spinner $? "ZIP extraído."
    
    RUN_FILE="$(find "${WORKDIR}" -maxdepth 2 -type f -name 'DaVinci_Resolve_*_Linux.run' | head -n1 || true)"
    if [[ -z "${RUN_FILE}" ]]; then
        log_error "No se encontró el archivo .run dentro del ZIP."
        return 1
    fi
    chmod +x "${RUN_FILE}"
    
    start_spinner "Extrayendo AppImage..."
    EX_DIR="$(dirname "${RUN_FILE}")"
    ( cd "${EX_DIR}" && "./$(basename "${RUN_FILE}")" --appimage-extract >/dev/null )
    stop_spinner $? "AppImage extraído."
    
    APPDIR="${EX_DIR}/squashfs-root"
    if [[ ! -d "${APPDIR}" ]]; then
        log_error "No se extrajo correctamente la carpeta squashfs-root."
        return 1
    fi
    
    chmod -R u+rwX,go+rX,go-w "${APPDIR}"
    if [[ ! -s "${APPDIR}/bin/resolve" ]]; then
        log_error "El binario resolve no existe o está vacío."
        return 1
    fi
    
    # Reemplazar librerías glib/gio/gmodule
    log_info "Ajustando bibliotecas glib/gio/gmodule para usar las del sistema..."
    pushd "${APPDIR}" >/dev/null
    rm -f libs/libglib-2.0.so.0 libs/libgio-2.0.so.0 libs/libgmodule-2.0.so.0 || true
    ln -sf /usr/lib/libglib-2.0.so.0 libs/libglib-2.0.so.0
    ln -sf /usr/lib/libgio-2.0.so.0 libs/libgio-2.0.so.0
    ln -sf /usr/lib/libgmodule-2.0.so.0 libs/libgmodule-2.0.so.0
    popd >/dev/null
    
    log_info "Aplicando RPATH con patchelf (esto puede tardar)..."
    RPATH_DIRS=(
        "libs"
        "libs/plugins/sqldrivers"
        "libs/plugins/xcbglintegrations"
        "libs/plugins/imageformats"
        "libs/plugins/platforms"
        "libs/Fusion"
        "plugins"
        "bin"
    )
    RPATH_ABS=""
    for p in "${RPATH_DIRS[@]}"; do
        RPATH_ABS+="/opt/resolve/${p}:"
    done
    RPATH_ABS+="\$ORIGIN"
    
    # Usar barra de progreso para patchelf
    if command -v patchelf &>/dev/null; then
        local files_to_patch
        files_to_patch=$(find "${APPDIR}" -type f -exec file {} + | grep "ELF" | cut -d: -f1)
        local total_files=$(echo "$files_to_patch" | wc -l)
        local current_file=0

        echo "$files_to_patch" | while read -r file; do
            current_file=$((current_file + 1))
            show_progress "$total_files" "$current_file" "Aplicando RPATH..."
            sudo patchelf --set-rpath "${RPATH_ABS}" "$file" &>/dev/null
        done
        log_success "RPATH aplicado a $total_files archivos."
    fi
    
    start_spinner "Copiando archivos a /opt/resolve..."
    sudo rm -rf /opt/resolve
    sudo mkdir -p /opt/resolve
    sudo rsync -a --delete "${APPDIR}/" /opt/resolve/
    stop_spinner $? "Archivos copiados a /opt/resolve."

    sudo mkdir -p /opt/resolve/.license
    
    # Enlazar libcrypt legado si es necesario
    sudo pacman -S --needed --noconfirm libxcrypt-compat || true
    sudo ldconfig || true
    if [[ -e /usr/lib/libcrypt.so.1 ]]; then
        sudo ln -sf /usr/lib/libcrypt.so.1 /opt/resolve/libs/libcrypt.so.1
    fi
    
    # Crear wrapper + acceso en escritorio
    log_info "Creando wrapper y acceso para DaVinci Resolve..."
    cat << 'EOF' | sudo tee /usr/local/bin/resolve-intel >/dev/null
#!/usr/bin/env bash
set -euo pipefail
find /tmp -maxdepth 1 -type f -name "qtsingleapp-DaVinci*lockfile" -delete 2>/dev/null || true
export QT_QPA_PLATFORM=xcb
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export OCL_ICD_VENDORS=/etc/OpenCL/vendors
exec /opt/resolve/bin/resolve "$@"
EOF
    
    sudo chmod +x /usr/local/bin/resolve-intel
    
    mkdir -p "${HOME}/.local/share/applications"
    cat > "${HOME}/.local/share/applications/davinci-resolve-wrapper.desktop" << EOF
[Desktop Entry]
Type=Application
Name=DaVinci Resolve (Intel)
Comment=DaVinci Resolve usando OpenCL de Intel
Exec=/usr/local/bin/resolve-intel %U
TryExec=/usr/local/bin/resolve-intel
Terminal=false
Icon=davinci-resolve
Categories=AudioVideo;Video;Graphics;
StartupWMClass=resolve
X-GNOME-UsesNotifications=true
EOF
    
    update-desktop-database "${HOME}/.local/share/applications" >/dev/null 2>&1 || true
    sudo gtk-update-icon-cache -f /usr/share/icons/hicolor >/dev/null 2>&1 || true
    
    log_success "DaVinci Resolve (Intel Edition) instalado en /opt/resolve"
    log_info "Usa 'resolve-intel' para lanzar la aplicación"
    log_info "Para verificar OpenCL: clinfo | grep -E 'Platform Name|Device Name'"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_davinci_resolve "$@"
fi
