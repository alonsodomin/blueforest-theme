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
# The module is inert unless `blueforest.btop.enable` is true: it does not
# enable btop, it only adds the theme to the configuration of a btop that the
# consumer already enabled.
#
# The switch is the one of this repository, and not `programs.btop.enable`, so
# that the theme and the template of the community catalogue of Noctalia for
# btop are alternatives. A consumer that enables both gets an error, because
# the two of them write the same configuration of btop.
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
  # The ids of the templates of Noctalia that the consumer enabled. The
  # configuration of Noctalia is one opaque value, and it may be an attribute
  # set, a string or a path: only the attribute set carries the ids, and the
  # others are read as "no template enabled", so that the assertion never
  # fires on a configuration it cannot read.
  enabledTemplates =
    let
      noctalia = (config.programs or { }).noctalia or { };
      settings = noctalia.settings or { };
      templates =
        if !(lib.isAttrs settings) then
          { }
        else if !(lib.isAttrs (settings.theme or null)) then
          { }
        else if !(lib.isAttrs (settings.theme.templates or null)) then
          { }
        else
          settings.theme.templates;
    in
    (templates.builtin_ids or [ ]) ++ (templates.community_ids or [ ]);
in
{
  options.blueforest.btop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the BlueForest theme for btop.";
    };
  };

  config = lib.mkMerge [
    {
      # The template of Noctalia for btop writes the same configuration of
      # btop, so the two of them cannot be enabled at the same time.
      assertions = [
        {
          assertion = !(config.blueforest.btop.enable && lib.elem "btop" enabledTemplates);
          message = ''
            The BlueForest theme for btop and the Noctalia template for btop
            are both enabled, and the two of them write the configuration of
            btop. Disable the template in the configuration of Noctalia
            (remove "btop" from `[theme.templates] builtin_ids`), or set
            `blueforest.btop.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest.btop.enable && config.programs.btop.enable) {
      # The theme, in the directory btop reads the themes from. The name of
      # the attribute is the name of the file, and btop needs the extension to
      # list the theme.
      programs.btop.themes.blueforest = lib.mkDefault ../themes/blueforest.theme;

      # The selection of the theme, in the configuration of btop.
      programs.btop.settings.color_theme = lib.mkDefault "blueforest.theme";
    })
  ];
}
