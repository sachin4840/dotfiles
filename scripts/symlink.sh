#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_BASE_DIR="$HOME/.dotfiles_backup"

# Files/directories to manage
declare -a SYMLINK_PAIRS=(
  "$DOTFILES_DIR/zsh/.zshrc_global:$HOME/.zshrc_global"
  "$DOTFILES_DIR/zsh/.p10k.zsh:$HOME/.p10k.zsh"
  "$DOTFILES_DIR/tmux/.tmux.conf:$HOME/.tmux.conf"
  "$DOTFILES_DIR/nvim:$HOME/.config/nvim"
  "$DOTFILES_DIR/claude/settings.json:$HOME/.claude/settings.json"
  "$DOTFILES_DIR/claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "$DOTFILES_DIR/claude/commands:$HOME/.claude/commands"
  "$DOTFILES_DIR/claude/agents:$HOME/.claude/agents"
)

usage() {
  cat <<EOF
Usage: symlink.sh [command]

Commands:
  link      Create symlinks (default, backs up existing files)
  unlink    Remove symlinks (keeps original files in dotfiles repo)
  backup    Backup current files without creating symlinks
  restore   Restore from a previous backup
  reset     Remove symlinks and restore from backup
  list      List available backups

Examples:
  ./scripts/symlink.sh              # Create symlinks (with auto-backup)
  ./scripts/symlink.sh link         # Same as above
  ./scripts/symlink.sh unlink       # Remove symlinks only
  ./scripts/symlink.sh backup       # Only backup, no symlinks
  ./scripts/symlink.sh restore      # Restore from backup
  ./scripts/symlink.sh reset        # Unlink + restore
  ./scripts/symlink.sh list         # Show available backups
EOF
}

# Create timestamped backup directory
create_backup_dir() {
  local timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_dir="$BACKUP_BASE_DIR/$timestamp"
  mkdir -p "$backup_dir"
  echo "$backup_dir"
}

# Backup a single file/directory
backup_item() {
  local src="$1"
  local backup_dir="$2"
  local basename
  basename=$(basename "$src")

  if [ -e "$src" ] || [ -L "$src" ]; then
    # Skip if it's already a symlink to our dotfiles
    if [ -L "$src" ]; then
      local link_target
      link_target=$(readlink "$src")
      if [[ "$link_target" == "$DOTFILES_DIR"* ]]; then
        echo "  Skipping $src (already linked to dotfiles)"
        return 1
      fi
    fi

    cp -RP "$src" "$backup_dir/$basename"
    echo "  Backed up $src"
    return 0
  else
    echo "  Skipping $src (does not exist)"
    return 1
  fi
}

# Backup all managed files
do_backup() {
  echo "==> Creating backup..."
  local backup_dir
  backup_dir=$(create_backup_dir)
  local backed_up=0

  for pair in "${SYMLINK_PAIRS[@]}"; do
    local dest="${pair#*:}"
    if backup_item "$dest" "$backup_dir"; then
      ((backed_up++)) || true
    fi
  done

  if [ "$backed_up" -eq 0 ]; then
    echo "  No files to backup"
    rmdir "$backup_dir" 2>/dev/null || true
  else
    echo "==> Backup complete: $backup_dir"
    echo "    $backed_up file(s) backed up"
  fi
}

