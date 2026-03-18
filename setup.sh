#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ./setup.sh [options]

Options:
  --all         Run everything (install + symlink)
  --install     Install packages only (Homebrew, casks, CLI tools, NVM, Oh My Zsh)
  --symlink     Create symlinks only (auto-backs up existing files)
  --unlink      Remove symlinks (keeps original files in dotfiles repo)
  --backup      Backup current config files without creating symlinks
  --restore     Restore config files from a previous backup
  --list        List available backups
  help, -h      Show this help message

Examples:
  ./setup.sh --all        # Full setup
  ./setup.sh --install    # Only install packages
  ./setup.sh --symlink    # Only create symlinks (backs up existing files)
  ./setup.sh --unlink     # Disconnect symlinks (originals stay in repo)
  ./setup.sh --backup     # Backup current configs before making changes
  ./setup.sh --restore    # Restore from a previous backup
  ./setup.sh --list       # Show available backups
EOF
}

run_install() {
  bash "$DOTFILES_DIR/scripts/install.sh"
}

run_symlink() {
  bash "$DOTFILES_DIR/scripts/symlink.sh" link
}

run_unlink() {
  bash "$DOTFILES_DIR/scripts/symlink.sh" unlink
}

run_backup() {
  bash "$DOTFILES_DIR/scripts/symlink.sh" backup
}

run_restore() {
  bash "$DOTFILES_DIR/scripts/symlink.sh" restore
}

run_list() {
  bash "$DOTFILES_DIR/scripts/symlink.sh" list
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    --all)
      run_install
      run_symlink
      ;;
    --install)
      run_install
      ;;
    --symlink)
      run_symlink
      ;;
    --unlink)
      run_unlink
      ;;
    --backup)
      run_backup
      ;;
    --restore)
      run_restore
      ;;
    --list)
      run_list
      ;;
    help|-h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      usage
      exit 1
      ;;
  esac
done
