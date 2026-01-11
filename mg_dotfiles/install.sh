#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Instalando dotfiles desde $DOTFILES_DIR"
echo "💾 Backups guardados en $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_and_link() {
  local src="$1"
  local dest="$2"
  
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "📦 Backing up $dest"
    mv "$dest" "$BACKUP_DIR/"
  fi
  
  echo "🔗 Linking $dest -> $src"
  ln -sf "$src" "$dest"
}

echo ""
echo "📝 Bash"
backup_and_link "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

echo ""
echo "🐚 Zsh"
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.zshrc.help" "$HOME/.zshrc.help"

mkdir -p "$HOME/.zsh_functions"
for func_file in "$DOTFILES_DIR/zsh/.zsh_functions"/*.zsh; do
  if [ -f "$func_file" ]; then
    backup_and_link "$func_file" "$HOME/.zsh_functions/$(basename "$func_file")"
  fi
done

# Crear .zshrc.local si no existe
if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "📄 Creando .zshrc.local (recuerda agregar tus API keys)"
  cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local" 2>/dev/null || cat > "$HOME/.zshrc.local" << 'EOF'
# .zshrc.local - Configuración local y variables sensibles
# Este archivo es cargado por .zshrc

# --- API Keys ----------------------------------------------------------------
# Agrega tus API keys aquí:

# OpenAI
# export OPENAI_API_KEY="sk-..."

# Google Gemini
# export GOOGLE_API_KEY="..."

# Anthropic Claude
# export ANTHROPIC_API_KEY="sk-..."
EOF
fi

echo ""
echo "🖥️  Omarchy / Hyprland / Waybar"
backup_and_link "$DOTFILES_DIR/omarchy/omarchy" "$HOME/.config/omarchy"
backup_and_link "$DOTFILES_DIR/omarchy/hypr" "$HOME/.config/hypr"
backup_and_link "$DOTFILES_DIR/omarchy/waybar" "$HOME/.config/waybar"
backup_and_link "$DOTFILES_DIR/omarchy/walker" "$HOME/.config/walker"

echo ""
echo "📟 Terminal (Alacritty/Kitty/Mako)"
[ -d "$DOTFILES_DIR/omarchy/alacritty" ] && backup_and_link "$DOTFILES_DIR/omarchy/alacritty" "$HOME/.config/alacritty"
[ -d "$DOTFILES_DIR/omarchy/kitty" ] && backup_and_link "$DOTFILES_DIR/omarchy/kitty" "$HOME/.config/kitty"
[ -d "$DOTFILES_DIR/omarchy/mako" ] && backup_and_link "$DOTFILES_DIR/omarchy/mako" "$HOME/.config/mako"

echo ""
echo "✅ Instalación completa!"
echo "📌 Recarga tu shell: source ~/.zshrc o reinicia tu terminal"
echo "⚠️  No olvides agregar tus API keys en ~/.zshrc.local"
