# SPDX-License-Identifier: MPL-2.0
#
# Checks that the colours of the theme of Zed are the colours of the other
# ports of the repository.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: it compares the theme of Zed with the theme of VS Code and the
# theme of Neovim.
#
# The theme of Zed has a variant per mode, and so have the themes of the
# other ports, so every variant is compared with the variants of the same
# mode.
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
  # The dark theme of VS Code.
  vscode,
  # The dark theme of Neovim.
  neovim,
  # The light theme of VS Code.
  vscodeLight,
  # The light theme of Neovim.
  neovimLight,
}:
let
  # The colour of every token of the syntax of the theme. The tokens are the
  # ones Zed knows, and the colours are the ones the other ports use.
  syntaxDark = {
    attribute = "#fffab1";
    boolean = "#0099FF";
    comment = "#a0ffa0";
    "comment.doc" = "#a0ffa0";
    "comment.inclusive" = "#a0ffa0";
    constant = "#0099FF";
    constructor = "#91ccff";
    embedded = "#80ff80";
    emphasis = "#F7FF66";
    "emphasis.strong" = "#F7FF66";
    function = "#a2cff5";
    keyword = "#0099FF";
    "keyword.control" = "#0099FF";
    "keyword.directive" = "#0099FF";
    "keyword.operator" = "#ffcc33";
    "link_text" = "#91CCFF";
    "link_uri" = "#91CCFF";
    number = "#FF8080";
    operator = "#ffcc33";
    "punctuation.bracket" = "#e7e7e7";
    "punctuation.delimiter" = "#e7e7e7";
    "punctuation.special" = "#ffcc33";
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

  # And the colour of the syntax of the light variant.
  syntaxLight = {
    attribute = "#333333";
    boolean = "#3A5F8A";
    comment = "#56697D";
    "comment.doc" = "#56697D";
    "comment.inclusive" = "#56697D";
    constant = "#3A5F8A";
    constructor = "#219186";
    embedded = "#1E5C1E";
    emphasis = "#1B2B40";
    "emphasis.strong" = "#1B2B40";
    function = "#1B7A70";
    keyword = "#3A5F8A";
    "keyword.control" = "#3A5F8A";
    "keyword.directive" = "#3A5F8A";
    "keyword.operator" = "#C57633";
    "link_text" = "#3A5F8A";
    "link_uri" = "#3A5F8A";
    number = "#B02A28";
    operator = "#C57633";
    "punctuation.bracket" = "#333333";
    "punctuation.delimiter" = "#333333";
    "punctuation.special" = "#C57633";
    string = "#1E5C1E";
    "string.escape" = "#1B2B40";
    "string.regex" = "#1E5C1E";
    "string.special" = "#1E5C1E";
    "string.special.symbol" = "#1E5C1E";
    tag = "#219186";
    "text.literal" = "#1E5C1E";
    type = "#808000";
    variable = "#333333";
    "variable.special" = "#3A5F8A";
  };

  # The colour of every element of the interface of the theme that the other
  # ports have as well.
  styleDark = {
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

  # And the colour of the interface of the light variant.
  styleLight = {
    background = "#E8ECF2";
    "border.focused" = "#B3871F";
    "editor.active_line_number" = "#141F2E";
    "editor.background" = "#E8ECF2";
    "editor.foreground" = "#141F2E";
    "editor.gutter.background" = "#E8ECF2";
    "element.hover" = "#C9CDD3";
    "element.selected" = "#3A5F8A";
    "elevated_surface.background" = "#E0E4EA";
    "ghost_element.hover" = "#C9CDD3";
    "ghost_element.selected" = "#3A5F8A";
    "panel.background" = "#E8ECF2";
    "scrollbar.track.background" = "#E8ECF2";
    "status_bar.background" = "#E0E4EA";
    "tab.active_background" = "#E8ECF2";
    "tab.inactive_background" = "#E0E4EA";
    "tab_bar.background" = "#E0E4EA";
    "title_bar.background" = "#E0E4EA";
    "toolbar.background" = "#E8ECF2";
  };
in
pkgs.runCommand "blueforest-zed-colours-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    expectedSyntax = builtins.toJSON {
      dark = syntaxDark;
      light = syntaxLight;
    };
    expectedStyle = builtins.toJSON {
      dark = styleDark;
      light = styleLight;
    };
  }
  ''
    zed="${theme}/themes/blueforest.json"

    # The palette of the repository, per mode. The alpha channel is dropped,
    # because the palette is about the colours themselves.
    palette() {
      case "$1" in
        dark)
          {
            jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscode}
            grep -oE '#[0-9A-Fa-f]{6}' ${neovim}
          }
          ;;
        light)
          {
            jq -r '.. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))' ${vscodeLight}
            grep -oE '#[0-9A-Fa-f]{6}' ${neovimLight}
          }
          ;;
      esac | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u
    }

    # The theme of Zed has a variant per mode, and every one of them is
    # compared with the variants of the other ports of the same mode.
    for variant in dark light; do
      case "$variant" in
        dark) index=0 ;;
        light) index=1 ;;
      esac

      palette "$variant" >"$TMPDIR/palette"

      # Every colour of the theme of Zed is one of them.
      jq -r --argjson index "$index" '
        .themes[$index].style
        | .. | strings | select(test("^#[0-9A-Fa-f]{6,8}$"))
      ' "$zed" | tr '[:lower:]' '[:upper:]' | cut -c1-7 | sort -u >"$TMPDIR/zed"

      missing="$(comm -23 "$TMPDIR/zed" "$TMPDIR/palette")"
      if [ -n "$missing" ]; then
        echo "the $variant theme of Zed has colours that the other $variant ports do not have:" >&2
        echo "$missing" >&2
        exit 1
      fi

      # And the syntax of the theme is the one of the other ports.
      actual="$(jq -cS --argjson index "$index" '
        .themes[$index].style.syntax | with_entries(.value |= (.color // ""))
      ' "$zed")"
      expected="$(echo "$expectedSyntax" | jq -cS --arg variant "$variant" '.[$variant]')"
      if [ "$actual" != "$expected" ]; then
        echo "the syntax of the $variant theme of Zed is not the one of the other ports:" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        exit 1
      fi

      # And so are the colours of its interface.
      actual="$(jq -cS --argjson index "$index" --argjson expected "$expectedStyle" --arg variant "$variant" '
        .themes[$index].style as $style
        | reduce ($expected[$variant] | keys[]) as $key ({}; . + { ($key): $style[$key] })
      ' "$zed")"
      expected="$(echo "$expectedStyle" | jq -cS --arg variant "$variant" '.[$variant]')"
      if [ "$actual" != "$expected" ]; then
        echo "the interface of the $variant theme of Zed is not the one of the other ports:" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        exit 1
      fi
    done

    touch $out
  ''
