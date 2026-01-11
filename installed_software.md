# 📦 Lista de Software Instalado - Omarchy Setup

Este documento lista todos los componentes que se instalan al ejecutar el script `omarchy-setup.sh` en orden de ejecución. Sirve como referencia para el equipo para entender qué software se configura en un nuevo equipo y para mantener actualizada la lista de aplicaciones necesarias.

> **Nota**: Para ver la documentación técnica detallada de cada módulo, consulta el archivo `Readme.md`.

---

## 📦 Opción 1: Instalar Aplicaciones

### Paquetes instalados desde Pacman:
- `base-devel`: Herramientas de desarrollo base
- `git`: Control de versiones
- `curl` y `wget`: Descarga de archivos
- `vim`: Editor de texto
- `nano`: Editor de texto
- `htop`: Monitor de procesos
- `btop`: Monitor de procesos mejorado
- `fastfetch`: Información del sistema
- `zoxide`: Navegación inteligente de directorios
- `tmux`: Terminal multiplexor
- `xdg-utils` y `xdg-user-dirs`: Herramientas de integración con el escritorio
- `stow`: Gestión de dotfiles
- `gnome-keyring`: Gestión de contraseñas
- `libsecret`: Librería para gestión de secretos
- `seahorse`: Interfaz gráfica para GNOME Keyring
- `openssh`: Cliente/servidor SSH
- `rsync`: Sincronización de archivos
- `usbutils`: Herramientas para USB
- `tlp`: Gestión de energía y optimización de batería

### Desarrollo:
- `python` y `python-pip`: Python y su gestor de paquetes
- `nodejs` y `npm`: Node.js y su gestor de paquetes
- `uv`: Gestor de paquetes Python rápido
- `arduino-cli`: Herramientas de línea de comandos para Arduino

### Multimedia:
- `vlc`: Reproductor multimedia
- `vlc-plugins-all`: Plugins para VLC
- `libdvdcss`: Soporte para DVD
- `audacity`: Editor de audio
- `inkscape`: Editor de gráficos vectoriales
- `ffmpeg`: Framework multimedia
- `gstreamer`: Framework multimedia
- `gst-plugins-good`, `gst-plugins-bad`, `gst-plugins-ugly`: Plugins de GStreamer
- `yt-dlp`: Descarga de videos/audio
- `alsa-utils`: Herramientas de audio ALSA
- `pavucontrol`: Control de volumen PulseAudio

### Red:
- `filezilla`: Cliente FTP
- `telegram-desktop`: Cliente de mensajería
- `scrcpy`: Mirroring de dispositivos Android
- `speedtest-cli`: Prueba de velocidad de conexión

### Flatpak:
- `flatpak`: Gestor de paquetes Flatpak

### Drivers Intel Iris Xe:
- `mesa`: Drivers gráficos
- `vulkan-intel`: Soporte Vulkan para Intel
- `lib32-mesa`: Drivers 32-bit
- `lib32-vulkan-intel`: Soporte Vulkan 32-bit
- `intel-media-driver`: Drivers para decodificación de video
- `libva-utils`: Utilidades VA-API
- `libvdpau-va-gl`: Puente VDPAU a VA-API
- `libva-mesa-driver`: Driver VA-API de Mesa
- `libva-intel-driver`: Driver VA-API de Intel
- `onevpl-intel-gpu`: Intel oneAPI Video Processing Library
- `ocl-icd`: OpenCL ICD Loader
- `libclc`: Biblioteca OpenCL C
- `clinfo`: Información de dispositivos OpenCL

### Paquetes instalados desde AUR:
- `visual-studio-code-bin`: Editor de código
- `cursor-bin`: Editor de código AI-powered
- `keyd`: Remapeo de teclas a nivel de kernel
- `fragments`: Cliente de torrent para GNOME
- `logiops`: Configuración de dispositivos Logitech
- `ltunify`: Herramienta para Unifying Receiver
- `teamviewer`: Soporte remoto
- `intel-compute-runtime`: OpenCL para Intel
- `antigravity`: Herramienta de gestión de energía
- `opencode`: Herramienta de IA para desarrolladores

### Otros:
- NVM (Node Version Manager): Gestión de versiones de Node.js
- Homebrew (Linuxbrew): Gestor de paquetes alternativo

### Paquetes instalados desde AUR:
- `google-chrome`: Navegador web
- `visual-studio-code-bin`: Editor de código
- `code-marketplace`: Extensión para VS Code marketplace
- `v3dv-git`: Drivers para Raspberry Pi
- `xdg-desktop-portal-hyprland`: Portal para Hyprland
- `neovim-git`: Editor de texto moderno (versión bleeding edge, instalación manual)

### Paquetes instalados desde Flatpak:
- VLC: Reproductor multimedia
- LibreOffice: Suite ofimática

---

## 🐚 Opción 2: Configurar Zsh

