# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for Yazi.
#
# Yazi reads the themes of the user from the configuration directory of the
# user, which is `~/.config/yazi`. A theme of its own is a flavour: a
# directory of the `flavors` directory, named after the flavour.
#
# This module installs the flavour there, and it selects the flavour in the
# theme of the user, so that Yazi picks it up without any further work.
#
# The module is inert unless `blueforest-theme.yazi.enable` is true: it does not
# enable Yazi, it only adds the flavour to the configuration of a Yazi that
# the consumer already enabled.
#
# Home Manager has an option of its own for the theme of Yazi,
# `programs.yazi.theme`, which writes the file the selection goes into. The
# definition here is a default one, so a consumer that sets that option keeps
# their own theme. Such a consumer selects the flavour by adding the `flavor`
# section to it.
#
# The overlay of the application is passed to the module, so that the flavour
# the consumer gets is the one of the application, with the theme of bat it
# carries.
{
  overlay,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.yazi;
in
{
  options.blueforest-theme.yazi = {
    enable = lib.mkEnableOption "the BlueForest theme for Yazi";
  };

  config = lib.mkMerge [
    {
      # The overlay of the application, so that the flavour the module
      # installs is the one of the application.
      nixpkgs.overlays = [ overlay ];
    }

    (lib.mkIf (config.blueforest-theme.yazi.enable && cfg.enable) {
      # The flavour goes into the directory Yazi reads the flavours from. It
      # is the flavour of the package, which links to the theme of bat for
      # the colours of the code preview.
      xdg.configFile."yazi/flavors/blueforest.yazi" = lib.mkDefault {
        source = "${pkgs.blueforest-yazi-theme}/share/yazi/flavors/blueforest.yazi";
      };

      # And the theme of the user selects it. The flavour is a dark one, so
      # it is selected in both modes.
      programs.yazi.theme = lib.mkDefault {
        flavor = {
          dark = "blueforest";
          light = "blueforest";
        };
      };
    })
  ];
}
