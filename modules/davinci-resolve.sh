#!/usr/bin/env bash
# ===============================================================
# davinci-resolve.sh - Instalador de DaVinci Resolve (Intel Edition)
# ===============================================================
#
# Este módulo automatiza la instalación y configuración de DaVinci
# Resolve en Arch Linux, con un enfoque específico en sistemas que
# utilizan GPUs de Intel. El proceso es complejo y requiere la
# instalación de múltiples dependencias, la configuración de
# librerías y la creación de un script "wrapper" para asegurar que
# la aplicación se ejecute con el entorno correcto.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# --- Definición de Dependencias ---
# Paquetes de los repositorios oficiales de Arch necesarios para Resolve.
PACMAN_DEPS=(
    # Herramientas básicas para la instalación.
    unzip patchelf libarchive xdg-user-dirs desktop-file-utils file rsync
    # Dependencias directas de Resolve.
    libpng libtiff libcurl ocl-icd libxcrypt-compat ffmpeg glu gtk2 fuse2
    # Dependencias de Qt5, usadas por la interfaz de Resolve.
    qt5-base qt5-svg qt5-x11extras
    # Drivers y herramientas de Intel para aceleración por hardware.
    intel-media-driver libva-utils libvdpau-va-gl clinfo
)

# Paquetes del AUR.
AUR_DEPS=(
    # Runtime de OpenCL para GPUs de Intel. Esencial para el renderizado.
    "intel-compute-runtime"
)

# --- Definición de Rutas ---
DOWNLOADS_DIR="${HOME}/Downloads"
INSTALL_DIR="/opt/resolve"
WRAPPER_PATH="/usr/local/bin/resolve-intel"

# ---------------------------------------------------------------
# show_progress(total_items, current_item, message, last_percent)
# ---------------------------------------------------------------
# Muestra una barra de progreso simple en la terminal.
# Está diseñada para ser llamada en un bucle y actualiza la línea
# solo cuando el porcentaje cambia para ser más eficiente.
#
# Parámetros:
#   $1 - Número total de ítems a procesar.
#   $2 - Ítem actual que se está procesando.
#   $3 - Mensaje a mostrar junto a la barra.
#   $4 - (Opcional) El último porcentaje mostrado.
# ---------------------------------------------------------------
show_progress() {
    local total=$1
    local current=$2
    local msg=$3
    local last_percent=${4:-"-1"}
    local percent=$((current * 100 / total))
    
    # Solo actualiza si el porcentaje ha cambiado.
    if [[ "$percent" -gt "$last_percent" ]]; then
        local completed_len=$((percent / 2))
        local bar=""
        for ((i=0; i<completed_len; i++)); do bar+="="; done
        local empty_len=$((50 - completed_len))
        for ((i=0; i<empty_len; i++)); do bar+=" "; done
        
        echo -ne "\r\033[K"
        echo -ne "  ${GREEN}[${bar}]${NC} ${percent}% - ${msg} (${current}/${total})"
    fi

    if [[ $current -eq $total ]]; then
        echo "" # Nueva línea al finalizar.
    fi
    echo "$percent" # Devuelve el porcentaje actual.
}

