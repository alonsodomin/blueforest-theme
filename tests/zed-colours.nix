# SPDX-License-Identifier: MPL-2.0
#
# Checks that the colours of the theme of Zed are the colours of the other
# ports of the repository.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: it compares the theme of Zed with the theme of VS Code and the
# theme of Neovim.
#
# Two things are checked:
#
#   - every colour of the theme of Zed is one of the colours of the other
#     ports, so that the palette of the theme is the palette of the
#     repository;
#
#   - the syntax and the interface of the theme of Zed are the ones of the
#     other ports, so that a token is painted the same everywhere.
{
  pkgs,
  # The package of the theme of Zed.
  theme,
  # The theme of VS Code.
  vscode,
  # The theme of Neovim.
  neovim,
}:
let
  # The colour of every token of the syntax of the theme. The tokens are the
  # ones Zed knows, and the colours are the ones the other ports use.
  syntax = {
    attribute = "#fffab1";
    boolean = "#0099FF";
    comment = "#a0ffa0";
    "comment.doc" = "#a0ffa0";
    constant = "#0099FF";
    constructor = "#91ccff";
    emphasis = "#F7FF66";
    "emphasis.strong" = "#F7FF66";
    function = "#a2cff5";
    keyword = "#0099FF";
    "link_text" = "#91CCFF";
    "link_uri" = "#91CCFF";
    number = "#FF8080";
    operator = "#ffcc33";
    string = "#80ff80";
    "string.escape" = "#F7FF66";
    "string.regex" = "#80ff80";
    "string.special" = "#80ff80";
    "string.special.symbol" = "#80ff80";
    tag = "#91ccff";
    "text.literal" = "#80ff80";
    type = "#808000";
    variable = "#fffab1";
    "variable.special" = "#91CCFF";
  };

  # The colour of every element of the interface of the theme that the other
  # ports have as well.
  style = {
    background = "#141F2E";
    "border.focused" = "#ffcc33";
    "editor.active_line_number" = "#D0D0D0";
    "editor.background" = "#141F2E";
    "editor.foreground" = "#D0D0D0";
    "editor.gutter.background" = "#141F2E";
    "element.hover" = "#375780";
    "element.selected" = "#273e5c";
    "elevated_surface.background" = "#1c2d42";
    "ghost_element.hover" = "#375780";
    "ghost_element.selected" = "#273e5c";
    "panel.background" = "#141F2E";
    "scrollbar.track.background" = "#141F2E";
    "status_bar.background" = "#1e5c1e";
    "tab.active_background" = "#141F2E";
    "tab.inactive_background" = "#0A101D";
    "tab_bar.background" = "#1b2b40";
    "title_bar.background" = "#1b2b40";
    "toolbar.background" = "#141F2E";
  };
in
pkgs.runCommand "blueforest-zed-colours-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    expectedSyntax = builtins.toJSON syntax;
    expectedStyle = builtins.toJSON style;
  }
  ''
    zed="${theme}/themes/blueforest.json"

    # The palette of the repository: the colours of the theme of VS Code and
    # the ones of the theme of Neovim. The alpha channel is dropped, because
    # the palette is about the colours themselves.
    {
      jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscode}
      grep -oE '#[0-9A-Fa-f]{6}' ${neovim}
    } | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/palette"

    # Every colour of the theme of Zed is one of them.
    jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' "$zed" \
      | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/zed"

    missing="$(comm -23 "$TMPDIR/zed" "$TMPDIR/palette")"
    if [ -n "$missing" ]; then
      echo "the theme of Zed has colours that the other ports do not have:" >&2
      echo "$missing" >&2
      exit 1
    fi

    # And the syntax of the theme is the one of the other ports.
    actual="$(jq -cS '
      .themes[0].style.syntax | with_entries(.value |= (.color // ""))
    ' "$zed")"
    expected="$(echo "$expectedSyntax" | jq -cS .)"
    if [ "$actual" != "$expected" ]; then
      echo "the syntax of the theme of Zed is not the one of the other ports:" >&2
      echo "  expected: $expected" >&2
      echo "  actual:   $actual" >&2
      exit 1
    fi

    # And so are the colours of its interface.
    actual="$(jq -cS --argjson expected "$expectedStyle" '
      .themes[0].style as $style
      | reduce ($expected | keys[]) as $key ({}; . + { ($key): $style[$key] })
    ' "$zed")"
    expected="$(echo "$expectedStyle" | jq -cS .)"
    if [ "$actual" != "$expected" ]; then
      echo "the interface of the theme of Zed is not the one of the other ports:" >&2
      echo "  expected: $expected" >&2
      echo "  actual:   $actual" >&2
      exit 1
    fi

    touch $out
  ''
