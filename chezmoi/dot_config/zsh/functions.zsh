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
