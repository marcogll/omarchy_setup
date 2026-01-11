#!/usr/bin/env bash
# ===============================================================
# ssh-keyring.sh - Sincronizar claves SSH con gcr-ssh-agent
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

_derive_fingerprint() {
    local key_path="$1"
    local pub_path="${key_path}.pub"
    local fingerprint=""

    if [[ -f "$pub_path" ]]; then
        fingerprint="$(ssh-keygen -lf "$pub_path" 2>/dev/null | awk '{print $2}')"
    else
        fingerprint="$(ssh-keygen -lf <(ssh-keygen -y -f "$key_path" 2>/dev/null) 2>/dev/null | awk '{print $2}')"
    fi
    echo "$fingerprint"
}

sync_ssh_keyring() {
    log_step "Sincronizar claves SSH con gcr-ssh-agent"

    if ! command_exists ssh-add; then
        log_error "ssh-add no está disponible (openssh). Instala el módulo de aplicaciones antes."
        return 1
    fi

    mkdir -p "${HOME}/.config/environment.d"
    cat <<'EOF' > "${HOME}/.config/environment.d/10-gnome-keyring.conf"
SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
EOF

    log_info "Verificando servicio gcr-ssh-agent.socket..."

    if ! systemctl --user is-enabled gcr-ssh-agent.socket &>/dev/null; then
        log_info "Habilitando gcr-ssh-agent.socket..."
        systemctl --user enable gcr-ssh-agent.socket
    fi

    if ! systemctl --user is-active gcr-ssh-agent.socket &>/dev/null; then
        log_info "Iniciando gcr-ssh-agent.socket..."
        systemctl --user start gcr-ssh-agent.socket
    fi

    log_info "Buscando el socket del agente GCR SSH..."

    local target_uid
    target_uid=$(stat -c '%u' "$HOME")

    local keyring_socket="/run/user/${target_uid}/gcr/ssh"

    if [[ ! -S "$keyring_socket" ]]; then
        log_error "No se encontró el socket de gcr-ssh-agent en la ruta esperada: ${keyring_socket}"
        log_warning "Intentando activar el socket solicitando el servicio..."
        if SSH_AUTH_SOCK="$keyring_socket" ssh-add -l &>/dev/null; then
            log_success "Socket de gcr-ssh-agent activado correctamente."
        else
            log_error "No se pudo activar el socket. Revisa la configuración de gcr-ssh-agent."
            return 1
        fi
    fi

    log_success "Socket de gcr-ssh-agent encontrado en: ${keyring_socket}"
    export SSH_AUTH_SOCK="$keyring_socket"

    local ssh_dir="${HOME}/.ssh"
    if [[ ! -d "$ssh_dir" ]]; then
        log_warning "No existe el directorio ${ssh_dir}. No hay claves para agregar."
        return 0
    fi

    mapfile -t ssh_private_keys < <(
        find "$ssh_dir" -maxdepth 1 -type f -perm -u=r \
            ! -name "*.pub" \
            ! -name "*-cert.pub" \
            ! -name "known_hosts" \
            ! -name "known_hosts.*" \
            ! -name "authorized_keys" \
            ! -name "config" \
            ! -name "*.old" \
            ! -name "agent" \
            ! -name "*.bak" \
            2>/dev/null | sort
    )
    if [[ ${#ssh_private_keys[@]} -eq 0 ]]; then
        log_warning "No se encontraron claves privadas SSH en ${ssh_dir}."
        return 0
    fi

    local existing_fingerprints=""
    if output=$(SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add -l 2>/dev/null); then
        existing_fingerprints="$(awk '{print $2}' <<<"$output")"
    else
        existing_fingerprints=""
    fi

    local added=0
    for key_path in "${ssh_private_keys[@]}"; do
        local fingerprint
        fingerprint="$(_derive_fingerprint "$key_path")"
        if [[ -z "$fingerprint" ]] && ! ssh-keygen -y -f "$key_path" >/dev/null 2>&1; then
            log_warning "El archivo $(basename "$key_path") no parece una clave privada válida. Se omite."
            continue
        fi

        if [[ -n "$fingerprint" ]] && grep -Fq "$fingerprint" <<<"$existing_fingerprints"; then
            log_info "Clave $(basename "$key_path") ya está registrada en el keyring."
            continue
        fi

        log_info "Añadiendo clave $(basename "$key_path") al keyring..."
        if SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add "$key_path"; then
            log_success "Clave $(basename "$key_path") añadida correctamente."
            added=$((added + 1))
            if [[ -n "$fingerprint" ]]; then
                existing_fingerprints+=$'\n'"$fingerprint"
            fi
        else
            log_warning "No se pudo añadir la clave $(basename "$key_path")."
        fi
    done

    if [[ $added -gt 0 ]]; then
        log_success "Claves SSH sincronizadas con gcr-ssh-agent."
    else
        log_info "No se añadieron nuevas claves SSH."
    fi

    log_info "Para verificar, ejecuta: ssh-add -l"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    sync_ssh_keyring "$@"
fi
