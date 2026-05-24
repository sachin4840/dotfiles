#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing packages..."

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> "$HOME/.zprofile"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
else
  echo "==> Homebrew already installed, updating..."
  brew update
fi

# --- Brew formulae ---
FORMULAE=(
  neovim
  tmux
  bat
  tree
  zsh-autosuggestions
  zsh-syntax-highlighting
  font-hack-nerd-font
  pre-commit
  zoxide
  fzf
  terminal-notifier
  gh
)

for formula in "${FORMULAE[@]}"; do
  if ! brew list "$formula" &>/dev/null; then
    echo "  Installing $formula..."
    brew install "$formula"
  else
    echo "  $formula already installed"
  fi
done

# --- Brew casks ---
CASKS=(
  iterm2
  rectangle
  stats
  alt-tab
)

for cask in "${CASKS[@]}"; do
  if ! brew list --cask "$cask" &>/dev/null; then
    echo "  Installing $cask..."
    brew install --cask "$cask"
  else
    echo "  $cask already installed"
  fi
done

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> Oh My Zsh already installed"
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "==> Powerlevel10k already installed"
fi

# --- TPM (Tmux Plugin Manager) ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "==> Installing TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "==> TPM already installed"
fi

# --- NVM & Node ---
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  echo "==> Installing latest Node.js..."
  nvm install node
else
  echo "==> NVM already installed"
fi

echo "==> Package installation complete!"
