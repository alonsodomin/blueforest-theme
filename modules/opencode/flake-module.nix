# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for OpenCode, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
#
# The inputs of the application. Its own flake binds them to the module and
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
        overlays = [ config.flake.overlays.opencode ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      theme = pkgs.blueforest-opencode-theme;

      # The theme of the repository.
      source = ./themes/blueforest.json;
    in
    {
      packages.blueforest-opencode-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository, and every
        # colour of the theme resolves.
        opencode-theme = import ./nix/checks/theme.nix {
          inherit
            lib
            pkgs
            theme
            source
            ;
        };

        # The configuration documented in the documentation installs the theme where
        # OpenCode reads it, and selects it.
        opencode-configuration = import ./nix/checks/configuration.nix {
          inherit lib pkgs source;
          homeManager = appInputs.home-manager;
          module = config.flake.homeModules.opencode;
        };

        # The modules add the overlay of the application.
        opencode-module = import ./nix/checks/module.nix {
          inherit lib;
          pkgs = basePkgs;
          modules = {
            nixos = config.flake.nixosModules.opencode;
            home = config.flake.homeModules.opencode;
          };
          overlay = config.flake.overlays.opencode;
        };
      };

    };

  flake = {
    # The overlay of the application. It adds the theme to a nixpkgs
    # instance, and it leaves the programs of nixpkgs alone: the theme is a
    # file of its own, so that applying the overlay does not replace the
    # OpenCode of a configuration that does not want the theme.
    overlays.opencode = final: _prev: {
      blueforest-opencode-theme = import ./nix/theme.nix {
        inherit (final) lib;
        pkgs = final;
        inherit version;
      };
    };

    # OpenCode is a program of the user, and Home Manager writes its
    # configuration only when the program is enabled, so the NixOS module can
    # do no more than adding the overlay.
    nixosModules.opencode = {
      nixpkgs.overlays = [ config.flake.overlays.opencode ];
    };

    homeModules.opencode = import ./nix/modules/default.nix {
      overlay = config.flake.overlays.opencode;
    };
  };
}
