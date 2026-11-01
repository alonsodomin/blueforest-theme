# SPDX-License-Identifier: MPL-2.0
#
# The release helper of the repository.
#
# tools/release.sh releases the repository: it asks for the version, stamps
# the changelogs, commits, tags and pushes. The push of the tag triggers the
# release workflow, which packages every application and publishes it.
#
# The wrapper only supplies a hermetic PATH with the tools the script needs.
{ pkgs }:
pkgs.writeShellApplication {
  name = "release";
  text = ''exec ${./release.sh} "$@"'';
  inheritPath = false;
  runtimeInputs = [
    pkgs.bash
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnugrep
    pkgs.git
    pkgs.gh
  ];
}
