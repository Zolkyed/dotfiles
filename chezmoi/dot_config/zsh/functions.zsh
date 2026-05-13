# Extract any archive
extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "extract: unknown archive: $1" ;;
  esac
}

# Find files by name
ff() {
  find . -iname "*$1*" 2>/dev/null
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