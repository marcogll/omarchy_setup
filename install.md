# 🌀 Guía de Instalación - Omarchy Setup

Este script modular automatiza la configuración de Arch Linux, instalando aplicaciones esenciales, configurando el entorno gráfico (Hyprland), y optimizando el sistema para desarrollo y multimedia.

## 🚀 Requisitos Previos

1.  **Sistema Operativo:** Arch Linux (instalación base).
2.  **Usuario:** Un usuario con permisos de `sudo`.
3.  **Conexión a Internet:** Necesaria para descargar paquetes.
4.  **Git:** Para clonar el repositorio (si no lo tienes, instálalo con `sudo pacman -S git`).

## 📥 Instalación

Clona el repositorio y ejecuta el script principal:

```bash
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
chmod +x omarchy-setup.sh
./omarchy-setup.sh
```

## 🛠️ Uso del Script

Al ejecutar `./omarchy-setup.sh`, verás un menú interactivo con las siguientes opciones:

1.  **Instalar Aplicaciones:** Herramientas base, desarrollo (Node, Python), multimedia (VLC, OBS), y drivers Intel.
2.  **Configurar Zsh:** Shell Zsh con Oh My Zsh, Oh My Posh y plugins.
3.  **Docker:** Instala Docker, Docker Compose y Portainer.
4.  **ZeroTier:** Configura la VPN P2P ZeroTier.
5.  **Impresoras:** Configura CUPS y drivers (especialmente Epson).
6.  **Cursor:** Instala el tema de cursor Bibata Modern Ice.
7.  **Iconos:** Gestor de temas de iconos (Tela, Papirus, Candy).
    *   **K:** Sincronizar claves SSH con GNOME Keyring.
    *   **F:** Soporte para formatos de disco (NTFS, exFAT, etc.).
    *   **R:** DaVinci Resolve (Intel) - *Requiere descargar el ZIP manualmente en ~/Downloads*.
    *   **H:** Configuración de Hyprland (copia archivos de configuración).
    *   **T:** Plantillas de documentos.

*   **A) Instalar Todo:** Ejecuta la mayoría de los módulos automáticamente (excluye DaVinci Resolve).

## 📝 Notas Importantes

*   **Reiniciar Sesión:** Muchos cambios (Docker, grupos de usuario, variables de entorno) requieren cerrar sesión y volver a entrar.
*   **Fuentes:** Para que la terminal se vea correctamente, asegúrate de instalar una **Nerd Font** (ej. `ttf-firacode-nerd`) y configurarla en tu terminal.
*   **DaVinci Resolve:** Debes descargar el archivo `DaVinci_Resolve_Studio_*_Linux.zip` (o la versión gratuita) desde la web de Blackmagic y ponerlo en `~/Downloads` antes de ejecutar la opción **R**.

## 📂 Estructura

*   `omarchy-setup.sh`: Script principal.
*   `modules/`: Scripts individuales para cada tarea.
*   `hypr_config/`: Archivos de configuración para Hyprland (se copian a `~/.config/hypr`).
*   `themes/`: Temas personalizados (ej. para Oh My Posh).
