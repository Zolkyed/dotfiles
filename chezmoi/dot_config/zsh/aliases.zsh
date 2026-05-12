# ===============================
# Basic Navigation & Terminal
# ===============================
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'

# ===============================
# Pacman / System Management
# ===============================
alias update='sudo pacman -Syu'
alias in='sudo pacman -S'
alias rm='sudo pacman -R'
alias rmc='sudo pacman -Rns'
alias search='pacman -Ss'
alias installed='pacman -Q'
alias clean='sudo pacman -Sc'
alias cleanall='sudo pacman -Scc'

# ===============================
# Git Shortcuts
# ===============================
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git pull'
alias gpush='git push'
alias gl='git log --oneline --graph --decorate'
alias ga='git add'
alias gc='git commit -v'
alias gcam='git commit -am'

# ===============================
# Docker Commands
# ===============================
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'

# ===============================
# Safety & Utilities
# ===============================
alias please='sudo !!'
alias grep='grep --color=auto'
alias e='exit'
alias mkdir='mkdir -pv'