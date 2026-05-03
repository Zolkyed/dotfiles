#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
profiles_dir="$repo_root/kde/konsave"

profile_name="${1:-default}"
archive_path="$profiles_dir/$profile_name.knsv"

if ! command -v konsave >/dev/null 2>&1; then
	echo "konsave is not installed. Install it first (for example: pipx install konsave)." >&2
	exit 1
fi

if [[ ! -f "$archive_path" ]]; then
	echo "Profile archive not found: $archive_path" >&2
	echo "Available archives:" >&2
	ls -1 "$profiles_dir"/*.knsv 2>/dev/null || echo "(none)" >&2
	exit 1
fi

konsave -i "$archive_path"
echo "Imported profile from: $archive_path"
