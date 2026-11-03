# SPDX-License-Identifier: MPL-2.0
#
# Checks that the colours of the light themes of the repository are the
# colours of the light palette of Noctalia.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: it compares the light themes with the canonical palette of the
# repository.
#
# The light palette is the reference of the light themes: every colour of a
# light theme has to be one of the colours of the light palette, so that the
# light theme is the light palette of the repository and not a palette of its
# own.
#
# The amber of the library is the one exception, and it is named here: it is
# the amber of BlueForest, and it is the same in both variants of the syntax
# palette.
{
  pkgs,
  # The light theme of VS Code, which is the reference of the light themes.
  vscode,
  # The canonical palette of the repository.
  palette,
}:
pkgs.runCommand "blueforest-light-colours-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  }
  ''
    # The colours of the light palette, and the amber of the library, which is
    # the exception.
    {
      jq -r '.light | .. | strings | select(test("^#[0-9A-Fa-f]{6}$"))' ${palette}
      echo "#FFCC33"
    } | tr '[:lower:]' '[:upper:]' | sort -u >"$TMPDIR/palette"

    # The colours of the light theme.
    jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6}$"))' ${vscode} \
      | tr '[:lower:]' '[:upper:]' | sort -u >"$TMPDIR/theme"

    missing="$(comm -23 "$TMPDIR/theme" "$TMPDIR/palette")"
    if [ -n "$missing" ]; then
      echo "the light theme has colours that the light palette does not have:" >&2
      echo "$missing" >&2
      exit 1
    fi

    touch $out
  ''