# ---------------------------------------------------------------
# install_davinci_resolve()
# ---------------------------------------------------------------
# Función principal que orquesta todo el proceso de instalación.
# ---------------------------------------------------------------
install_davinci_resolve() {
    log_step "Iniciando instalación de DaVinci Resolve (Intel Edition)"

    # --- 1. Verificaciones Previas ---
    log_info "Realizando verificaciones previas..."

    # Comprueba que el archivo ZIP de DaVinci Resolve exista en ~/Downloads.
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

    # Verifica que haya suficiente espacio en disco.
    local NEEDED_GB=10
    local FREE_KB
    FREE_KB=$(df --output=avail -k "${DOWNLOADS_DIR}" | tail -n1)
    local FREE_GB=$((FREE_KB / 1024 / 1024))
    if (( FREE_GB < NEEDED_GB )); then
        log_error "No hay suficiente espacio libre en ${DOWNLOADS_DIR}: ${FREE_GB}GiB disponibles, se necesitan ${NEEDED_GB}GiB."
        return 1
    fi

    # Advierte si hay drivers de NVIDIA, ya que pueden causar conflictos.
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

    # Instala los headers del kernel si son necesarios.
    local KERNEL_VERSION
    KERNEL_VERSION=$(uname -r)
    local KERNEL_PKG
    KERNEL_PKG=$(pacman -Qo "/boot/vmlinuz-${KERNEL_VERSION%%-*}" | awk '{print $1}')
    if [[ -n "$KERNEL_PKG" && ! -d "/usr/lib/modules/${KERNEL_VERSION}/build" ]]; then
        log_info "Instalando headers para el kernel actual (${KERNEL_PKG}-headers)..."
        sudo pacman -S --needed --noconfirm "${KERNEL_PKG}-headers" || log_warning "No se pudieron instalar los headers del kernel."
    fi

    # Instala dependencias desde los repositorios oficiales.
    start_spinner "Instalando dependencias de Pacman..."
    sudo pacman -S --needed --noconfirm "${PACMAN_DEPS[@]}" &> /dev/null
    stop_spinner $? "Dependencias de Pacman instaladas."

    # Instala dependencias desde AUR.
    start_spinner "Instalando dependencias de AUR..."
    if aur_install_packages "${AUR_DEPS[@]}"; then
        stop_spinner 0 "Dependencias de AUR instaladas."
    else
        stop_spinner 1 "Falló la instalación de dependencias de AUR."
        return 1
    fi

    # --- 3. Configuración del Entorno ---
    log_info "Configurando el entorno para OpenCL..."

    # Asegura que el fichero de configuración de OpenCL para Intel exista.
    if [[ ! -f /etc/OpenCL/vendors/intel.icd ]]; then
        log_info "Creando vendor file de OpenCL para Intel..."
        sudo mkdir -p /etc/OpenCL/vendors
        echo "/usr/lib/intel-opencl/libigdrcl.so" | sudo tee /etc/OpenCL/vendors/intel.icd >/dev/null
    fi

    # Algunas aplicaciones antiguas esperan los certificados en /etc/pki/tls.
    if [[ ! -e /etc/pki/tls ]]; then
        log_info "Creando enlace /etc/pki/tls → /etc/ssl"
        sudo mkdir -p /etc/pki
        sudo ln -sf /etc/ssl /etc/pki/tls
    fi

    sudo ldconfig || true

    # Verifica que OpenCL y VA-API estén funcionando.
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

    # El ZIP contiene un archivo .run, que a su vez contiene un AppImage.
    local RUN_FILE
    RUN_FILE="$(find "${WORKDIR}" -maxdepth 2 -type f -name 'DaVinci_Resolve_*_Linux.run' -print -quit)"
    if [[ -z "${RUN_FILE}" ]]; then log_error "No se encontró el archivo .run dentro del ZIP."; return 1; fi
    chmod +x "${RUN_FILE}"
    
    start_spinner "Extrayendo AppImage..."
    local EX_DIR
    EX_DIR="$(dirname "${RUN_FILE}")"
    ( cd "${EX_DIR}" && "./$(basename "${RUN_FILE}")" --appimage-extract >/dev/null )
    stop_spinner $? "AppImage extraído."
    
    local APPDIR="${EX_DIR}/squashfs-root"
    if [[ ! -d "${APPDIR}" ]]; then log_error "No se extrajo correctamente la carpeta squashfs-root."; return 1; fi
    
    chmod -R u+rwX,go+rX,go-w "${APPDIR}"
    if [[ ! -x "${APPDIR}/bin/resolve" ]]; then log_error "El binario resolve no existe o está vacío."; return 1; fi
    
    # Resolve incluye sus propias versiones de librerías que pueden ser incompatibles.
    # Se reemplazan por enlaces a las versiones del sistema.
    log_info "Ajustando bibliotecas glib/gio/gmodule para usar las del sistema..."
    pushd "${APPDIR}" >/dev/null
    rm -f libs/libglib-2.0.so.0 libs/libgio-2.0.so.0 libs/libgmodule-2.0.so.0 || true
    ln -sf /usr/lib/libglib-2.0.so.0 libs/libglib-2.0.so.0
    ln -sf /usr/lib/libgio-2.0.so.0 libs/libgio-2.0.so.0
    ln -sf /usr/lib/libgmodule-2.0.so.0 libs/libgmodule-2.0.so.0
    popd >/dev/null
    
    # --- 5. Aplicar Patches y Copiar Archivos ---
    log_info "Aplicando RPATH con patchelf (esto puede tardar)..."
    # Se modifica el RPATH de los binarios de Resolve para que busquen las librerías
    # dentro de su propio directorio de instalación (/opt/resolve).
    RPATH_DIRS=("libs" "libs/plugins/sqldrivers" "libs/plugins/xcbglintegrations" "libs/plugins/imageformats" "libs/plugins/platforms" "libs/Fusion" "plugins" "bin")
    RPATH_ABS=""
    for p in "${RPATH_DIRS[@]}"; do
        RPATH_ABS+="${INSTALL_DIR}/${p}:"
    done
    RPATH_ABS+="\$ORIGIN"
    
    if ! command_exists patchelf; then
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
    
    # Copia los archivos de la aplicación a /opt/resolve.
    start_spinner "Copiando archivos a /opt/resolve..."
    sudo rm -rf "${INSTALL_DIR}"
    sudo mkdir -p "${INSTALL_DIR}"
    sudo rsync -a --delete "${APPDIR}/" "${INSTALL_DIR}/"
    stop_spinner $? "Archivos copiados a ${INSTALL_DIR}."

    sudo mkdir -p "${INSTALL_DIR}/.license"
    
    # Enlaza libcrypt.so.1 si es necesario.
    sudo ldconfig || true
    if [[ -e /usr/lib/libcrypt.so.1 ]]; then
        sudo ln -sf /usr/lib/libcrypt.so.1 "${INSTALL_DIR}/libs/libcrypt.so.1"
    fi
    
    # --- 6. Crear Wrapper y Acceso Directo ---
    log_info "Creando wrapper y acceso para DaVinci Resolve..."
    # Se crea un script que establece variables de entorno necesarias antes de ejecutar Resolve.
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
    
    # Crea un archivo .desktop para que la aplicación aparezca en el menú de aplicaciones.
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
    
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_davinci_resolve "$@"
fi
