#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-default}"

echo "Restoring KDE profile: $PROFILE"

konsave -i "$HOME/.local/share/konsave/profiles/$PROFILE.knsv"
konsave -a "$PROFILE"

echo "Done."