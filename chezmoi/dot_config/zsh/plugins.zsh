# oh-my-zsh bundled plugins only
plugins=(
  git
  sudo
  z
  extract
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# Arch package plugins
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf-tab (oh-my-zsh custom plugin)
[[ -f $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh ]] && source $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh

# spaceship from Arch package if not found by oh-my-zsh
if [[ ! -f $ZSH/custom/themes/spaceship.zsh-theme ]]; then
  source /usr/share/zsh/themes/spaceship.zsh 2>/dev/null || true
fi

# zsh-syntax-highlighting must be loaded last
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
