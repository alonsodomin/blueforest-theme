# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest prompt for sbt, as a flake-parts module.
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
      # The nixpkgs instance of the application. The package is built with the
      # overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.sbt ];
      };

      # The unoverlaid nixpkgs, used to evaluate the module without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      prompt = pkgs.blueforest-sbt-prompt;

      # The files of the repository that the package and the module install.
      sources = {
        plugin = ./config/sbt-prompt.sbt;
        settings = ./config/blueforest-prompt.sbt;
      };
    in
    {
      packages.blueforest-sbt-prompt = prompt;

      checks = {
        # The package carries the files of the repository, and they declare
        # the plugin and select the theme of the plugin.
        sbt-package = import ./nix/checks/package.nix {
          inherit pkgs prompt sources;
        };

        # The Home Manager module installs those files where both generations
        # of sbt read their global configuration, and only when sbt is
        # enabled.
        sbt-module = import ./nix/checks/module.nix {
          inherit sources;
          pkgs = basePkgs;
          homeManager = appInputs.home-manager;
          module = config.flake.homeModules.sbt;
        };
      };

    };

  flake = {
    # The overlay of the application. It adds the prompt to a nixpkgs
    # instance, and it leaves the programs of nixpkgs alone: the prompt is a
    # pair of configuration files, not a replacement for sbt, so that applying
    # the overlay does not change the sbt of a configuration that does not
    # want the prompt.
    overlays.sbt = final: _prev: {
      blueforest-sbt-prompt = import ./nix/package.nix {
        inherit (final) lib;
        pkgs = final;
        inherit version;
      };
    };

    # sbt reads the configuration of the user, and there is no system-wide
    # directory it reads, so the application publishes a Home Manager module
    # and no NixOS module.
    homeModules.sbt = import ./nix/module.nix;
  };
}
