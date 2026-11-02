# Adding an application

An application is a directory with the theme, the packaging of it, and a flake
of its own. The simplest application to mirror is `modules/bat`; a package with
an overlay and modules can mirror `modules/starship`.

## 1. Create the application

Create `modules/<app>/` with:

```text
modules/<app>/
├── flake.nix            # the application as a flake of its own
├── flake-module.nix     # the application as a flake-parts module
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging
└── themes/              # the theme itself
```

The flake of the application imports the module of the application, so that the
application is usable on its own and so that the root flake can compose it:

```nix
outputs =
  inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (
    { config, lib, flake-parts-lib, ... }:
    let
      inherit (flake-parts-lib) importApply;

      flakeModules.default = importApply ./flake-module.nix { appInputs = inputs; };
    in
    {
      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.home-manager.flakeModules.home-manager
        flakeModules.default
      ];

      flake = {
        inherit flakeModules;
      };
    }
  );
```

The module takes the inputs of the application as a static argument, and the
arguments of the flake that imports it as its own: `inputs` is the input set of
the consumer, so the packages of the application are built with the nixpkgs of
the consumer, and the checks of the application use the Home Manager and the
nixvim of the application.

## 2. Register it in the root flake

Add the application as a path input, with the `follows` of the inputs it shares
with the root:

```nix
inputs = {
  <app> = {
    url = "path:./modules/<app>";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.home-manager.follows = "home-manager";
  };
};
```

Import its flake module:

```nix
imports = [
  inputs.<app>.flakeModule
];
```

Then expose it in the aggregate modules if it provides an overlay, a NixOS
module, or a Home Manager module.

## 3. Register it in the workflows

Add the application to the list in `workflows/lib.nix`. That list feeds the CI
matrix and the release checks.

Add an entry to the table in `workflows/release.nix` with the way the
application is packaged and the asset it uploads:

```nix
{
  app = "<app>";
  title = "<Title>";
  asset = "dist/blueforest-<app>-theme-$VERSION.<extension>";
  package = ''
    # package the theme into dist/
  '';
}
```

The release workflow renders all the assets into the GitHub release; an
application that is not in the table is not released.

## 4. Add the documentation

Add a page under `docs/themes/<app>.md` with:

- a description of the theme
- installation with Nix
- manual installation
- how to select the theme

The manual installation goes after the installation with Nix, and it is the
section that explains how to install the published files by hand. An
application that publishes its theme to a registry of its own, such as VS Code
and Zed, leads with that registry instead, and its installation with Nix
carries a note that the route is meant for developing and testing the theme.

Add it to the navigation in `mkdocs.yml`, to the table in `docs/themes/index.md`,
and to the table in the root `README.md`.

Keep the installation snippets in the documentation in sync with the
configuration checks of the application. The checks evaluate the configuration
that the documentation describes.

## 5. Update the repository metadata

- Add the application to the list in `CHANGELOG.md`.
- Add the application to the table in `README.md`, and its paths to the table
  in `NOTICE.md`.
- Add an entry to `modules/<app>/CHANGELOG.md`.
- If the application has a version that an external tool must track, add it to
  `renovate.json5`.

The application is released with the rest of the repository: there is no
release script per application, and one tag releases every application.
