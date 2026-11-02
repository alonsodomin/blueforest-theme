# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme paints the shell scopes with the colours of the
# repository.
#
# The scopes are the ones of the shell grammar of VS Code, and the colours
# are the ones the other applications of the repository use for the same
# token: the command is a function, the arguments are parameters, the
# punctuation is punctuation, and the variables are variables.
{
  pkgs,
  # The theme of the repository.
  source,
}:
let
  # The colour of every scope of the shell.
  shell = {
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
in
pkgs.runCommand "blueforest-vscode-theme-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    # The scopes the check looks at, and the colour they have to carry.
    expected = builtins.toJSON shell;
  }
  ''
    # Every scope of the shell is painted with the colour of the repository.
    echo "$expected" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r scope colour; do
      actual="$(
        jq -r --arg scope "$scope" -f ${./colour.jq} ${source} | tr '[:upper:]' '[:lower:]'
      )"
      if [ "$actual" != "$colour" ]; then
        echo "the theme paints $scope with $actual, not $colour:" >&2
        exit 1
      fi
    done

    touch $out
  ''
