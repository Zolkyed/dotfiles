# Use fd for fzf path/dir completion
_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }

# Command-specific fzf previews
_fzf_comprun() {
  local command=$1; shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always --icons {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "$_fzf_file_preview" "$@" ;;
  esac
}

# Yazi - cd to last directory on exit
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Fuzzy find file and open in editor
ff() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat -n --color=always {}') && $EDITOR "$file"
}

# Fuzzy find text in files and open match in editor
ftext() {
  local result file line
  result=$(rg --color=always --line-number --no-heading "$1" | fzf --ansi --delimiter=: --preview 'bat -n --color=always --highlight-line {2} {1}' --preview-window=right:60%) \
    && file=$(echo "$result" | cut -d: -f1) \
    && line=$(echo "$result" | cut -d: -f2) \
    && $EDITOR +"$line" "$file"
}

# Copy file content to clipboard
copyfile() {
  wl-copy < "$1" 2>/dev/null || xclip -selection clipboard < "$1"
}

# Copy current directory path to clipboard
copypath() {
  printf '%s' "$PWD" | wl-copy 2>/dev/null || printf '%s' "$PWD" | xclip -selection clipboard
}

# Kill process by port
killport() {
  kill -9 "$(lsof -t -i:"$1")" 2>/dev/null
}
