# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for lazydocker, as a flake-parts module.
#
# The root flake imports this module out of the tree of the repository, and
# publishes it for the consumers that want the theme of the application
# alone.
#
# The inputs of the application. The root flake binds them to the module and
# passes them as a static argument, so that the module does not depend on the
# inputs of the flake that imports it.
#
# The arguments of the module are the ones of the flake that imports it: the
# `inputs` below are the inputs of that flake, so that the packages of the
# application are built with the nixpkgs of the consumer.
{
  appInputs,
}:
{
  config,
  lib,
  inputs,
  self,
  ...
}:
let
  # The version of the packages of the application.
  #
  # A release of the repository is a tag of the form vMAJOR.MINOR.PATCH. A
  # package of the repository is never a release: it is a snapshot of the
  # commit it is built from, and it carries the revision of that commit. The
  # version of a release is the one of its tag, and it is the release
  # workflow that applies it.
  version =
    if self ? shortRev then
      "0.0.0+${self.shortRev}"
    else if self ? dirtyShortRev then
      "0.0.0+${lib.removeSuffix "-dirty" self.dirtyShortRev}.dirty"
    else
      "0.0.0";
in
{
  # The flake module of Home Manager, which declares `flake.homeModules`. It
  # is imported here, so that the module of the application can be composed
  # with the others without the consumer having to import it.
  #
  # The Home Manager of the consumer is the one to use when it has one: the
  # declaration of the option is then the one of the consumer, and the module
  # system imports it only once.
  imports = [
    (inputs.home-manager or appInputs.home-manager).flakeModules.home-manager
  ];

  perSystem =
    {
      system,
      ...
    }:
    let
      # The nixpkgs instance of the application. The theme is built with the
      # overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.lazydocker ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      theme = pkgs.blueforest-lazydocker-theme;

      # The theme of the repository.
      source = ./themes/blueforest.json;
      sourceLight = ./themes/blueforest-light.json;
    in
    {
      packages.blueforest-lazydocker-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository.
        lazydocker-theme = import ./nix/checks/theme.nix {
          inherit
            pkgs
            theme
            source
            sourceLight
            ;
        };

        # lazydocker reads the theme of the repository and paints with it.
        lazydocker-render = import ./nix/checks/render.nix {
          inherit pkgs source sourceLight;
        };

        # The Home Manager module adds the theme to the settings of lazydocker,
        # and it writes nothing when lazydocker is not enabled.
        lazydocker-module = import ./nix/checks/module.nix {
          inherit source sourceLight;
          pkgs = basePkgs;
          homeManager = appInputs.home-manager;
          module = config.flake.homeModules.lazydocker;
        };
      };
    };

  flake = {
    # The overlay of the application. It adds the theme to a nixpkgs
    # instance, and it leaves the programs of nixpkgs alone: the theme is a
    # file of its own, so that applying the overlay does not replace the
    # lazydocker of a configuration that does not want the theme.
    overlays.lazydocker = final: _prev: {
      blueforest-lazydocker-theme = import ./nix/theme.nix {
        inherit (final) lib;
        pkgs = final;
        inherit version;
      };
    };

    # lazydocker reads the configuration of the user from the `lazydocker`
    # directory of its configuration directory, and there is no system-wide
    # configuration file it reads, so the application publishes a Home
    # Manager module and no NixOS module.
    homeModules.lazydocker = import ./nix/module.nix;
  };
}
