#!/usr/bin/env bash
set -euo pipefail
# Módulo: Formateo de discos (FAT32 / exFAT / NTFS / ext4)

format_disk() {
    log_step "Módulo: Formateo de discos (FAT32 / exFAT / NTFS / ext4)"

    # Dependencias
    local PKGS=(dosfstools exfatprogs ntfs-3g e2fsprogs)
    local missing=()
    for p in "${PKGS[@]}"; do
        if ! pacman -Qi "$p" &>/dev/null; then
            missing+=("$p")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_info "Instalando dependencias: ${missing[*]}"
        sudo pacman -Sy --needed --noconfirm "${missing[@]}" || {
            log_error "No se pudieron instalar: ${missing[*]}"
            return 1
        }
    fi

    echo
    lsblk -dpno NAME,SIZE,MODEL | sed '/loop/d' | nl -w2 -s'. '
    echo
    read -rp "Introduce el dispositivo a formatear (ej. /dev/sdb o /dev/sdb1): " DEVICE
    if [[ ! -b "$DEVICE" ]]; then
        log_error "Dispositivo no válido: $DEVICE"
        return 1
    fi

    # Desmontar si está montado
    local mp
    mp=$(lsblk -no MOUNTPOINT "$DEVICE" | tr -d '[:space:]')
    if [[ -n "$mp" ]]; then
        log_warning "El dispositivo está montado en: $mp. Intentando desmontar..."
        sudo umount "${DEVICE}"* || {
            log_error "No se pudo desmontar $DEVICE"
            return 1
        }
    fi

    echo
    echo "Tipos disponibles:"
    echo "  1) FAT32"
    echo "  2) exFAT"
    echo "  3) NTFS"
    echo "  4) ext4"
    read -rp "Selecciona tipo [1-4]: " ft
    case "$ft" in
        1) FS="fat32"; CMD_BASE="sudo mkfs.fat -F32" ;;
        2) FS="exfat"; CMD_BASE="sudo mkfs.exfat" ;;
        3) FS="ntfs"; CMD_BASE="sudo mkfs.ntfs -f" ;;
        4) FS="ext4"; CMD_BASE="sudo mkfs.ext4 -F" ;;
        *) log_error "Opción inválida"; return 1 ;;
    esac

    read -rp "Etiqueta (opcional): " LABEL
    echo
    echo -e "ADVERTENCIA: Se eliminarán todos los datos en ${DEVICE}."
    read -rp "Escribe 'SI' para confirmar: " confirm
    if [[ "${confirm}" != "SI" ]]; then
        log_info "Operación cancelada"
        return 0
    fi

    # Añadir etiqueta si se proporcionó
    if [[ -n "${LABEL}" ]]; then
        case "$FS" in
            fat32) CMD="${CMD_BASE} -n ${LABEL} ${DEVICE}" ;;
            exfat) CMD="${CMD_BASE} -n ${LABEL} ${DEVICE}" ;;
            ntfs)  CMD="${CMD_BASE} -L ${LABEL} ${DEVICE}" ;;
            ext4)  CMD="${CMD_BASE} -L ${LABEL} ${DEVICE}" ;;
        esac
    else
        CMD="${CMD_BASE} ${DEVICE}"
    fi

    log_info "Ejecutando: ${CMD}"
    if eval "${CMD}"; then
        log_success "Formateo completado: ${DEVICE} → ${FS}"
        return 0
    else
        log_error "Fallo al formatear ${DEVICE}"
        return 1
    fi
}

export -f format_disk