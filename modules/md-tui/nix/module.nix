# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for md-tui.
#
# md-tui saves the palettes of the user in the `themes` directory of its
# configuration directory, and it selects one of them with the
# `selected-theme` file of that directory, whose value is the name of the
# palette. This module writes the theme there and selects it, so that md-tui
# picks the theme up without any further work.
#
# The module is inert unless `blueforest-theme.md-tui.enable` is true: it does
# not enable md-tui, it only adds the theme to the configuration of an md-tui
# that the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.md-tui.enable`,
# because Home Manager has no module for md-tui: the option of Home Manager
# would clash with the one of this module if Home Manager ever gained a module
# of its own.
#
# md-tui reads the configuration directory of the user from `$HOME/.config`,
# and it ignores `XDG_CONFIG_HOME`, so the files are written there and not in
# the configuration directory of `XDG_CONFIG_HOME`.
#
# The theme is written with `lib.mkDefault`, so a consumer that brings a
# palette of its own keeps it, and so does a consumer that selects a theme of
# its own.
#
# The theme has a variant per mode, and `blueforest-theme.md-tui.variant`
# selects the one that is installed: the dark one, which is named
# `blueforest`, or the light one, which is named `blueforest-light`.
{
  config,
  lib,
  ...
}:
let
  # The variant of the theme that is installed.
  variant = config.blueforest-theme.md-tui.variant;
in
{
  options.blueforest-theme.md-tui = {
    enable = lib.mkEnableOption "the BlueForest theme for md-tui";

    variant = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "The variant of the theme of md-tui that is installed.";
    };
  };

  config = lib.mkIf config.blueforest-theme.md-tui.enable {
    # The theme, in the directory md-tui reads the palettes from. The name of
    # the file is the name of the theme.
    #
    # The selection of the theme is written next to it.
    home.file = lib.mkMerge [
      (lib.mkIf (variant == "dark") {
        ".config/mdt/themes/blueforest.json".source = ../themes/blueforest.json;
      })
      (lib.mkIf (variant == "light") {
        ".config/mdt/themes/blueforest-light.json".source = ../themes/blueforest-light.json;
      })
      {
        ".config/mdt/selected-theme".text = lib.mkDefault (
          if variant == "dark" then "blueforest\n" else "blueforest-light\n"
        );
      }
    ];
  };
}
