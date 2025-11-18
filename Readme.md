# 🚀 Omarchy Setup Script

Script de instalación y configuración **modular** para **Arch Linux / Omarchy** con menú interactivo.

## 🎯 Características Principales

- **✅ Estructura Modular**: Scripts independientes para cada componente.
- **🎨 Menú Interactivo**: Selecciona qué instalar según tus necesidades.
- **🌀 Progreso Limpio**: Las tareas en background muestran el estado sin invadir los prompts.
- **🔐 Sesión Sudo Persistente**: Reutiliza la contraseña durante toda la ejecución.
- **🔧 Fácil de Extender**: Agrega nuevos módulos fácilmente.

## ⚡ Instalación rápida

```bash
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
./omarchy-setup.sh
```

## 📂 Estructura del Repositorio

```
omarchy_setup/
├── omarchy-setup.sh      # Script principal con el menú interactivo.
├── modules/              # Directorio con todos los módulos de instalación.
│   ├── common.sh         # Funciones compartidas por todos los módulos.
│   ├── apps.sh           # Instalación de aplicaciones y herramientas.
│   ├── zsh-config.sh     # Configuración de Zsh, Oh My Zsh y Oh My Posh.
│   └── ...               # Otros módulos.
└── hypr_config/          # Configuración de Hyprland (copiada por el módulo).
```

---

## 📋 Módulos Disponibles

A continuación se describe cada uno de los módulos que puedes instalar.

### 1. Aplicaciones (`apps.sh`)

Este módulo instala un conjunto de aplicaciones y herramientas esenciales para un entorno de desarrollo y de escritorio completo.

- **Qué instala:**
  - **Herramientas de sistema:** `git`, `curl`, `htop`, `fastfetch`, `stow`, `gnome-keyring`.
  - **Editores de código:** Visual Studio Code (`visual-studio-code-bin`) y Cursor (`cursor-bin`) desde AUR.
  - **Multimedia:** VLC, Audacity, Inkscape y `yt-dlp`.
  - **Red:** FileZilla, Telegram y `speedtest-cli`.
  - **Drivers de Intel:** Soporte completo para gráficos **Intel Iris Xe**, incluyendo Mesa, Vulkan, VA-API para aceleración de video y OpenCL.
  - **Utilidades de AUR:** `keyd` (remapeo de teclado), `logiops` (configuración de ratones Logitech), `teamviewer`.

- **Cómo funciona:**
  - Instala paquetes desde los repositorios oficiales y AUR.
  - Configura **GNOME Keyring** para actuar como agente de SSH, cargando automáticamente las claves que encuentre en `~/.ssh`.
  - Habilita los servicios necesarios para `keyd`, `logiops` y `teamviewer`.

### 2. Zsh (`zsh-config.sh`)

Transforma la terminal con Zsh, Oh My Zsh y Oh My Posh, junto con una configuración personalizada que incluye aliases y funciones útiles.

- **Qué instala:**
  - `zsh` y plugins como `zsh-syntax-highlighting` y `zsh-autosuggestions`.
  - **Oh My Zsh** para la gestión de la configuración de Zsh.
  - **Oh My Posh** como motor para el prompt, con el tema **Catppuccin Frappe**.
  - Herramientas de terminal como `zoxide` para una navegación rápida.

- **Cómo funciona:**
  - Instala todas las dependencias y clona los repositorios necesarios.
  - Reemplaza tu `~/.zshrc` con una versión preconfigurada (creando una copia de seguridad).
  - Cambia tu shell por defecto a Zsh.

> **¡Importante!** Después de instalar este módulo, necesitarás instalar una **Nerd Font** para que el prompt se vea bien. El script te recomendará instalar la fuente **Meslo** con el comando: `oh-my-posh font install meslo`.

### 3. Docker (`docker.sh`)

Instala y configura Docker para la gestión de contenedores.

- **Qué instala:**
  - `docker` y `docker-compose`.
  - (Opcional) **Portainer**, una interfaz web para gestionar Docker.

- **Cómo funciona:**
  - Habilita el servicio de Docker.
  - Añade tu usuario al grupo `docker`, lo que te permite ejecutar comandos de Docker sin `sudo` (requiere reiniciar sesión).
  - Te pregunta si quieres instalar Portainer.

### 4. ZeroTier (`zerotier.sh`)

Instala el cliente de ZeroTier, una herramienta para crear redes virtuales seguras.

