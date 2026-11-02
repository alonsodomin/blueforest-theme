# SPDX-License-Identifier: MPL-2.0
#
# Checks that kitty reads the theme of the repository and paints with it.
#
# kitty ignores a configuration key it does not know, and it ignores a colour
# it cannot resolve, and it does so silently: the terminal falls back to the
# colours kitty ships with. The check therefore parses the theme with kitty
# itself, and looks at the colours that come out of it.
#
# The parse happens with the python interpreter that kitty carries, through
# `kitty +runpy`, so that the theme is read by the very same code that reads
# it when the terminal starts.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-kitty-parse-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.kitty
    ];
  }
  ''
    work="$TMPDIR/work"
    mkdir -p "$work"

    cat >"$work/check.py" <<'PYTHON'
    import sys
    from kitty.config import load_config

    path = sys.argv[1]

    # The lines kitty does not accept. A colour it cannot resolve ends up
    # here, and so does a key it does not know.
    bad = []
    opts = load_config(path, accumulate_bad_lines=bad)

    if bad:
        for line in bad:
            print("kitty does not accept: " + line, file=sys.stderr)
        raise SystemExit(1)

    # The colours of the interface of the terminal.
    interface = {
        "background": 0x141F2E,
        "foreground": 0xD0D0D0,
        "selection_foreground": 0x141F2E,
        "selection_background": 0x375780,
        "cursor": 0xD0D0D0,
        "cursor_text_color": 0x141F2E,
        "url_color": 0x91CCFF,
        "active_border_color": 0x0099FF,
        "inactive_border_color": 0x56697D,
        "bell_border_color": 0xFF8080,
        "active_tab_foreground": 0xD0D0D0,
        "active_tab_background": 0x141F2E,
        "inactive_tab_foreground": 0x56697D,
        "inactive_tab_background": 0x0A101D,
        "tab_bar_background": 0x1B2B40,
        "mark1_background": 0x375780,
        "mark2_background": 0x4FD6A0,
        "mark3_background": 0xFFCC33,
    }

    for name, value in interface.items():
        got = int(getattr(opts, name))
        if got != value:
            print("%s is %06X, not %06X" % (name, got, value), file=sys.stderr)
            raise SystemExit(1)

    # The sixteen colours of the terminal.
    colors = [
        0x1B2B40, 0xB02A28, 0x219186, 0xB3871F,
        0x0099FF, 0xC57633, 0x1B7A70, 0x7F8FA3,
        0x56697D, 0xFF8080, 0x80FF80, 0xFFCC33,
        0x91CCFF, 0xDDBB88, 0x4FD6A0, 0xD0D0D0,
    ]

    for index, value in enumerate(colors):
        got = opts.color_table[index]
        if got != value:
            print("color%d is %06X, not %06X" % (index, got, value), file=sys.stderr)
            raise SystemExit(1)
    PYTHON

    # kitty reads the theme, and it reads it silently: nothing it does not
    # like ends up in the standard error.
    kitty +runpy "exec(open('$work/check.py').read())" ${source} \
      2>"$work/stderr"

    if [ -s "$work/stderr" ]; then
      echo "kitty complains about the theme:" >&2
      cat "$work/stderr" >&2
      exit 1
    fi

    touch $out
  ''
