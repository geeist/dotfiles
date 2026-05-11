# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Plugins
plugins=(
  git
  brew
  macos
  docker
  kubectl
  terraform
  aws
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# GHOSTTY INTEGRATION
# ============================================================================

# Set TERM for optimal Ghostty experience
export TERM="xterm-256color"
export COLORTERM="truecolor"

# Enhanced Ghostty shell integration
# Ghostty automatically injects shell integration, but we add manual fallback
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  # Verify automatic integration is working
  if ! type ghostty_prompt_mark &>/dev/null; then
    # Fallback to manual integration if auto-injection failed
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" 2>/dev/null || true
  fi

  # Enhanced terminal title for better VS Code integration
  autoload -Uz add-zsh-hook

  function ghostty_set_title() {
    # Set both tab title and window title
    print -Pn "\e]0;%n@%m: %~\a"
    print -Pn "\e]1;%~\a"
  }

  add-zsh-hook precmd ghostty_set_title

  # Mark command boundaries for better semantic selection
  function ghostty_preexec() {
    # Mark the start of command execution
    print -Pn "\e]133;C\a"
  }

  add-zsh-hook preexec ghostty_preexec
fi

# ============================================================================
# DEVELOPMENT ENVIRONMENT SETUP
# ============================================================================
# Go development
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fnm (Node version manager)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Ghostty terminal command line tools
export PATH="/Applications/Ghostty.app/Contents/MacOS:$PATH"

# Colima docker socket (for tools that ignore docker contexts, e.g. testcontainers)
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
# Path testcontainers bind-mounts into the Ryuk reaper container; Colima's host
# socket isn't at /var/run/docker.sock, but Ryuk expects that canonical path inside.
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"

# Advanced docker functions
dockershell() {
  local container=${1:-$(docker ps --format "{{.Names}}" | head -1)}
  if [ -n "$container" ]; then
    echo "🐚 Entering container: $container"
    docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
  else
    echo "❌ No running containers found"
  fi
}

dockerlogs() {
  local container=${1:-$(docker ps --format "{{.Names}}" | head -1)}
  if [ -n "$container" ]; then
    docker logs -f "$container"
  else
    echo "❌ No running containers found"
  fi
}

# Enhanced kubernetes functions
kubeshell() {
  local pod=${1:-$(kubectl get pods -o name | head -1 | cut -d/ -f2)}
  if [ -n "$pod" ]; then
    echo "🐚 Entering pod: $pod"
    kubectl exec -it "$pod" -- /bin/bash || kubectl exec -it "$pod" -- /bin/sh
  else
    echo "❌ No pods found"
  fi
}

# ============================================================================
# ENVIRONMENT VARIABLES - Optimized for 2025
# ============================================================================

# Terminal and color support
export TERM='xterm-256color'
export COLORTERM='truecolor'

# Optimize for Ghostty's capabilities
export MANPAGER="bat --language man --style plain"
export PAGER="bat --style plain"

# Development
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# History configuration - Enhanced
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST

# ============================================================================
# FZF INTEGRATION - Enhanced for Ghostty
# ============================================================================

# Enhanced FZF setup if available
if command -v fzf &>/dev/null; then
  # Key bindings
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Custom functions using fzf
  fcd() {
    local dir
    dir=$(fd --type d 2>/dev/null | fzf --preview 'eza --tree --level=2 {}' || find . -type d 2>/dev/null | fzf) && cd "$dir"
  }

  fcode() {
    local file
    file=$(fd --type f 2>/dev/null | fzf --preview 'bat --color=always {}' || find . -type f 2>/dev/null | fzf) && code "$file"
  }

  # Git integration with fzf
  fgco() {
    local branch
    branch=$(git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf) && git checkout "$branch"
  }

  # Process killer with fzf
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
      echo $pid | xargs kill -${1:-9}
    fi
  }
fi

# ============================================================================
# STARSHIP
# ============================================================================

eval "$(starship init zsh)"


# ============================================================================
# LOAD EXTERNAL CONFIGURATIONS
# ============================================================================

# Load aliases from separate file
[[ -f "$ZSH_CUSTOM/aliases.sh" ]] && source "$ZSH_CUSTOM/aliases.sh"
[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"

# Load local customizations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load any work-specific configurations
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work
