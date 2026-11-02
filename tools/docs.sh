#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# Builds and serves the documentation of the repository.
#
#   docs.sh generate   generates the site under the data directory of the
#                      project
#   docs.sh serve      generates the site and serves it locally
#   docs.sh watch      generates the site, serves it locally, and generates it
#                      again whenever a source of the documentation changes
#
# The site is generated with the mkdocs of the documentation flake, which
# carries the theme of Material for MkDocs that the site of the repository
# uses.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

cd "$repo_root"

# The directory the site is generated in. The development shell sets it to the
# data directory of the project, which is `.data` by default.
data_dir="${PRJ_DATA_DIR:-$repo_root/.data}"
site_dir="$data_dir/site"

require() {
	command -v "$1" >/dev/null 2>&1 || {
		printf '\nError: missing required program: %s\n' "$1" >&2
		exit 1
	}
}

usage() {
	printf 'Usage: %s {generate|serve|watch}\n\n' "$(basename "$0")"
	printf '  generate   generate the site under %s\n' "$site_dir"
	printf '  serve      generate the site and serve it locally\n'
	printf '  watch      serve the site locally and generate it again on every change\n'
}

require mkdocs

case "${1:-}" in
-h | --help)
	usage
	exit 0
	;;
generate)
	shift
	exec mkdocs build --strict --site-dir "$site_dir" "$@"
	;;
serve)
	shift
	exec mkdocs serve --strict --no-livereload "$@"
	;;
watch)
	shift
	exec mkdocs serve --strict "$@"
	;;
*)
	usage >&2
	exit 1
	;;
esac
