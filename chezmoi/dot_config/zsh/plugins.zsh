plugins=(
  git
  sudo
  z
  extract
  colored-man-pages
)

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# Auto-suggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444444'
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf-tab
[[ -f $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh ]] &&
  source $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh

# Spaceship
[[ -f /usr/share/zsh/themes/spaceship.zsh ]] &&
  source /usr/share/zsh/themes/spaceship.zsh

# Zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
