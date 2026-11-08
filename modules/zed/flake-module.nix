# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Zed, as a flake-parts module.
#
# The root flake imports this module out of the tree of the repository, and
# publishes it for the consumers that want the theme of Zed alone.
#
# The inputs of the application. The root flake binds them to the module and
# passes them as a static argument, so that the module does not depend on the
# inputs of the flake that imports it.
#
# The extension of Zed, which is the theme of the application. It is a
# repository of its own, and it is pinned by the lock file of the repository.
#
# The arguments of the module are the ones of the flake that imports it: the
# `inputs` below are the inputs of that flake, so that the packages of the
# application are built with the nixpkgs of the consumer.
{
  appInputs,
  extension,
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

  # The sources of the extension: the repository Zed installs the extension
  # from, at the revision the lock file of the repository pins.
  #
  # The extension is an input of the root flake, so it is fetched by the
  # store and its contents are verified against the hash of the lock file. A
  # consumer that takes the repository gets the extension with it, and the
  # theme of Zed builds without a submodule.
  source = extension;
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
        overlays = [ config.flake.overlays.zed ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      theme = pkgs.blueforest-zed-theme;
    in
    {
      packages.blueforest-zed-theme = theme;

      checks = {
        # The package carries the extension of the repository.
        zed-extension = import ./nix/checks/extension.nix {
          inherit pkgs theme source;
        };

        # The extension of the package is the extension Zed reads.
        zed-theme = import ./nix/checks/theme.nix {
          inherit pkgs theme;
        };

        # The Home Manager module installs the extension where Zed reads it.
        zed-module = import ./nix/checks/module.nix {
          inherit source;
          pkgs = basePkgs;
          homeManager = appInputs.home-manager;
          module = config.flake.homeModules.zed;
        };
      };

    };

  flake = {
    # The overlay of the application. It adds the theme to a nixpkgs
    # instance, and it leaves the programs of nixpkgs alone: the theme is a
    # directory of its own, so that applying the overlay does not replace the
    # Zed of a configuration that does not want the theme.
    overlays.zed = final: _prev: {
      blueforest-zed-theme = import ./nix/extension.nix {
        inherit (final) lib;
        pkgs = final;
        inherit version source;
      };
    };

    # Zed reads the theme from the data directory of the user, and there is
    # no system-wide directory it reads, so the application publishes a Home
    # Manager module and no NixOS module.
    homeModules.zed = import ./nix/module.nix {
      overlay = config.flake.overlays.zed;
    };
  };
}
