# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for kitty.
#
# kitty reads the themes of the user from the `themes` directory of its
# configuration directory, and it selects one of them with an `include` line
# in its own configuration. This module writes the theme there and adds the
# line that selects it, so that kitty picks the theme up without any further
# work.
#
# The module is inert unless `programs.kitty.enable` is true: it does not
# enable kitty, it only adds the theme to the configuration of a kitty that
# the consumer already enabled.
#
# The line that selects the theme comes before the ones Home Manager writes
# for the options of kitty, and before the ones the consumer writes, so that
# a colour the consumer sets wins over the one of the theme.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.kitty;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."kitty/themes/blueforest.conf" = lib.mkDefault {
      source = ../themes/blueforest.conf;
    };

    # Home Manager writes the configuration of kitty with an order of its
    # own, and the order below comes before all of them. The theme is the
    # background of the colours of the terminal, and anything the consumer
    # sets is painted over it.
    programs.kitty.extraConfig = lib.mkOrder 505 ''
      include themes/blueforest.conf
    '';
  };
}
