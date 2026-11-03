# SPDX-License-Identifier: MPL-2.0
#
# Checks that Yazi reads the flavours of the repository and paints with them.
#
# Yazi ignores a flavour it cannot read, and it ignores it silently: a
# malformed file, or a colour it cannot resolve, makes Yazi fall back to the
# preset it ships with. The check therefore reads the output of Yazi, and
# looks for the colours of the flavour in it.
#
# Yazi is a terminal program, and it needs a terminal to run in. The check
# gives it one with `script`, which allocates a pseudo terminal and runs Yazi
# in it. The colours of the theme are true colour, so the terminal has to
# support it.
#
# Yazi asks the terminal about its capabilities when it starts, and it applies
# the flavour when the terminal answers. The check answers the query the way a
# terminal would, and it answers it again and again, so that the flavour is
# applied as soon as Yazi is up.
#
# The theme of the user selects a flavour per mode, and the mode is the one
# the terminal reports. The check renders Yazi twice: once with a terminal
# that reports a dark scheme, and once with a terminal that reports a light
# one, and it looks at the colours of the flavour of that mode in the output.
{
  pkgs,
  source,
  sourceLight,
}:
pkgs.runCommand "blueforest-yazi-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.util-linux
      pkgs.yazi
    ];
  }
  ''
    work="$TMPDIR/work"
    config="$TMPDIR/config"

    # A directory, a file, and the configuration directory of Yazi with the
    # flavours in it.
    mkdir -p "$work/subdir" "$config/flavors/blueforest.yazi" \
      "$config/flavors/blueforest-light.yazi"
    touch "$work/file.txt"
    cp -r ${source}/. "$config/flavors/blueforest.yazi/"
    cp -r ${sourceLight}/. "$config/flavors/blueforest-light.yazi/"

    # And the theme of the user selects them, one per mode.
    printf '[flavor]\ndark = "blueforest"\nlight = "blueforest-light"\n' \
      >"$config/theme.toml"

    cd "$work"

    # The terminal of the check answers the queries of Yazi the way a
    # terminal would: the device attributes, and the colour scheme of the
    # terminal, which is what tells Yazi the mode it paints in.
    #
    # The answer of the colour scheme is the report of the mode: `997;1` is
    # a dark terminal, and `997;2` is a light one.
    answer() {
      local mode="$1"
      timeout 12 sh -c '
        while :; do
          printf "\033[?1;2c"
          printf "\033[?997;'"$mode"'n"
          sleep 1
        done
      '
    }

    # Yazi is killed after a while: it waits for a key that never comes, and
    # the check only reads what it painted.
    render() {
      local mode="$1"
      local out="$2"

      answer "$mode" | \
        HOME="$TMPDIR" YAZI_CONFIG_HOME="$config" TERM=xterm-256color \
        timeout 12 script -qec "stty rows 40 cols 120; yazi" /dev/null \
        >"$out" 2>/dev/null || true
    }

    render 1 "$TMPDIR/dark"
    render 2 "$TMPDIR/light"

    # Yazi does not complain about the flavours.
    for themed in "$TMPDIR/dark" "$TMPDIR/light"; do
      if grep -aq "Failed to parse" "$themed"; then
        echo "Yazi does not read the flavour of the repository:" >&2
        grep -ao "Failed to parse[^\x1b]*" "$themed" >&2
        exit 1
      fi
    done

    # And it paints with the colours of the flavour of the mode the terminal
    # reports: the blue of the directory in the header, the background of the
    # application, and the background of the status bar.
    #
    # The dark flavour paints with the blue of the dark palette, and the
    # light one with the blue of the light palette.
    grep -aq '38;2;0;153;255' "$TMPDIR/dark"
    grep -aq '48;2;20;31;46' "$TMPDIR/dark"
    grep -aq '48;2;27;43;64' "$TMPDIR/dark"

    grep -aq '38;2;58;95;138' "$TMPDIR/light"
    grep -aq '48;2;232;236;242' "$TMPDIR/light"
    grep -aq '48;2;224;228;234' "$TMPDIR/light"

    # And the flavour of a mode is not the one of the other mode: the dark
    # flavour paints with the blue of the dark palette, and the light one
    # with the blue of the light palette, and neither of them paints with
    # the blue of the other.
    ! grep -aq '38;2;58;95;138' "$TMPDIR/dark"
    ! grep -aq '38;2;0;153;255' "$TMPDIR/light"

    # Without the flavours, Yazi paints with the colours of the preset it
    # ships with, and none of them is one of ours.
    mkdir -p "$TMPDIR/empty"
    HOME="$TMPDIR" YAZI_CONFIG_HOME="$TMPDIR/empty" TERM=xterm-256color \
      timeout 12 script -qec "stty rows 40 cols 120; yazi" /dev/null \
      >"$TMPDIR/plain" 2>/dev/null || true

    ! grep -aq '38;2;0;153;255' "$TMPDIR/plain"
    ! grep -aq '48;2;20;31;46' "$TMPDIR/plain"

    touch $out
  ''
