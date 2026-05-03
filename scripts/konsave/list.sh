#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
profiles_dir="$repo_root/kde/konsave"

echo "Repo profile archives (.knsv):"
if [[ -d "$profiles_dir" ]]; then
	find "$profiles_dir" -maxdepth 1 -type f -name "*.knsv" -printf "%f\n" | sort || true
else
	echo "(folder does not exist yet: $profiles_dir)"
fi

if command -v konsave >/dev/null 2>&1; then
	echo
	echo "Installed konsave profiles:"
	konsave -l
else
	echo
	echo "konsave is not installed; skipping 'konsave -l'."
fi
