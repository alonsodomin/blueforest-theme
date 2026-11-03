# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for bat, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
#
# The inputs of the application. Its own flake binds them to the module and
# passes them as a static argument, so that the module does not depend on the
# inputs of the flake that imports it.
#
# The theme of bat needs none of them: it is built with the nixpkgs of the
# The theme of bat needs none of the inputs of the application: it is built
# with the nixpkgs of the consumer, and its checks need nothing else. The
# Home Manager of the application is the one to use when the consumer has no
# Home Manager of its own.
#
# The arguments of the module are the ones of the flake that imports it, so
# that the packages of the application are built with the nixpkgs of the
# consumer.
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
      pkgs,
      system,
      ...
    }:
    let
      theme = import ./nix/theme.nix {
        inherit lib pkgs version;
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      # The theme of the repository.
      source = ./themes/BlueForest.tmTheme;
    in
    {
      packages.blueforest-bat-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository.
        bat-theme = import ./nix/checks/theme.nix {
          inherit pkgs theme source;
        };

        # The theme paints the shell blocks of a Markdown file the way the
        # other applications of the repository paint them.
        bat-render = import ./nix/checks/render.nix {
          inherit pkgs source;
        };

        # The theme is installed in the configuration directory of the user.
        bat-theme-home = import ./nix/checks/home.nix {
          inherit pkgs theme source;
        };

        # The theme is installed in the system-wide configuration directory.
        bat-theme-nixos = import ./nix/checks/nixos.nix {
          inherit pkgs theme;
        };

        # The Home Manager module installs the theme where bat reads it,
        # and selects it.
        bat-module = import ./nix/checks/module.nix {
          inherit source;
          pkgs = basePkgs;
          homeManager = appInputs.home-manager;
          module = config.flake.homeModules.bat;
        };
      };
    };

  flake = {
    # The overlay of the application. It adds the theme to a nixpkgs
    # instance, and it leaves the programs of nixpkgs alone.
    overlays.bat = final: _prev: {
      blueforest-bat-theme = import ./nix/theme.nix {
        inherit (final) lib;
        pkgs = final;
        inherit version;
      };
    };

    # bat reads the themes of the user from the `themes` directory of its
    # configuration directory, and there is no system-wide configuration file
    # it reads, so the application publishes a Home Manager module and no
    # NixOS module.
    homeModules.bat = import ./nix/module.nix;
  };
}
