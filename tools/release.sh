#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The release helper of the repository.
#
#   release.sh   release the repository
#
# The repository is released as a whole: one version, one tag and one GitHub
# release with the assets of every application. The helper asks for the
# version, stamps the changelogs with it, commits, tags and pushes. The push
# of the tag triggers the release workflow of the repository, which packages
# every application and publishes it.
#
# The version is checked against the releases of GitHub: a version that has a
# release already is never released again.
#
# The changelogs of the repository carry the changes that are not released
# yet under the heading "Unreleased". The release turns that heading into the
# heading of the release.
#
# Press Enter with an empty value at a prompt to abort, except at the prompt
# of the version, where it accepts the version that is offered.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

workflow="release.yml"

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

die() {
	printf '\nError: %s\n' "$1" >&2
	exit 1
}

abort() {
	printf '\nAborted. Nothing has been changed.\n'
	exit 0
}

require() {
	command -v "$1" >/dev/null 2>&1 || die "missing required program: $1"
}

# MAJOR.MINOR.PATCH, no leading zeros, no pre-release suffix.
is_semver() {
	[[ $1 =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

# True when $1 is strictly greater than $2.
version_gt() {
	local newer="$1" older="$2"
	if [ "$newer" = "$older" ]; then
		return 1
	fi
	[ "$(printf '%s\n%s\n' "$older" "$newer" | sort -V | tail -n1)" = "$newer" ]
}

# The version that follows the given one.
next_version() {
	local version="$1"
	local major minor patch
	IFS=. read -r major minor patch <<<"$version"
	printf '%s.%s.%s\n' "$major" "$minor" "$((patch + 1))"
}

# The body of the "Unreleased" section of a changelog.
unreleased_body() {
	awk '
		/^## / {
			if (inside) {
				exit
			}
			inside = ($0 == "## Unreleased")
			next
		}
		inside { print }
	' "$1"
}

# Turns the "Unreleased" section of a changelog into the section of a release.
stamp_changelog() {
	local file="$1" heading="$2"
	awk -v heading="$heading" '
		/^## Unreleased$/ { print heading; next }
		{ print }
	' "$file" >"$file.tmp"
	mv "$file.tmp" "$file"
}

# --------------------------------------------------------------------------
# 1. the repository
# --------------------------------------------------------------------------

printf '\nBlueforest release\n'
printf '===================\n'

for tool in git gh; do
	require "$tool"
done

branch=$(git -C "$repo_root" rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then
	die "detached HEAD; check out a branch before releasing"
fi

if [ -n "$(git -C "$repo_root" status --porcelain)" ]; then
	die "the working tree has uncommitted changes; commit or stash them first"
fi

if ! gh auth status >/dev/null 2>&1; then
	die "gh is not authenticated, so the releases of GitHub could not be read. Run: gh auth login"
fi

# The tags of the remote, so that the latest release and the tags that are
# taken are the ones of the remote.
git -C "$repo_root" fetch --quiet --tags origin ||
	die "could not fetch the tags of the repository"

# --------------------------------------------------------------------------
# 2. the version of the release
# --------------------------------------------------------------------------

current_version=$(bash "$repo_root/tools/version.sh" --latest)
if [ -z "$current_version" ]; then
	current_version="0.0.0"
	suggested_version="0.1.0"
else
	suggested_version=$(next_version "$current_version")
fi

printf '\nCurrent release: %s\n' "$current_version"
printf 'Enter the next version (Enter accepts %s): ' "$suggested_version"
if ! IFS= read -r version; then
	abort
fi
if [ -z "$version" ]; then
	version="$suggested_version"
fi

if ! is_semver "$version"; then
	die "not a MAJOR.MINOR.PATCH version: $version"
fi

if ! version_gt "$version" "$current_version"; then
	die "must be newer than the current release ($current_version)"
fi

tag="v$version"

# The version is checked against the releases of GitHub, and against the tags
# of the remote: a version that is taken already is never released again.
if gh release view "$tag" >/dev/null 2>&1; then
	die "the release $tag already exists on GitHub"
fi

if git -C "$repo_root" rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
	die "the tag $tag already exists"
fi

if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null 2>&1; then
	die "the tag $tag already exists on the remote"
fi

# --------------------------------------------------------------------------
# 3. the changelogs
# --------------------------------------------------------------------------

heading="## $version - [$(date +%d-%m-%Y)]"

changelogs=()
for file in "$repo_root/CHANGELOG.md" "$repo_root"/modules/*/CHANGELOG.md; do
	[ -f "$file" ] || continue
	body=$(unreleased_body "$file")
	if [ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
		changelogs+=("$file")
	fi
done

if [ "${#changelogs[@]}" -eq 0 ]; then
	die "there is nothing to release: no changelog has an Unreleased section"
fi

for file in "${changelogs[@]}"; do
	stamp_changelog "$file" "$heading"
done

printf '\nChanges to be committed:\n'
git -C "$repo_root" --no-pager diff --stat -- "${changelogs[@]}"

printf '\nThe release %s will be created with these changes.\n' "$tag"
printf 'Type the whole word "yes" to continue, Enter alone to abort: '
if ! IFS= read -r answer; then
	answer=""
fi
if [ "$answer" != "yes" ]; then
	git -C "$repo_root" checkout -- "${changelogs[@]}"
	printf '\nAborted. Nothing has been changed.\n'
	exit 0
fi

# --------------------------------------------------------------------------
# 4. the commit and the tag
# --------------------------------------------------------------------------

git -C "$repo_root" add "${changelogs[@]}"
git -C "$repo_root" commit -m "Release $version"
git -C "$repo_root" tag -a "$tag" -m "Release $version"

git -C "$repo_root" push origin "$branch"

if ! git -C "$repo_root" push origin "$tag"; then
	printf '\nThe commit is pushed, but the tag %s is not.\n' "$tag" >&2
	printf 'Push it with: git push origin %s\n' "$tag" >&2
	exit 1
fi

# --------------------------------------------------------------------------
# 5. the workflow
# --------------------------------------------------------------------------

repo_url=$(gh repo view --json url --jq .url)

printf '\n%s has been pushed to %s.\n' "$tag" "$branch"
printf 'The release workflow is running:\n  %s/actions/workflows/%s\n' \
	"$repo_url" "$workflow"
