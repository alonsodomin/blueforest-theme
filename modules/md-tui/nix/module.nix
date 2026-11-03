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
# The module is inert unless `blueforest.md-tui.enable` is true: it does not
# enable md-tui, it only adds the theme to the configuration of an md-tui
# that the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.md-tui.enable`,
# because Home Manager has no module for md-tui: the option of Home Manager
# would clash with the one of this module if Home Manager ever gained one.
#
# md-tui reads the configuration directory of the user from `$HOME/.config`,
# and it ignores `XDG_CONFIG_HOME`, so the files are written there and not in
# the configuration directory of `XDG_CONFIG_HOME`.
#
# The theme is written with `lib.mkDefault`, so a consumer that brings a
# palette of its own keeps it, and so does a consumer that selects a theme of
# its own.
{
  config,
  lib,
  ...
}:
{
  options.blueforest.md-tui = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the BlueForest theme for md-tui.";
    };
  };

  config = lib.mkIf config.blueforest.md-tui.enable {
    # The theme, in the directory md-tui reads the palettes from. The name of
    # the file is the name of the theme.
    home.file.".config/mdt/themes/blueforest.json" = lib.mkDefault {
      source = ../themes/blueforest.json;
    };

    # The selection of the theme.
    home.file.".config/mdt/selected-theme" = lib.mkDefault {
      text = "blueforest\n";
    };
  };
}
