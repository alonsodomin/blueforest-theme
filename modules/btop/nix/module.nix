# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for btop.
#
# btop reads the themes of the user from the `themes` directory of its
# configuration directory, and it selects one of them with the `color_theme`
# setting of its configuration file, whose value is the name of the file.
# This module writes the theme there and selects it, so that btop picks the
# theme up without any further work.
#
# The module is inert unless `programs.btop.enable` is true: it does not
# enable btop, it only adds the theme to the configuration of a btop that the
# consumer already enabled.
#
# Home Manager has options of its own for the themes of btop and for the
# settings of its configuration file. The definitions here are default ones,
# so a consumer that brings a theme or a setting of its own keeps it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.btop;
in
{
  config = lib.mkIf cfg.enable {
    # The theme, in the directory btop reads the themes from. The name of
    # the attribute is the name of the file, and btop needs the extension to
    # list the theme.
    programs.btop.themes.blueforest = lib.mkDefault ../themes/blueforest.theme;

    # The selection of the theme, in the configuration of btop.
    programs.btop.settings.color_theme = lib.mkDefault "blueforest.theme";
  };
}
