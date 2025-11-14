# 🚀 Omarchy Setup Script v3.0.0

Script de instalación y configuración **modular** para **Arch Linux / Omarchy** con menú interactivo.

## 🎯 Características Principales

- **✅ Estructura Modular**: Scripts independientes para cada componente
- **🎨 Menú Interactivo**: Selecciona qué instalar según tus necesidades
- **🎨 Interfaz Mejorada**: Colores y mensajes claros durante la instalación
- **🔧 Fácil de Extender**: Agrega nuevos módulos fácilmente

## ⚡ Instalación rápida

```bash
# Clonar el repositorio
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup

# Ejecutar el script maestro
./omarchy-setup.sh
```

## 📦 Estructura Modular

```
omarchy_zsh_setup/
├── omarchy-setup.sh          # Script maestro con menú interactivo
├── modules/
│   ├── common.sh              # Funciones comunes (colores, logging, etc.)
│   ├── apps.sh                # Instalación de aplicacionesç
│   ├── zsh-config.sh          # Configuración de Zsh
│   ├── docker.sh              # Docker y Portainer
│   ├── zerotier.sh            # ZeroTier VPN
│   ├── printer.sh             # Configuración de impresoras (CUPS)
│   ├── mouse_cursor.sh        # Tema de cursor Bibata
│   ├── icon_manager.sh        # Gestor de temas de iconos
│   ├── davinci-resolve.sh     # DaVinci Resolve (Intel Edition)
└── Readme.md
```

## 🎮 Uso del Menú Interactivo

Al ejecutar `./omarchy-setup.sh`, verás un menú con las siguientes opciones:

```
╔════════════════════════════════════════════════════════════╗
║  🌀 Omarchy Setup Script — Configuración Modular          ║
╚════════════════════════════════════════════════════════════╝

Selecciona las opciones que deseas instalar:

  1) 📦 Instalar Aplicaciones (VS Code, Cursor, VLC, herramientas)
  2) 🐚 Configurar Zsh (shell, plugins, configuración personalizada)
  3) 🐳 Instalar Docker y Portainer
  4) 🌐 Instalar ZeroTier
  5) 🖨️  Configurar Impresoras (CUPS)
  6) 🎬 Instalar DaVinci Resolve (Intel Edition)
  7) 🔄 Actualizar Sistema
  8) 🧹 Limpiar Paquetes Huérfanos
  9) ✅ Instalar Todo (opciones 1-5)
  0) 🚪 Salir
```

## 📋 Módulos Disponibles

### 1. 📦 Aplicaciones (`apps.sh`)
- Editores como VS Code y Cursor (desde AUR)

### 2. 🐚 Zsh (`zsh-config.sh`)
- Modifica `.bashrc` para lanzar Zsh automáticamente

### 3. 🐳 Docker (`docker.sh`)
- Instalación de Docker y Docker Compose
- Configuración de servicios
- Instalación de Portainer
- Agregar usuario al grupo docker

### 4. 🌐 ZeroTier (`zerotier.sh`)
- Instalación de ZeroTier One
- Configuración de servicio
- Instrucciones para unirse a redes

### 5. 🖨️ Impresoras (`printer.sh`)
- Instalación de CUPS
- Drivers comunes de impresora

### 6. 🖱️ Tema de Cursor (`mouse_cursor.sh`)
- Instala el tema de cursor `Bibata-Modern-Ice`.
- Configura el cursor para Hyprland y aplicaciones GTK.

### 7. 🎨 Gestor de Iconos (`icon_manager.sh`)
- Menú interactivo para instalar y cambiar entre temas de iconos como Papirus, Tela y Candy.

### 8. 🎬 DaVinci Resolve (`davinci-resolve.sh`)
- Configuración de librerías y wrapper

## 🔧 Ejecutar Módulos Individualmente

Cada módulo puede ejecutarse de forma independiente:

```bash
# Instalar solo aplicaciones
./modules/apps.sh

# Configurar solo Zsh
./modules/zsh-config.sh

# Instalar Docker
./modules/docker.sh
```

