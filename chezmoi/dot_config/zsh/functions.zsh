# Copy file content to clipboard
function copyfile() {
  cat "$1" | wl-copy 2>/dev/null || cat "$1" | xclip -selection clipboard
}

# Copy current directory path to clipboard
function copypath() {
  pwd | wl-copy 2>/dev/null || pwd | xclip -selection clipboard
}

# Create a directory and cd into it
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
function extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "unknown archive: $1" ;;
  esac
}

# Find file by name
function ff() {
  find . -iname "*$1*" 2>/dev/null
}

# Find text in files
function ftext() {
  rg -l "$1" 2>/dev/null
}

# Kill process by port
function killport() {
  kill -9 "$(lsof -t -i:"$1")" 2>/dev/null
}

# Weather
function weather() {
  curl "wttr.in/${1:-}" 2>/dev/null
}
