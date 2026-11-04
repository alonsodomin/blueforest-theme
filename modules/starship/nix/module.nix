# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest palettes for Starship, and the preset of the
# repository.
#
# The preset and the palettes are two things, and the module installs them
# apart. The palette is a table of colours that the preset names, so the
# preset is the shape of the prompt and the palette is what paints it:
#
# - `blueforest-theme.starship.palette.enable` defines the palette of the
#   variant in the settings of Starship, and it selects it. The selection is
#   a default one, so a consumer that selects a palette of its own keeps it.
# - `blueforest-theme.starship.preset.enable` selects the package that carries
#   the preset, so that `programs.starship.presets` can name it. It does not
#   select the preset: the consumer writes
#   `programs.starship.presets = [ "blueforest" ]`.
#
# The module is inert unless `programs.starship.enable` is true: it does not
# enable Starship, it only adds the palette and the preset to the
# configuration of a Starship that the consumer already enabled.
#
# The switches are the ones of this repository, and not `programs.starship.enable`,
# so that the theme and the templates of the community catalogue of Noctalia
# for Starship are alternatives. A consumer that enables the palette of the
# repository and a template gets an error, because the two of them write the
# same configuration of Starship. The preset can go with a template: it is a
# package that carries the prompt, and the prompt names the keys of the
# palette that the template writes.
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
  cfg = config.programs.starship;

  # The variant of the palette that is defined.
  variant = config.blueforest-theme.starship.palette.variant;

  # The palettes of the repository, as Starship reads them. The files are
  # TOML, and Nix reads them at evaluation time, so that the colours of the
  # module and the colours of the files are the same ones.
  palettes = {
    dark =
      (builtins.fromTOML (builtins.readFile ../themes/palettes/blueforest.toml)).palettes.blueforest;
    light =
      (builtins.fromTOML (builtins.readFile ../themes/palettes/blueforest-light.toml))
      .palettes.blueforest-light;
  };

  # The name of the palette of the variant, which is the name the module
  # selects with `programs.starship.settings.palette`.
  palette = if variant == "dark" then "blueforest" else "blueforest-light";

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
    palette = {
      enable = lib.mkEnableOption "the BlueForest palette for Starship";

      variant = lib.mkOption {
        type = lib.types.enum [
          "dark"
          "light"
        ];
        default = "dark";
        description = "The variant of the palette of Starship that is defined.";
      };
    };

    preset.enable = lib.mkEnableOption "the BlueForest preset for Starship";
  };

  config = lib.mkMerge [
    {
      # The overlay of the application, so that the package the module
      # selects is the one of the application.
      nixpkgs.overlays = [ overlay ];
    }

    {
      # The templates of Noctalia for Starship write the same configuration
      # of Starship, so they and the palette of the repository cannot be
      # enabled at the same time. The preset is a package that carries the
      # prompt, and it does not write the configuration, so it can be
      # enabled with a template: the template writes the palette, and the
      # preset names the keys of that palette.
      assertions = [
        {
          assertion =
            !(
              config.blueforest-theme.starship.palette.enable
              && (lib.elem "starship" enabledTemplates || lib.elem "starship-m3" enabledTemplates)
            );
          message = ''
            The BlueForest palette for Starship and a Noctalia template for
            Starship are both enabled, and the two of them write the
            configuration of Starship. Disable the template in the
            configuration of Noctalia (remove "starship" from
            `[theme.templates] builtin_ids`, or "starship-m3" from
            `[theme.templates] community_ids`), or set
            `blueforest-theme.starship.palette.enable = false`. The preset of
            the repository can be enabled with a template: it names the keys
            of the palette that the template writes.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest-theme.starship.palette.enable && cfg.enable) {
      # The palette of the variant, in the settings of Starship. The keys are
      # set one by one, and every one of them is a default one, so that a
      # consumer that brings a colour of its own keeps it and keeps the rest
      # of the palette as well.
      programs.starship.settings.palettes.${palette} = lib.mapAttrs (
        _: value: lib.mkDefault value
      ) palettes.${variant};

      # The palette of the variant is selected as well, so that the consumer
      # does not have to name it. The selection is a default one, so a
      # consumer that selects a palette of its own keeps it.
      programs.starship.settings.palette = lib.mkDefault palette;
    })

    (lib.mkIf (config.blueforest-theme.starship.preset.enable && cfg.enable) {
      # The package of the consumer is the one that carries the preset of the
      # repository, so that `programs.starship.presets` can name it.
      programs.starship.package = lib.mkDefault pkgs.blueforest-starship;
    })
  ];
}