## 🌐 Instalación desde URL

**Nota**: El script requiere que los módulos estén presentes localmente. Se recomienda clonar el repositorio completo.

```bash
# Clonar el repositorio
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup
./omarchy-setup.sh
```

---

## ✨ Características de los Módulos

### 📦 Aplicaciones
- **Herramientas base**: git, curl, wget, base-devel, stow
- **Editores**: 
  - VS Code (desde AUR: visual-studio-code-bin)
  - Cursor (desde AUR: cursor-bin)
- **Multimedia**: 
  - VLC con todos los plugins (vlc-plugins-all)
  - Audacity (editor de audio)
  - Inkscape (editor gráfico vectorial)
  - ffmpeg, gstreamer con plugins
  - yt-dlp (descarga de videos)
- **Red y transferencia**:
  - FileZilla (cliente FTP)
  - Telegram Desktop
  - scrcpy (control Android desde PC)
- **Utilidades**: neofetch, htop, fastfetch, btop, vim, nano, tmux
- **Flatpak**: Sistema de paquetes universal
- **Drivers Intel Iris Xe**:
  - Mesa y Vulkan (gráficos 3D)
  - Intel Media Driver (aceleración de video VA-API)
  - OpenCL (Intel Compute Runtime desde AUR)
  - Codecs y herramientas de hardware acceleration
- **Desde AUR**:
  - keyd (remapeo de teclado)
  - fragments (cliente BitTorrent)
  - logiops (driver Logitech)
  - ltunify (Logitech Unifying Receiver)
  - TeamViewer (acceso remoto, con daemon habilitado)
  - intel-compute-runtime (OpenCL para Intel)

### 🐚 Zsh
- Modifica `.bashrc` para lanzar Zsh automáticamente

### 🐳 Docker
- Portainer (interfaz web de gestión)
- Usuario agregado al grupo docker
- Servicios habilitados y configurados

### 🌐 ZeroTier
- ZeroTier One VPN
- Servicio configurado y habilitado
- Instrucciones para unirse a redes

### 🖨️ Impresoras
- CUPS (Common Unix Printing System)
- Drivers comunes de impresora
- Interfaz web en http://localhost:631
- Soporte para impresoras de red

### 🎬 DaVinci Resolve
- Instalación para Intel GPU
- Configuración de OpenCL
- Ajuste de librerías del sistema
- Wrapper para ejecución

---

## 📦 Paquetes instalados

<details>
<summary>Ver lista completa (click para expandir)</summary>

### Sistema Base
- **zsh**, **zsh-completions**
- **oh-my-posh-bin** (desde AUR)
- **git**, **curl**, **wget**
- **yay** (AUR helper, compilado desde AUR)

### Desarrollo
- **python**, **python-pip**, **python-virtualenv**
- **nodejs**, **npm**
- **go** (Golang)
- **docker**, **docker-compose**
- **base-devel** (herramientas de compilación)

### Utilidades de Terminal
- **eza** (ls mejorado)
- **bat** (cat mejorado)
- **zoxide** (cd inteligente)
- **fastfetch** (info del sistema)
- **htop**, **btop** (monitores del sistema)
- **tree** (visualización de directorios)

### Multimedia y Control
- **yt-dlp**, **ffmpeg**
- **playerctl**, **brightnessctl**, **pamixer**
- **audacity**, **inkscape**

### Red y Seguridad
- **zerotier-one** (desde AUR)
- **gnome-keyring**, **libsecret**, **seahorse**
- **lsof**, **net-tools**
- **teamviewer**

### Utilidades del Sistema
- **nano**, **unzip**, **tar**
- **p7zip**, **unrar**

### Instalaciones Adicionales
- **speedtest-cli** (vía pip)

</details>

---

## 🎯 Durante la instalación

El script ejecuta los siguientes pasos:

