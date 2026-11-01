# Repository layout

The repository is a Nix flake monorepo. Every application lives in a directory
of its own under `modules/`, and every one of those directories is a
self-contained flake.

```text
.
├── flake.nix                 # the root flake, which composes the applications
├── flake.lock
├── mkdocs.yml                # the documentation site
├── docs/                     # the documentation sources
├── modules/
│   ├── bat/                  # the simplest application: a package and checks
│   ├── eza/
│   ├── neovim/
│   ├── opencode/
│   ├── sbt/
│   ├── starship/
│   ├── vscode/
│   ├── yazi/
│   └── zed/
├── tests/                    # checks of the root flake
├── tools/                    # the release and update helpers
└── workflows/                # the definitions of the GitHub Actions workflows
```

## What an application directory holds

Every application is self-contained, so that a consumer can install just one
of them:

```text
modules/<app>/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging of the theme
└── themes/              # the theme itself
```

The theme files are hand-edited sources, not generated files. The checks
compare the packaged copies against them:

- `modules/vscode/themes/Blueforest-color-theme.json`
- `modules/bat/themes/BlueForest.tmTheme`
- `modules/neovim/themes/blueforest.lua` and
  `modules/neovim/themes/lualine-blueforest.lua`
- `modules/starship/themes/blueforest.toml`
- `modules/opencode/themes/blueforest.json`
- `modules/eza/themes/blueforest.yml`
- `modules/yazi/themes/blueforest.yazi/flavor.toml` and
  `modules/yazi/themes/blueforest.yazi/tmtheme.xml`

`modules/sbt` is the exception: it does not define a theme. It installs the
upstream `sbt-prompt` plugin and selects its `BlueforestTheme` from
`modules/sbt/config/`.

`modules/zed` is the other exception: its theme is not in the application
either. The theme is part of the
[zed-blueforest-theme](https://github.com/alonsodomin/zed-blueforest-theme)
extension, which lives in a repository of its own because that is how Zed
ships extensions. The repository is a submodule of the application, at
`modules/zed/extension/`, so every change of the extension is reviewed here.

Nix cannot fetch the contents of a submodule of a git tree, so the checks of
the repository run against the working tree, where the submodule is checked
out. The checkout of the CI brings the submodules with it.

The `tmtheme.xml` of the flavour of Yazi is the theme the repository ships
for bat, and the two of them are the same file: an application cannot depend
on another one, so the file is copied, and the check `yazi-tmtheme` of the
repository compares the two copies.

## The flake module of an application

`modules/<app>/flake-module.nix` describes what the application provides: its
packages, its checks, its overlay, and its modules. The module takes the inputs
of the application as a static argument, so that it does not depend on the
inputs of the flake that imports it.

The flake of the application binds those inputs and publishes the module, so
that the root flake can compose it:

```nix
# modules/neovim/flake.nix
outputs =
  inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (
    { config, lib, flake-parts-lib, ... }:
    let
      inherit (flake-parts-lib) importApply;

      # The inputs of the application are bound to the module.
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

The arguments of the module are the ones of the flake that imports it:
`inputs` is the input set of the consumer, so the packages of the application
are built with the nixpkgs of the consumer. The checks use `appInputs`, the
inputs of the application.

## The root flake

The root flake registers every application as a path input, imports its flake
module, and composes the aggregate outputs:

```nix
inputs = {
  neovim = {
    url = "path:./modules/neovim";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.home-manager.follows = "home-manager";
    inputs.nixvim.follows = "nixvim";
  };
};

imports = [
  inputs.devshell.flakeModule
  inputs.home-manager.flakeModules.home-manager
  inputs.vscode.flakeModule
  inputs.neovim.flakeModule
];
```

The aggregate modules are explicit. The root flake composes the overlays of
the applications that have one, and the Home Manager and NixOS modules of the
applications that provide them. The theme of bat is a package alone, so it has
no module in the aggregates.

The root flake also owns the pins of the repository. An application keeps a
lock file of its own, for consumers that take it on its own, and the `update`
helper pins the inputs it shares with the root to the revisions the root
resolved.

## Generated files

The files in `.github/workflows/` are generated from the definitions in
`workflows/` by `actions-nix`. They are not edited by hand: edit the
definitions and run `nix run .#render-workflows`, or let the pre-commit hook of
the development shell render them.

The documentation site is generated from `mkdocs.yml` and `docs/`, but its
sources are hand-written. `mkdocs.yml` lives at the repository root, and the
Markdown files live under `docs/`.
