# --- Oh-My-Zsh plugins ---
plugins=(
  git             # git aliases and prompt info
  sudo            # ESC ESC to prepend sudo to previous command
  extract         # 'x' to extract any archive format
  colored-man-pages
)

[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# --- zsh-autosuggestions ---
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606079,underline"
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- fzf (must come before fzf-tab) ---
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# --- fzf-tab ---
[[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]] &&
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# --- Zoxide ---
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# --- zsh-syntax-highlighting (must be last) ---
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
