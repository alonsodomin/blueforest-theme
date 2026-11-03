# SPDX-License-Identifier: MPL-2.0
#
# Checks that the colours of the theme of Noctalia are the colours of the
# other ports of the repository.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: it compares the palette of Noctalia with the theme of VS Code, the
# theme of Neovim and the theme of kitty.
#
# The palette of the repository is the colours of the theme of VS Code and of
# the theme of Neovim, which carry the colours of the syntax, and the colours
# of the theme of kitty, which carries the tones of the interface.
#
# Every colour of the palette of Noctalia has to be one of them, so that the
# palette of the theme is the palette of the repository.
#
# The palette has a variant per mode, and the ports have a theme per mode, so
# the variants are compared with each other: the dark palette with the dark
# themes, and the light palette with the light ones.
{
  pkgs,
  # The package of the theme of Noctalia.
  theme,
  # The dark theme of VS Code.
  vscode,
  # The dark theme of Neovim.
  neovim,
  # The dark theme of kitty.
  kitty,
  # The light theme of VS Code.
  vscodeLight,
  # The light theme of Neovim.
  neovimLight,
  # The light theme of kitty.
  kittyLight,
}:
pkgs.runCommand "blueforest-noctalia-colours-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  }
  ''
    noctalia="${theme}/share/noctalia/palettes/blueforest.json"

    # The colours of the themes of the repository, per mode. Every mode is
    # compared with the themes of the same mode.
    colours_of_themes() {
      case "$1" in
        dark)
          {
            jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscode}
            grep -oE '#[0-9A-Fa-f]{6}' ${neovim}
            grep -oE '#[0-9A-Fa-f]{6}' ${kitty}
          }
          ;;
        light)
          {
            jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscodeLight}
            grep -oE '#[0-9A-Fa-f]{6}' ${neovimLight}
            grep -oE '#[0-9A-Fa-f]{6}' ${kittyLight}
          }
          ;;
      esac | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u
    }

    for mode in dark light; do
      colours_of_themes "$mode" >"$TMPDIR/$mode-themes"

      # Every colour of the palette of Noctalia is one of them.
      jq -r ".$mode | .. | strings | select(test(\"^#[0-9A-Fa-f]{6,8}$\"))" "$noctalia" \
        | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/$mode-palette"

      missing="$(comm -23 "$TMPDIR/$mode-palette" "$TMPDIR/$mode-themes")"
      if [ -n "$missing" ]; then
        echo "the $mode theme of Noctalia has colours that the other $mode ports do not have:" >&2
        echo "$missing" >&2
        exit 1
      fi
    done

    touch $out
  ''
