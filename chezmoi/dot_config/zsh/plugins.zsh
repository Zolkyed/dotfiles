plugins=(
  git
  sudo
  extract
  colored-man-pages
)

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# Auto-suggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606079,underline"
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf key bindings + completion (must come before fzf-tab)
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# fzf-tab
[[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]] &&
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# Zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Syntax highlighting must be sourced last
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
