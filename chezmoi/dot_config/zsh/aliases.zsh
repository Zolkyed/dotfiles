# Core tools
alias cat='bat --paging=never'
alias find='fd'
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias grep='rg'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias top='htop'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Pacman
alias update='sudo pacman -Syu'
alias in='sudo pacman -S'
alias pacrem='sudo pacman -Rns'
alias search='pacman -Ss'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Convenience
alias cd='z'
alias reload='source ~/.zshrc'
alias zshrc='$EDITOR ~/.zshrc'
alias please='sudo !!'
alias c='clear'

# Global
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
