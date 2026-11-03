# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for Noctalia.
#
# Noctalia reads the palettes of the user from the `palettes` directory of its
# configuration directory, and it selects one of them with the `source` and
# `custom_palette` settings of its configuration. This module writes the
# palette there and adds the file that selects it, so that Noctalia picks the
# theme up without any further work.
#
# The module is inert unless `programs.noctalia.enable` is true: it does not
# enable Noctalia, it only adds the theme to the configuration of a Noctalia
# that the consumer already enabled.
#
# The palette is written through the `customPalettes` option of Home Manager,
# which is the option that knows where Noctalia reads the palettes from. The
# selection is a file of its own: `settings` is one opaque value, so the module
# cannot merge the two keys into it. Noctalia merges every `*.toml` file of its
# configuration directory, sorted by name, and `blueforest.toml` sorts before
# `config.toml`, so a setting the consumer writes wins over the selection of
# the module.
#
# The definitions are default ones, so a consumer that brings a palette or a
# selection of its own keeps it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.noctalia;
in
{
  config = lib.mkIf cfg.enable {
    # The palette, in the directory Noctalia reads the palettes of the user
    # from. The name of the attribute is the name of the palette, which is the
    # name the selection refers to.
    programs.noctalia.customPalettes.blueforest = lib.mkDefault ../themes/blueforest.json;

    # The selection of the palette. The file is one of the `*.toml` files that
    # Noctalia merges, and it carries only the two keys that select the
    # palette, so that the rest of the configuration is untouched.
    xdg.configFile."noctalia/blueforest.toml" = lib.mkDefault {
      text = ''
        [theme]
        source = "custom"
        custom_palette = "blueforest"
      '';
    };
  };
}
