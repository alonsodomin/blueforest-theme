# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for Zed.
#
# Zed reads the themes of the extensions it installs, and it reads the themes
# of the user from its themes directory:
#
#   ~/.config/zed/themes/blueforest.json
#
# The module writes the theme there, so that the theme shows up in the theme
# picker without any further work. Zed watches that directory, so the theme is
# picked up without restarting the editor.
#
# The module does not enable Zed: it only adds the theme to the configuration
# of an editor that the consumer already installed.
#
# The overlay of the application is passed to the module, so that the theme
# the consumer gets is the one of the application, with its version.
{
  overlay,
}:
{
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [ overlay ];

  xdg.configFile."zed/themes/blueforest.json".source =
    "${pkgs.blueforest-zed-theme}/themes/blueforest.json";
}
