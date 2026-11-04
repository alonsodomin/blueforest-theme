# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for MkDocs, as a flake-parts module.
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

  # The overlay of the application. It adds the theme to a nixpkgs instance,
  # and it leaves the programs of nixpkgs alone: the theme is a file of its
  # own, so that applying the overlay does not replace the MkDocs of a
  # configuration that does not want the theme.
  overlay = final: _prev: {
    blueforest-mkdocs-theme = import ./nix/theme.nix {
      inherit (final) lib;
      pkgs = final;
      inherit version;
    };
  };
in
{
  # The module of mkdocs-flake, which declares the options of the
  # documentation. It is imported here, so that a consumer that imports only
  # this module gets a working MkDocs setup, and so that the hook of the
  # module below always has an option to extend.
  #
  # The mkdocs-flake of the consumer is the one to use when it has one: the
  # declaration of the options is then the one of the consumer, and the module
  # system imports it only once.
  imports = [
    (inputs.mkdocs-flake or appInputs.mkdocs-flake).flakeModules.default
  ];

  perSystem =
    { config, system, ... }:
    let
      # The nixpkgs instance of the application. The theme is built with the
      # overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };

      theme = pkgs.blueforest-mkdocs-theme;

      # The theme of the repository.
      source = ./themes/blueforest.css;
    in
    {
      options.blueforest-theme.mkdocs = {
        # The option is enabled by default: the stylesheet of the theme is
        # part of the documentation of the repository, and a consumer that
        # does not want it turns it off.
        enable = lib.mkEnableOption "the stylesheet of the theme in the sources of the documentation" // {
          default = true;
        };

        docsDir = lib.mkOption {
          type = lib.types.str;
          default = "docs";
          description = "The directory of the sources of the documentation, relative to the root of the project.";
        };

        path = lib.mkOption {
          type = lib.types.str;
          default = "assets/stylesheets/blueforest.css";
          description = "The path of the stylesheet inside the sources of the documentation.";
        };

        preBuildHook = lib.mkOption {
          type = lib.types.lines;
          readOnly = true;
          description = "The hook that installs the stylesheet in the sources of the documentation.";
          default = ''
            # The sources of the site are copied into the build directory
            # with the permissions they have in the store, and the store is
            # read-only. The stylesheet is written into one of those
            # directories, so the sources are made writable first.
            chmod -R u+w ${config.blueforest-theme.mkdocs.docsDir} 2>/dev/null || true
            rm -f ${config.blueforest-theme.mkdocs.docsDir}/${config.blueforest-theme.mkdocs.path}
            install -Dm644 ${config.packages.blueforest-mkdocs-theme}/blueforest.css \
              ${config.blueforest-theme.mkdocs.docsDir}/${config.blueforest-theme.mkdocs.path}
          '';
        };
      };

      config = {
        packages.blueforest-mkdocs-theme = theme;

        checks = {
          # The stylesheet of the package is the stylesheet of the
          # repository, and it only recolours the dark scheme.
          mkdocs-theme = import ./nix/checks/theme.nix {
            inherit pkgs theme source;
          };

          # The hook of the module puts the stylesheet in the sources of a
          # site built the way mkdocs-flake builds one.
          mkdocs-render = import ./nix/checks/render.nix {
            inherit pkgs theme;
            mkdocs = config.documentation.mkdocs-package;
            preBuildHook = config.blueforest-theme.mkdocs.preBuildHook;
          };
        };

        # The hook of the module runs before `mkdocs build`, after mkdocs-flake
        # has copied the sources of the site into the build directory. It is
        # appended to the hook of the consumer, so that both of them run.
        documentation.mkdocs-preBuildHook = lib.mkAfter (
          if config.blueforest-theme.mkdocs.enable then config.blueforest-theme.mkdocs.preBuildHook else ""
        );
      };
    };

  flake.overlays.mkdocs = overlay;
}
