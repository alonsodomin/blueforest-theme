# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where Zed reads the
# themes of the user from.
{
  lib,
  pkgs,
  homeManager,
  module,
  source,
}:
let
  # The identity of the user of the configuration, so that the paths of the
  # files are known.
  identity = {
    home.username = "blueforest";
    home.homeDirectory = "/home/blueforest";
    home.stateVersion = "26.11";
  };

  evaluated =
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        identity
      ];
    }).config;

  result = builtins.toJSON {
    theme = {
      target = "${evaluated.xdg.configHome}/zed/themes/blueforest.json";
      source = evaluated.xdg.configFile."zed/themes/blueforest.json".source;
    };
  };
in
pkgs.runCommand "blueforest-zed-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    inherit result;
  }
  ''
    # The theme ends up in the directory Zed reads the themes of the user
    # from.
    echo "$result" | jq -e '
      .theme.target == "/home/blueforest/.config/zed/themes/blueforest.json"
    ' >/dev/null

    # And the theme that ends up installed is the theme of the extension.
    cmp "$(echo "$result" | jq -r '.theme.source')" ${source}/themes/blueforest.json

    touch $out
  ''
