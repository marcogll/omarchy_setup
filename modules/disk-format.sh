#!/usr/bin/env bash
set -euo pipefail
# ===============================================================
# disk-format.sh - Soporte para FAT32 / exFAT / NTFS / ext4
# ===============================================================
#
# Este módulo instala las herramientas necesarias para trabajar
# con los sistemas de archivos más comunes, como FAT32, exFAT,
# NTFS y ext4. Además de las utilidades de línea de comandos,
# también instala herramientas gráficas como GParted y GNOME Disks
# para facilitar la gestión de discos y particiones.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

run_module_main() {
    log_step "Habilitar soporte para sistemas de archivos"

    # --- Definición de Paquetes ---
    # Se instalarán las siguientes herramientas:
    #   - dosfstools: Para crear y verificar sistemas de archivos FAT.
    #   - exfatprogs: Para sistemas de archivos exFAT.
    #   - ntfs-3g:    Driver de código abierto para leer y escribir en NTFS.
    #   - e2fsprogs:  Utilidades para el sistema de archivos ext2/3/4.
    #   - gparted:    Editor de particiones gráfico.
    #   - gnome-disk-utility: Herramienta de discos de GNOME.
    local pkgs=(
        dosfstools exfatprogs ntfs-3g e2fsprogs
        gparted gnome-disk-utility
    )

    local failed=false
    for pkg in "${pkgs[@]}"; do
        if ! check_and_install_pkg "$pkg"; then
            failed=true
        fi
    done

    if [[ "$failed" == true ]]; then
        log_warning "Algunos paquetes no se pudieron instalar. Revisa los mensajes anteriores."
    fi

    log_success "Soporte para sistemas de archivos comunes habilitado."
    echo ""
    log_info "Para formatear discos desde la terminal, puedes usar:"
    echo "  • FAT32 : sudo mkfs.fat -F32 /dev/sdXn"
    echo "  • exFAT : sudo mkfs.exfat /dev/sdXn"
    echo "  • NTFS  : sudo mkfs.ntfs -f /dev/sdXn"
    echo "  • ext4  : sudo mkfs.ext4 -F /dev/sdXn"
    log_info "También puedes usar 'gparted' o 'gnome-disks' para una gestión gráfica."
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