### Paquetes instalados desde Pacman:
- `zsh`: Shell Zsh
- `zsh-completions`: Completaciones para Zsh
- `zsh-syntax-highlighting`: Coloreado de sintaxis
- `zsh-autosuggestions`: Sugestiones de comandos
- `unrar` y `p7zip`: Descompresores (dependencias para funciones en .zshrc)
- `lsof`: Listado de archivos abiertos (dependencia para funciones en .zshrc)

### Notas:
- `git`, `zoxide`, `fastfetch` y `yt-dlp` se instalan en la Opción 1 (Aplicaciones) para evitar duplicidades.

### Pasos realizados:
1. Instala Zsh y dependencias desde pacman
2. Instala Oh My Zsh en `~/.oh-my-zsh`
3. Instala Oh My Posh (desde pacman, AUR o script oficial)
4. Descarga tema de Oh My Posh (Catppuccin Frappe)
5. Clona plugins de Oh My Zsh:
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
6. Crea enlace simbólico de `~/.zshrc` desde `mg_dotfiles`
7. Crea enlace simbólico de `~/.zshrc.help` desde `mg_dotfiles`
8. Crea enlaces simbólicos de funciones en `~/.zsh_functions/` desde `mg_dotfiles`
9. Cambia el shell del usuario a Zsh
10. Configura `.bashrc` para ejecutar `exec zsh` automáticamente en terminales interactivas

---

## 🐳 Opción 3: Docker

### Pasos realizados:
1. Instala `docker` y `docker-compose`
2. Instala Portainer como contenedor Docker
3. Habilita e inicia el servicio Docker
4. Configura permisos para el usuario actual

---

## 🌐 Opción 4: ZeroTier

### Pasos realizados:
1. Agrega la clave GPG de ZeroTier
2. Agrega repositorio de ZeroTier
3. Actualiza repositorios
4. Instala `zerotier-one`
5. Habilita e inicia el servicio ZeroTier

---

## 🖨️ Opción 5: Impresoras

### Pasos realizados:
1. Instala `cups` (sistema de impresión)
2. Instala `system-config-printer` (configuración gráfica)
3. Instala `hplip` (drivers HP)
4. Instala `epson-inkjet-printer-201207w` (drivers Epson)
5. Habilita e inicia el servicio `org.cups.cupsd`
6. Inicia el servicio `avahi-daemon` (para descubrimiento de impresoras en red)
7. Añade el usuario al grupo `sys` y `lp`

---

## 🖱️ Opción 6: Cursor (Bibata Modern Ice)

### Pasos realizados:
1. Descarga tema de cursor Bibata Modern Ice desde GitHub (v2.0.7)
2. Descomprime e instala en `~/.icons/`
3. Configura variables de entorno en `~/.config/hypr/envs.conf`:
   - `HYPRCURSOR_THEME=Bibata-Modern-Ice`
   - `HYPRCURSOR_SIZE=24`
   - `XCURSOR_THEME=Bibata-Modern-Ice`
   - `XCURSOR_SIZE=24`
4. Configura cursor para aplicaciones GTK usando `gsettings`:
   - Tema: `Bibata-Modern-Ice`
   - Tamaño: `24`

### Nota:
- Las variables de entorno configuran el cursor para aplicaciones X11 y Hyprland.
- `gsettings` configura el cursor para aplicaciones GTK y Flatpak.

---

## 🎨 Opción 7: Iconos (Gestor Interactivo)

### Pasos realizados:
1. Presenta menú para seleccionar tema de iconos:
   - Tela (Opciones: blue, brown, cyan, dark, grey, orange, pink, purple, red, teal, violet, yellow)
   - Papirus (Opciones: dark, light, red, violet, adwaita)
   - Candy (Opciones: dark, light, blue, orange, purple, teal, yellow)
2. Descarga el tema seleccionado desde GitHub
3. Instala el tema en `~/.local/share/icons`

---

## 🎨 Opción 7D: Iconos por Defecto

### Pasos realizados:
1. Descarga e instala tema Tela Nord por defecto
2. No requiere interacción del usuario

---

## 🌙 Opción S: Activar Suspensión

### Pasos realizados:
1. Verifica que el comando `omarchy-toggle-suspend` existe
2. Ejecuta `omarchy-toggle-suspend` para crear el archivo de estado `~/.local/state/omarchy/toggles/suspend-on`
3. Notifica que la opción "Suspend" ahora está disponible en el menú System (Super+Esc)

---

## 🔐 Opción K: SSH Keyring (gcr-ssh-agent)

### Pasos realizados:
1. Verifica que `ssh-add` está disponible (openssh)
2. Crea archivo de configuración `~/.config/environment.d/10-gnome-keyring.conf` con:
   - `SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh`
