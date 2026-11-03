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
# The ramp of a hue is the exception, and it is skipped: the themes that have
# one build their own scale of shades, and the scale is not a colour of the
# palette. The colours a theme names outside of its ramps are the ones of the
# palette.
#
# The amber of the library is the other exception, and it is named here: it is
# the amber of BlueForest, and it is the same in both variants of the syntax
# palette. The text of a selection is the same amber, because it is the only
# yellow of the repository that reads on the blue of a selection.
{
  pkgs,
  # The light theme of VS Code, which is the reference of the light themes.
  vscode,
  # The light theme of OpenCode, which has a ramp of shades of its own.
  opencode,
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

    # The colours of the light themes. The theme of OpenCode inherits the
    # tokens of its base, and its ramp of shades is its own.
    {
      jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6}$"))' ${vscode}
      jq -r '.base * .light | del(.hue) | .. | strings | select(test("^#[0-9A-Fa-f]{6}$"))' ${opencode}
    } | tr '[:lower:]' '[:upper:]' | sort -u >"$TMPDIR/themes"

    missing="$(comm -23 "$TMPDIR/themes" "$TMPDIR/palette")"
    if [ -n "$missing" ]; then
      echo "the light themes have colours that the light palette does not have:" >&2
      echo "$missing" >&2
      exit 1
    fi

    touch $out
  ''
