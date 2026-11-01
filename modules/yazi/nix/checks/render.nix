# SPDX-License-Identifier: MPL-2.0
#
# Checks that Yazi reads the flavour of the repository and paints with it.
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
{
  pkgs,
  source,
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
    # flavour in it.
    mkdir -p "$work/subdir" "$config/flavors/blueforest.yazi"
    touch "$work/file.txt"
    cp -r ${source}/. "$config/flavors/blueforest.yazi/"

    # And the theme of the user selects the flavour.
    printf '[flavor]\ndark = "blueforest"\nlight = "blueforest"\n' \
      >"$config/theme.toml"

    cd "$work"

    # Yazi is killed after a while: it waits for a key that never comes, and
    # the check only reads what it painted.
    render() {
      local config="$1"
      local out="$2"

      # The answer to the query of the primary device attributes, which is
      # what a terminal answers.
      timeout 10 sh -c 'while :; do printf "\033[?1;2c"; sleep 1; done' | \
        HOME="$TMPDIR" YAZI_CONFIG_HOME="$config" TERM=xterm-256color \
        timeout 10 script -qec "stty rows 40 cols 120; yazi" /dev/null \
        >"$out" 2>/dev/null || true
    }

    render "$config" "$TMPDIR/themed"

    # Yazi does not complain about the flavour.
    if grep -aq "Failed to parse" "$TMPDIR/themed"; then
      echo "Yazi does not read the flavour of the repository:" >&2
      grep -ao "Failed to parse[^\x1b]*" "$TMPDIR/themed" >&2
      exit 1
    fi

    # And it paints with the colours of the flavour: the blue of the
    # directory in the header, the background of the application, and the
    # background of the status bar.
    grep -aq '38;2;0;153;255' "$TMPDIR/themed"
    grep -aq '48;2;20;31;46' "$TMPDIR/themed"
    grep -aq '48;2;27;43;64' "$TMPDIR/themed"

    # Without the flavour, Yazi paints with the colours of the preset it
    # ships with, and none of them is one of ours.
    mkdir -p "$TMPDIR/empty"
    render "$TMPDIR/empty" "$TMPDIR/plain"

    ! grep -aq '38;2;0;153;255' "$TMPDIR/plain"
    ! grep -aq '48;2;20;31;46' "$TMPDIR/plain"

    touch $out
  ''