3. Habilita e inicia el servicio `gcr-ssh-agent.socket`
4. Busca el socket del agente en `/run/user/$UID/gcr/ssh`
5. Busca todas las claves SSH privadas en `~/.ssh/`
6. Añade cada clave al agente usando `ssh-add`
7. La primera vez, gcr-ssh-agent pide la passphrase y la guarda en el keyring
8. En futuras conexiones, desbloquea automáticamente la clave

### Nota:
- Este módulo usa `gcr-ssh-agent` (para GNOME 46+) en lugar del componente SSH de `gnome-keyring`.
- La gestión de SSH fue movida de `gnome-keyring` a `gcr` en versiones recientes.

---

## 💾 Opción F: Formatos de Disco

### Pasos realizados:
1. Instala `dosfstools`: Soporte para FAT32
2. Instala `exfatprogs`: Soporte para exFAT
3. Instala `ntfs-3g`: Soporte para NTFS
4. Instala `e2fsprogs`: Soporte para ext4 (ya incluido en Arch base)

---

## 🎨 Opción H: Hyprland

### Pasos realizados:
1. Verifica que existe el directorio `mg_dotfiles/omarchy/hypr`
2. Crea copia de seguridad si ya existe configuración en `~/.config/hypr`
3. Crea enlace simbólico desde `mg_dotfiles/omarchy/hypr` a `~/.config/hypr`
4. Instala tema de iconos Tela Nord por defecto
5. Activa opción de suspensión en el menú System (ejecuta `omarchy-toggle-suspend`)

---

## ✏️ Neovim (mg_dotfiles)

### Configuración disponible:
- La configuración personalizada de Neovim está disponible en `mg_dotfiles/nvim/`
- Incluye LazyVim, plugins personalizados, colores y atajos de teclado

### Pasos para vincular (opcional):
1. Neovim debe estar instalado previamente (ej: `paru -S neovim-git` o `pacman -S neovim`)
2. Para vincular la configuración desde mg_dotfiles:
   ```bash
   ln -s ~/Work/code/mg_dotfiles/nvim ~/.config/nvim
   ```
3. Al abrir Neovim, se instalarán automáticamente los plugins mediante Lazy.nvim

---

## 📄 Opción T: Plantillas de Documentos

### Pasos realizados:
1. Crea directorio `~/Templates` si no existe
2. Copia plantillas de documentos desde `doc_templates/`:
   - Plantillas de archivos bash
   - Plantillas de archivos markdown
   - Plantillas para otros formatos disponibles

---

## ✅ Opción A: Instalar Todo

### Ejecuta los siguientes módulos:
1. Instalar Aplicaciones
2. Configurar Zsh
3. Docker
4. ZeroTier
5. Impresoras
6. Cursor
7D. Iconos por Defecto (Tela Nord)
S. Suspensión
K. SSH Keyring
F. Formatos de Disco
H. Hyprland
T. Plantillas de Documentos

**Nota:** No ejecuta la opción 7 (Gestor Interactivo de Iconos) porque requiere selección manual. Neovim debe instalarse y configurarse manualmente según las instrucciones en la sección de Neovim.

---

## 📝 Notas para el Equipo

- **Actualización de este documento**: Cuando se agreguen nuevos módulos o software a los scripts existentes, actualizar este archivo para mantener la lista sincronizada.
- **Dotfiles**: Las configuraciones de Zsh, Hyprland y Neovim se encuentran en `mg_dotfiles`. El script verifica que `mg_dotfiles` exista en `~/Work/code/mg_dotfiles` al inicio. Si no existe, muestra una advertencia. Zsh y Hyprland se crean como enlaces simbólicos automáticamente. Neovim puede vincularse manualmente según preferencia.
- **Neovim**: La configuración de Neovim no se instala automáticamente con el script. Debe instalarse previamente (ej: `paru -S neovim-git`) y la configuración en `mg_dotfiles/nvim/` está disponible para ser copiada o enlazada.
- **Paquetes duplicados**: Para evitar redundancia, algunos paquetes se instalan en el módulo `apps.sh` y se reutilizan en otros módulos. Ejemplo: `git`, `zoxide`, `fastfetch`, `yt-dlp`.
- **SSH Keyring**: A partir de GNOME 46+, la funcionalidad SSH fue movida de `gnome-keyring` a `gcr`. El módulo `apps.sh` ahora solo configura GNOME Keyring para gestión de contraseñas, mientras que el módulo `ssh-keyring.sh` gestiona las claves SSH usando `gcr-ssh-agent`.
- **Servicios**: Los servicios (`keyd`, `logiops`, `teamviewerd`, `tlp`) ahora verifican si ya están habilitados antes de intentar habilitarlos nuevamente.
- **Fuentes**: Asegurarse de instalar una **Nerd Font** para que los iconos se vean correctamente.
- **Reiniciar**: Cerrar sesión después de instalar para aplicar cambios de grupos (Docker) y variables de entorno.
- **Logs**: Cada ejecución genera un log en `logs/omarchy-setup-YYYY-MM-DD_HH-MM-SS.log`
