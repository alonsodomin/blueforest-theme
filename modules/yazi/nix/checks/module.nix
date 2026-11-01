# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the flavour where Yazi reads
# it, that it selects it, and that it writes nothing when Yazi is not
# enabled.
#
# Home Manager has an option of its own for the theme of Yazi, and the check
# covers a consumer that uses it: their theme wins over the one of this
# application, and the two of them do not collide.
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

  evaluate =
    extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        identity
        extra
      ];
    }).config;

  enabled = evaluate { programs.yazi.enable = true; };
  disabled = evaluate { };

  # A consumer that brings a theme of its own.
  own = evaluate {
    programs.yazi.enable = true;
    programs.yazi.theme = {
      mgr.cwd.fg = "#ff0000";
    };
  };

  result = builtins.toJSON {
    enabled = {
      flavour = "${enabled.xdg.configHome}/yazi/flavors/blueforest.yazi";
      theme = "${enabled.xdg.configHome}/yazi/theme.toml";
    };

    # The module does not enable Yazi, so a configuration that does not enable
    # it gets neither the flavour nor the theme.
    disabled = {
      flavour = disabled.xdg.configFile ? "yazi/flavors/blueforest.yazi";
      theme = disabled.xdg.configFile ? "yazi/theme.toml";
    };

    own = {
      theme = "${own.xdg.configHome}/yazi/theme.toml";
    };
  };
in
pkgs.runCommand "blueforest-yazi-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    inherit result;

    # The file Home Manager writes for the theme of the user.
    themeFile = enabled.xdg.configFile."yazi/theme.toml".source;

    # And the one it writes for the theme of the consumer.
    ownFile = own.xdg.configFile."yazi/theme.toml".source;

    # The flavour the module installs.
    flavour = enabled.xdg.configFile."yazi/flavors/blueforest.yazi".source;
  }
  ''
    # The flavour ends up in the directory Yazi reads the flavours from, and
    # the theme of the user is written next to it.
    echo "$result" | jq -e '
      .enabled.flavour == "/home/blueforest/.config/yazi/flavors/blueforest.yazi"
      and .enabled.theme == "/home/blueforest/.config/yazi/theme.toml"
      and (.disabled.flavour | not)
      and (.disabled.theme | not)
      and .own.theme == "/home/blueforest/.config/yazi/theme.toml"
    ' >/dev/null

    # And the theme that ends up installed selects the flavour.
    grep -q 'blueforest' "$themeFile"

    # The flavour that ends up installed is the flavour of the repository.
    diff -r "$flavour" ${source}

    # The theme of a consumer that brings one of its own is the one of the
    # consumer, and the two of them do not collide.
    grep -q '#ff0000' "$ownFile"
    ! grep -q 'blueforest' "$ownFile"

    touch $out
  ''
