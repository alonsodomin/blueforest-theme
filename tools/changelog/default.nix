# SPDX-License-Identifier: MPL-2.0
#
# The changelog of the changes that are not released yet.
#
# The wrapper supplies CoCoGitto, the conventional commit toolbox of the
# repository, which reads the commits of the repository. The script itself is
# `tools/changelog/main.sh`.
{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "blueforest-changelog";
  text = ''exec ${./main.sh} "$@"'';
  inheritPath = false;
  runtimeInputs = [
    pkgs.bash
    pkgs.coreutils
    pkgs.cocogitto
    pkgs.git
    pkgs.gnugrep
  ];
}
