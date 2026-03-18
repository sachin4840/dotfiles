# --- Homebrew ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- NVM (installed via install.sh) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Core Aliases ---
alias v='vim'
alias n="nvim"
alias t=tmux
alias tx="tmux new -A -s default"

# ============================================
# DO NOT ADD ANYTHING BELOW THIS LINE
# Machine-specific configs go in ~/.zprofile.local
# ============================================
[ -f ~/.zprofile.local ] && source ~/.zprofile.local
