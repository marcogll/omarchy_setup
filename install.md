# 🌀 Guía de Instalación - Omarchy Setup

Este script modular automatiza la configuración de Arch Linux, vinculando tus **dotfiles personales** e instalando aplicaciones esenciales.

## 🚀 Requisitos Previos

1.  **Sistema Operativo:** Arch Linux (instalación base).
2.  **Repositorio de Dotfiles:** Debes tener clonado tu repositorio personal en `~/Work/code/mg_dotfiles`.
3.  **Git:** Para clonar los repositorios (`sudo pacman -S git`).

## 📥 Instalación

El proceso recomendado consta de dos pasos: preparar tus dotfiles y ejecutar el setup.

### 1. Clonar Dotfiles (Obligatorio para Zsh/Hyprland)

El script buscará la configuración en esta ruta específica:

```bash
mkdir -p ~/Work/code
git clone https://github.com/marcogll/mg_dotfiles.git ~/Work/code/mg_dotfiles
```

### 2. Ejecutar Omarchy Setup

```bash
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
chmod +x omarchy-setup.sh
./omarchy-setup.sh
```

## 🛠️ Uso del Script

Al ejecutar `./omarchy-setup.sh`, verás un menú interactivo:

1.  **Instalar Aplicaciones:** Herramientas base, desarrollo (Node, Python), multimedia y drivers Intel.
2.  **Configurar Zsh:** Enlaza `.zshrc` desde `mg_dotfiles` e instala Oh My Zsh/Posh.
3.  **Docker:** Instala Docker, Docker Compose y Portainer.
4.  **ZeroTier:** Configura la VPN P2P ZeroTier.
5.  **Impresoras:** Configura CUPS y drivers (especialmente Epson).
6.  **Cursor:** Instala el tema de cursor Bibata Modern Ice.
7.  **Iconos:** Gestor de temas de iconos (Tela, Papirus, Candy).
    *   **K:** Sincronizar claves SSH con GNOME Keyring.
    *   **F:** Soporte para formatos de disco (NTFS, exFAT, etc.).
    *   **R:** DaVinci Resolve (Intel) - *Requiere ZIP en ~/Downloads*.
    *   **H:** Configuración de Hyprland (enlaza desde `mg_dotfiles`).
    *   **T:** Plantillas de documentos.

*   **A) Instalar Todo:** Ejecuta la mayoría de los módulos automáticamente (excluye DaVinci Resolve).

## 📝 Notas Importantes

*   **Enlace Simbólico:** Las configuraciones de **Zsh** y **Hyprland** se crean como enlaces simbólicos a `mg_dotfiles`. Cualquier cambio que hagas en tus archivos originales se reflejará inmediatamente.
*   **Fuentes:** Asegúrate de instalar una **Nerd Font** (ej. `ttf-firacode-nerd`) para que los iconos se vean correctamente.
*   **Reiniciar:** Cierra sesión después de instalar para aplicar cambios de grupos (Docker) y variables de entorno.

## 📂 Estructura

*   `omarchy-setup.sh`: Script principal.
*   `modules/`: Scripts individuales para cada tarea.
*   `doc_templates/`: Plantillas de documentos.
*   `themes/`: Temas de apoyo (ej. configuraciones por defecto de Oh My Posh).
