# SPDX-License-Identifier: MPL-2.0
#
# Checks that the modules of the application add the overlay of the theme, and
# that the Home Manager module installs the palette and the preset of the
# repository only when the consumer asks for them.
#
# The palette and the preset are two things: the palette is defined in the
# settings of Starship and it is never selected, and the preset is installed
# as a package and it is never selected either. The check covers the two of
# them apart and together, the light variant, and a consumer that brings a
# colour of its own.
#
# The check covers the conflict with the templates of the community catalogue
# of Noctalia for Starship: a configuration that enables a template and the
# palette of the repository fails to evaluate. The preset of the repository
# can be enabled with a template, and the check proves it.
{
  lib,
  pkgs,
  homeManager,
  modules,
  overlay,
  palettes,
}:
let
  # The overlay of the application, applied to the nixpkgs of the check, so
  # that the package the module selects is the one of the application.
  applied = overlay pkgs pkgs;

  # The NixOS module of the application does no more than adding the overlay,
  # so it is evaluated against the module system of NixOS.
  consumerModule =
    { lib, ... }:
    {
      options.nixpkgs.overlays = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [ ];
      };
    };

  nixosOverlays =
    (lib.evalModules {
      modules = [
        consumerModule
        modules.nixos
      ];
    }).config.nixpkgs.overlays;

  # The configuration of a consumer, evaluated against Home Manager.
  evaluateHome =
    extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        modules.home
        {
          home.username = "blueforest";
          home.homeDirectory = "/home/blueforest";
          home.stateVersion = "26.11";
        }
      ]
      ++ extra;
    }).config;

  # The palettes of the repository, as the module reads them.
  expected = {
    dark = (builtins.fromTOML (builtins.readFile palettes.blueforest)).palettes.blueforest;
    light = (builtins.fromTOML (builtins.readFile palettes.blueforest-light)).palettes.blueforest-light;
  };

  # The palette a configuration defines, or null when it defines none.
  paletteOf =
    cfg: name:
    let
      palettes = cfg.programs.starship.settings.palettes or { };
    in
    lib.attrByPath [ name ] null palettes;

  # The palette a configuration selects, or null when it selects none.
  selectedOf = cfg: cfg.programs.starship.settings.palette or null;

  # A consumer that asks for the dark palette only.
  paletteOnly = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.palette.enable = true;
    }
  ];

  # A consumer that asks for the light palette.
  light = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.palette = {
        enable = true;
        variant = "light";
      };
    }
  ];

  # A consumer that asks for the preset only.
  presetOnly = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.preset.enable = true;
    }
  ];

  # A consumer that asks for both of them.
  both = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.palette.enable = true;
      blueforest-theme.starship.preset.enable = true;
    }
  ];

  # A consumer that does not ask for anything.
  disabled = evaluateHome [ ];

  # A consumer that asks for the palette but does not enable Starship: the
  # palette has no consumer, so the module defines nothing.
  themeOnly = evaluateHome [
    {
      blueforest-theme.starship.palette.enable = true;
    }
  ];

  # A consumer that brings a colour of its own: the colour of the consumer
  # wins over the colour of the palette, and the rest of the palette
  # survives, because the module sets every colour with `lib.mkDefault`.
  own = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.palette.enable = true;
      programs.starship.settings.palettes.blueforest.blue = "#FF0000";
    }
  ];

  # A consumer that selects a palette of its own: the selection of the
  # consumer wins over the one of the module, because the module selects the
  # palette of the variant with `lib.mkDefault`.
  selected = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.palette.enable = true;
      programs.starship.settings.palette = "blueforest-light";
    }
  ];

  # A consumer that selects the preset and the palette, the way the
  # documentation of the application tells: the configuration file of
  # Starship carries the preset and the palette together, and the palette of
  # the variant is selected.
  consumer = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship = {
        palette.enable = true;
        preset.enable = true;
      };
      programs.starship.presets = [ "blueforest" ];
    }
  ];

  # A configuration that enables the theme of the repository and a template
  # of Noctalia for Starship: it fails to evaluate.
  conflictOf =
    extra:
    if
      (builtins.tryEval
        (evaluateHome (
          [
            {
              programs.starship.enable = true;
            }
            {
              programs.noctalia.settings.theme.templates.builtin_ids = [ "starship" ];
            }
          ]
          ++ extra
        )).home.username
      ).success
    then
      "no"
    else
      "yes";

  result = builtins.toJSON {
    nixos = {
      overlayCount = builtins.length nixosOverlays;
      overlaysAreFunctions = builtins.all builtins.isFunction nixosOverlays;
    };
    home = {
      overlayCount = builtins.length paletteOnly.nixpkgs.overlays;
      overlaysAreFunctions = builtins.all builtins.isFunction paletteOnly.nixpkgs.overlays;
    };
    overlay = {
      hasPreset = applied ? blueforest-starship-preset;
      hasPalette = applied ? blueforest-starship-palette;
      hasWrapper = applied ? blueforest-starship;
      # The overlay leaves the Starship of nixpkgs alone, so that a
      # configuration that does not want the theme keeps the one it has.
      leavesStarshipAlone = !(applied ? starship);
    };
    paletteOnly = {
      selected = selectedOf paletteOnly;
      presets = paletteOnly.programs.starship.presets;
      package = paletteOnly.programs.starship.package.name;
      dark = paletteOf paletteOnly "blueforest";
      light = paletteOf paletteOnly "blueforest-light";
    };
    light = {
      selected = selectedOf light;
      dark = paletteOf light "blueforest";
      light = paletteOf light "blueforest-light";
    };
    presetOnly = {
      selected = selectedOf presetOnly;
      presets = presetOnly.programs.starship.presets;
      package = presetOnly.programs.starship.package.name;
      palettes = presetOnly.programs.starship.settings.palettes or { };
    };
    both = {
      selected = selectedOf both;
      dark = paletteOf both "blueforest";
      package = both.programs.starship.package.name;
    };
    disabled = {
      selected = selectedOf disabled;
      presets = disabled.programs.starship.presets;
      palettes = disabled.programs.starship.settings.palettes or { };
    };
    themeOnly = {
      selected = selectedOf themeOnly;
      presets = themeOnly.programs.starship.presets;
      palettes = themeOnly.programs.starship.settings.palettes or { };
    };
    own = {
      inherit ((paletteOf own "blueforest")) blue;
      inherit ((paletteOf own "blueforest")) mantle;
    };
    selected = {
      selected = selectedOf selected;
    };
    inherit expected;
    conflict = {
      palette = conflictOf [
        {
          blueforest-theme.starship.palette.enable = true;
        }
      ];
      preset = conflictOf [
        {
          blueforest-theme.starship.preset.enable = true;
        }
      ];
    };
  };
