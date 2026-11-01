# SPDX-License-Identifier: MPL-2.0
#
# Checks that eza reads the theme of the repository and paints with it.
#
# eza ignores a theme it cannot read, and it ignores it silently: a malformed
# file, or a colour it cannot resolve, makes eza fall back to the theme it
# ships with. The check therefore reads the output of eza, and looks for the
# colours of the theme in it.
#
# The colours of the environment would take precedence over the theme, so
# they are unset before eza runs.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-eza-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.eza
    ];
  }
  ''
    work="$TMPDIR/work"
    config="$TMPDIR/config"

    mkdir -p "$work" "$config/eza"
    cp ${source} "$config/eza/theme.yml"

    # A directory, an executable, and a file.
    mkdir "$work/blueforest"
    printf '#!/bin/sh\n' >"$work/forest"
    chmod +x "$work/forest"
    touch "$work/file"

    unset LS_COLORS EXA_COLORS EZA_COLORS NO_COLOR

    # With the theme, eza paints the directory with the blue of BlueForest,
    # and the executable with the green of it.
    XDG_CONFIG_HOME="$config" eza --color=always "$work" >"$TMPDIR/themed"

    grep -q '38;2;0;153;255' "$TMPDIR/themed"
    grep -q '38;2;128;255;128' "$TMPDIR/themed"

    # Without the theme, eza paints with the colours of the theme it ships
    # with, which are the sixteen of the terminal, and none of them is one of
    # ours.
    mkdir "$TMPDIR/empty"
    XDG_CONFIG_HOME="$TMPDIR/empty" eza --color=always "$work" >"$TMPDIR/plain"

    ! grep -q '38;2;' "$TMPDIR/plain"

    touch $out
  ''
