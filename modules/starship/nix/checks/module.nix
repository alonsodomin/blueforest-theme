# SPDX-License-Identifier: MPL-2.0
#
# Checks that the modules of the application add the overlay of the theme, and
# that the Home Manager module selects the preset of the repository only when
# the consumer asks for it.
#
# The check covers the conflict with the templates of the community catalogue
# of Noctalia for Starship: a configuration that enables both fails to
# evaluate.
{
  lib,
  pkgs,
  homeManager,
  modules,
  overlay,
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

  # A consumer that asks for the preset of the repository.
  enabled = evaluateHome [
    {
      programs.starship.enable = true;
      blueforest-theme.starship.enable = true;
    }
  ];

  # A consumer that does not ask for it.
  disabled = evaluateHome [ ];

  # A consumer that asks for the preset but does not enable Starship: the
  # preset has no consumer, so the module selects nothing.
  themeOnly = evaluateHome [
    {
      blueforest-theme.starship.enable = true;
    }
  ];

  # A configuration that enables the preset of the repository and a template
  # of Noctalia for Starship: it fails to evaluate.
  conflict =
    if
      (builtins.tryEval
        (evaluateHome [
          {
            programs.starship.enable = true;
            blueforest-theme.starship.enable = true;
          }
          {
            programs.noctalia.settings.theme.templates.builtin_ids = [ "starship" ];
          }
        ]).home.username
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
      overlayCount = builtins.length enabled.nixpkgs.overlays;
      overlaysAreFunctions = builtins.all builtins.isFunction enabled.nixpkgs.overlays;
    };
    overlay = {
      hasPreset = applied ? blueforest-starship-preset;
      hasWrapper = applied ? blueforest-starship;
      # The overlay leaves the Starship of nixpkgs alone, so that a
      # configuration that does not want the theme keeps the one it has.
      leavesStarshipAlone = !(applied ? starship);
    };
    enabled = {
      presets = enabled.programs.starship.presets;
      package = enabled.programs.starship.package.name;
    };
    disabled = {
      presets = disabled.programs.starship.presets;
    };
    themeOnly = {
      presets = themeOnly.programs.starship.presets;
    };
  };
in
pkgs.runCommand "blueforest-starship-module-check"
  {
    nativeBuildInputs = [ pkgs.jq ];

    inherit conflict result;
  }
  ''
    echo "$result" | jq -e '
      .nixos.overlayCount > 0 and .nixos.overlaysAreFunctions
      and .home.overlayCount > 0 and .home.overlaysAreFunctions
      and .overlay.hasPreset
      and .overlay.hasWrapper
      and .overlay.leavesStarshipAlone
    ' >/dev/null

    # The preset of the repository is selected, and it comes with the
    # package that carries it.
    echo "$result" | jq -e '
      .enabled.presets == [ "blueforest" ]
      and (.enabled.package | startswith("blueforest-starship"))
    ' >/dev/null

    # And a consumer that does not ask for it selects no preset at all.
    echo "$result" | jq -e '
      (.disabled.presets | length) == 0
      and (.themeOnly.presets | length) == 0
    ' >/dev/null

    # The templates of Noctalia for Starship and the preset of the
    # repository cannot be enabled at the same time.
    if [ "$conflict" != "yes" ]; then
      echo "the conflict with the Noctalia template for Starship did not fail" >&2
      exit 1
    fi

    touch $out
  ''
