#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Creating symlinks..."

# Helper: backup existing file and create symlink
link_file() {
  local src="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "  $dest already linked"
      return
    fi
    echo "  Backing up $dest -> ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -s "$src" "$dest"
  echo "  Linked $src -> $dest"
}

# --- Zsh ---
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

# --- Tmux ---
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- Neovim ---
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "==> Symlinks complete!"