in
pkgs.runCommand "blueforest-starship-module-check"
  {
    nativeBuildInputs = [
      pkgs.jq
      pkgs.gnugrep
    ];

    inherit result;

    # The configuration file that Home Manager writes for the consumer that
    # selects the preset and the palette.
    config = "${consumer.home.file."${consumer.programs.starship.configPath}".source}";
  }
  ''
    echo "$result" | jq -e '
      .nixos.overlayCount > 0 and .nixos.overlaysAreFunctions
      and .home.overlayCount > 0 and .home.overlaysAreFunctions
      and .overlay.hasPreset
      and .overlay.hasPalette
      and .overlay.hasWrapper
      and .overlay.leavesStarshipAlone
    ' >/dev/null

    # The palette only: the dark palette is defined and selected, no preset
    # is installed, and the package of Starship is the upstream one.
    echo "$result" | jq -e '
      .paletteOnly.selected == "blueforest"
      and (.paletteOnly.presets | length) == 0
      and .paletteOnly.dark == .expected.dark
      and .paletteOnly.light == null
      and (.paletteOnly.package | startswith("starship"))
    ' >/dev/null

    # The light variant: the light palette is defined and selected, and the
    # dark one is not.
    echo "$result" | jq -e '
      .light.selected == "blueforest-light"
      and .light.light == .expected.light
      and .light.dark == null
    ' >/dev/null

    # The preset only: the package that carries it is selected, and neither
    # a palette nor the selection of one is there.
    echo "$result" | jq -e '
      .presetOnly.selected == null
      and (.presetOnly.presets | length) == 0
      and (.presetOnly.palettes | length) == 0
      and (.presetOnly.package | startswith("blueforest-starship"))
    ' >/dev/null

    # Both of them.
    echo "$result" | jq -e '
      .both.selected == "blueforest"
      and .both.dark == .expected.dark
      and (.both.package | startswith("blueforest-starship"))
    ' >/dev/null

    # A consumer that does not ask for anything gets nothing.
    echo "$result" | jq -e '
      .disabled.selected == null
      and (.disabled.presets | length) == 0
      and (.disabled.palettes | length) == 0
      and (.themeOnly.presets | length) == 0
      and (.themeOnly.palettes | length) == 0
      and .themeOnly.selected == null
    ' >/dev/null

    # A consumer that brings a colour of its own keeps it, and the rest of
    # the palette survives.
    echo "$result" | jq -e '
      .own.blue == "#FF0000"
      and .own.mantle == .expected.dark.mantle
    ' >/dev/null

    # A consumer that selects a palette of its own keeps the selection.
    echo "$result" | jq -e '
      .selected.selected == "blueforest-light"
    ' >/dev/null

    # The templates of Noctalia for Starship and the palette of the
    # repository cannot be enabled at the same time. The preset can: it is a
    # package that carries the prompt, and it does not write the
    # configuration.
    if [ "$(echo "$result" | jq -r .conflict.palette)" != "yes" ]; then
      echo "the conflict of the palette with the Noctalia template did not fail" >&2
      exit 1
    fi
    if [ "$(echo "$result" | jq -r .conflict.preset)" != "no" ]; then
      echo "the preset of the repository cannot be enabled with a Noctalia template" >&2
      exit 1
    fi

    # The configuration file of the consumer carries the preset and the
    # palette together: the preset is merged into the configuration, and the
    # palette is defined in it. The right-handed part of the prompt is a
    # segment of the format, and not a right prompt of its own.
    test -s "$config"
    grep -qF '$fill$cmd_duration$nix_shell$line_break$character' "$config"
    grep -qF '[palettes.blueforest]' "$config"
    grep -qF 'blue = "#0099FF"' "$config"
    grep -qF 'palette = "blueforest"' "$config"

    touch $out
  ''
