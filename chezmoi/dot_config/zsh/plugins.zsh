# --- sudo widget (ESC ESC to prepend/strip sudo) ---
_sudo_command_line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N _sudo_command_line
bindkey '\e\e' _sudo_command_line

# --- extract function (replaces OMZ extract plugin) ---
x() {
  if [[ -z "$1" ]]; then echo "Usage: x <archive>"; return 1; fi
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1"          ;;
    *.tar.gz|*.tgz)   tar xzf "$1"          ;;
    *.tar.xz)          tar xJf "$1"          ;;
    *.tar.zst)         tar --zstd -xf "$1"   ;;
    *.tar)             tar xf "$1"           ;;
    *.bz2)             bunzip2 "$1"          ;;
    *.gz)              gunzip "$1"           ;;
    *.zip)             unzip "$1"            ;;
    *.Z)               uncompress "$1"       ;;
    *.7z)              7z x "$1"             ;;
    *.xz)              unxz "$1"             ;;
    *.zst)             unzstd "$1"           ;;
    *)                 echo "Unknown archive format: $1" ;;
  esac
}

# --- zsh-autosuggestions ---
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#606079,underline"
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- fzf (must come before fzf-tab) ---
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

# --- Spaceship prompt ---
if [[ -f /usr/lib/spaceship-prompt/spaceship.zsh ]]; then
  source /usr/lib/spaceship-prompt/spaceship.zsh
fi

# --- zsh-syntax-highlighting (must be last) ---
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
