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
# The module is inert unless `blueforest-theme.kitty.enable` is true: it does not
# enable kitty, it only adds the theme to the configuration of a kitty that
# the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.kitty.enable`, so
# that the theme and the template of the community catalogue of Noctalia for
# kitty are alternatives. A consumer that enables both gets an error, because
# the two of them write the same configuration of kitty.
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

  # The variant of the theme that is installed.
  variant = config.blueforest-theme.kitty.variant;

  # The name of the file of the theme, which is the name of the include line
  # that selects it.
  file = if variant == "dark" then "blueforest.conf" else "blueforest-light.conf";

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
  options.blueforest-theme.kitty = {
    enable = lib.mkEnableOption "the BlueForest theme for kitty";

    variant = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "The variant of the theme of kitty that is installed.";
    };
  };

  config = lib.mkMerge [
    {
      # The template of Noctalia for kitty writes the same configuration of
      # kitty, so the two of them cannot be enabled at the same time.
      assertions = [
        {
          assertion = !(config.blueforest-theme.kitty.enable && lib.elem "kitty" enabledTemplates);
          message = ''
            The BlueForest theme for kitty and the Noctalia template for kitty
            are both enabled, and the two of them write the configuration of
            kitty. Disable the template in the configuration of Noctalia
            (remove "kitty" from `[theme.templates] builtin_ids`), or set
            `blueforest-theme.kitty.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest-theme.kitty.enable && cfg.enable) {
      # The theme, in the directory kitty reads the themes from. The name of
      # the attribute is the name of the file, and the variant decides which
      # one of them is installed.
      xdg.configFile."kitty/themes/blueforest.conf" = lib.mkIf (variant == "dark") {
        source = lib.mkDefault ../themes/blueforest.conf;
      };

      xdg.configFile."kitty/themes/blueforest-light.conf" = lib.mkIf (variant == "light") {
        source = lib.mkDefault ../themes/blueforest-light.conf;
      };

      # Home Manager writes the configuration of kitty with an order of its
      # own, and the order below comes before all of them. The theme is the
      # background of the colours of the terminal, and anything the consumer
      # sets is painted over it.
      programs.kitty.extraConfig = lib.mkOrder 505 ''
        include themes/${file}
      '';
    })
  ];
}
