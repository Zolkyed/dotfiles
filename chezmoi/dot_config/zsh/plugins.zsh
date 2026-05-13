plugins=(
  git
  sudo
  z
  extract
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

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

# Spaceship fallback
if [[ ! -f $ZSH/custom/themes/spaceship.zsh-theme ]]; then
  source /usr/share/zsh/themes/spaceship.zsh 2>/dev/null || true
fi

# Zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
