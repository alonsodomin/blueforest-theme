# SPDX-License-Identifier: MPL-2.0
#
# Checks that the roles of the theme of OpenCode are the roles of the other
# ports of the repository.
#
# A theme of OpenCode is a tree of semantic tokens, and every one of them
# ends up as a colour. The check looks at the syntax and the markdown of the
# theme, which are the roles the other ports paint with the same colours:
# the comment is the comment, the keyword is the keyword, and the string is
# the string, so that a token is painted the same everywhere.
#
# The theme has a mode per appearance, and every mode is checked on its own:
# the modes do not inherit from each other, so a role of one of them may
# have a colour the other one does not.
{
  pkgs,
  # The theme of the repository.
  source,
}:
let
  # The theme, as it was read.
  theme = builtins.fromJSON (builtins.readFile source);

  # The colour of every role of the syntax and of the markdown, per mode.
  #
  # The dark mode paints them with the colours of the dark palette, and the
  # light one with the colours of the light palette.
  syntaxDark = {
    comment = "#a0ffa0";
    function = "#a2cff5";
    keyword = "#0099ff";
    number = "#ff8080";
    operator = "#ffcc33";
    punctuation = "#e7e7e7";
    string = "#80ff80";
    type = "#808000";
    variable = "#fffab1";
  };

  syntaxLight = {
    comment = "#56697d";
    function = "#1b7a70";
    keyword = "#3a5f8a";
    number = "#b02a28";
    operator = "#c57633";
    punctuation = "#333333";
    string = "#1e5c1e";
    type = "#808000";
    variable = "#333333";
  };

  markdownDark = {
    blockQuote = "#a0ffa0";
    code = "#80ff80";
    codeBlock = "#e7e7e7";
    emphasis = "#f7ff66";
    heading = "#0099ff";
    horizontalRule = "#333333";
    image = "#91ccff";
    imageText = "#a2cff5";
    link = "#91ccff";
    linkText = "#a2cff5";
    listEnumeration = "#91ccff";
    listItem = "#d0d0d0";
    strong = "#f7ff66";
    text = "#d0d0d0";
  };

  markdownLight = {
    blockQuote = "#56697d";
    code = "#1e5c1e";
    codeBlock = "#333333";
    emphasis = "#1b2b40";
    heading = "#3a5f8a";
    horizontalRule = "#7f8fa3";
    image = "#3a5f8a";
    imageText = "#1b7a70";
    link = "#3a5f8a";
    linkText = "#1b7a70";
    listEnumeration = "#3a5f8a";
    listItem = "#141f2e";
    strong = "#1b2b40";
    text = "#141f2e";
  };
in
pkgs.runCommand "blueforest-opencode-roles-check"
  {
    nativeBuildInputs = [ pkgs.jq ];

    # The roles of every mode, with the references resolved.
    roles =
      builtins.toJSON
        (import ./lib/roles.nix {
          inherit (pkgs) lib;
          inherit theme;
        }).modes;

    # The colours the roles have to carry, per mode.
    expected = builtins.toJSON {
      dark = {
        syntax = syntaxDark;
        markdown = markdownDark;
      };
      light = {
        syntax = syntaxLight;
        markdown = markdownLight;
      };
    };
  }
  ''
    # The syntax of every mode is the syntax of the other ports, and so is
    # the markdown.
    for mode in dark light; do
      for group in syntax markdown; do
        actual="$(echo "$roles" | jq -cS --arg mode "$mode" --arg group "$group" '
          .[]
          | select(.name == $mode)
          | .roles
          | map(select(.path | startswith($group + ".")))
          | map({ key: (.path | split(".") | .[1]), value: .colour })
          | from_entries
        ')"

        wanted="$(echo "$expected" | jq -cS --arg mode "$mode" --arg group "$group" '.[$mode][$group]')"

        if [ "$actual" != "$wanted" ]; then
          echo "the $group of the $mode theme of OpenCode is not the one of the other ports:" >&2
          echo "  expected: $wanted" >&2
          echo "  actual:   $actual" >&2
          exit 1
        fi
      done
    done

    touch $out
  ''
