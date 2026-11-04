# SPDX-License-Identifier: MPL-2.0
#
# Checks that bat paints the shell blocks of a Markdown file with the colours
# of the theme of the repository.
#
# The check renders a file with a shell block, and looks at the colours bat
# painted it with. The block is a shell one, because that is the marker the
# documentation uses for the commands it shows.
#
# The theme has a variant per mode, and the shell of the light variant is
# painted with the colours of the light palette of the repository, so both of
# them are rendered and looked at.
{
  pkgs,
  source,
  sourceLight,
}:
pkgs.runCommand "blueforest-bat-render-check"
  {
    nativeBuildInputs = [
      pkgs.bat
      pkgs.coreutils
    ];
  }
  ''
    export HOME="$TMPDIR"
    export XDG_CONFIG_HOME="$TMPDIR/.config"
    export XDG_CACHE_HOME="$TMPDIR/.cache"

    # The build has no terminal, so bat would paint the file with the colours
    # of the palette of 256, and the check would read the approximation of the
    # colours of the theme instead of the colours themselves.
    export TERM="xterm-256color"
    export COLORTERM="truecolor"

    # bat reads the themes of the user from the themes directory of its
    # configuration directory, and the cache it builds from them.
    mkdir -p "$XDG_CONFIG_HOME/bat/themes"
    cp ${source} "$XDG_CONFIG_HOME/bat/themes/BlueForest.tmTheme"
    cp ${sourceLight} "$XDG_CONFIG_HOME/bat/themes/BlueForestLight.tmTheme"
    bat cache --build

    cat >"$TMPDIR/block.md" <<'MARKDOWN'
    ```bash
    nix build "path:."
    if [ -f foo ]; then echo "$HOME"; fi
    ```
    MARKDOWN

    render() {
      bat --theme="$1" --color=always --style=plain --paging=never \
        "$TMPDIR/block.md" >"$TMPDIR/rendered-$1"
    }

    render BlueForest
    render BlueForestLight

    # The command is painted with the colour of the functions, its arguments
    # with the colour of the parameters, the keyword with the colour of the
    # keywords, the option with the colour of the operators, and the string
    # with the colour of the strings.
    #
    # The dark theme paints them with the colours of the dark palette.
    grep -q $'\e\[38;2;162;207;245mnix' "$TMPDIR/rendered-BlueForest"
    grep -q $'\e\[38;2;231;231;231m build' "$TMPDIR/rendered-BlueForest"
    grep -q $'\e\[1;38;2;0;153;255mif' "$TMPDIR/rendered-BlueForest"
    grep -q $'\e\[38;2;255;204;51m-' "$TMPDIR/rendered-BlueForest"
    grep -q $'\e\[38;2;128;255;128mpath:.' "$TMPDIR/rendered-BlueForest"

    # And the block is a shell one, so it is painted at all: the fence of the
    # block carries the colour of the constants.
    grep -q $'\e\[38;2;247;255;102mbash' "$TMPDIR/rendered-BlueForest"

    # And the light theme paints them with the colours of the light palette.
    grep -q $'\e\[38;2;27;122;112mnix' "$TMPDIR/rendered-BlueForestLight"
    grep -q $'\e\[38;2;51;51;51m build' "$TMPDIR/rendered-BlueForestLight"
    grep -q $'\e\[1;38;2;58;95;138mif' "$TMPDIR/rendered-BlueForestLight"
    grep -q $'\e\[38;2;197;118;51m-' "$TMPDIR/rendered-BlueForestLight"
    grep -q $'\e\[38;2;30;92;30mpath:.' "$TMPDIR/rendered-BlueForestLight"

    # And the fence of the block carries the colour of the constants of the
    # light palette.
    grep -q $'\e\[38;2;27;43;64mbash' "$TMPDIR/rendered-BlueForestLight"

    touch $out
  ''
