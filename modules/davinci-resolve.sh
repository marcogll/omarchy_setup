#!/usr/bin/env bash
# ===============================================================
# davinci-resolve.sh - Instalador de DaVinci Resolve (Intel Edition)
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# --- Definición de Dependencias ---
# Paquetes de los repositorios oficiales de Arch
PACMAN_DEPS=(
    # Herramientas básicas
    unzip patchelf libarchive xdg-user-dirs desktop-file-utils file rsync
    # Dependencias de Resolve
    libpng libtiff libcurl ocl-icd libxcrypt-compat ffmpeg glu gtk2 fuse2
    # Dependencias de Qt
    qt5-base qt5-svg qt5-x11extras
    # Drivers y herramientas Intel
    intel-media-driver libva-utils libvdpau-va-gl clinfo
)

# Paquetes del AUR
AUR_DEPS=(
    "intel-compute-runtime" # Runtime OpenCL para GPUs Intel
)

# Directorio de descargas y nombre del ejecutable
DOWNLOADS_DIR="${HOME}/Downloads"
INSTALL_DIR="/opt/resolve"
WRAPPER_PATH="/usr/local/bin/resolve-intel"

# Función para mostrar una barra de progreso
# Uso: show_progress TOTAL_ITEMS CURRENT_ITEM "Mensaje"
show_progress() {
    local total=$1
    local current=$2
    local msg=$3
    local last_percent=${4:-"-1"} # Nuevo: Almacena el último porcentaje mostrado
    local percent=$((current * 100 / total))
    
    # Solo actualizar la barra si el porcentaje ha cambiado
    if [[ "$percent" -gt "$last_percent" ]]; then
        local completed_len=$((percent / 2))
        local bar=""
        for ((i=0; i<completed_len; i++)); do bar+="="; done
        local empty_len=$((50 - completed_len))
        for ((i=0; i<empty_len; i++)); do bar+=" "; done
        
        # Asegurarse de que el cursor esté al principio de la línea y la limpie
        echo -ne "\r\033[K"
        # Imprimir la barra de progreso
        echo -ne "  ${GREEN}[${bar}]${NC} ${percent}% - ${msg} (${current}/${total})"
    fi

    if [[ $current -eq $total ]]; then
        echo "" # Nueva línea al final
    fi
    echo "$percent" # Devolver el porcentaje actual para la siguiente iteración
}

