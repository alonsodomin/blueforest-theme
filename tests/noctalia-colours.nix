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
{
  pkgs,
  # The package of the theme of Noctalia.
  theme,
  # The theme of VS Code.
  vscode,
  # The theme of Neovim.
  neovim,
  # The theme of kitty.
  kitty,
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

    # The palette of the repository. The alpha channel is dropped, because the
    # palette is about the colours themselves.
    {
      jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscode}
      grep -oE '#[0-9A-Fa-f]{6}' ${neovim}
      grep -oE '#[0-9A-Fa-f]{6}' ${kitty}
    } | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/palette"

    # Every colour of the palette of Noctalia is one of them.
    jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' "$noctalia" \
      | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/noctalia"

    missing="$(comm -23 "$TMPDIR/noctalia" "$TMPDIR/palette")"
    if [ -n "$missing" ]; then
      echo "the theme of Noctalia has colours that the other ports do not have:" >&2
      echo "$missing" >&2
      exit 1
    fi

    touch $out
  ''
