# 🌀 Omarchy Setup Script v3.5.0

Script de configuración **modular** y **personalizado** para **Arch Linux / Omarchy**. Esta herramienta automatiza la instalación de aplicaciones y la vinculación de mis dotfiles personales.

## 🎯 Características Principales

- **📦 Arquitectura Modular**: Scripts independientes para cada componente del sistema.
- **🔗 Integración con Dotfiles**: Vincula automáticamente configuraciones de Zsh y Hyprland desde el repositorio [mg_dotfiles](https://github.com/marcogll/mg_dotfiles).
- **🎨 Menú Interactivo**: Selecciona exactamente qué componentes deseas configurar.
- **🔐 Seguridad y Persistencia**: Gestión de sudo optimizada y sincronización con GNOME Keyring.

## 🚀 Instalación Rápida

Para un setup completo, se recomienda tener clonado el repositorio de dotfiles en `~/Work/code/mg_dotfiles` antes de empezar.

```bash
# 1. Clonar dotfiles (Opcional pero recomendado para Zsh/Hyprland)
mkdir -p ~/Work/code
git clone https://github.com/marcogll/mg_dotfiles.git ~/Work/code/mg_dotfiles

# 2. Clonar y ejecutar el setup
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
chmod +x omarchy-setup.sh
./omarchy-setup.sh
```

## 📦 Estructura del Proyecto

```
omarchy_setup/
├── omarchy-setup.sh        # Script principal (Menú)
├── modules/                # Scripts de instalación lógica
│   ├── common.sh           # Funciones compartidas y RUTAS (DOTFILES_DIR)
│   ├── apps.sh             # Apps base, Dev, Multimedia y Drivers Intel
│   ├── zsh-config.sh       # Enlaza .zshrc y funciones desde mg_dotfiles
│   ├── hyprland-config.sh  # Enlaza configs de Hyprland desde mg_dotfiles
│   └── ...                 # Docker, ZeroTier, Impresoras, etc.
├── mg_dotfiles/            # Dotfiles personales (Zsh, Hyprland, Neovim)
│   ├── zsh/                # Configuración de Zsh
│   ├── omarchy/hypr/       # Configuración de Hyprland
│   └── nvim/               # Configuración de Neovim (LazyVim)
├── doc_templates/          # Plantillas para ~/Templates
├── themes/                 # Temas de apoyo (Oh My Posh)
└── installed_software.md   # Lista detallada de componentes instalados
```

## 🎮 Opciones del Menú

| Opción | Descripción | Dependencia |
| :--- | :--- | :--- |
| **1** | **Aplicaciones** | Repositorios Arch/AUR/Flatpak/Homebrew |
| **2** | **Zsh Config** | Requiere `mg_dotfiles` |
| **3** | **Docker** | Docker + Portainer (Web UI) |
| **5** | **Impresoras** | CUPS + Drivers Epson |
| **6** | **Cursor** | Tema Bibata Modern Ice |
| **7** | **Iconos** | Gestor de temas interactivos (Tela, Papirus, Candy) |
| **7D** | **Iconos por Defecto** | Tela Nord (automático) |
| **S** | **Suspensión** | Activa opción en menú System |
| **H** | **Hyprland** | Requiere `mg_dotfiles` |
| **K** | **SSH Keyring** | Sincroniza llaves con gcr-ssh-agent (GNOME 46+) |
| **F** | **Formatos Disco** | FAT/exFAT/NTFS/ext4 |
| **T** | **Plantillas** | Documentos en ~/Templates |
| **A** | **Instalar Todo** | Ejecuta la mayoría de los módulos |

> **Nota:** Neovim debe instalarse manualmente (ej: `paru -S neovim-git`) y su configuración está disponible en `mg_dotfiles/nvim/`.

---

## 🎨 Configuraciones de mg_dotfiles

Este repositorio vincula configuraciones personalizadas desde [mg_dotfiles](https://github.com/marcogll/mg_dotfiles):

- **Zsh**: Configuración del shell con Oh My Zsh, Oh My Posh, plugins y alias personalizados
- **Hyprland**: Configuración completa del gestor de ventanas tiling y componentes relacionados
- **Neovim**: Configuración personalizada de Neovim con plugins y LazyVim (ubicado en `mg_dotfiles/nvim/`)

Para usar la configuración de Neovim:
```bash
# Opcional: Crea un enlace simbólico (si prefieres mantener config en mg_dotfiles)
ln -s ~/Work/code/mg_dotfiles/nvim ~/.config/nvim
```

---

## 📚 Documentación Técnica de Módulos

### 1. Script Principal: `omarchy-setup.sh`

Este es el script orquestador y el punto de entrada para el usuario.

- **Función Principal:** Proporcionar una interfaz de menú interactiva que permite al usuario seleccionar qué módulos de configuración desea ejecutar.
- **Características Clave:**
    - **Menú Dinámico:** Muestra una lista de todos los módulos disponibles, permitiendo al usuario elegir uno, varios ("Instalar Todo") o salir.
     - **Gestión de `sudo`:** Solicita la contraseña de `sudo` una vez y la mantiene activa en segundo plano para evitar que el usuario tenga que introducirla repetidamente.
     - **Ejecución Modular:** Llama a las funciones principales de los scripts ubicados en el directorio `modules/`.
     - **Feedback Visual:** Implementa un "spinner" (indicador de progreso) para las tareas que se ejecutan en segundo plano, mejorando la experiencia del usuario.
     - **Registro (`Logging`):** Guarda un registro detallado de toda la sesión de instalación en el directorio `logs/`, lo que facilita la depuración en caso de errores.
     - **Verificación del Sistema:** Comprueba que el script se está ejecutando en Arch Linux antes de proceder.
     - **Verificación de Dependencias:** Verifica que `mg_dotfiles` exista en la ruta esperada antes de ejecutar módulos que lo requieren.

### 2. Módulos (`modules/`)

#### 2.1. `common.sh`

Este script no es un módulo ejecutable desde el menú, sino una librería de funciones compartidas por todos los demás módulos.

- **Función Principal:** Centralizar el código común para evitar duplicaciones y mantener la consistencia.
- **Funciones Proporcionadas:**
    - **Logs con Colores:** Funciones como `log_info`, `log_success`, `log_warning` y `log_error` para mostrar mensajes con un formato estandarizado.
    - **Gestión de Paquetes:**
        - `check_and_install_pkg`: Verifica si un paquete ya está instalado desde los repositorios oficiales y, si no, lo instala con `pacman`.
        - `ensure_aur_helper` y `aur_install_packages`: Detectan un helper de AUR (como `yay` o `paru`), lo instalan si es necesario, y lo utilizan para instalar paquetes desde el Arch User Repository.
    - **Copias de Seguridad:** La función `backup_file` renombra un archivo existente (ej. `.zshrc`) a `.zshrc.bak_FECHA` antes de sobrescribirlo, para prevenir la pérdida de configuraciones del usuario.
    - **Verificaciones:** `command_exists` comprueba si un comando está disponible en el sistema.

#### 2.2. `apps.sh`

Es uno de los módulos más extensos y se encarga de la instalación de un conjunto base de aplicaciones y herramientas.

- **Función Principal:** Instalar software esencial de diversas categorías.
- **Software Instalado:**
    - **Base del Sistema:** `git`, `curl`, `wget`, `htop`, `btop`, `fastfetch`, `zoxide`, `stow`, `gnome-keyring`, `openssh`, `rsync`, `usbutils`, `tlp`.
    - **Desarrollo:** `python`, `python-pip`, `nodejs`, `npm`, `uv`, `arduino-cli`. También instala `nvm` (Node Version Manager) y `Homebrew` para una gestión de paquetes más flexible.
    - **Multimedia:** VLC (y sus codecs), Audacity, Inkscape, `ffmpeg`, `gstreamer`, `gst-plugins-*`, `yt-dlp` para descargar vídeos, herramientas de audio ALSA y pulseaudio.
    - **Red:** FileZilla, Telegram, `scrcpy`, `speedtest-cli`.
    - **AUR:** Visual Studio Code, Cursor, Keyd, Fragments, Logiops, TeamViewer, Antigravity, OpenCode, Intel Compute Runtime.
    - **Drivers para Intel Iris Xe:** Instala todos los paquetes necesarios para el correcto funcionamiento de los gráficos integrados de Intel, incluyendo `mesa`, `vulkan-intel`, `lib32-mesa`, `lib32-vulkan-intel`, y los drivers para la aceleración de vídeo por hardware (VA-API), OpenCL e Intel Compute Runtime.
- **Configuraciones Adicionales:**
    - Habilita y configura servicios del sistema como `gnome-keyring-daemon` (para gestión de contraseñas), `keyd` y `logiops` (para teclados y ratones avanzados), `teamviewer` y `tlp` (para la gestión avanzada de energía y optimización de la batería).
    - **Nota:** La gestión de claves SSH ahora se realiza mediante el módulo `ssh-keyring.sh` usando `gcr-ssh-agent` (para GNOME 46+), no desde este módulo.

#### 2.3. `zsh-config.sh`

Este módulo personaliza la experiencia del shell del usuario.

- **Función Principal:** Configurar Zsh como el shell principal con una apariencia y funcionalidad mejoradas.
- **Acciones Realizadas:**
    - **Instalación:** Instala `zsh`, `zsh-completions`, `zsh-syntax-highlighting`, `zsh-autosuggestions` y dependencias (`unrar`, `p7zip`, `lsof`). Nota: `git`, `zoxide`, `fastfetch` y `yt-dlp` se instalan en el módulo `apps.sh` para evitar duplicidades.
    - **Oh My Zsh:** Instala el framework "Oh My Zsh" para la gestión de plugins.
    - **Plugins:** Añade plugins populares como `zsh-autosuggestions` (sugiere comandos mientras escribes) y `zsh-syntax-highlighting` (colorea la sintaxis de los comandos).
    - **Oh My Posh:** Instala esta herramienta para crear un prompt de terminal altamente personalizable y descarga un tema predefinido (Catppuccin Frappe).
    - **.zshrc:** Reemplaza el `~/.zshrc` del usuario por una versión pre-configurada que integra todas estas herramientas y añade alias y funciones útiles, incluyendo una función `zsh_help` que muestra una lista de todos los comandos personalizados. Si no se puede crear backup, continúa de todas formas.
    - **Shell por Defecto:** Cambia el shell de inicio de sesión del usuario a Zsh.
    - **Integración con .bashrc:** Configura `.bashrc` para ejecutar `exec zsh` automáticamente al iniciar una terminal interactiva.

#### 2.4. `docker.sh`

Configura un entorno de desarrollo basado en contenedores.

- **Función Principal:** Instalar y configurar Docker Engine y Docker Compose.
- **Acciones Realizadas:**
    - **Instalación:** Instala los paquetes `docker` y `docker-compose`.
    - **Servicio:** Habilita e inicia el servicio (`daemon`) de Docker para que se ejecute automáticamente al iniciar el sistema.
    - **Permisos:** Agrega el usuario actual al grupo `docker`, permitiéndole ejecutar comandos de Docker sin necesidad de `sudo`.
    - **Portainer (Opcional):** Pregunta al usuario si desea instalar Portainer, una interfaz gráfica web para gestionar contenedores, imágenes y volúmenes de Docker.

#### 2.5. `disk-format.sh`

Añade soporte para sistemas de archivos comunes.

- **Función Principal:** Instalar las herramientas necesarias para interactuar con particiones y discos formateados en sistemas de archivos no nativos de Linux.
- **Soporte Añadido:**
    - `ntfs-3g`: Para leer y escribir en particiones NTFS (Windows).
    - `exfatprogs`: Para particiones exFAT, comunes en tarjetas SD y unidades USB.
    - `e2fsprogs`: Herramientas para el sistema de archivos nativo de Linux (ext4).

#### 2.6. `hyprland-config.sh`

Configura un entorno de escritorio basado en el gestor de ventanas Hyprland.

- **Función Principal:** Instalar Hyprland y un conjunto de aplicaciones y configuraciones para tener un entorno de "tiling window manager" funcional y estético.
- **Software Adicional:** Instala componentes como `waybar` (barra de estado), `wofi` (lanzador de aplicaciones), `swaylock` (bloqueo de pantalla), y `kitty` (emulador de terminal).
- **Configuración:** Despliega una estructura de archivos de configuración predefinida para todos estos componentes.

#### 2.7. `icon_manager.sh`

Permite personalizar la apariencia del sistema.

- **Función Principal:** Instalar y aplicar diferentes temas de iconos.
- **Temas Disponibles:** Ofrece una selección de temas populares como Papirus y Tela, instalándolos desde los repositorios de Arch o AUR.
- **Aplicación:** Utiliza `gsettings` para cambiar el tema de iconos activo en el entorno de escritorio.

#### 2.8. `mouse_cursor.sh`

Mejora la apariencia del cursor del ratón.

- **Función Principal:** Instalar y configurar el tema de cursores Bibata.
- **Acciones Realizadas:** Descarga e instala el tema, y luego lo establece como el predeterminado para las aplicaciones GTK y el servidor gráfico X11.

#### 2.9. `printer.sh`

Configura el sistema para poder utilizar impresoras.

- **Función Principal:** Instalar el sistema de impresión CUPS y los drivers necesarios.
- **Acciones Realizadas:**
    - **CUPS:** Instala el servidor de impresión CUPS y sus filtros.
    - **Drivers:** Instala drivers genéricos y específicos para impresoras Epson.
    - **Servicios:** Habilita los servicios de `cups` y `avahi` (para la detección de impresoras en red).
    - **Permisos:** Añade al usuario al grupo `lp` para permitirle administrar impresoras.

#### 2.10. `ssh-keyring.sh`

Mejora la gestión de claves SSH.

- **Función Principal:** Sincronizar las claves SSH del usuario con el agente gcr-ssh-agent.
- **Funcionamiento:**
    1.  Habilita e inicia el servicio `gcr-ssh-agent.socket` (el componente SSH que ahora está en `gcr` en lugar de `gnome-keyring`).
    2.  Configura la variable de entorno `SSH_AUTH_SOCK` para apuntar a `$XDG_RUNTIME_DIR/gcr/ssh`.
    3.  Busca todas las claves SSH privadas en el directorio `~/.ssh/`.
    4.  Utiliza `ssh-add` para añadir cada clave al agente. La primera vez que se use cada clave, gcr-ssh-agent pedirá la contraseña y la almacenará de forma segura. En usos posteriores, la desbloqueará automáticamente.
    - **Importancia:** Evita tener que escribir la contraseña de la clave SSH cada vez que se establece una conexión.
    - **Nota:** A partir de gnome-keyring 46.0+, la funcionalidad SSH fue movida a `gcr`, por lo que este módulo ahora usa `gcr-ssh-agent` en lugar del componente SSH de `gnome-keyring`.

#### 2.11. Neovim (mg_dotfiles)

Configuración personalizada de Neovim disponible en mg_dotfiles.

- **Ubicación:** La configuración se encuentra en `mg_dotfiles/nvim/` y se ha copiado a este repositorio.
- **Contenido:** Incluye configuración con LazyVim, plugins personalizados, colores y atajos de teclado.
- **Instalación Manual:** Si deseas vincular la configuración desde mg_dotfiles:
    ```bash
    ln -s ~/Work/code/mg_dotfiles/nvim ~/.config/nvim
    ```
- **Nota:** Neovim debe instalarse previamente (ej: `paru -S neovim-git` o `pacman -S neovim`).

#### 2.12. `zerotier.sh`

Instala una herramienta de VPN.

- **Función Principal:** Instalar y configurar el cliente de la VPN ZeroTier.
- **Acciones Realizadas:**
    - **Instalación:** Instala el paquete `zerotier-one`.
    - **Servicio:** Habilita e inicia el servicio de ZeroTier.
    - **Unirse a Red (Opcional):** Pregunta al usuario si desea unirse a una red de ZeroTier y, en caso afirmativo, le pide el ID de la red.

---

## 📝 Notas Importantes

- **Dotfiles**: Este script ahora es **opinionated**. Si no encuentra `mg_dotfiles` en la ruta configurada en `common.sh`, el script mostrará una advertencia y los módulos de Zsh e Hyprland fallarán.
- **Verificación de mg_dotfiles**: Al iniciar el script, se verifica que `mg_dotfiles` existe en la ruta esperada (`~/Work/code/mg_dotfiles`). Si no se encuentra, se mostrarán instrucciones para clonarlo.
- **Neovim**: La configuración personalizada de Neovim está disponible en `mg_dotfiles/nvim/`. No se instala automáticamente, pero puede vincularse manualmente con `ln -s ~/Work/code/mg_dotfiles/nvim ~/.config/nvim`.
- **Fuentes**: Es imprescindible usar una **Nerd Font** (ej: `CaskaydiaMono NF` o `ttf-firacode-nerd`) para que los iconos de la terminal y Hyprland se visualicen correctamente.
- **Reinicio**: Tras la instalación de Docker o el cambio de Shell, es necesario **cerrar sesión** para aplicar los cambios de grupos y entorno.
- **Logs**: Cada ejecución genera un log en `logs/omarchy-setup-YYYY-MM-DD_HH-MM-SS.log`
- **SSH Keyring**: A partir de GNOME 46+, la funcionalidad SSH fue movida a `gcr`, por lo que la gestión de claves SSH ahora usa `gcr-ssh-agent` en lugar del componente SSH de `gnome-keyring`.

## 🛠️ Desarrollo

Para añadir una funcionalidad:
1. Crea un script en `modules/`.
2. Regístralo en el array `MODULES` de `omarchy-setup.sh`.
3. Actualiza la documentación técnica y `installed_software.md` con los nuevos componentes.

---

**Marco** - [GitHub](https://github.com/marcogll) | [mg_dotfiles](https://github.com/marcogll/mg_dotfiles)
