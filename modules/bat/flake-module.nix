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
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      theme = import ./nix/theme.nix {
        inherit lib pkgs version;
      };

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

        # The theme is installed in the configuration directory of the user.
        bat-theme-home = import ./nix/checks/home.nix {
          inherit pkgs theme source;
        };

        # The theme is installed in the system-wide configuration directory.
        bat-theme-nixos = import ./nix/checks/nixos.nix {
          inherit pkgs theme source;
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
  };
}
