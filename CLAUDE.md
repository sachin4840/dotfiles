# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository for setting up a development environment with zsh, neovim, tmux, and related tools.

## Commands

```bash
./setup.sh --all         # Full setup (install packages + create symlinks)
./setup.sh --install     # Install packages only (Homebrew, casks, Oh My Zsh, NVM)
./setup.sh --symlink     # Create symlinks only (auto-backs up existing files)
./setup.sh --unlink      # Remove symlinks (originals stay in dotfiles repo)
./setup.sh --backup      # Backup current config files without creating symlinks
./setup.sh --restore     # Restore config files from a previous backup
./setup.sh --reset       # Remove symlinks and restore from backup
./setup.sh --list        # List available backups
```

Backups are stored in `~/.dotfiles_backup/` with timestamped directories (e.g., `20260318_143052`).

## Pre-commit

Uses gitleaks for secrets scanning. Run manually with:
```bash
pre-commit run --all-files
```

## Architecture

- `setup.sh` - Main entry point that delegates to scripts in `scripts/`
- `scripts/install.sh` - Installs Homebrew, formulae, casks, Oh My Zsh, Powerlevel10k, TPM, and NVM
- `scripts/symlink.sh` - Creates symlinks from config directories to `$HOME` (with automatic backup of existing files)

Config directories (`zsh/`, `nvim/`, `tmux/`, `claude/`) are symlinked to their standard locations:
- `zsh/.zshrc_global` → `~/.zshrc_global`
- `zsh/.p10k.zsh` → `~/.p10k.zsh`
- `tmux/.tmux.conf` → `~/.tmux.conf`
- `nvim/` → `~/.config/nvim/`
- `claude/settings.json` → `~/.claude/settings.json`
- `claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `claude/commands/` → `~/.claude/commands/`
- `claude/agents/` → `~/.claude/agents/`

## Zsh Config Pattern

`~/.zshrc` is NOT symlinked - it stays as a local file that:
1. Sources `~/.zshrc_global` (your dotfiles config, symlinked)
2. Contains machine-specific additions from installers (bun, cargo, etc.)

This means when tools modify `~/.zshrc`, no manual cleanup is needed.

On first setup, `~/.zshrc` is created from `zsh/.zshrc.template`.

## CI

Pull requests run gitleaks secrets scanning via GitHub Actions.
