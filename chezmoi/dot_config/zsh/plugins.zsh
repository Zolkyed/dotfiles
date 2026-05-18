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
# Cache the init script — regenerate only when fzf binary changes
if command -v fzf &>/dev/null; then
  _fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf-init.zsh"
  if [[ ! -f "$_fzf_cache" || "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    fzf --zsh >| "$_fzf_cache"
  fi
  source "$_fzf_cache"
fi

# --- fzf-tab ---
[[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]] &&
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# --- Zoxide ---
if command -v zoxide &>/dev/null; then
  _zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zoxide-init.zsh"
  if [[ ! -f "$_zoxide_cache" || "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    zoxide init zsh >| "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
fi

# --- zsh-syntax-highlighting (must be last) ---
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
