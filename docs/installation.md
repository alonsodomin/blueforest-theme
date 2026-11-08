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

Every application is a module of the root flake, so a consumer that only
wants one of them does not have to take the others. The root flake publishes
the module of every application under its own name:

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-theme";

  outputs =
    { nixpkgs, blueforest, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          blueforest.nixosModules.vscode
        ];
      };
    };
}
```

The same works for `blueforest.nixosModules.bat`,
`blueforest.nixosModules.starship`, `blueforest.nixosModules.opencode`,
`blueforest.nixosModules.sbt`, `blueforest.nixosModules.neovim`,
`blueforest.nixosModules.eza`, `blueforest.nixosModules.zed`,
`blueforest.nixosModules.yazi`, `blueforest.nixosModules.kitty`,
`blueforest.nixosModules.btop`, `blueforest.nixosModules.lazygit`,
`blueforest.nixosModules.md-tui`, and `blueforest.nixosModules.noctalia`.
The Home Manager modules are under `blueforest.homeModules`, and the overlays
under `blueforest.overlays`.

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
