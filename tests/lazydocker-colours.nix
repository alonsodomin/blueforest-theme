# SPDX-License-Identifier: MPL-2.0
#
# Checks that the colours of the theme of lazydocker are the colours of the
# other ports of the repository.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: it compares the theme of lazydocker with the theme of VS Code and
# the theme of Neovim.
#
# Every colour of the theme of lazydocker has to be one of the colours of the
# other ports, so that the palette of the theme is the palette of the
# repository.
{
  pkgs,
  # The package of the theme of lazydocker.
  theme,
  # The theme of VS Code.
  vscode,
  # The theme of Neovim.
  neovim,
}:
pkgs.runCommand "blueforest-lazydocker-colours-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  }
  ''
    lazydocker="${theme}/blueforest.json"

    # The palette of the repository: the colours of the theme of VS Code and
    # the ones of the theme of Neovim. The alpha channel is dropped, because
    # the palette is about the colours themselves.
    {
      jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscode}
      grep -oE '#[0-9A-Fa-f]{6}' ${neovim}
    } | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/palette"

    # Every colour of the theme of lazydocker is one of them.
    jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' "$lazydocker" \
      | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/lazydocker"

    missing="$(comm -23 "$TMPDIR/lazydocker" "$TMPDIR/palette")"
    if [ -n "$missing" ]; then
      echo "the theme of lazydocker has colours that the other ports do not have:" >&2
      echo "$missing" >&2
      exit 1
    fi

    touch $out
  ''
