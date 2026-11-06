#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The guard of the tags.
#
#   git-guard/main.sh
#
# The script is the `pre-push` hook of the repository, which the development
# shell installs. It reads the refs that are being pushed, and it stops the
# push of a tag of a release when the user did not confirm it: the release
# of the repository is made with `nix run .#release`, which is the only way
# to write the changelog of the release and to tag it.
#
# The guard speaks to a person: it says nothing when it has no terminal to
# ask in, and it says nothing when the release helper pushes the tags, which
# it marks with the variable BLUEFOREST_RELEASE.

set -euo pipefail

# The release helper pushes the tags of the release itself.
if [ -n "${BLUEFOREST_RELEASE:-}" ]; then
	exit 0
fi

# The tags of a release: the tag of the repository, and the tags of the
# applications, which carry the name of the application before the prefix.
is_release_tag() {
	[[ $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
		[[ $1 =~ ^.+-v[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# The refs that are being pushed: the local ref, the local object, the
# remote ref and the remote object. A tag that is not on the remote yet has
# no object there.
tags=()
while read -r local_ref _local_object _remote_ref remote_object; do
	case "$local_ref" in
	refs/tags/*) ;;
	*) continue ;;
	esac

	if [ "$remote_object" != "0000000000000000000000000000000000000000" ]; then
		# The tag is on the remote already.
		continue
	fi

	name="${local_ref#refs/tags/}"
	if is_release_tag "$name"; then
		tags+=("$name")
	fi
done

if [ "${#tags[@]}" -eq 0 ]; then
	exit 0
fi

# The guard asks the user, so it needs a terminal to ask in.
if [ ! -t 0 ] && [ ! -t 2 ]; then
	exit 0
fi

printf '\nThe release of the repository is made with: nix run .#release\n' >&2
printf 'The tag %s would be pushed without the changelog of the release.\n' \
	"${tags[*]}" >&2
printf 'Do you still want to push it? Type yes to continue: ' >&2

answer=""
if ! read -r answer </dev/tty 2>/dev/null; then
	# There is no terminal to ask in.
	exit 0
fi

if [ "$answer" != "yes" ]; then
	printf '\nThe push was stopped. The tag is local.\n' >&2
	exit 1
fi
