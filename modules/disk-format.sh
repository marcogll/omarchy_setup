#!/usr/bin/env bash
set -euo pipefail
# ===============================================================
# disk-format.sh - Soporte para FAT32 / exFAT / NTFS / ext4
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

run_module_main() {
    log_step "Habilitar sistemas de archivos (FAT32 / exFAT / NTFS / ext4)"

    local pkgs=(
        dosfstools
        exfatprogs
        ntfs-3g
        e2fsprogs
        gparted
        gnome-disk-utility
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

    log_success "Soporte de sistemas de archivos habilitado."
    echo ""
    log_info "Formatea manualmente con las utilidades instaladas:"
    echo "  • FAT32 : sudo mkfs.fat -F32 /dev/sdXn"
    echo "  • exFAT : sudo mkfs.exfat /dev/sdXn"
    echo "  • NTFS  : sudo mkfs.ntfs -f /dev/sdXn"
    echo "  • ext4  : sudo mkfs.ext4 -F /dev/sdXn"
    log_info "Alternativamente puedes usar GParted o GNOME Disks para un asistente gráfico."
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_module_main "$@"
fi
