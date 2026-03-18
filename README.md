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
├── run.sh             # Main entry point
└── README.md
```

## Quick Start

```bash
git clone git@github.com:sachin4840/dotfiles.git ~/dotfiles
cd ~/dotfiles
./run.sh --all
```

## Usage

```bash
./run.sh --all         # Full setup (install + symlink)
./run.sh --install     # Install packages only
./run.sh --symlink     # Create symlinks only
./run.sh --help        # Show help
```

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
