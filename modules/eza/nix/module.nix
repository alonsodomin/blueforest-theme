# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for eza.
#
# eza reads a single theme file, `theme.yml`, from the configuration directory
# of the user. This module writes it there, so that eza picks the theme up
# without any further work.
#
# The module is inert unless `programs.eza.enable` is true: it does not enable
# eza, it only adds the theme to the configuration of an eza that the consumer
# already enabled.
#
# Home Manager has an option of its own for the theme of eza,
# `programs.eza.theme`, which writes the same file. The definition here is a
# default one, so a consumer that sets that option keeps its own theme.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.eza;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."eza/theme.yml" = lib.mkDefault {
      source = ../themes/blueforest.yml;
    };
  };
}
