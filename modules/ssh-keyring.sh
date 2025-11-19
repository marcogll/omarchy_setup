#!/usr/bin/env bash
# ===============================================================
# ssh-keyring.sh - Sincronizar claves SSH con GNOME Keyring
# ===============================================================
#
# Este módulo se encarga de encontrar todas las claves SSH privadas
# en el directorio ~/.ssh del usuario y añadirlas al agente de
# GNOME Keyring. Esto permite que las claves estén disponibles
# para autenticación sin necesidad de introducir la passphrase
# cada vez, ya que el keyring las gestiona de forma segura.
#
# Funciones principales:
#   - Inicia el daemon de GNOME Keyring con los componentes de
#     SSH y secretos.
#   - Configura la variable de entorno SSH_AUTH_SOCK para que
#     apunten al socket del keyring.
#   - Detecta claves ya cargadas para evitar añadirlas de nuevo.
#
# Dependencias: gnome-keyring, openssh.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# ---------------------------------------------------------------
# _derive_fingerprint(key_path)
# ---------------------------------------------------------------
# Obtiene el "fingerprint" (huella digital) de una clave SSH.
# Esto se usa para identificar de forma única cada clave y así
# evitar añadir al agente claves que ya han sido cargadas.
#
# Parámetros:
#   $1 - Ruta a la clave SSH privada.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# sync_ssh_keyring()
# ---------------------------------------------------------------
# Función principal que orquesta la sincronización de claves.
# ---------------------------------------------------------------
sync_ssh_keyring() {
    log_step "Sincronizar claves SSH con GNOME Keyring"

    # --- 1. Verificación de Dependencias ---
    if ! command_exists gnome-keyring-daemon; then
        log_error "El comando 'gnome-keyring-daemon' no está instalado. Ejecuta primero el módulo de aplicaciones."
        return 1
    fi
    if ! command_exists ssh-add; then
        log_error "El comando 'ssh-add' (de openssh) no está disponible. Instala primero el módulo de aplicaciones."
        return 1
    fi

    # --- 2. Configuración del Entorno de GNOME Keyring ---
    # Asegura que la variable SSH_AUTH_SOCK apunte al socket correcto.
    mkdir -p "${HOME}/.config/environment.d"
    cat <<'EOF' > "${HOME}/.config/environment.d/10-gnome-keyring.conf"
SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
EOF

    # Inicia el daemon de GNOME Keyring si no está ya en ejecución.
    local keyring_eval=""
    if keyring_eval="$(gnome-keyring-daemon --start --components=ssh,secrets 2>/dev/null)"; then
        eval "$keyring_eval"
        log_success "El daemon de GNOME Keyring se ha iniciado."
    else
        log_info "El daemon de GNOME Keyring ya estaba en ejecución."
    fi

    # Exporta la variable SSH_AUTH_SOCK para la sesión actual.
    local keyring_socket="${SSH_AUTH_SOCK:-/run/user/$UID/keyring/ssh}"
    if [[ ! -S "$keyring_socket" ]]; then
        log_error "No se encontró el socket de GNOME Keyring. El componente SSH podría no estar activo."
        return 1
    fi
    export SSH_AUTH_SOCK="$keyring_socket"

    # --- 3. Búsqueda y Filtrado de Claves SSH ---
    local ssh_dir="${HOME}/.ssh"
    if [[ ! -d "$ssh_dir" ]]; then
        log_warning "El directorio ${ssh_dir} no existe. No hay claves para agregar."
        return 0
    fi

    # Encuentra todas las claves privadas en ~/.ssh, excluyendo ficheros públicos y de configuración.
    mapfile -t ssh_private_keys < <(
        find "$ssh_dir" -maxdepth 1 -type f -perm -u=r \
            ! -name "*.pub" ! -name "*-cert.pub" ! -name "known_hosts" \
            ! -name "known_hosts.*" ! -name "authorized_keys" ! -name "config" \
            ! -name "*.old" ! -name "agent" ! -name "*.bak" 2>/dev/null | sort
    )
    if [[ ${#ssh_private_keys[@]} -eq 0 ]]; then
        log_info "No se encontraron claves privadas en ${ssh_dir}."
        return 0
    fi

    # --- 4. Sincronización de Claves ---
    # Obtiene los fingerprints de las claves que ya están cargadas en el agente.
    local existing_fingerprints=""
    if output=$(SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add -l 2>/dev/null); then
        existing_fingerprints="$(awk '{print $2}' <<<"$output")"
    fi

    local added=0
    for key_path in "${ssh_private_keys[@]}"; do
        local fingerprint
        fingerprint="$(_derive_fingerprint "$key_path")"
        if [[ -z "$fingerprint" ]] && ! ssh-keygen -y -f "$key_path" >/dev/null 2>&1; then
            log_warning "El archivo $(basename "$key_path") no parece una clave privada válida y será omitido."
            continue
        fi

        # Si la clave ya está en el agente, la omite.
        if [[ -n "$fingerprint" ]] && grep -Fq "$fingerprint" <<<"$existing_fingerprints"; then
            log_info "La clave $(basename "$key_path") ya está registrada en el keyring."
            continue
        fi

        # Intenta añadir la clave. Se pedirá la passphrase si está protegida.
        log_info "Añadiendo la clave $(basename "$key_path") al keyring..."
        if SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add "$key_path"; then
            log_success "La clave $(basename "$key_path") se ha añadido correctamente."
            added=$((added + 1))
            if [[ -n "$fingerprint" ]]; then
                existing_fingerprints+=$'\n'"$fingerprint"
            fi
        else
            log_warning "No se pudo añadir la clave $(basename "$key_path"). Es posible que la passphrase sea incorrecta."
        fi
    done

    if [[ $added -gt 0 ]]; then
        log_success "Se han sincronizado ${added} claves SSH con GNOME Keyring."
    else
        log_info "Todas las claves SSH ya estaban sincronizadas. No se añadieron nuevas claves."
    fi

    log_info "Para verificar las claves cargadas, puedes ejecutar: ssh-add -l"
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    sync_ssh_keyring "$@"
fi
