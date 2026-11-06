#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The changelog of the changes that are not released yet.
#
#   changelog.sh [--output <dir>]
#
# The script writes the changelog of the commits that are not released yet
# to the data directory of the project, under `changelog/`, and prints it.
# The data directory is `.data` by default, and it is ignored by git: the
# changelog of the release is written by the release itself, into the
# changelog files of the repository.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

cd "$repo_root"

# The directory the changelog is written to. The development shell sets the
# data directory of the project, which is `.data` by default.
data_dir="${PRJ_DATA_DIR:-$repo_root/.data}"
output="$data_dir/changelog"

require() {
	command -v "$1" >/dev/null 2>&1 || {
		printf '\nError: missing required program: %s\n' "$1" >&2
		exit 1
	}
}

usage() {
	printf 'Usage: %s [--output <dir>]\n\n' "$(basename "$0")"
	printf '  --output <dir>   the directory the changelog is written to (%s)\n' "$output"
}

while [ $# -gt 0 ]; do
	case "$1" in
	--output)
		output="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		usage >&2
		exit 1
		;;
	esac
done

require cog
require git

# The last release of the repository. The tags of the applications carry the
# name of the application before the prefix, so they are not releases of the
# repository.
last_tag=$(git tag --list 'v[0-9]*' --sort=-version:refname |
	grep -E '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' |
	head -n1 || true)

if [ -z "$last_tag" ]; then
	# The repository has no release yet: every commit is unreleased.
	range=".."
else
	range="$last_tag.."
fi

mkdir -p "$output"

# The changelog of the unreleased commits, with the links to the commits and
# to the authors.
cog changelog --unified "$range" >"$output/CHANGELOG.md"

printf '\nThe changelog of the unreleased changes is in %s\n\n' "$output/CHANGELOG.md"
cat "$output/CHANGELOG.md"
