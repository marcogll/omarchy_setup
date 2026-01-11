# mg_dotfiles

Dotfiles personales para mi configuración de Arch Linux con Hyprland, Omarchy, Zsh y Bash.

## 📦 Incluye

### Shell
- **Zsh**: Oh My Zsh + Oh My Posh + plugins (git, docker, npm, python, etc.)
- **Bash**: Config básica con auto-launch a Zsh
- **Funciones**: yt-dlp (ytm, ytv, ytls), docker, git, venv, etc.
- **Aliases**: Sistema, Git, Docker, NPM, Python, Arch/Pacman
- **Local Config**: `.zshrc.local.example` para personalizaciones sin secretos

### Desktop
- **Omarchy**: Config completa (themes, backgrounds, hooks)
- **Hyprland**: keybindings, monitors, autostart, idle/lock
- **Waybar**: Barra personalizada
- **Walker**: Launcher/appmenu
- **Mako**: Notificaciones

### Terminal
- **Alacritty** o **Kitty**: Config temática
- **Oh My Posh**: Theme Catppuccin Frappé

## 🚀 Instalación

```bash
cd ~/Work/mg_dotfiles
chmod +x install.sh
./install.sh
```

El script:
- Crea backups automáticos en `~/.dotfiles_backup_FECHA`
- Crea symlinks a los archivos de configuración
- Genera `~/.zshrc.local` desde `.zshrc.local.example` si no existe

## ⚙️ Post-instalación

1. **Recarga tu shell**: `source ~/.zshrc` o reinicia terminal
2. **Config local**: Copia el ejemplo y edítalo:
   ```bash
   cp mg_dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
   # Edita ~/.zshrc.local para agregar tus configuraciones locales
   ```
3. **API Keys**: Agrega tus API keys en `~/.zshrc.local` (usa variables de entorno o gestores de secretos):
   ```bash
   export OPENAI_API_KEY="sk-..."
   export ANTHROPIC_API_KEY="sk-..."
   # etc...
   ```
3. **Oh My Zsh**: Instálalo si no lo tienes:
   ```bash
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```
4. **Oh My Posh**: Instálalo si no lo tienes:
   ```bash
   curl -s https://ohmyposh.dev/install.sh | bash -s
   ```

## 📁 Estructura

```
~/Work/mg_dotfiles/
├── bash/
│   └── .bashrc
├── zsh/
│   ├── .zshrc
│   ├── .zshrc.help
│   ├── .zshrc.local.example   # Plantilla para ~/.zshrc.local
│   └── .zsh_functions/
├── omarchy/
│   ├── omarchy/          # Themes, backgrounds, hooks
│   ├── hypr/             # Hyprland config
│   ├── waybar/           # Bar config
│   ├── walker/           # Launcher config
│   ├── alacritty/        # Terminal (opcional)
│   ├── kitty/            # Terminal (opcional)
│   └── mako/             # Notificaciones
└── install.sh
```

## 🔥 Comandos útiles

### Zsh functions
- `ytm <URL>` - Descarga audio de YouTube a `~/Videos/YouTube/Music/`
- `ytv <URL> [calidad]` - Descarga video de YouTube (1080/720/480)
- `ytls` - Lista últimas descargas
- `venv create|on|off` - Gestiona entornos virtuales Python
- `killport <puerto>` - Mata proceso en puerto específico
- `extract <archivo>` - Extrae cualquier archivo comprimido
- `mkcd <dir>` - Crea directorio y entra en él

### Aliases destacados
- `pacu` / `yayu` - Actualizar sistema
- `paci` / `yayi` - Instalar paquete
- `ga`, `gcm`, `glog` - Git shortcuts
- `dc`, `dps`, `dex` - Docker compose shortcuts
- `nrs`, `nrd`, `nrb` - NPM run shortcuts

## ⚠️ Archivos excluidos

Los siguientes archivos **NO** están incluidos (por seguridad/privacidad):

- `zsh/.zshrc.local` - Contiene API keys (usa `.zshrc.local.example` como plantilla)
- `misc/.gitconfig` - Config personal con tokens
- `~/.zsh_history`, `~/.bash_history` - Historiales
- `~/.oh-my-zsh/` - Demasiado grande para incluir

## 📝 Notas

- El archivo `~/.zshrc.local` debe copiarse desde `.zshrc.local.example` y editarse manualmente
- **IMPORTANTE**: No pongas API keys reales en `.zshrc.local.example` - usa solo configuraciones públicas allí
- El script de instalación crea symlinks, no copia archivos
- Los backups se guardan en `~/.dotfiles_backup_FECHA`

## 🤝 Contribuciones

Estos son mis dotfiles personales, siéntete libre de usarlos como referencia.
