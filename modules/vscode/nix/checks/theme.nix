# SPDX-License-Identifier: MPL-2.0
#
# Checks that the themes paint the shell scopes with the colours of the
# repository.
#
# The scopes are the ones of the shell grammar of VS Code, and the colours
# are the ones the other applications of the repository use for the same
# token: the command is a function, the arguments are parameters, the
# punctuation is punctuation, and the variables are variables.
#
# The themes have a variant per mode, and the colours of the shell of the
# light variant are the ones of the light palette of the repository.
{
  pkgs,
  # The dark theme of the repository.
  dark,
  # The light theme of the repository.
  light,
}:
let
  # The colour of every scope of the shell, in the dark theme.
  shellDark = {
    "comment.line.number-sign.shell" = "#a0ffa0";
    "constant.numeric.shell" = "#ff8080";
    "constant.other.option.shell" = "#ffcc33";
    "entity.name.function.call.shell" = "#a2cff5";
    "keyword.control.if.shell" = "#0099ff";
    "keyword.operator.assignment.shell" = "#ffcc33";
    "punctuation.definition.arguments.shell" = "#e7e7e7";
    "punctuation.definition.logical-expression.shell" = "#e7e7e7";
    "punctuation.terminator.statement.semicolon.shell" = "#e7e7e7";
    "string.quoted.double.shell" = "#80ff80";
    "string.unquoted.argument.shell" = "#e7e7e7";
    "support.function.builtin.shell" = "#ffcc33";
    "variable.other.assignment.shell" = "#fffab1";
    "variable.other.normal.shell" = "#fffab1";
  };

  # The colour of every scope of the shell, in the light theme.
  shellLight = {
    "comment.line.number-sign.shell" = "#56697d";
    "constant.numeric.shell" = "#b02a28";
    "constant.other.option.shell" = "#c57633";
    "entity.name.function.call.shell" = "#1b7a70";
    "keyword.control.if.shell" = "#3a5f8a";
    "keyword.operator.assignment.shell" = "#c57633";
    "punctuation.definition.arguments.shell" = "#333333";
    "punctuation.definition.logical-expression.shell" = "#333333";
    "punctuation.terminator.statement.semicolon.shell" = "#333333";
    "string.quoted.double.shell" = "#1e5c1e";
    "string.unquoted.argument.shell" = "#333333";
    "support.function.builtin.shell" = "#ffcc33";
    "variable.other.assignment.shell" = "#333333";
    "variable.other.normal.shell" = "#333333";
  };
in
pkgs.runCommand "blueforest-vscode-theme-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    # The scopes the check looks at, and the colour they have to carry, per
    # theme.
    expected = builtins.toJSON {
      dark = shellDark;
      light = shellLight;
    };
  }
  ''
    # Every scope of the shell is painted with the colour of the repository.
    for variant in dark light; do
      case "$variant" in
        dark) source="${dark}" ;;
        light) source="${light}" ;;
      esac

      echo "$expected" | jq -r --arg variant "$variant" '
        .[$variant] | to_entries[] | "\(.key) \(.value)"
      ' | while read -r scope colour; do
        actual="$(
          jq -r --arg scope "$scope" -f ${./colour.jq} "$source" | tr '[:upper:]' '[:lower:]'
        )"
        if [ "$actual" != "$colour" ]; then
          echo "the $variant theme paints $scope with $actual, not $colour:" >&2
          exit 1
        fi
      done
    done

    touch $out
  ''
