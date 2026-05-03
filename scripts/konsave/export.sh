#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
profiles_dir="$repo_root/kde/konsave"

profile_name="${1:-default}"
export_name="${2:-$profile_name}"

if ! command -v konsave >/dev/null 2>&1; then
	echo "konsave is not installed. Install it first (for example: pipx install konsave)." >&2
	exit 1
fi

mkdir -p "$profiles_dir"

# Refresh the local konsave profile, then export a deterministic .knsv into the repo.
konsave -s "$profile_name" -f
konsave -e "$profile_name" -d "$profiles_dir" -n "$export_name" -f

echo "Exported profile '$profile_name' to: $profiles_dir/$export_name.knsv"
