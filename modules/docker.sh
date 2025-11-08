#!/usr/bin/env bash
# ===============================================================
# docker.sh - Configuración de Docker y Portainer
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_docker() {
    log_step "Configuración de Docker y Portainer"
    
    # Instalar Docker
    log_info "Instalando Docker y Docker Compose..."
    sudo pacman -S --noconfirm --needed \
        docker docker-compose || {
        log_error "Error al instalar Docker"
        return 1
    }
    
    # Habilitar y iniciar Docker
    log_info "Habilitando servicio de Docker..."
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker.service
    
    # Agregar usuario al grupo docker (si no está ya)
    if ! groups "$USER" | grep -q docker; then
        log_info "Agregando usuario al grupo docker..."
        sudo usermod -aG docker "$USER"
        log_warning "Necesitarás cerrar sesión y volver a iniciar para usar Docker sin sudo"
    fi
    
    # Instalar Portainer
    log_info "Configurando Portainer..."
    
    # Verificar si Portainer ya está corriendo
    if sudo docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
        log_info "Portainer ya existe. Reiniciando contenedor..."
        sudo docker stop portainer 2>/dev/null || true
        sudo docker rm portainer 2>/dev/null || true
    fi
    
    # Crear volumen y contenedor de Portainer
    sudo docker volume create portainer_data 2>/dev/null || true
    
    if sudo docker run -d -p 8000:8000 -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest; then
        log_success "Portainer instalado y ejecutándose"
        log_info "Accede a Portainer en: https://localhost:9443"
    else
        log_error "Error al instalar Portainer"
        return 1
    fi
    
    log_success "Docker y Portainer configurados correctamente"
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker "$@"
fi

