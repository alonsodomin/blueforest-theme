#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The release of the repository.
#
#   release.sh
#
# The script releases the repository with CoCoGitto. `cog bump --auto`
# computes the version of every application that changed, writes the
# changelogs, commits them, and tags the release. The script pushes the
# branch and the tags afterwards, and the push of the tag of the release
# triggers the release workflow, which packages every application and
# publishes it.
#
# The release is one tag and one version for the repository, and every
# application that changed has a version and a tag of its own.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

cd "$repo_root"

# The branch the release is made from.
branch="$(git rev-parse --abbrev-ref HEAD)"

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

die() {
	printf '\nError: %s\n' "$1" >&2
	exit 1
}

require() {
	command -v "$1" >/dev/null 2>&1 || die "missing required program: $1"
}

# The tags of the releases of the repository, without the prefix.
release_tags() {
	git tag --list 'v*' --sort=-version:refname |
		grep -E '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' || true
}

# --------------------------------------------------------------------------
# 1. the repository
# --------------------------------------------------------------------------

printf '\nBlueforest release\n'
printf '===================\n'

for tool in git cog; do
	require "$tool"
done

if [ "$branch" = "HEAD" ]; then
	die "detached HEAD; check out a branch before releasing"
fi

if [ "$branch" != "master" ]; then
	die "the release is made from master, not from $branch"
fi

if [ -n "$(git status --porcelain)" ]; then
	die "the working tree has uncommitted changes; commit or stash them first"
fi

current_version=$(release_tags | head -n1)
printf '\nCurrent release: %s\n' "${current_version:-none}"

# --------------------------------------------------------------------------
# 2. the release
# --------------------------------------------------------------------------

# The bump writes the changelogs of the repository and of the applications
# that changed, commits them, and tags the release.
printf '\nThe release is being prepared...\n'
cog bump --auto

# The tag of the release, which the release workflow runs on.
tag=$(git tag --list 'v*' --sort=-version:refname |
	grep -E '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' |
	head -n1 || true)

if [ -z "$tag" ]; then
	die "the bump did not tag the release"
fi

version="${tag#v}"

printf '\nThe release %s is ready:\n' "$version"
git --no-pager log --oneline -1
git tag --list 'v*' --sort=-version:refname | head -n5

# --------------------------------------------------------------------------
# 3. the push
# --------------------------------------------------------------------------

printf '\nDo you want to push the release? Type yes to continue: '
if ! IFS= read -r answer; then
	answer=""
fi
if [ "$answer" != "yes" ]; then
	printf '\nThe release was not pushed. The commit and the tags are local.\n'
	exit 0
fi

# The guard of the tags lets the push of the release through.
export BLUEFOREST_RELEASE=1

git push origin "$branch"
# The tags of CoCoGitto are lightweight, so they are pushed one by one.
git push origin --tags

repo_url=$(git remote get-url origin 2>/dev/null |
	sed -e 's|^git@github.com:|https://github.com/|' -e 's|\.git$||' || true)

printf '\n%s has been pushed to %s.\n' "$tag" "$branch"
printf 'The release workflow is running:\n  %s/actions/workflows/release.yml\n' \
	"$repo_url"
