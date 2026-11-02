# SPDX-License-Identifier: MPL-2.0
#
# Checks that btop reads the theme of the repository and paints with it.
#
# btop ignores a theme it cannot read, and it ignores it silently: a
# malformed file, or a colour it cannot resolve, makes btop fall back to the
# colours it ships with. The check therefore reads what btop painted, and
# looks for the colours of the theme in it.
#
# btop is a terminal program, and it needs a terminal to run in. The check
# gives it one with `script`, which allocates a pseudo terminal and runs btop
# in it. The colours of the theme are true colour, so the terminal has to
# support it.
#
# btop writes the errors it finds in the theme to its log, which lives in the
# state directory of the user. The check points that directory at a scratch
# one, and looks at the log, so that a colour btop cannot resolve is caught
# even when btop falls back to another one.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-btop-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.util-linux
      pkgs.btop
    ];
  }
  ''
    work="$TMPDIR/work"
    config="$TMPDIR/config"
    state="$TMPDIR/state"

    # The configuration directory of btop, with the theme of the repository in
    # the directory it reads the themes from.
    mkdir -p "$config/btop/themes" "$state"
    cp ${source} "$config/btop/themes/blueforest.theme"

    # And the configuration of btop selects the theme.
    printf 'color_theme = "blueforest.theme"\n' >"$config/btop/btop.conf"

    # btop is killed after a while: it waits for a key that never comes, and
    # the check only reads what it painted.
    #
    # btop refuses to start when it finds no UTF-8 locale, and the build
    # sandbox has none, so the check gives it one.
    render() {
      local config="$1"
      local out="$2"

      HOME="$TMPDIR" XDG_CONFIG_HOME="$config" XDG_STATE_HOME="$state" \
        LC_ALL=C.UTF-8 TERM=xterm-256color \
        timeout 10 script -qec "stty rows 40 cols 120; btop" /dev/null \
        >"$out" 2>/dev/null || true
    }

    render "$config" "$TMPDIR/themed"

    # btop does not complain about the theme.
    if [ -f "$state/btop.log" ]; then
      if grep -aq "Invalid hex value\|Invalid size of hex value\|Invalid RGB decimal value" \
        "$state/btop.log"; then
        echo "btop does not read the theme of the repository:" >&2
        grep -a "Invalid" "$state/btop.log" >&2
        exit 1
      fi
    fi

    # And it paints with the colours of the theme: the background of the
    # interface, the text of it, the outline of the boxes of the processors
    # and of the memory.
    grep -aq '48;2;20;31;46' "$TMPDIR/themed"
    grep -aq '38;2;208;208;208' "$TMPDIR/themed"
    grep -aq '38;2;145;204;255' "$TMPDIR/themed"
    grep -aq '38;2;79;214;160' "$TMPDIR/themed"

    # Without the theme, btop paints with the colours it ships with, and none
    # of them is one of ours.
    mkdir -p "$TMPDIR/empty"
    render "$TMPDIR/empty" "$TMPDIR/plain"

    ! grep -aq '48;2;20;31;46' "$TMPDIR/plain"
    ! grep -aq '38;2;208;208;208' "$TMPDIR/plain"

    touch $out
  ''
