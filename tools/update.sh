#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# Updates the lock file of the repository.
#
#   update.sh   update the lock file of the repository
#
# The repository is a flake, and the applications are modules of it: the root
# flake owns the pins of the repository, and there is one lock file, the one
# of the root flake.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

cd "$repo_root"

root_lock="$repo_root/flake.lock"

require() {
	command -v "$1" >/dev/null 2>&1 || {
		printf '\nError: missing required program: %s\n' "$1" >&2
		exit 1
	}
}

die() {
	printf '\nError: %s\n' "$1" >&2
	exit 1
}

usage() {
	printf 'Usage: %s\n\n' "$(basename "$0")"
	printf 'Updates the lock file of the repository.\n'
}

require nix
require git

[ -f "$root_lock" ] || die "lock file not found: $root_lock"

case "${1:-}" in
-h | --help)
	usage
	exit 0
	;;
esac

# --------------------------------------------------------------------------
# the repository
# --------------------------------------------------------------------------

printf '\n==> repository\n\n'
nix flake update

printf '\nThe lock file is updated.\n'
