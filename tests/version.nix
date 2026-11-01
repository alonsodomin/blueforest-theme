# SPDX-License-Identifier: MPL-2.0
#
# Checks the version of the sources of the repository.
#
# The version of a commit is derived from the tags of the repository, and the
# check runs the script that derives it against scratch repositories, so that
# every rule of it is covered.
#
# The check also makes sure that the repository does not carry a version of
# its own: the version comes from the tags, and the packages of the
# repository carry the revision of the commit they are built from.
{ pkgs }:
let
  # The script that derives the version of a commit from the tags.
  versionScript = ../tools/version.sh;
in
pkgs.runCommand "blueforest-version-check"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
    ];
    src = ../.;
  }
  ''
    # The repository does not carry a version of its own.
    cd "$src"
    for file in VERSION modules/*/VERSION; do
      if [ -e "$file" ]; then
        echo "$file exists: the version comes from the tags of the repository" >&2
        exit 1
      fi
    done

    jq -e '.version == "0.0.0"' modules/vscode/package.json >/dev/null

    # The scratch repository the version is derived from.
    export HOME="$TMPDIR"
    export GIT_CONFIG_NOSYSTEM=1
    export GIT_AUTHOR_NAME="Blueforest"
    export GIT_AUTHOR_EMAIL="blueforest@example.com"
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

    repo="$TMPDIR/repository"
    mkdir -p "$repo"
    cd "$repo"
    git init -q -b main .

    version() {
      bash ${versionScript} "$@"
    }

    check() {
      local expected="$1"
      local actual
      actual=$(version)
      if [ "$actual" != "$expected" ]; then
        echo "expected the version $expected, got $actual" >&2
        exit 1
      fi
    }

    echo one >file
    git add file
    git commit -qm one
    revision=$(git rev-parse --short=7 HEAD)

    # Without a tag, the version is the revision of the commit.
    check "0.0.0+$revision"

    # The tags that are not releases are ignored.
    git tag "release/0.3.2"
    git tag "v0.3"
    check "0.0.0+$revision"

    # A release tag is the version of the commit that carries it.
    git tag "v1.2.3"
    check "1.2.3"

    # The latest release is the base of the version of the commits after it.
    echo two >file
    git commit -qam two
    revision=$(git rev-parse --short=7 HEAD)
    check "1.2.3+$revision"

    # A tree that is not clean says so.
    echo three >>file
    check "1.2.3+$revision.dirty"
    git checkout -- file

    # The latest release is the one of the latest tag.
    git tag "v1.3.0"
    if [ "$(version --latest)" != "1.3.0" ]; then
      echo "the latest release is not 1.3.0" >&2
      exit 1
    fi

    touch $out
  ''