install_davinci_resolve() {
    log_step "Iniciando instalación de DaVinci Resolve (Intel Edition)"

    # --- 1. Verificaciones Previas ---
    log_info "Realizando verificaciones previas..."

    # Comprobar que el ZIP de Resolve existe
    local RESOLVE_ZIP
    RESOLVE_ZIP="$(find "${DOWNLOADS_DIR}" -maxdepth 1 -name 'DaVinci_Resolve*_Linux.zip' -print -quit)"

    if [[ -z "${RESOLVE_ZIP}" ]]; then
        log_error "No se encontró el ZIP de DaVinci Resolve en ${DOWNLOADS_DIR}."
        log_info "Ve al sitio de descargas de Blackmagic Design:"
        log_info "https://www.blackmagicdesign.com/support/"
        log_info "Descarga el archivo Linux ZIP y colócalo en ${DOWNLOADS_DIR}"
        return 1
    fi
    log_info "Usando ZIP: ${RESOLVE_ZIP}"

    # Verificar espacio en disco
    local NEEDED_GB=10
    local FREE_KB
    FREE_KB=$(df --output=avail -k "${DOWNLOADS_DIR}" | tail -n1)
    local FREE_GB=$((FREE_KB / 1024 / 1024))
    if (( FREE_GB < NEEDED_GB )); then
        log_error "No hay suficiente espacio libre en ${DOWNLOADS_DIR}: ${FREE_GB}GiB disponibles, se necesitan ${NEEDED_GB}GiB."
        return 1
    fi

    # Advertir sobre paquetes NVIDIA
    if pacman -Qi nvidia &>/dev/null; then
        log_warning "Se detectaron paquetes de NVIDIA. Resolve para Intel puede tener conflictos."
        read -p "¿Deseas intentar desinstalar los paquetes de NVIDIA? [s/N]: " confirm
        if [[ "${confirm}" =~ ^[Ss]$ ]]; then
            start_spinner "Desinstalando paquetes de NVIDIA..."
            sudo pacman -Rns --noconfirm nvidia nvidia-utils nvidia-settings opencl-nvidia &> /dev/null
            stop_spinner $? "Paquetes de NVIDIA desinstalados."
        else
            log_info "Continuando sin desinstalar los paquetes de NVIDIA. La instalación podría fallar."
        fi
    fi

    # --- 2. Instalación de Dependencias ---
    log_info "Instalando dependencias necesarias..."

    # Instalar headers del kernel correspondiente
    local KERNEL_VERSION
    KERNEL_VERSION=$(uname -r)
    local KERNEL_PKG
    # Extrae el nombre base del kernel (ej. 'linux', 'linux-zen', 'linux-lts')
    KERNEL_PKG=$(pacman -Qo "/boot/vmlinuz-${KERNEL_VERSION%%-*}" | awk '{print $1}')
    if [[ -n "$KERNEL_PKG" && ! -d "/usr/lib/modules/${KERNEL_VERSION}/build" ]]; then
        log_info "Instalando headers para el kernel actual (${KERNEL_PKG}-headers)..."
        sudo pacman -S --needed --noconfirm "${KERNEL_PKG}-headers" || log_warning "No se pudieron instalar los headers del kernel."
    fi

    # Instalar dependencias de Pacman
    start_spinner "Instalando dependencias de Pacman..."
    sudo pacman -S --needed --noconfirm "${PACMAN_DEPS[@]}" &> /dev/null
    stop_spinner $? "Dependencias de Pacman instaladas."

    # Instalar dependencias de AUR
    start_spinner "Instalando dependencias de AUR..."
    if aur_install_packages "${AUR_DEPS[@]}"; then
        stop_spinner 0 "Dependencias de AUR instaladas."
    else
        stop_spinner 1 "Falló la instalación de dependencias de AUR."
        log_error "No se pudieron instalar paquetes como 'intel-compute-runtime' desde AUR."
        return 1
    fi

    # --- 3. Configuración del Entorno ---
    log_info "Configurando el entorno para OpenCL..."

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

    # --- 4. Extracción e Instalación de DaVinci Resolve ---
    start_spinner "Extrayendo DaVinci Resolve del ZIP (puede tardar)..."
    local WORKDIR
    WORKDIR="$(mktemp -d -p "${DOWNLOADS_DIR}" .resolve-extract-XXXXXXXX)"
    trap 'rm -rf "${WORKDIR}"' EXIT
    unzip -q "${RESOLVE_ZIP}" -d "${WORKDIR}"
    stop_spinner $? "ZIP extraído."

    local RUN_FILE
    RUN_FILE="$(find "${WORKDIR}" -maxdepth 2 -type f -name 'DaVinci_Resolve_*_Linux.run' -print -quit)"
    if [[ -z "${RUN_FILE}" ]]; then
        log_error "No se encontró el archivo .run dentro del ZIP."
        return 1
    fi
    chmod +x "${RUN_FILE}"
    
    start_spinner "Extrayendo AppImage..."
    local EX_DIR
    EX_DIR="$(dirname "${RUN_FILE}")"
    ( cd "${EX_DIR}" && "./$(basename "${RUN_FILE}")" --appimage-extract >/dev/null )
    stop_spinner $? "AppImage extraído."
    
    local APPDIR="${EX_DIR}/squashfs-root"
    if [[ ! -d "${APPDIR}" ]]; then
        log_error "No se extrajo correctamente la carpeta squashfs-root."
        return 1
    fi
    
    chmod -R u+rwX,go+rX,go-w "${APPDIR}"
    if [[ ! -x "${APPDIR}/bin/resolve" ]]; then
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
    
    # --- 5. Aplicar Patches y Copiar Archivos ---
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
        RPATH_ABS+="${INSTALL_DIR}/${p}:"
    done
    RPATH_ABS+="\$ORIGIN"
    
    # Usar barra de progreso para patchelf
    if ! command_exists patchelf; then
        log_warning "El comando 'patchelf' no está instalado. Es necesario para ajustar las librerías."
        start_spinner "Instalando patchelf..."
        sudo pacman -S --noconfirm --needed patchelf &> /dev/null
        stop_spinner $? "patchelf instalado."
    fi

    if command_exists patchelf; then
        local files_to_patch
        files_to_patch=$(find "${APPDIR}" -type f -exec file {} + | grep "ELF" | cut -d: -f1)
        local total_files=$(echo "$files_to_patch" | wc -l)
        local current_file=0
        local last_percent=-1

        echo "$files_to_patch" | while read -r file; do
            current_file=$((current_file + 1))
            sudo patchelf --set-rpath "${RPATH_ABS}" "$file" &>/dev/null
            last_percent=$(show_progress "$total_files" "$current_file" "Aplicando RPATH..." "$last_percent")
        done
        log_success "RPATH aplicado a $total_files archivos."
    fi
    
    start_spinner "Copiando archivos a /opt/resolve..."
    sudo rm -rf "${INSTALL_DIR}"
    sudo mkdir -p "${INSTALL_DIR}"
    sudo rsync -a --delete "${APPDIR}/" "${INSTALL_DIR}/"
    stop_spinner $? "Archivos copiados a ${INSTALL_DIR}."

    sudo mkdir -p "${INSTALL_DIR}/.license"
    
    # Enlazar libcrypt legado si es necesario
    sudo ldconfig || true
    if [[ -e /usr/lib/libcrypt.so.1 ]]; then
        sudo ln -sf /usr/lib/libcrypt.so.1 "${INSTALL_DIR}/libs/libcrypt.so.1"
    fi
    
    # --- 6. Crear Wrapper y Acceso Directo ---
    # Crear wrapper + acceso en escritorio
    log_info "Creando wrapper y acceso para DaVinci Resolve..."
    cat << EOF | sudo tee "${WRAPPER_PATH}" >/dev/null
#!/usr/bin/env bash
set -euo pipefail
find /tmp -maxdepth 1 -type f -name "qtsingleapp-DaVinci*lockfile" -delete 2>/dev/null || true
export QT_QPA_PLATFORM=xcb
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export OCL_ICD_VENDORS=/etc/OpenCL/vendors
exec ${INSTALL_DIR}/bin/resolve "\$@"
EOF
    
    sudo chmod +x "${WRAPPER_PATH}"
    
    mkdir -p "${HOME}/.local/share/applications"
    cat > "${HOME}/.local/share/applications/davinci-resolve-wrapper.desktop" << EOF
[Desktop Entry]
Type=Application
Name=DaVinci Resolve (Intel)
Comment=DaVinci Resolve usando OpenCL de Intel
Exec=${WRAPPER_PATH} %U
TryExec=${WRAPPER_PATH}
Terminal=false
Icon=davinci-resolve
Categories=AudioVideo;Video;Graphics;
StartupWMClass=resolve
X-GNOME-UsesNotifications=true
EOF
    
    update-desktop-database "${HOME}/.local/share/applications" >/dev/null 2>&1 || true
    sudo gtk-update-icon-cache -f /usr/share/icons/hicolor >/dev/null 2>&1 || true

    log_success "DaVinci Resolve (Intel Edition) instalado en ${INSTALL_DIR}"
    log_info "Usa '${WRAPPER_PATH##*/}' para lanzar la aplicación"
    log_info "Para verificar OpenCL: clinfo | grep -E 'Platform Name|Device Name'"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_davinci_resolve "$@"
fi
