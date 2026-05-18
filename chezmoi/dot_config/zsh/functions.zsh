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

# Find files by name
ff() {
  command find . -iname "*$1*" 2>/dev/null
}

# Find text inside files (requires ripgrep)
ftext() {
  rg -l "$1" 2>/dev/null
}

# Copy file content to clipboard
copyfile() {
  cat "$1" | wl-copy 2>/dev/null || cat "$1" | xclip -selection clipboard
}

# Copy current directory path to clipboard
copypath() {
  pwd | wl-copy 2>/dev/null || pwd | xclip -selection clipboard
}

# Kill process by port
killport() {
  kill -9 "$(lsof -t -i:"$1")" 2>/dev/null
}
