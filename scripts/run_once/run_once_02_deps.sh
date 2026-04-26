#!/usr/bin/env bash
set -euo pipefail

echo "== Python CLI tools (pipx layer) =="

# Ensure pipx exists
if ! command -v pipx >/dev/null 2>&1; then
  echo "Installing pipx..."
  sudo pacman -S --needed python-pipx
  pipx ensurepath
fi

# Install konsave (important dependency for KDE system)
echo "Installing konsave..."
pipx install konsave || pipx upgrade konsave

echo "Python tools installed."