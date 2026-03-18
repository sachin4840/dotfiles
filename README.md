# Dotfiles

Mac development environment setup — zsh, neovim, tmux, git, and more.

## Structure

```
dotfiles/
├── zsh/               # Zsh configuration (.zshrc, .zprofile, .zshenv)
├── nvim/              # Neovim configuration
├── tmux/              # Tmux configuration
├── git/               # Git configuration (.gitconfig, .gitignore_global)
├── scripts/
│   ├── install.sh     # Install all packages and tools
│   └── symlink.sh     # Symlink config files to home directory
├── setup.sh           # Main entry point
└── README.md
```

## Quick Start

```bash
git clone git@github.com:sachin4840/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh --all
```

## Usage

```bash
./setup.sh --all         # Full setup (install + symlink)
./setup.sh --install     # Install packages only
./setup.sh --symlink     # Create symlinks only (auto-backs up existing files)
./setup.sh --backup      # Backup current config files only
./setup.sh --restore     # Restore from a previous backup
./setup.sh --list        # List available backups
./setup.sh --help        # Show help
```

## Backup & Restore

The symlink script automatically backs up existing config files before replacing them with symlinks. Backups are stored in `~/.dotfiles_backup/` with timestamped directories.

```bash
# Manually backup before making changes
./setup.sh --backup

# View available backups
./setup.sh --list

# Restore if something goes wrong
./setup.sh --restore
```

The restore command will show an interactive list of available backups to choose from.

## What Gets Installed

### Homebrew Formulae
neovim, tmux, bat, tree, zsh-autosuggestions, zsh-syntax-highlighting, font-hack-nerd-font

### Homebrew Casks
iterm2, rectangle, stats, alt-tab

### Other
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- [NVM](https://github.com/nvm-sh/nvm) + latest Node.js

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

See [LICENSE](LICENSE) for details.
