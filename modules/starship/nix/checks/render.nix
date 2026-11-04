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
# The duration and the shell live on the right prompt, and the right prompt is
# where the block of the shell tapers with the inverted cap.
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

      starship prompt -w 120 -d 1500 >$TMPDIR/$name-left
      starship prompt --right -w 120 -d 1500 >$TMPDIR/$name-right
      starship prompt -w 120 -d 1500 2>>$TMPDIR/$name-errors >/dev/null
      starship prompt --right -w 120 -d 1500 2>>$TMPDIR/$name-errors >/dev/null

      # The prompt of a healthy preset is not empty, and Starship does not
      # complain about it.
      test -s $TMPDIR/$name-left
      test -s $TMPDIR/$name-right
      test ! -s $TMPDIR/$name-errors

      # The palette is applied: a reference that does not resolve is painted
      # with no colour at all, and no escape sequence carries the colour.
      grep -qF $'\e[38;2;' $TMPDIR/$name-left
      grep -qF $'\e[48;2;' $TMPDIR/$name-left
      grep -qF $'\e[38;2;' $TMPDIR/$name-right

      # The duration and the shell are on the right prompt, and nowhere else.
      if grep -qF '󰔛' $TMPDIR/$name-left || grep -qF '' $TMPDIR/$name-left; then
        echo "the duration or the shell is on the left prompt of $name" >&2
        exit 1
      fi
      grep -qF '󰔛' $TMPDIR/$name-right
      grep -qF '' $TMPDIR/$name-right

      # The block of the shell tapers with the inverted cap. The bytes are
      # written down, because the locale of the build is not UTF-8 and the
      # shell would not expand a `\u` escape.
      cap=$(printf '\xee\x82\xb2')
      grep -qF "$cap" $TMPDIR/$name-right
    }

    render blueforest ${palettes.blueforest}
    render blueforest-light ${palettes.blueforest-light}

    touch $out
  ''
