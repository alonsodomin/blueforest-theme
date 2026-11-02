# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest theme for MkDocs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mkdocs-flake = {
      url = "github:applicative-systems/mkdocs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;

        flakeModules.default = importApply ./flake-module.nix { appInputs = inputs; };
      in
      {
        imports = [
          inputs.flake-parts.flakeModules.flakeModules
          flakeModules.default
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          inherit flakeModules;

          overlays.default = final: prev: config.flake.overlays.mkdocs final prev;
        };
      }
    );
}
