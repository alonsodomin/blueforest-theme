# SPDX-License-Identifier: MPL-2.0
#
# Checks that the configuration documented in the documentation installs the theme
# where OpenCode reads it, and selects it.
{
  pkgs,
  source,
  homeManager,
  module,
}:
let
  evaluated = import ./lib/evaluation.nix {
    inherit
      pkgs
      source
      homeManager
      module
      ;
  };

  result = builtins.toJSON {
    inherit (evaluated)
      selectedMode
      selectedTheme
      themeIsTheRepositoryTheme
      themeTarget
      ;
  };
in
pkgs.runCommand "blueforest-opencode-configuration-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;

    # Whether the conflict with the template of Noctalia for OpenCode fails
    # the evaluation of the configuration.
    inherit (evaluated) conflict;

    # The file Home Manager writes for the settings of the terminal.
    inherit (evaluated) cliFile;
  }
  ''
    # The theme ends up where OpenCode reads the themes from, and it is the
    # theme of this repository.
    echo "$result" | jq -e '
      .themeTarget == "/home/blueforest/.config/opencode/themes/blueforest.json"
      and .themeIsTheRepositoryTheme
      and .selectedTheme == "blueforest"
      and .selectedMode == "dark"
    ' >/dev/null

    # And the settings of the terminal are the ones OpenCode 2 reads.
    jq -e '
      ."$schema" == "https://opencode.ai/v2/cli.json"
      and .theme.name == "blueforest"
      and .theme.mode == "dark"
    ' "$cliFile" >/dev/null

    # The template of Noctalia for OpenCode and the theme of the repository
    # cannot be enabled at the same time.
    if [ "$conflict" != "yes" ]; then
      echo "the conflict with the Noctalia template for OpenCode did not fail" >&2
      exit 1
    fi

    touch $out
  ''
