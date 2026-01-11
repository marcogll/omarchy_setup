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
- `neovim`: Editor de texto moderno
- `tree`: Visualizador de directorios en árbol
- `htop`: Monitor de procesos
- `btop`: Monitor de procesos mejorado
- `ripgrep` (rg): Buscador de archivos rápido
- `fd`: Buscador de archivos alternativo
- `bat`: Clon de cat con mejoras
- `eza`: Alternativa moderna a ls
- `fzf`: Buscador interactivo
- `tmux`: Terminal multiplexor
- `jq`: Procesador JSON
- `unzip`: Descompresor ZIP
- `p7zip`: Descompresor 7z
- `zip`: Compresor ZIP
- `xdg-utils`: Herramientas de integración con el escritorio
- `bluez` y `bluez-utils`: Soporte Bluetooth
- `pipewire` y `wireplumber`: Audio y video
- `noto-fonts`: Fuente base
- `noto-fonts-cjk`: Fuentes CJK (Chino, Japonés, Coreano)
- `ttf-firacode-nerd`: Fuente con iconos Nerd
- `intel-media-driver`: Drivers para GPU Intel

### Paquetes instalados desde AUR:
- `google-chrome`: Navegador web
- `visual-studio-code-bin`: Editor de código
- `code-marketplace`: Extensión para VS Code marketplace
- `v3dv-git`: Drivers para Raspberry Pi
- `xdg-desktop-portal-hyprland`: Portal para Hyprland

### Paquetes instalados desde Flatpak:
- VLC: Reproductor multimedia
- LibreOffice: Suite ofimática

---

## 🐚 Opción 2: Configurar Zsh

### Pasos realizados:
1. Instala `zsh` desde pacman
2. Cambia el shell del usuario a Zsh
3. Clona `oh-my-zsh` en `~/.oh-my-zsh`
4. Instala `oh-my-posh` desde binario
5. Descarga tema de Oh My Posh (CaskaydiaCove)
6. Crea enlace simbólico de `~/.zshrc` desde `mg_dotfiles`
7. Instala plugins de Zsh: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`

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

## 🖱️ Opción 6: Cursor

### Pasos realizados:
1. Descarga tema de cursor Bibata Modern Ice desde GitHub
2. Descomprime en `/usr/share/icons`
3. Ejecuta `update-alternatives` para configurar el cursor por defecto

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

## 🔐 Opción K: SSH Keyring

### Pasos realizados:
1. Verifica que `ssh-add` está disponible (openssh)
2. Habilita e inicia el servicio `gcr-ssh-agent.socket`
3. Configura `SSH_AUTH_SOCK` en `$XDG_RUNTIME_DIR/gcr/ssh`
4. Busca todas las claves SSH privadas en `~/.ssh/`
5. Añade cada clave al agente usando `ssh-add`
6. La primera vez, gcr-ssh-agent pide la passphrase y la guarda en el keyring
7. En futuras conexiones, desbloquea automáticamente la clave

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

**Nota:** No ejecuta la opción 7 (Gestor Interactivo de Iconos) porque requiere selección manual.

---

## 📝 Notas para el Equipo

- **Actualización de este documento**: Cuando se agreguen nuevos módulos o software a los scripts existentes, actualizar este archivo para mantener la lista sincronizada.
- **Dotfiles**: Las configuraciones de Zsh y Hyprland se crean como enlaces simbólicos a `mg_dotfiles`. Cualquier cambio en los archivos originales se refleja inmediatamente.
- **Fuentes**: Asegurarse de instalar una **Nerd Font** para que los iconos se vean correctamente.
- **Reiniciar**: Cerrar sesión después de instalar para aplicar cambios de grupos (Docker) y variables de entorno.
- **Logs**: Cada ejecución genera un log en `logs/omarchy-setup-YYYY-MM-DD_HH-MM-SS.log`
