#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ./run.sh [options]

Options:
  --all         Run everything (install + symlink)
  --install     Install packages only (Homebrew, casks, CLI tools, NVM, Oh My Zsh)
  --symlink     Create symlinks only
  help, -h      Show this help message

Examples:
  ./run.sh --all        # Full setup
  ./run.sh --install    # Only install packages
  ./run.sh --symlink    # Only create symlinks
EOF
}

run_install() {
  bash "$DOTFILES_DIR/scripts/install.sh"
}

run_symlink() {
  bash "$DOTFILES_DIR/scripts/symlink.sh"
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