# List available backups
do_list() {
  echo "==> Available backups:"
  if [ ! -d "$BACKUP_BASE_DIR" ]; then
    echo "  No backups found"
    return
  fi

  local count=0
  for backup in "$BACKUP_BASE_DIR"/*/; do
    if [ -d "$backup" ]; then
      local dirname
      dirname=$(basename "$backup")
      local files
      files=$(find "$backup" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | tr -d ' ')
      echo "  $dirname ($files files)"
      ((count++)) || true
    fi
  done

  if [ "$count" -eq 0 ]; then
    echo "  No backups found"
  fi
}

# Remove symlinks without deleting original files
do_unlink() {
  echo "==> Removing symlinks..."
  local removed=0

  for pair in "${SYMLINK_PAIRS[@]}"; do
    local src="${pair%%:*}"
    local dest="${pair#*:}"

    if [ -L "$dest" ]; then
      local link_target
      link_target=$(readlink "$dest")
      if [ "$link_target" = "$src" ]; then
        rm "$dest"
        echo "  Removed symlink: $dest"
        ((removed++)) || true
      else
        echo "  Skipping $dest (symlink points elsewhere: $link_target)"
      fi
    elif [ -e "$dest" ]; then
      echo "  Skipping $dest (not a symlink)"
    else
      echo "  Skipping $dest (does not exist)"
    fi
  done

  if [ "$removed" -eq 0 ]; then
    echo "==> No symlinks to remove"
  else
    echo "==> Removed $removed symlink(s)"
    echo "    Original files remain in: $DOTFILES_DIR"
  fi
}

# Restore from backup
do_restore() {
  if [ ! -d "$BACKUP_BASE_DIR" ]; then
    echo "Error: No backups found at $BACKUP_BASE_DIR"
    exit 1
  fi

  # Get available backups
  local backups=()
  for backup in "$BACKUP_BASE_DIR"/*/; do
    if [ -d "$backup" ]; then
      backups+=("$(basename "$backup")")
    fi
  done

  if [ ${#backups[@]} -eq 0 ]; then
    echo "Error: No backups found"
    exit 1
  fi

  echo "==> Available backups:"
  local i=1
  for backup in "${backups[@]}"; do
    local files
    files=$(find "$BACKUP_BASE_DIR/$backup" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | tr -d ' ')
    echo "  $i) $backup ($files files)"
    ((i++))
  done

  # Prompt for selection
  echo ""
  read -rp "Select backup to restore (1-${#backups[@]}, or 'q' to quit): " choice

  if [[ "$choice" == "q" ]]; then
    echo "Restore cancelled"
    exit 0
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#backups[@]} ]; then
    echo "Error: Invalid selection"
    exit 1
  fi

  local selected_backup="${backups[$((choice-1))]}"
  local backup_dir="$BACKUP_BASE_DIR/$selected_backup"

  echo ""
  echo "==> Restoring from $selected_backup..."

  # Restore each file
  for file in "$backup_dir"/*; do
    if [ -e "$file" ]; then
      local basename
      basename=$(basename "$file")
      local dest

      # Determine destination based on file name
      case "$basename" in
        .zshrc|.zshrc_global|.zprofile|.zshenv|.p10k.zsh|.tmux.conf)
          dest="$HOME/$basename"
          ;;
        nvim)
          dest="$HOME/.config/nvim"
          ;;
        settings.json|CLAUDE.md)
          dest="$HOME/.claude/$basename"
          ;;
        commands)
          dest="$HOME/.claude/commands"
          ;;
        agents)
          dest="$HOME/.claude/agents"
          ;;
        *)
          echo "  Skipping unknown file: $basename"
          continue
          ;;
      esac

      # Remove existing symlink/file
      if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
      fi

      # Ensure parent directory exists
      mkdir -p "$(dirname "$dest")"

      # Copy back
      cp -RP "$file" "$dest"
      echo "  Restored $dest"
    fi
  done

  echo "==> Restore complete!"
  echo "    Note: You may need to restart your shell for changes to take effect"
}

# Remove symlinks and restore from backup
do_reset() {
  echo "==> Resetting to backup state..."
  do_unlink
  echo ""
  do_restore
}

# Helper: backup existing file and create symlink
link_file() {
  local src="$1"
  local dest="$2"
  local backup_dir="$3"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "  $dest already linked"
      return
    fi

    # Backup before removing
    if [ -n "$backup_dir" ]; then
      backup_item "$dest" "$backup_dir" || true
    fi

    rm -rf "$dest"
  fi

  ln -s "$src" "$dest"
  echo "  Linked $src -> $dest"
}

# Create symlinks (with automatic backup)
do_link() {
  echo "==> Creating symlinks..."

  # Create backup directory for this run
  local backup_dir
  backup_dir=$(create_backup_dir)
  local backed_up=0

  # Ensure target directories exist
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.claude"

  # Create ~/.zshrc from template if it doesn't exist or is a broken/dotfiles symlink
  if [ -L "$HOME/.zshrc" ]; then
    local zshrc_target
    zshrc_target=$(readlink "$HOME/.zshrc")
    if [[ "$zshrc_target" == "$DOTFILES_DIR"* ]] || [ ! -e "$HOME/.zshrc" ]; then
      rm "$HOME/.zshrc"
      echo "  Removed old ~/.zshrc symlink"
    fi
  fi
  if [ ! -f "$HOME/.zshrc" ]; then
    cp "$DOTFILES_DIR/zsh/.zshrc.template" "$HOME/.zshrc"
    echo "  Created ~/.zshrc from template"
  fi

  for pair in "${SYMLINK_PAIRS[@]}"; do
    local src="${pair%%:*}"
    local dest="${pair#*:}"

    # Check if we'll need to backup
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if ! [ -L "$dest" ] || [ "$(readlink "$dest")" != "$src" ]; then
        ((backed_up++)) || true
      fi
    fi

    link_file "$src" "$dest" "$backup_dir"
  done

  # Clean up empty backup directory
  if [ "$backed_up" -eq 0 ]; then
    rmdir "$backup_dir" 2>/dev/null || true
  else
    echo "==> Backed up $backed_up file(s) to: $backup_dir"
  fi

  # Install tmux plugins via TPM (if TPM exists)
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ -d "$TPM_DIR" ]; then
    echo "==> Installing tmux plugins..."
    "$TPM_DIR/bin/install_plugins"
  else
    echo "  TPM not found, skipping plugin installation"
  fi

  echo "==> Symlinks complete!"
}

# Main
case "${1:-link}" in
  link)
    do_link
    ;;
  unlink)
    do_unlink
    ;;
  backup)
    do_backup
    ;;
  restore)
    do_restore
    ;;
  reset)
    do_reset
    ;;
  list)
    do_list
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