1. **Verificación de requerimientos** (root, Arch Linux, conexión a Internet)
2. **Instalación de paquetes base** desde repositorios oficiales
3. **Instalación de yay** desde AUR (si no está instalado)
4. **Configuración de Docker** (servicio y permisos de usuario)
5. **Instalación de Oh My Zsh y plugins**
6. **Configuración de .zshrc y tema Catppuccin** desde GitHub
7. **Configuración de TeamViewer** (servicio)
8. **Instalación de ZeroTier One** desde AUR (opcional)
9. **Configuración de GNOME Keyring** (opcional)
10. **Configuración de claves SSH** (opcional)

### Preguntas interactivas:

- **ZeroTier Network ID**: Si deseas unirte a una red ZeroTier (opcional)
- **GNOME Keyring**: Si deseas configurar el almacén de contraseñas
- **Claves SSH**: Si deseas añadir claves SSH existentes al agente

---

## 🔑 GNOME Keyring

El keyring guarda contraseñas de forma segura:
- **Git** (credential helper)
- **SSH keys** (almacenadas de forma segura)
- **Aplicaciones GNOME**

### Configuración automática:

El script configura automáticamente:
- PAM para auto-desbloqueo del keyring
- Inicio automático de gnome-keyring-daemon
- Integración con SSH agent

### Comandos útiles:

```bash
# Abrir gestor de contraseñas
seahorse

# Ver estado del keyring
gnome-keyring-daemon --version

# Comandos de ZeroTier (aliases en .zshrc)
zt              # Alias de sudo zerotier-cli
ztstatus        # Ver redes conectadas (listnetworks)
ztinfo          # Info del nodo (info)
```

---

## ⚙️ Configuración incluida

### Aliases de Arch Linux
```bash
pacu            # Actualizar sistema
paci <pkg>      # Instalar paquete
pacr <pkg>      # Remover paquete
pacs <query>    # Buscar paquete
yayu            # Actualizar AUR
yayi <pkg>      # Instalar desde AUR
```

### Git shortcuts
```bash
gs              # git status
ga              # git add
gc              # git commit
gcm "msg"       # git commit -m
gp              # git push
gl              # git pull
gco <branch>    # git checkout
gcb <branch>    # git checkout -b
glog            # git log gráfico
gac "msg"       # add + commit
```

### Docker
```bash
dc              # docker compose
d               # docker
dps             # docker ps -a
di              # docker images
dex <name> sh   # docker exec -it
dlog <name>     # docker logs -f
```

### Python
```bash
py              # python
venv create     # Crear .venv
venv on         # Activar
venv off        # Desactivar
pir             # pip install -r requirements.txt
pipf            # pip freeze > requirements.txt
```

### yt-dlp
```bash
ytm <URL>           # Descargar audio MP3 320kbps
ytm "lofi beats"    # Buscar y descargar
ytv <URL>           # Descargar video MP4 (calidad por defecto)
ytv <URL> 1080      # Descargar video en 1080p
ytv <URL> 720       # Descargar video en 720p
ytls                # Listar últimos descargas
```

Descargas en: `~/Videos/YouTube/{Music,Videos}/`

### NPM
```bash
nrs             # npm run start
nrd             # npm run dev
nrb             # npm run build
nrt             # npm run test
ni              # npm install
nid             # npm install --save-dev
nig             # npm install -g
```

### Utilidades
```bash
mkcd <dir>          # mkdir + cd
extract <file>      # Extraer cualquier archivo
killport <port>     # Matar proceso en puerto
serve [port]        # Servidor HTTP (default 8000)
clima               # Ver clima Saltillo
```

---

## 🌐 ZeroTier Network ID

Tu Network ID tiene formato: `a0cbf4b62a1234567` (16 caracteres hex)

### Dónde encontrarlo:
1. Ve a https://my.zerotier.com
2. Selecciona tu red
3. Copia el Network ID

### Después de la instalación:
1. Ve a tu panel de ZeroTier
2. Busca el nuevo dispositivo
3. **Autorízalo** marcando el checkbox

### Comandos útiles:
```bash
# Ver redes
ztstatus

# Unirse a red
sudo zerotier-cli join <network-id>

# Salir de red
sudo zerotier-cli leave <network-id>

# Info del nodo
ztinfo
```

