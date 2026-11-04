# SPDX-License-Identifier: MPL-2.0
#
# Checks that Starship parses and renders the preset with each palette.
#
# Rendering the prompt exercises the whole preset: a malformed TOML or a value
# Starship cannot read makes Starship report an error. Starship does not fail
# on such an error, so the check reads what it writes to the error stream.
#
# A colour the preset names and the palette does not define is painted with no
# colour at all, and Starship reports nothing either. The check therefore
# looks at the escape sequences of the prompt, which carry the true colour of
# the palette.
#
# The prompt is two lines: the information line, and the line of the
# character. The right-handed part of the prompt, the duration and the Nix
# shell, is placed with a `fill` segment at the right of the information line,
# and not with a right prompt of its own: a right prompt is a prompt the
# shell renders on its own, and every shell places it somewhere else.
{
  pkgs,
  preset,
  palettes,
}:
pkgs.runCommand "blueforest-starship-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.starship
    ];
  }
  ''
    export HOME=$TMPDIR
    export TERM=xterm-256color
    export IN_NIX_SHELL=impure

    mkdir -p $TMPDIR/proj
    cd $TMPDIR/proj

    render() {
      name=$1
      palette=$2

      # The preset and the palette are two files, and the name of the palette
      # is what joins them.
      {
        echo "palette = \"$name\""
        cat ${preset}/share/starship/presets/blueforest.toml
        cat "$palette"
      } >$TMPDIR/$name.toml

      export STARSHIP_CONFIG=$TMPDIR/$name.toml

      starship prompt -w 120 -d 1500 >$TMPDIR/$name-prompt
      starship prompt --right -w 120 -d 1500 >$TMPDIR/$name-right
      starship prompt -w 120 -d 1500 2>>$TMPDIR/$name-errors >/dev/null
      starship prompt --right -w 120 -d 1500 2>>$TMPDIR/$name-errors >/dev/null

      # The prompt of a healthy preset is not empty, and Starship does not
      # complain about it.
      test -s $TMPDIR/$name-prompt
      test ! -s $TMPDIR/$name-errors

      # The right prompt is empty: the right-handed part of the prompt is
      # part of the format, and not a prompt of its own.
      test ! -s $TMPDIR/$name-right

      # The palette is applied: a reference that does not resolve is painted
      # with no colour at all, and no escape sequence carries the colour.
      grep -qF $'\e[38;2;' $TMPDIR/$name-prompt
      grep -qF $'\e[48;2;' $TMPDIR/$name-prompt

      # The prompt is two lines: the information line, and the line of the
      # character. The prompt starts with the newline of `add_newline`, so the
      # information line is the second one, and the line of the character is
      # the last one.
      info=$(tail -n +2 $TMPDIR/$name-prompt | head -n 1)
      character=$(tail -n 1 $TMPDIR/$name-prompt)

      # The duration and the shell are at the right of the information line.
      if ! printf '%s' "$info" | grep -qF '󰔛'; then
        echo "the duration is not on the information line of $name" >&2
        exit 1
      fi
      if ! printf '%s' "$info" | grep -qF ''; then
        echo "the shell is not on the information line of $name" >&2
        exit 1
      fi

      # The block of the shell tapers with the inverted cap. The bytes are
      # written down, because the locale of the build is not UTF-8 and the
      # shell would not expand a `\u` escape.
      cap=$(printf '\xee\x82\xb2')
      if ! printf '%s' "$info" | grep -qF "$cap"; then
        echo "the inverted cap is not on the information line of $name" >&2
        exit 1
      fi

      # The fill pushes the right-handed part to the right of the line, so
      # the line carries a run of spaces that nothing else writes.
      if ! printf '%s' "$info" | grep -qE ' {8,}'; then
        echo "the information line of $name is not filled" >&2
        exit 1
      fi

      # The line of the character carries none of them.
      if printf '%s' "$character" | grep -qF '󰔛' || printf '%s' "$character" | grep -qF ''; then
        echo "the duration or the shell is on the line of the character of $name" >&2
        exit 1
      fi
    }

    render blueforest ${palettes.blueforest}
    render blueforest-light ${palettes.blueforest-light}

    touch $out
  ''
