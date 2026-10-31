#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# Updates the lock files of the repository.
#
#   update.sh          update the lock file of the repository and the lock file
#                      of every application
#   update.sh vscode   update the lock file of one application only
#
# The root flake owns the pins of the repository: the applications follow its
# inputs. Every application keeps a lock file of its own, for the consumers
# that take it on its own, so the script updates that lock file as well, and
# pins the inputs that the application shares with the repository to the
# revisions the repository resolved, so that both agree.

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

# The locked node of an input of a lock file, when the input is one that can
# be pinned to a revision of a git repository.
locked_node() {
	jq -r --arg input "$2" '
		.nodes[.root].inputs[$input] as $reference
		| select($reference != null)
		| ($reference | if type == "string" then . else .[0] end) as $node
		| .nodes[$node]
		| select(. != null)
		| select(.locked.rev != null)
		| select(.locked.type == "github" or .locked.type == "gitlab" or .locked.type == "sourcehut")
		| .locked
	' "$1"
}

# The revision of an input of a lock file, when the input is pinned to a git
# reference that can be pinned again.
locked_revision() {
	locked_node "$1" "$2" | jq -r '.rev'
}

# The flake reference of an input of a lock file, at the revision it is locked
# to. It is the reference that pins the input again, whichever branch or tag
# the input follows.
locked_ref() {
	locked_node "$1" "$2" | jq -r '"\(.type):\(.owner)/\(.repo)/\(.rev)"'
}

# The names of the direct inputs of a lock file.
input_names() {
	jq -r '.nodes[.root].inputs | keys[]' "$1"
}

# The applications of the repository, in the order of their directories.
applications() {
	local dir
	for dir in "$repo_root"/modules/*/; do
		[ -d "$dir" ] || continue
		[ -f "${dir}flake.lock" ] || continue
		basename "${dir%/}"
	done
}

# Pins the inputs that an application shares with the repository to the
# revisions the repository resolved, so that both agree.
#
# The lock file of an application is updated on its own, so it can end up at
# a revision that is one commit ahead of the lock file of the repository.
sync_application() {
	local app_lock="$1"
	local input app_revision repository_ref
	local overrides=()

	while read -r input; do
		app_revision="$(locked_revision "$app_lock" "$input")"
		repository_ref="$(locked_ref "$root_lock" "$input")"

		# The input is not a git reference, or the repository does not have
		# it: there is nothing to pin.
		[ -n "$app_revision" ] || continue
		[ -n "$repository_ref" ] || continue

		[ "$app_revision" != "${repository_ref##*/}" ] || continue

		overrides+=(--override-input "$input" "$repository_ref")
	done < <(input_names "$app_lock")

	[ "${#overrides[@]}" -eq 0 ] && return 0

	printf '  Pinning the shared inputs to the revisions of the repository.\n'
	(
		cd "$(dirname "$app_lock")"
		nix flake lock "${overrides[@]}"
	)
}

update_application() {
	local app="$1"
	local app_dir="$repo_root/modules/$app"
	local app_lock="$app_dir/flake.lock"

	[ -d "$app_dir" ] || die "unknown application: $app"
	[ -f "$app_lock" ] || die "the application has no lock file: $app"

	printf '\n==> %s\n\n' "$app"

	(
		cd "$app_dir"
		nix flake update
	)

	sync_application "$app_lock"
}

# --------------------------------------------------------------------------
# the arguments
# --------------------------------------------------------------------------

usage() {
	printf 'Usage: %s [app...]\n\n' "$(basename "$0")"
	printf 'Updates the lock file of the repository, and the lock file of every\n'
	printf 'application given, or of every application of the repository.\n\n'
	printf 'Applications: %s\n' "$(applications | tr '\n' ' ')"
}

require nix
require jq
require git

[ -f "$root_lock" ] || die "lock file not found: $root_lock"

case "${1:-}" in
-h | --help)
	usage
	exit 0
	;;
esac

selected=()
if [ "$#" -eq 0 ]; then
	while read -r app; do
		selected+=("$app")
	done < <(applications)
else
	selected=("$@")
fi

[ "${#selected[@]}" -gt 0 ] || die "there are no applications to update"

# --------------------------------------------------------------------------
# the repository
# --------------------------------------------------------------------------

printf '\n==> repository\n\n'
nix flake update

# --------------------------------------------------------------------------
# the applications
# --------------------------------------------------------------------------

for app in "${selected[@]}"; do
	update_application "$app"
done

printf '\nThe lock files are updated.\n'
