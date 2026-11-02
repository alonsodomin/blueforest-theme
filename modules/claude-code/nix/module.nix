# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for Claude Code.
#
# Claude Code reads the custom themes of the user from the `themes` directory
# of its configuration directory, and it selects one of them with the `theme`
# setting of its settings file, whose value is `custom:<slug>`, where the slug
# is the name of the file without its extension. This module writes the theme
# there and selects it.
#
# The module is inert unless `programs.claude-code.enable` is true: it does
# not enable Claude Code, it only adds the theme to the configuration of a
# Claude Code that the consumer already enabled.
#
# The theme is selected with `lib.mkDefault`, so a consumer that selects a
# theme of its own keeps it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf cfg.enable {
    # The theme, in the directory Claude Code reads the themes from.
    home.file."${cfg.configDir}/themes/blueforest.json".source = ../themes/blueforest.json;

    # The selection of the theme, in the settings of Claude Code.
    programs.claude-code.settings.theme = lib.mkDefault "custom:blueforest";
  };
}
