# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for lazygit.
#
# lazygit has no theme file of its own: the theme is the `gui.theme` mapping
# of the configuration file of lazygit, which is
# `$XDG_CONFIG_HOME/lazygit/config.yml`. This module adds that mapping to the
# settings of lazygit, so that lazygit picks the theme up without any further
# work.
#
# The module is inert unless `blueforest-theme.lazygit.enable` is true: it does not
# enable lazygit, it only adds the theme to the configuration of a lazygit
# that the consumer already enabled.
#
# The colours are set one by one, and every one of them is a default one, so
# that a consumer that brings a colour of its own keeps it and keeps the rest
# of the theme as well. The settings of lazygit are one value, and a value
# that is set as a whole would be replaced by the settings of the consumer,
# colours and all.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.lazygit;

  # The theme of the repository. The file is JSON, and JSON is a subset of
  # YAML, so lazygit reads it as its own format, and Nix reads it at
  # evaluation time, so that the colours of the module and the colours of the
  # file are the same ones.
  theme = (builtins.fromJSON (builtins.readFile ../themes/blueforest.json)).gui.theme;
in
{
  options.blueforest-theme.lazygit = {
    enable = lib.mkEnableOption "the BlueForest theme for lazygit";
  };

  config = lib.mkIf (config.blueforest-theme.lazygit.enable && cfg.enable) {
    # The border of the window that has the focus.
    programs.lazygit.settings.gui.theme.activeBorderColor = lib.mkDefault theme.activeBorderColor;

    # The border of the windows that have no focus.
    programs.lazygit.settings.gui.theme.inactiveBorderColor = lib.mkDefault theme.inactiveBorderColor;

    # The border of the window that has the focus while it is searched.
    programs.lazygit.settings.gui.theme.searchingActiveBorderColor =
      lib.mkDefault theme.searchingActiveBorderColor;

    # The text of the line at the bottom, which carries the keybindings.
    programs.lazygit.settings.gui.theme.optionsTextColor = lib.mkDefault theme.optionsTextColor;

    # The text of the selected line. It keeps the colour it has, and it is
    # written in bold.
    programs.lazygit.settings.gui.theme.selectedLineFgColor = lib.mkDefault theme.selectedLineFgColor;

    # The background of the selected line of the window that has the focus.
    programs.lazygit.settings.gui.theme.selectedLineBgColor = lib.mkDefault theme.selectedLineBgColor;

    # The background of the selected line of the windows that have no focus.
    programs.lazygit.settings.gui.theme.inactiveViewSelectedLineBgColor =
      lib.mkDefault theme.inactiveViewSelectedLineBgColor;

    # The commit that was copied to the clipboard.
    programs.lazygit.settings.gui.theme.cherryPickedCommitFgColor =
      lib.mkDefault theme.cherryPickedCommitFgColor;
    programs.lazygit.settings.gui.theme.cherryPickedCommitBgColor =
      lib.mkDefault theme.cherryPickedCommitBgColor;

    # The commit that was marked as the base of a rebase.
    programs.lazygit.settings.gui.theme.markedBaseCommitFgColor =
      lib.mkDefault theme.markedBaseCommitFgColor;
    programs.lazygit.settings.gui.theme.markedBaseCommitBgColor =
      lib.mkDefault theme.markedBaseCommitBgColor;

    # The files with changes that were not staged.
    programs.lazygit.settings.gui.theme.unstagedChangesColor = lib.mkDefault theme.unstagedChangesColor;

    # The text of the interface.
    programs.lazygit.settings.gui.theme.defaultFgColor = lib.mkDefault theme.defaultFgColor;
  };
}
