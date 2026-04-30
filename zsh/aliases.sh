#!/bin/zsh
# shellcheck shell=bash

# ============================================================================
# SYSTEM ALIASES
# ============================================================================

# Enhanced directory listing with modern tools
if command -v eza &>/dev/null; then
  alias ls='eza --icons --git --group-directories-first'
  alias la='eza -la --icons --git --group-directories-first'
  alias ll='eza -la --icons --git --time-style=long-iso --group-directories-first'
  alias tree='eza --tree --icons --git'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls -G --color=auto'
  alias la='ls -la'
  alias ll='ls -la'
fi

# Quick access to common directories
alias developer='cd ~/Developer'

# System shortcuts
alias reload='source ~/.zshrc && echo "✅ Zsh configuration reloaded"'

# Docker shortcuts with better formatting
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"'
alias dv='docker volume ls'
alias dn='docker network ls'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -f'
alias dcleanall='docker system prune -a -f'

# Docker Compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs'
alias dcr='docker-compose restart'

# Kubernetes shortcuts
alias k='kubectl'
alias kgp='kubectl get pods -o wide'
alias kgs='kubectl get services -o wide'
alias kgd='kubectl get deployments -o wide'
alias kgn='kubectl get nodes -o wide'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
alias kctx='kubectl config current-context'
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'
