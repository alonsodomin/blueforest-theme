# SPDX-License-Identifier: MPL-2.0
#
# The release of the repository.
#
# The wrapper supplies CoCoGitto, the conventional commit toolbox of the
# repository, which writes the changelogs of the release and tags it. The
# script itself is `tools/release/main.sh`.
{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "blueforest-release";
  text = ''exec ${./main.sh} "$@"'';
  inheritPath = false;
  runtimeInputs = [
    pkgs.bash
    pkgs.coreutils
    pkgs.cocogitto
    pkgs.git
    pkgs.gnugrep
    pkgs.gnused
  ];
}
