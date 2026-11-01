#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The version of the sources of the repository.
#
#   version.sh           the version of the commit of HEAD
#   version.sh --latest  the version of the latest release
#
# A release of the repository is a tag of the form vMAJOR.MINOR.PATCH, and a
# commit that carries such a tag is the version of the tag. Every other
# commit carries the version of the latest release before it, with the hash
# of the commit appended, so that two commits never share a version. A tree
# that is not clean carries a ".dirty" suffix as well.
#
# The tags of the repository before this scheme are not releases, and they are
# ignored: only the tags of the strict form are.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

cd "$repo_root"

# The tags that are releases of the repository.
readonly TAG_PATTERN='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

# The latest release tag of the repository, without the "v" of the tag.
latest_version() {
	local tag
	tag=$(git tag --list 'v*' --sort=-version:refname | grep -E "$TAG_PATTERN" | head -n1 || true)
	[ -n "$tag" ] || return 0
	printf '%s\n' "${tag#v}"
}

# The release tag of the commit of HEAD, without the "v" of the tag.
version_of_head() {
	local tag
	tag=$(git tag --points-at HEAD --list 'v*' --sort=-version:refname | grep -E "$TAG_PATTERN" | head -n1 || true)
	[ -n "$tag" ] || return 0
	printf '%s\n' "${tag#v}"
}

usage() {
	printf 'Usage: %s [--latest]\n\n' "$(basename "$0")"
	printf '  (no option)  the version of the commit of HEAD\n'
	printf '  --latest     the version of the latest release\n'
}

case "${1:-}" in
-h | --help)
	usage
	exit 0
	;;
--latest)
	latest_version
	exit 0
	;;
"")
	;;
*)
	usage >&2
	exit 1
	;;
esac

# The hash of the commit, which tells two commits apart.
revision=$(git rev-parse --short=7 HEAD)

# The suffix of a tree that carries changes that are not committed. The files
# that are not tracked are not part of the sources, so they do not count.
suffix=""
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
	suffix=".dirty"
fi

# The version of the tag of the commit, when it carries one.
tag_version=$(version_of_head)
if [ -n "$tag_version" ]; then
	if [ -n "$suffix" ]; then
		printf '%s+%s%s\n' "$tag_version" "$revision" "$suffix"
	else
		printf '%s\n' "$tag_version"
	fi
	exit 0
fi

# The version of the latest release, which is the base of the version of a
# commit that is not a release itself.
base=$(latest_version)
if [ -z "$base" ]; then
	base="0.0.0"
fi

printf '%s+%s%s\n' "$base" "$revision" "$suffix"
