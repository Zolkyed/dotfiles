#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# CONFIG VARIABLES
# ==================================================

REPO="$(chezmoi source-path 2>/dev/null || true)"

PROFILE_DEFAULT="default"

KONSAVE_CONFIG_DIR="$HOME/.config/konsave/profiles"

REPO_DEST_DIR="$REPO/desktop/kde/profiles"

# ==================================================
# VALIDATION
# ==================================================

if [[ -z "$REPO" ]]; then
  echo "Error: not inside a chezmoi source directory"
  exit 1
fi

if ! command -v konsave >/dev/null 2>&1; then
  echo "Error: konsave is not installed"
  exit 1
fi

# ==================================================
# USER INPUT
# ==================================================

read -rp "Enter KDE profile name [$PROFILE_DEFAULT]: " PROFILE
PROFILE="${PROFILE:-$PROFILE_DEFAULT}"
PROFILE="${PROFILE// /_}"

SRC_FILE="$KONSAVE_CONFIG_DIR/$PROFILE.knsv"
DEST_FILE="$REPO_DEST_DIR/$PROFILE.knsv"

# ==================================================
# PREPARE DIRECTORIES
# ==================================================

mkdir -p "$REPO_DEST_DIR"

# ==================================================
# SAFETY CHECK
# ==================================================

if [[ -f "$DEST_FILE" ]]; then
  read -rp "Profile exists. Overwrite? (y/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || {
    echo "Aborted."
    exit 0
  }
fi

# ==================================================
# EXPORT KDE PROFILE
# ==================================================

echo "Exporting KDE profile: $PROFILE"

konsave -s "$PROFILE"
konsave -e "$PROFILE"

if [[ ! -f "$SRC_FILE" ]]; then
  echo "Error: konsave export failed: $SRC_FILE not found"
  exit 1
fi

# ==================================================
# COPY INTO REPO
# ==================================================

cp "$SRC_FILE" "$DEST_FILE"

echo "Saved to repo:"
echo "  $DEST_FILE"

# ==================================================
# GIT STAGING
# ==================================================

cd "$REPO"
git add desktop/kde/profiles >/dev/null 2>&1 || true

# ==================================================
# FINAL OUTPUT
# ==================================================

echo ""
echo "✔ KDE profile exported successfully"
echo "→ Commit with:"
echo "   git commit -m \"kde: update profile $PROFILE\""