---

## 📂 Estructura creada

```
$HOME/
├── .zshrc                          # Configuración de Zsh (descargado desde GitHub)
├── .zshrc.local                   # Config local (opcional, no creado automáticamente)
├── .oh-my-zsh/                    # Oh My Zsh
│   └── custom/plugins/            # Plugins adicionales
│       ├── zsh-autosuggestions/
│       └── zsh-syntax-highlighting/
├── .poshthemes/                   # Temas Oh My Posh
│   └── catppuccin.omp.json        # Tema Catppuccin Frappe
├── .zsh_functions/                # Funciones personalizadas (directorio creado)
├── Videos/YouTube/                # Descargas de yt-dlp
│   ├── Music/                     # Audios MP3
│   └── Videos/                    # Videos MP4
├── .ssh/                          # Claves SSH (si existen)
└── omarchy-setup.log             # Log de instalación
```

---

## 🔄 Después de la instalación

### 1. Reiniciar sesión o terminal (IMPORTANTE)

**⚠️ REINICIO REQUERIDO** si se instalaron servicios como TeamViewer o ZeroTier.

```bash
# Cerrar y volver a abrir la terminal para usar Zsh
# O cerrar sesión y volver a entrar para aplicar:
# - Cambio de shell a Zsh
# - Grupos (docker)
# - Permisos del sistema
```

### 2. Verificar instalación

```bash
# Ver versión de Zsh
zsh --version

# Ver tema Oh My Posh
oh-my-posh version

# Verificar Docker
docker ps

# Ver ZeroTier (si se configuró)
ztstatus

# Ver TeamViewer (si se instaló)
teamviewer info

# Actualizar sistema
pacu
```

### 3. Configuraciones opcionales

```bash
# Crear archivo de configuración local
nano ~/.zshrc.local

# Ejemplo de contenido:
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
alias miproyecto="cd ~/Projects/mi-app && code ."
```

---

## 🛠️ Solución de problemas

### Docker no funciona sin sudo

```bash
# Verificar que estás en el grupo docker
groups  # Debe incluir 'docker'

# Si no aparece, reinicia sesión o ejecuta:
newgrp docker

# Verificar acceso
docker ps
```

### Git sigue pidiendo contraseña

```bash
# Verificar credential helper
git config --global credential.helper

# Debe ser: libsecret

# Si no, configurar:
git config --global credential.helper libsecret

# Abrir Seahorse y verificar keyring
seahorse

# Verificar que el keyring está corriendo
pgrep -u "$USER" gnome-keyring-daemon
```

### ZeroTier no conecta

```bash
# Verificar servicio
sudo systemctl status zerotier-one

# Ver logs
sudo journalctl -u zerotier-one -f

# Reiniciar servicio
sudo systemctl restart zerotier-one

# Verificar que autorizaste el nodo en https://my.zerotier.com
ztinfo
ztstatus
```

### Oh My Posh no se muestra correctamente

```bash
# Verificar instalación
which oh-my-posh
oh-my-posh version

# Verificar que el tema existe
ls ~/.poshthemes/catppuccin.omp.json

# Verificar que tienes una Nerd Font instalada
# (El script NO instala fuentes automáticamente)
fc-list | grep -i nerd

# Si no tienes Nerd Font, instala una:
# - Nerd Fonts: https://www.nerdfonts.com/
```

### El shell no cambió a Zsh

```bash
# Verificar shell actual
echo $SHELL

# Cambiar manualmente
chsh -s $(which zsh)

# Cerrar y abrir nueva terminal
```

---

## 📚 Recursos

