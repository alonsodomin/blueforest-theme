# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for bat.
#
# bat reads the themes of the user from the `themes` directory of its
# configuration directory, and it selects one of them with the `theme`
# setting of its configuration file, whose value is the name of the file
# without its extension. This module writes the theme there and selects it,
# so that bat picks the theme up without any further work.
#
# The module is inert unless `blueforest-theme.bat.enable` is true: it does
# not enable bat, it only adds the theme to the configuration of a bat that
# the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.bat.enable`, so
# that the theme and the template of the community catalogue of Noctalia for
# bat are alternatives. A consumer that enables both gets an error, because
# the two of them write the same configuration of bat.
#
# The theme has a variant per mode, and `blueforest-theme.bat.variant`
# selects the one that is installed: the dark one, which is named
# `BlueForest`, or the light one, which is named `BlueForestLight`.
#
# Home Manager has options of its own for the themes of bat and for the
# configuration of the program. The definitions here are default ones, so a
# consumer that brings a theme or a setting of its own keeps it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.bat;

  # The variant of the theme that is installed.
  variant = config.blueforest-theme.bat.variant;

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
  options.blueforest-theme.bat = {
    enable = lib.mkEnableOption "the BlueForest theme for bat";

    variant = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "The variant of the theme of bat that is installed.";
    };
  };

  config = lib.mkMerge [
    {
      # The template of Noctalia for bat writes the same configuration of
      # bat, so the two of them cannot be enabled at the same time.
      assertions = [
        {
          assertion = !(config.blueforest-theme.bat.enable && lib.elem "bat" enabledTemplates);
          message = ''
            The BlueForest theme for bat and the Noctalia template for bat are
            both enabled, and the two of them write the configuration of bat.
            Disable the template in the configuration of Noctalia (remove
            "bat" from `[theme.templates] community_ids`), or set
            `blueforest-theme.bat.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest-theme.bat.enable && cfg.enable) {
      # The theme, in the directory bat reads the themes from. The name of
      # the attribute is the name of the file, and bat needs the extension to
      # list the theme.
      programs.bat.themes = lib.mkMerge [
        (lib.mkIf (variant == "dark") {
          BlueForest = lib.mkDefault {
            src = ../themes;
            file = "BlueForest.tmTheme";
          };
        })
        (lib.mkIf (variant == "light") {
          BlueForestLight = lib.mkDefault {
            src = ../themes;
            file = "BlueForestLight.tmTheme";
          };
        })
      ];

      # The selection of the theme, in the configuration of bat.
      programs.bat.config.theme = lib.mkDefault (
        if variant == "dark" then "BlueForest" else "BlueForestLight"
      );
    })
  ];
}
