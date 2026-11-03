# SPDX-License-Identifier: MPL-2.0
#
# Makes the BlueForest theme for Neovim available to the consumer's
# configuration.
#
# The module adds the theme as a plugin of Neovim, so that the colourscheme
# and the theme of lualine are both on the runtimepath. It does not enable
# Neovim: whether the editor is installed at all stays the consumer's
# decision. It does not select the colourscheme either: that is a line of the
# consumer's own configuration, and Home Manager writes that configuration
# only when the consumer asks for it.
#
#   programs.neovim.enable = true;
#   blueforest.neovim.enable = true;
#
# and, in the configuration of the editor:
#
#   vim.cmd.colorscheme("blueforest")
#
# The module is inert unless `blueforest.neovim.enable` is true: the plugin
# is added to the plugins of a Neovim that the consumer already enabled, and
# never in place of them.
#
# The overlay of the application is passed to the module, so that the theme
# the consumer gets is the one of the application, with its version.
{
  overlay,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.blueforest.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the BlueForest theme for Neovim.";
    };
  };

  config = lib.mkMerge [
    {
      nixpkgs.overlays = [ overlay ];
    }

    (lib.mkIf (config.blueforest.neovim.enable && config.programs.neovim.enable) {
      # The theme is a plugin, and the plugins of Neovim are a list: the
      # theme is added to the plugins of the consumer, not in place of them.
      programs.neovim.plugins = lib.mkDefault [ pkgs.blueforest-neovim-theme ];
    })
  ];
}
