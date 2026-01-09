# 🌀 Omarchy Setup Script v3.5.0

Script de configuración **modular** y **personalizado** para **Arch Linux / Omarchy**. Esta herramienta automatiza la instalación de aplicaciones y la vinculación de mis dotfiles personales.

## 🎯 Características Principales

- **📦 Arquitectura Modular**: Scripts independientes para cada componente del sistema.
- **🔗 Integración con Dotfiles**: Vincula automáticamente configuraciones de Zsh y Hyprland desde el repositorio [mg_dotfiles](https://github.com/marcogll/mg_dotfiles).
- **🎨 Menú Interactivo**: Selecciona exactamente qué componentes deseas configurar.
- **🔐 Seguridad y Persistencia**: Gestión de sudo optimizada y sincronización con GNOME Keyring.
- **🎬 Soporte DaVinci Resolve**: Instalador especializado para GPUs Intel Iris Xe.

## 🚀 Instalación Rápida

Para un setup completo, se recomienda tener clonado el repositorio de dotfiles en `~/Work/code/mg_dotfiles` antes de empezar.

```bash
# 1. Clonar dotfiles (Opcional pero recomendado para Zsh/Hyprland)
mkdir -p ~/Work/code
git clone https://github.com/marcogll/mg_dotfiles.git ~/Work/code/mg_dotfiles

# 2. Clonar y ejecutar el setup
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
./omarchy-setup.sh
```

## 📦 Estructura del Proyecto

```
omarchy_setup/
├── omarchy-setup.sh      # Script principal (Menú)
├── modules/              # Scripts de instalación lógica
│   ├── common.sh         # Funciones compartidas y RUTAS (DOTFILES_DIR)
│   ├── apps.sh           # Apps base, Dev, Multimedia y Drivers Intel
│   ├── zsh-config.sh     # Enlaza .zshrc y funciones desde mg_dotfiles
│   ├── hyprland-config.sh # Enlaza configs de Hyprland desde mg_dotfiles
│   └── ...               # Docker, ZeroTier, Impresoras, etc.
├── doc_templates/        # Plantillas para ~/Templates
├── themes/               # Temas de apoyo (Oh My Posh)
└── install.md            # Guía detallada de componentes
```

## 🎮 Opciones del Menú

| Opción | Descripción | Dependencia |
| :--- | :--- | :--- |
| **1** | **Aplicaciones** | Repositorios Arch/AUR/Flatpak |
| **2** | **Zsh Config** | Requiere `mg_dotfiles` |
| **3** | **Docker** | Docker + Portainer (Web UI) |
| **H** | **Hyprland** | Requiere `mg_dotfiles` |
| **R** | **DaVinci** | Requiere ZIP en `~/Downloads` |
| **K** | **SSH Keyring** | Sincroniza llaves con GNOME |
| **A** | **Instalar Todo** | Ejecuta la mayoría de los módulos |

## 📝 Notas Importantes

- **Dotfiles**: Este script ahora es **opinionated**. Si no encuentra `mg_dotfiles` en la ruta configurada en `common.sh`, los módulos de Zsh e Hyprland fallarán.
- **Fuentes**: Es imprescindible usar una **Nerd Font** (ej: `CaskaydiaMono NF`) para que los iconos de la terminal y Hyprland se visualicen correctamente.
- **Reinicio**: Tras la instalación de Docker o el cambio de Shell, es necesario **cerrar sesión** para aplicar los cambios de grupos y entorno.

## 🛠️ Desarrollo

Para añadir una funcionalidad:
1. Crea un script en `modules/`.
2. Regístralo en el array `MODULES` de `omarchy-setup.sh`.

---
**Marco** - [GitHub](https://github.com/marcogll) | [mg_dotfiles](https://github.com/marcogll/mg_dotfiles)
