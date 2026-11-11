# SPDX-License-Identifier: MPL-2.0
#
# Checks that lazydocker reads the themes of the repository and paints with
# them.
#
# lazydocker ignores a key it does not know, and a colour it cannot resolve, and
# it does so silently: the interface falls back to the colours lazydocker ships
# with. The check therefore reads what lazydocker painted, and looks for the
# colours of the theme in it.
#
# lazydocker is a terminal program, and it needs a terminal to run in. The check
# gives it one with `script`, which allocates a pseudo terminal and runs
# lazydocker in it. The colours of the theme are true colour, so the terminal has
# to support it.
#
# The pseudo terminal merges the output of lazydocker and its errors, so the
# check looks at the result of lazydocker as well: a lazydocker that cannot read
# its configuration quits with an error.
#
# lazydocker needs no Docker daemon to paint the interface: the check runs it
# without one, and it paints the theme all the same.
#
# The themes have a variant per mode, and every one of them is rendered and
# looked at.
{
  pkgs,
  source,
  sourceLight,
}:
pkgs.runCommand "blueforest-lazydocker-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.util-linux
      pkgs.lazydocker
      pkgs.jq
      pkgs.gnugrep
    ];
  }
  ''
    work="$TMPDIR/work"
    themed="$TMPDIR/themed"
    themedLight="$TMPDIR/themed-light"
    plain="$TMPDIR/plain"

    export HOME="$TMPDIR"

    mkdir -p "$work/themed/lazydocker" "$work/themed-light/lazydocker" \
      "$work/plain/lazydocker"

    # The configurations of lazydocker, with the themes of the repository. The
    # files are JSON, and JSON is a subset of YAML, so lazydocker reads them as
    # its own format.
    cp ${source} "$work/themed/lazydocker/config.yml"
    cp ${sourceLight} "$work/themed-light/lazydocker/config.yml"

    # And the same configuration, without the theme.
    jq 'del(.gui.theme)' ${source} \
      >"$work/plain/lazydocker/config.yml"

    # lazydocker is run in a pseudo terminal, and it is sent the key that quits
    # it once it has painted the interface. The result of lazydocker is written
    # next to its output, because a lazydocker that cannot read its
    # configuration quits with an error.
    render() {
      local config="$1"
      local out="$2"
      local status=0

      (
        sleep 2

        # lazydocker may have quit already, and the pipe may be closed: the
        # error of the write is of no use.
        printf 'q' 2>/dev/null || true
      ) | HOME="$TMPDIR" XDG_CONFIG_HOME="$config" \
        COLORTERM=truecolor TERM=xterm-256color \
        timeout 30 script -qec "stty rows 40 cols 120; lazydocker" /dev/null \
        >"$out" 2>&1 || status=$?

      echo "$status" >"$out.status"
    }

    # The theme of the dark variant is rendered first.
    render "$work/themed" "$themed"

    # lazydocker reads the configuration of the repository.
    if [ "$(cat "$themed.status")" != "0" ]; then
      echo "lazydocker does not read the theme of the repository:" >&2
      cat "$themed" >&2
      exit 1
    fi

    # And it paints with the colours of the theme: the border of the window
    # that has the focus, the border of the windows that have no focus, the
    # background of the selected line, and the text of the line at the bottom.
    grep -aq '38;2;0;153;255' "$themed"
    grep -aq '38;2;51;51;51' "$themed"
    grep -aq '48;2;39;62;92' "$themed"
    grep -aq '38;2;145;204;255' "$themed"

    # The light variant is rendered as well.
    render "$work/themed-light" "$themedLight"

    if [ "$(cat "$themedLight.status")" != "0" ]; then
      echo "lazydocker does not read the light theme of the repository:" >&2
      cat "$themedLight" >&2
      exit 1
    fi

    grep -aq '38;2;0;153;255' "$themedLight"
    grep -aq '38;2;127;143;163' "$themedLight"
    grep -aq '48;2;201;205;211' "$themedLight"
    grep -aq '38;2;58;95;138' "$themedLight"

    # Without the theme, lazydocker paints with the colours it ships with, and
    # none of them is a true colour.
    render "$work/plain" "$plain"

    ! grep -aq '38;2;' "$plain"
    ! grep -aq '48;2;' "$plain"

    touch $out
  ''
