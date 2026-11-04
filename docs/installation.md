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
          blueforest.nixosModules.vscode
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

Every theme of the repository has a switch of its own,
`blueforest-theme.<application>.enable`, and it is off by default. The switch is
separate from `programs.<application>.enable`, so that a theme and a template
of the community catalogue of Noctalia are alternatives, and so that a
configuration that wants the theme of one application only does not get the
themes of all of them. The pages of the applications explain the switch of
each of them.

The same aggregate works for Home Manager as `blueforest.homeModules.default`:

```nix
{
  imports = [
    blueforest.homeModules.default
    blueforest.homeModules.vscode
  ];

  programs.vscodium = {
    enable = true;
    profiles.default.extensions = [
      pkgs.blueforest-vscode-theme
    ];
  };
}
```

The modules of VS Code and Zed are not part of the aggregates: they are
imported explicitly, as the examples above do. The module of the theme of
MkDocs is not part of them either, and it is a flake module:
`inputs.blueforest.flakeModules.mkdocs`.

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
`?dir=modules/eza`, `?dir=modules/zed`, `?dir=modules/yazi`,
`?dir=modules/kitty`, `?dir=modules/mkdocs`, `?dir=modules/btop`,
`?dir=modules/lazygit`, `?dir=modules/md-tui`, and `?dir=modules/noctalia`.

The theme of bat is a package and a Home Manager module, so it has a module
to import: `blueforest.homeModules.bat`. The packages of the other
applications are there too, and they can be taken on their own when you only
want the theme files.

See the [outputs reference](reference/outputs.md) for the complete list of
outputs, and the [identifiers reference](reference/identifiers.md) for the
names of the packages, themes, and modules.

## Per-application instructions

The [themes overview](themes/index.md) links to the installation page of every
application. Each page explains how to install the theme with Nix, how to
install it by hand, and how to select it once it is installed.
