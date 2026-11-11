# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for lazydocker.
#
# lazydocker has no theme file of its own: the theme is the `gui.theme` mapping
# of the configuration file of lazydocker, which is
# `$XDG_CONFIG_HOME/lazydocker/config.yml`. This module adds that mapping to the
# settings of lazydocker, so that lazydocker picks the theme up without any
# further work.
#
# The module is inert unless `blueforest-theme.lazydocker.enable` is true: it does
# not enable lazydocker, it only adds the theme to the configuration of a
# lazydocker that the consumer already enabled.
#
# The colours are set one by one, and every one of them is a default one, so
# that a consumer that brings a colour of its own keeps it and keeps the rest
# of the theme as well. The settings of lazydocker are one value, and a value
# that is set as a whole would be replaced by the settings of the consumer,
# colours and all.
#
# The theme has a variant per mode, and `blueforest-theme.lazydocker.variant`
# selects the one that is installed: the dark one, which is named
# `blueforest`, or the light one, which is named `blueforest-light`.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.lazydocker;

  # The variant of the theme that is installed.
  variant = config.blueforest-theme.lazydocker.variant;

  # The theme of the repository. The file is JSON, and JSON is a subset of
  # YAML, so lazydocker reads it as its own format, and Nix reads it at
  # evaluation time, so that the colours of the module and the colours of the
  # file are the same ones.
  theme =
    (builtins.fromJSON (
      builtins.readFile (
        if variant == "dark" then ../themes/blueforest.json else ../themes/blueforest-light.json
      )
    )).gui.theme;
in
{
  options.blueforest-theme.lazydocker = {
    enable = lib.mkEnableOption "the BlueForest theme for lazydocker";

    variant = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "The variant of the theme of lazydocker that is installed.";
    };
  };

  config = lib.mkIf (config.blueforest-theme.lazydocker.enable && cfg.enable) {
    # The border of the window that has the focus, and the text of the selected
    # line, which lazydocker paints with the same colour.
    programs.lazydocker.settings.gui.theme.activeBorderColor = lib.mkDefault theme.activeBorderColor;

    # The border of the windows that have no focus.
    programs.lazydocker.settings.gui.theme.inactiveBorderColor =
      lib.mkDefault theme.inactiveBorderColor;

    # The background of the selected line.
    programs.lazydocker.settings.gui.theme.selectedLineBgColor =
      lib.mkDefault theme.selectedLineBgColor;

    # The text of the line at the bottom, which carries the keybindings.
    programs.lazydocker.settings.gui.theme.optionsTextColor = lib.mkDefault theme.optionsTextColor;
  };
}
