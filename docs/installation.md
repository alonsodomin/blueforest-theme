# Installation with Nix

The repository is a flake that provides the theme of every application,
together with modules that make them available to a NixOS or Home Manager
configuration.

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-theme";

  outputs =
    { nixpkgs, blueforest, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          blueforest.nixosModules.default
          {
            programs.vscode = {
              enable = true;
              extensions = [
                pkgs.blueforest-vscode-theme
              ];
            };
          }
        ];
      };
    };
}
```

The aggregate modules add the overlays of the applications. They do not
enable the programs themselves: which editor or terminal installs the theme,
and whether it is installed at all, stays your decision.

The same aggregate works for Home Manager as `blueforest.homeModules.default`:

```nix
{
  imports = [
    blueforest.homeModules.default
  ];

  programs.vscodium = {
    enable = true;
    profiles.default.extensions = [
      pkgs.blueforest-vscode-theme
    ];
  };
}
```

If you prefer to wire the overlay yourself:

```nix
{
  nixpkgs.overlays = [ blueforest.overlays.default ];
}
```

## Installing a single application

Every application is a flake of its own, so a consumer that only wants one of
them does not have to take the others:

```nix
{
  inputs.blueforest-vscode.url = "github:alonsodomin/blueforest-theme?dir=modules/vscode";

  outputs =
    { nixpkgs, blueforest-vscode, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          blueforest-vscode.nixosModules.default
        ];
      };
    };
}
```

The same works for `?dir=modules/bat`, `?dir=modules/starship`,
`?dir=modules/opencode`, `?dir=modules/sbt`, `?dir=modules/neovim`,
`?dir=modules/eza`, `?dir=modules/zed`, `?dir=modules/yazi`, and
`?dir=modules/kitty`.

The theme of bat is a package and nothing else, so it has no modules to
import: take it from the outputs of the flake. The same is true of the
packages of the other applications when you only want the theme files.

See the [outputs reference](reference/outputs.md) for the complete list of
outputs, and the [identifiers reference](reference/identifiers.md) for the
names of the packages, themes, and modules.

## Per-application instructions

The [themes overview](themes/index.md) links to the installation page of every
application. Each page explains how to install the theme with Nix, how to
install it by hand, and how to select it once it is installed.