- **Qué instala:**
  - El paquete `zerotier-one`.

- **Cómo funciona:**
  - Habilita el servicio de ZeroTier.
  - Te ofrece unirte a una red de ZeroTier de forma interactiva después de la instalación.

### 5. Impresoras (`printer.sh`)

Instala y configura el sistema de impresión CUPS.

- **Qué instala:**
  - `cups`, `cups-pdf` y filtros de impresión.
  - Drivers de impresión genéricos (`gutenprint`, `foomatic-db`).
  - Drivers para impresoras **Epson** desde AUR.
  - `avahi` para la detección de impresoras en red.

- **Cómo funciona:**
  - Habilita los servicios de `cups` y `avahi`.
  - Añade tu usuario al grupo `lp` para que puedas administrar impresoras (requiere reiniciar sesión).

### 6. Tema de Cursor (`mouse_cursor.sh`)

Instala un tema de cursor personalizado y lo configura para Hyprland y aplicaciones GTK.

- **Qué instala:**
  - El tema de cursor **Bibata-Modern-Ice**.

- **Cómo funciona:**
  - Descarga el tema y lo instala en `~/.icons`.
  - Modifica los ficheros de configuración de Hyprland (`envs.conf`) y GTK (`gsettings`).

### 7. Gestor de Iconos (`icon_manager.sh`)

Un menú interactivo para instalar y cambiar entre diferentes temas de iconos.

- **Qué instala (a elección):**
  - **Tela** (variante Nord).
  - **Papirus** (estándar o con colores Catppuccin).
  - **Candy Icons**.

- **Cómo funciona:**
  - Clona los repositorios de los temas de iconos desde GitHub.
  - Modifica la configuración de Hyprland (`autostart.conf`) para que el tema sea persistente.

### 8. Sincronizar Claves SSH (`ssh-keyring.sh`)

Añade tus claves SSH existentes al agente de GNOME Keyring para que no tengas que escribir tu passphrase repetidamente.

- **Cómo funciona:**
  - Inicia el `gnome-keyring-daemon`.
  - Busca claves privadas en `~/.ssh` y las añade al agente usando `ssh-add`.
  - Evita añadir claves que ya estén cargadas.

### 9. Soporte de Formatos (`disk-format.sh`)

Instala herramientas para poder leer, escribir y formatear particiones con los sistemas de archivos más comunes.

- **Qué instala:**
  - `dosfstools` (para FAT), `exfatprogs` (para exFAT) y `ntfs-3g` (para NTFS).
  - Herramientas gráficas como **GParted** y **GNOME Disks**.

### 10. DaVinci Resolve (`davinci-resolve.sh`)

Un instalador especializado para DaVinci Resolve, enfocado en sistemas con GPUs de Intel.

> **Nota:** Este módulo es complejo y requiere que hayas descargado previamente el fichero ZIP de DaVinci Resolve desde la web de Blackmagic y lo hayas colocado en tu carpeta de `~/Downloads`.

- **Cómo funciona:**
  - Instala todas las dependencias necesarias, incluyendo librerías de `ocl-icd` y `intel-compute-runtime`.
  - Extrae el instalador, aplica parches a las librerías con `patchelf` y lo copia todo a `/opt/resolve`.
  - Crea un script "wrapper" y un acceso directo en el menú de aplicaciones para lanzar el programa con la configuración correcta.

### 11. Configuración de Hyprland (`hyprland-config.sh`)

Instala una configuración personalizada para el gestor de ventanas Hyprland.

- **Cómo funciona:**
  - Hace una copia de seguridad de tu configuración actual en `~/.config/hypr`.
  - Copia el contenido de la carpeta `hypr_config` del repositorio a `~/.config/hypr`.
  - Establece el tema de iconos por defecto (Tela Nord) usando el módulo de gestión de iconos.

---

## 🔧 Extender el Script

Añadir un nuevo módulo es sencillo:

1.  **Crea tu script** en la carpeta `modules/` (ej. `mi-modulo.sh`). Asegúrate de que tenga una función principal.
2.  **Añádelo al menú** en `omarchy-setup.sh`, dentro del array `MODULES`. Sigue el formato: `"tecla"="nombre-fichero;nombre-funcion;Descripción;tipo"`.
    -   `tipo` puede ser `bg` (para tareas en segundo plano) o `fg` (para tareas interactivas).

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
