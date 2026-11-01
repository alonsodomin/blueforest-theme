# SPDX-License-Identifier: MPL-2.0
#
# Makes `pkgs.blueforest-vscode-theme` available to the consumer's
# configuration.
#
# The module deliberately does not touch `programs.vscodium`: which editor
# installs the theme, and whether it is installed at all, stays the
# consumer's decision. For example:
#
#   programs.vscodium.profiles.default.extensions = [
#     pkgs.blueforest-vscode-theme
#   ];
#
# The overlay of the application is passed to the module, so that the theme
# the consumer gets is the one of the application, with its version.
{
  overlay,
}:
{
  ...
}:
{
  nixpkgs.overlays = [ overlay ];
}
