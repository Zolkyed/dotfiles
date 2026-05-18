# --- Core tool replacements ---
alias cat='bat --paging=never'
alias find='fd'
alias grep='rg'
alias diff='diff --color=auto'
alias ip='ip -c'
alias ls='eza --icons=auto'
alias ll='eza -lah --icons=auto --git'
alias la='eza -a --icons=auto'
alias lt='eza --tree --icons=auto'
alias top='htop'
alias df='df -h'
alias du='du -sh'
alias free='free -h'

# --- Editors ---
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# --- Network ---
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'

# --- Git ---
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gst='git stash'

# --- Pacman ---
alias update='sudo pacman -Syu'
alias in='sudo pacman -S'
alias pacrem='sudo pacman -Rns'
alias search='pacman -Ss'

# --- Safety ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# --- Convenience ---
alias cd='z'
alias c='clear'
alias reload='source ~/.zshrc'
alias zshrc='$EDITOR ~/.zshrc'
alias please='sudo !!'

# --- Global path shortcuts ---
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
