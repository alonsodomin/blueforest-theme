# SPDX-License-Identifier: MPL-2.0
#
# Checks that lazygit reads the theme of the repository and paints with it.
#
# lazygit ignores a key it does not know, and a colour it cannot resolve, and
# it does so silently: the interface falls back to the colours lazygit ships
# with. The check therefore reads what lazygit painted, and looks for the
# colours of the theme in it.
#
# lazygit is a terminal program, and it needs a terminal to run in. The check
# gives it one with `script`, which allocates a pseudo terminal and runs
# lazygit in it. The colours of the theme are true colour, so the terminal has
# to support it.
#
# The pseudo terminal merges the output of lazygit and its errors, so the
# check looks for the errors in the output, and it looks at the result of
# lazygit as well: a lazygit that cannot read its configuration says so and
# quits with an error.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-lazygit-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.util-linux
      pkgs.git
      pkgs.jq
      pkgs.gnugrep
      pkgs.lazygit
    ];
  }
  ''
    work="$TMPDIR/work"
    themed="$TMPDIR/themed"
    plain="$TMPDIR/plain"

    export HOME="$TMPDIR"
    export GIT_CONFIG_GLOBAL=/dev/null
    export GIT_CONFIG_NOSYSTEM=1
    export GIT_AUTHOR_NAME="Blueforest"
    export GIT_AUTHOR_EMAIL="blueforest@example.com"
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

    mkdir -p "$work/repo" "$work/themed/lazygit" "$work/plain/lazygit"

    # The configuration of lazygit, with the theme of the repository and the
    # settings the check needs: the popups of the first run would cover the
    # interface, and the check of the version would reach the network.
    jq '.disableStartupPopups = true | .gui.update.method = "never"' \
      ${source} >"$work/themed/lazygit/config.yml"

    # And the same configuration, without the theme.
    jq 'del(.gui.theme)' "$work/themed/lazygit/config.yml" \
      >"$work/plain/lazygit/config.yml"

    # The repository lazygit looks at. The file with the changes that were
    # not staged is what the unstaged colour is painted on.
    cd "$work/repo"
    git init -q -b main .
    echo "blueforest" >file.txt
    git add file.txt
    git commit -qm "The first commit"
    echo "blueforest" >>file.txt

    # lazygit is run in a pseudo terminal, and it is sent the key that quits
    # it once it has painted the interface. The result of lazygit is written
    # next to its output, because a lazygit that cannot read its
    # configuration quits with an error.
    render() {
      local config="$1"
      local out="$2"
      local status=0

      (
        sleep 2

        # lazygit may have quit already, and the pipe may be closed: the
        # error of the write is of no use.
        printf 'q' 2>/dev/null || true
      ) | HOME="$TMPDIR" XDG_CONFIG_HOME="$config" \
        COLORTERM=truecolor TERM=xterm-256color \
        timeout 30 script -qec "stty rows 40 cols 120; lazygit" /dev/null \
        >"$out" 2>&1 || status=$?

      echo "$status" >"$out.status"
    }

    render "$work/themed" "$themed"

    # lazygit reads the configuration of the repository.
    if [ "$(cat "$themed.status")" != "0" ]; then
      echo "lazygit does not read the theme of the repository:" >&2
      cat "$themed" >&2
      exit 1
    fi

    # And it does not complain about it.
    if grep -aE "couldn't be parsed|validation error" "$themed" >/dev/null; then
      echo "lazygit complains about the theme of the repository:" >&2
      grep -aE "couldn't be parsed|validation error" "$themed" >&2
      exit 1
    fi

    # And it paints with the colours of the theme: the border of the window
    # that has the focus, the border of the windows that have no focus, the
    # text of the interface, the text of the line at the bottom, the colour of
    # the files with changes that were not staged, and the background of the
    # selected line.
    grep -aq '38;2;0;153;255' "$themed"
    grep -aq '38;2;51;51;51' "$themed"
    grep -aq '38;2;208;208;208' "$themed"
    grep -aq '38;2;145;204;255' "$themed"
    grep -aq '38;2;255;204;51' "$themed"
    grep -aq '48;2;39;62;92' "$themed"

    # Without the theme, lazygit paints with the colours it ships with, and
    # none of them is one of ours.
    render "$work/plain" "$plain"

    ! grep -aq '38;2;0;153;255' "$plain"
    ! grep -aq '38;2;51;51;51' "$plain"
    ! grep -aq '48;2;39;62;92' "$plain"

    touch $out
  ''