- **Arch Wiki**: https://wiki.archlinux.org/
- **Oh My Zsh**: https://ohmyz.sh/
- **Oh My Posh**: https://ohmyposh.dev/
- **Catppuccin Theme**: https://github.com/catppuccin/catppuccin
- **ZeroTier**: https://www.zerotier.com/
- **yt-dlp**: https://github.com/yt-dlp/yt-dlp
- **Nerd Fonts**: https://www.nerdfonts.com/ (requerido para iconos del prompt)
- **yay AUR Helper**: https://github.com/Jguer/yay

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los mensajes de error durante la instalación
2. Verifica que cerraste sesión después de instalar (para aplicar grupos)
3. Comprueba que los grupos se aplicaron: `groups`
4. Verifica que los módulos están presentes: `ls modules/`
5. Ejecuta módulos individualmente para aislar problemas
6. Abre un issue en: https://github.com/marcogll/scripts_mg/issues

### Verificar Instalación de Módulos

```bash
# Verificar que todos los módulos existen
ls -la modules/

# Ejecutar un módulo individual para debug
bash -x modules/apps.sh
```

---

## 🔧 Agregar Nuevos Módulos

Para agregar un nuevo módulo:

1. Crea un archivo en `modules/nombre-modulo.sh`:

```bash
#!/usr/bin/env bash
# ===============================================================
# nombre-modulo.sh - Descripción del módulo
# ===============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_nombre_modulo() {
    log_step "Instalación de Nombre Módulo"
    
    # Tu código aquí
    log_info "Instalando paquetes..."
    sudo pacman -S --noconfirm --needed paquete1 paquete2 || {
        log_error "Error al instalar paquetes"
        return 1
    }
    
    log_success "Módulo instalado correctamente"
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nombre_modulo "$@"
fi
```

2. Agrega el módulo al menú en `omarchy-setup.sh`:

```bash
# En la función show_menu(), agrega:
echo -e "  ${GREEN}X)${NC} 📦 Descripción del módulo"

# En el case statement, agrega:
X)
    run_module "nombre-modulo"
    echo ""
    read -p "Presiona Enter para continuar..."
    ;;

# En la función run_module(), agrega:
"nombre-modulo")
    install_nombre_modulo
    ;;
```

3. Si quieres incluirlo en "Instalar Todo", agrégalo al array `modules` en la función `install_all()`.

---

## 📝 Changelog

### v3.0.0 (2025-01-XX)
- ✨ **Nueva estructura modular**: Scripts independientes para cada componente
- 🎨 **Menú interactivo**: Selecciona qué instalar según tus necesidades
- 🎨 **Interfaz mejorada**: Colores y mensajes claros durante la instalación
- 📦 **Módulos disponibles**:
  - Aplicaciones (apps.sh)
  - Zsh (zsh-config.sh)
  - Docker y Portainer (docker.sh)
  - ZeroTier (zerotier.sh)
  - Impresoras CUPS (printer.sh)
  - Tema de Cursor (mouse_cursor.sh)
  - DaVinci Resolve (davinci-resolve.sh)
  - Gestor de Iconos (icon_manager.sh)

### v2.8.1 (2025-11-02)
- Versión unificada con estética Catppuccin
- Instalación mejorada de paquetes con manejo de errores robusto
- **oh-my-posh** instalado desde AUR automáticamente
- Configuración `.zshrc` descargada desde GitHub

---

## 📄 Licencia

MIT License - Libre de usar y modificar

---

## 👤 Autor

**Marco**
- GitHub: [@marcogll](https://github.com/marcogll)
- Repo: [scripts_mg](https://github.com/marcogll/scripts_mg)

---


```bash
# Instalar en una línea
bash <(curl -fsSL https://raw.githubusercontent.com/marcogll/scripts_mg/main/omarchy_zsh_setup/omarchy-setup.sh)
```

## 📝 Notas importantes

- **Shell por defecto**: El módulo de Zsh modifica `.bashrc` para que las terminales nuevas usen Zsh.

## 🚀 Próximos Pasos

1. Ejecuta `./omarchy-setup.sh` para ver el menú interactivo
2. Selecciona los módulos que deseas instalar
3. Revisa los mensajes durante la instalación
4. Reinicia o cierra sesión después de instalar servicios
5. Disfruta de tu configuración personalizada

---

🚀 **¡Disfruta tu nuevo setup modular de Omarchy!**
