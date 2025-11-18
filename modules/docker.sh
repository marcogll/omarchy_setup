#!/usr/bin/env bash
# ===============================================================
# docker.sh - Configuración de Docker y Portainer
# ===============================================================
#
# Este módulo se encarga de la instalación y configuración de Docker
# y, opcionalmente, de Portainer, una interfaz web para gestionar
# contenedores.
#
# Funciones principales:
#   - Instala Docker y Docker Compose desde los repositorios oficiales.
#   - Habilita e inicia los servicios de Docker.
#   - Agrega el usuario actual al grupo `docker` para permitir la
#     ejecución de comandos de Docker sin `sudo`.
#   - Ofrece la opción de instalar Portainer.
#
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# ---------------------------------------------------------------
# install_docker()
# ---------------------------------------------------------------
# Orquesta la instalación y configuración de Docker y Portainer.
# ---------------------------------------------------------------
install_docker() {
    log_step "Configuración de Docker y Portainer"
    
    # --- 1. Instalación de Docker ---
    log_info "Instalando Docker y Docker Compose..."
    if ! sudo pacman -S --noconfirm --needed docker docker-compose; then
        log_error "No se pudo instalar Docker. Abortando."
        return 1
    fi
    
    # --- 2. Configuración del Servicio de Docker ---
    log_info "Habilitando e iniciando los servicios de Docker..."
    # Habilita los servicios para que se inicien automáticamente con el sistema.
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    # Inicia los servicios en la sesión actual.
    sudo systemctl start docker.service
    
    # --- 3. Configuración de Permisos de Usuario ---
    # Agrega el usuario actual al grupo `docker` para evitar tener que usar `sudo`.
    if ! groups "$USER" | grep -q docker; then
        log_info "Agregando al usuario '$USER' al grupo 'docker'..."
        if ! sudo usermod -aG docker "$USER"; then
            log_error "No se pudo agregar el usuario al grupo 'docker'."
            # No es un error fatal, así que solo se muestra una advertencia.
        else
            log_warning "Para que los cambios de grupo surtan efecto, debes cerrar sesión y volver a iniciarla."
        fi
    fi
    
    # --- 4. Instalación Opcional de Portainer ---
    echo ""
    read -p "¿Deseas instalar Portainer (interfaz web para Docker)? [S/n]: " confirm_portainer
    if [[ ! "${confirm_portainer}" =~ ^[Nn]$ ]]; then
        log_info "Instalando Portainer..."
        
        # Comprueba si el contenedor de Portainer ya existe para evitar errores.
        if sudo docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
            log_info "El contenedor de Portainer ya existe. Se detendrá y eliminará para volver a crearlo."
            sudo docker stop portainer >/dev/null 2>&1 || true
            sudo docker rm portainer >/dev/null 2>&1 || true
        fi
        
        # Crea un volumen de Docker para persistir los datos de Portainer.
        sudo docker volume create portainer_data >/dev/null 2>&1 || true
        
        # Ejecuta el contenedor de Portainer.
        if sudo docker run -d -p 8000:8000 -p 9443:9443 \
            --name portainer \
            --restart=always \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            portainer/portainer-ce:latest; then
            log_success "Portainer se ha instalado y está corriendo."
            log_info "Puedes acceder a la interfaz web en: https://localhost:9443"
        else
            log_error "No se pudo instalar Portainer."
            # No se devuelve un error aquí porque la instalación de Docker fue exitosa.
        fi
    else
        log_info "Se omitió la instalación de Portainer."
    fi
    
    log_success "La configuración de Docker ha finalizado."
    return 0
}

# Ejecutar si se llama directamente al script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker "$@"
fi
