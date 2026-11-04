# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest preset for Starship.
#
# Starship reads the presets of the user from the `presets` directory of the
# directory of its configuration, and the ones of the package are read from
# the same place. The module selects the preset of the repository, and it
# selects the package that carries it, so that Starship picks the preset up
# without any further work.
#
# The module is inert unless `blueforest-theme.starship.enable` is true: it does not
# enable Starship, it only adds the preset to the configuration of a Starship
# that the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.starship.enable`,
# so that the preset and the templates of the community catalogue of Noctalia
# for Starship are alternatives. A consumer that enables both gets an error,
# because the two of them write the same configuration of Starship.
#
# The overlay of the application is passed to the module, so that the package
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
  options.blueforest-theme.starship = {
    enable = lib.mkEnableOption "the BlueForest preset for Starship";
  };

  config = lib.mkMerge [
    {
      # The overlay of the application, so that the package the module
      # selects is the one of the application.
      nixpkgs.overlays = [ overlay ];
    }

    {
      # The templates of Noctalia for Starship write the same configuration
      # of Starship, so they and the preset of the repository cannot be
      # enabled at the same time.
      assertions = [
        {
          assertion =
            !(
              config.blueforest-theme.starship.enable
              && (lib.elem "starship" enabledTemplates || lib.elem "starship-m3" enabledTemplates)
            );
          message = ''
            The BlueForest preset for Starship and a Noctalia template for
            Starship are both enabled, and the two of them write the
            configuration of Starship. Disable the template in the
            configuration of Noctalia (remove "starship" from
            `[theme.templates] builtin_ids`, or "starship-m3" from
            `[theme.templates] community_ids`), or set
            `blueforest-theme.starship.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest-theme.starship.enable && config.programs.starship.enable) {
      # The package of the consumer is the one that carries the preset of the
      # repository.
      programs.starship.package = lib.mkDefault pkgs.blueforest-starship;

      # And the preset of the repository is selected.
      programs.starship.presets = lib.mkDefault [ "blueforest" ];
    })
  ];
}
