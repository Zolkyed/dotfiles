#!/usr/bin/env bash
set -euo pipefail

FILE="${CHEZMOI_SOURCE_DIR:-.}/packages.yaml"
PROFILE="${1:-all}"

command -v yq >/dev/null || exit 1
command -v paru >/dev/null || exit 1

if [[ "$PROFILE" == "all" ]]; then
  QUERY='.packages | .. | select(tag != "!!map")'
else
  QUERY=".packages.${PROFILE} | .. | select(tag != \"!!map\")"
fi

mapfile -t PKGS < <(yq -r "$QUERY" "$FILE")

paru -S --needed --noconfirm "${PKGS[@]}"