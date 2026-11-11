# Repository layout

The repository is a Nix flake monorepo. Every application lives in a directory
of its own under `modules/`, and every one of those directories is a module of
the root flake.

```text
.
├── flake.nix                 # the root flake, which composes the applications
├── flake.lock
├── cog.toml                  # the configuration of CoCoGitto
├── mkdocs.yml                # the documentation site
├── docs/                     # the documentation sources
├── modules/
│   ├── bat/                  # the simplest application: a package and checks
│   ├── btop/
│   ├── claude-code/
│   ├── eza/
│   ├── kitty/
│   ├── lazygit/
│   ├── lazydocker/
│   ├── md-tui/
│   ├── mkdocs/
│   ├── neovim/
│   ├── noctalia/
│   ├── opencode/
│   ├── sbt/
│   ├── starship/
│   ├── vscode/
│   ├── yazi/
│   └── zed/
├── tests/                    # checks of the root flake
├── tools/                    # the release, changelog and documentation helpers
└── workflows/                # the definitions of the GitHub Actions workflows
```

## What an application directory holds

Every application is self-contained, so that a consumer can install just one
of them:

```text
modules/<app>/
├── flake-module.nix     # the application as a flake-parts module
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging of the theme
└── themes/              # the theme itself
```

The theme files are hand-edited sources, not generated files. The checks
compare the packaged copies against them:

- `modules/vscode/themes/Blueforest-color-theme.json`
- `modules/bat/themes/BlueForest.tmTheme`
- `modules/btop/themes/blueforest.theme`
- `modules/neovim/themes/blueforest.lua` and
  `modules/neovim/themes/lualine-blueforest.lua`
- `modules/starship/themes/blueforest.toml`, the preset, and
  `modules/starship/themes/palettes/blueforest.toml` and
  `modules/starship/themes/palettes/blueforest-light.toml`, the palettes
- `modules/opencode/themes/blueforest.json`
- `modules/eza/themes/blueforest.yml`
- `modules/yazi/themes/blueforest.yazi/flavor.toml`
- `modules/kitty/themes/blueforest.conf`
- `modules/mkdocs/themes/blueforest.css`
- `modules/claude-code/themes/blueforest.json`
- `modules/lazygit/themes/blueforest.json`
- `modules/lazydocker/themes/blueforest.json` and
  `modules/lazydocker/themes/blueforest-light.json`
- `modules/md-tui/themes/blueforest.json`
- `modules/noctalia/themes/blueforest.json`

The theme of lazygit is a configuration file of lazygit that carries the theme
under the `gui.theme` key, because lazygit has no theme file of its own. It is
JSON, and JSON is a subset of YAML: lazygit reads the file as its own format,
and Nix reads it at evaluation time, so that the colours of the Home Manager
module and the colours of the file are the same ones.

The theme of lazydocker is a configuration file of lazydocker that carries the
theme under the `gui.theme` key, because lazydocker has no theme file of its own
either. It is JSON for the same reason, and it carries the four colours
lazydocker knows: the border of the focused panel, the border of the unfocused
panels, the background of the selected line, and the text of the line at the
bottom.

The theme of md-tui is a palette of md-tui, the format the chooser of its
themes saves. The name of the palette is the name of the file, and md-tui
selects it with the `selected-theme` file of its configuration directory.

`modules/sbt` is the exception: it does not define a theme. It installs the
upstream `sbt-prompt` plugin and selects its `BlueforestTheme` from
`modules/sbt/config/`.

`modules/zed` is the other exception: its theme is not in the application
either. The theme is part of the
[zed-blueforest-theme](https://github.com/alonsodomin/zed-blueforest-theme)
extension, which lives in a repository of its own because that is how Zed
ships extensions. The root flake takes it as an input without a flake of its
own, so the pin of it lives in the lock file of the repository, and the
release fetches it at the revision the lock file pins.

The flavour of Yazi paints the code of its preview with a TextMate theme,
and it is the theme the repository ships for bat. The module of Yazi
therefore imports the module of bat, and the flavour links to the theme of
bat instead of carrying a copy of it. The check `yazi-tmtheme` of the
repository checks that the link points to the theme of bat.

The asset of the release of Yazi is unpacked by hand, so it cannot carry a
link to the store: it carries the theme of bat itself. The check `yazi-asset`
of the repository packages the theme the way the release workflow does, with
the packaging of the workflow itself, and looks at what the asset carries.

## The flake module of an application

`modules/<app>/flake-module.nix` describes what the application provides: its
packages, its checks, its overlay, and its modules. The module takes the inputs
of the application as a static argument, so that it does not depend on the
inputs of the flake that imports it.

The root flake binds those inputs and imports the module, so that the
repository composes the applications:

```nix
# flake.nix
let
  inherit (flake-parts-lib) importApply;

  # The inputs of the application are bound to the module.
  neovimModule = (importApply ./modules/neovim/flake-module.nix { appInputs = inputs; }) // { key = "blueforest:neovim"; };
in
{
  imports = [
    inputs.devshell.flakeModule
    inputs.home-manager.flakeModules.home-manager
    neovimModule
  ];

  flake.flakeModules.neovim = neovimModule;
}
```

Every module carries a key of its own. The module system evaluates a module
once, and the key is what tells it that two imports of the same module are
the same one: the module of an application is imported by the root flake and,
in the case of Yazi, by the module of another application, and the option
`flake.overlays.bat` is declared to be unique.

The arguments of the module are the ones of the flake that imports it:
`inputs` is the input set of the consumer, so the packages of the application
are built with the nixpkgs of the consumer. The checks use `appInputs`, the
inputs of the application.

## The tools

The helpers of the repository live in `tools/`, one directory per tool:

```text
tools/
├── changelog/                # the changelog of the unreleased changes
│   ├── default.nix           # the Nix wrapper
│   └── main.sh               # the script
├── docs.sh                   # the documentation of the repository
├── git-guard/                # the guard of the tags
│   └── main.sh               # the script
├── release/                  # the release of the repository
│   ├── default.nix           # the Nix wrapper
│   └── main.sh               # the script
└── version.sh                # the version of the sources
```

A tool that is a package of the root flake has a `default.nix`, which wraps
its script with the programs it needs, and a `main.sh`, which is the script
itself. A tool that is not a package has only the script.

The `release` and the `changelog` tools are the commands of the development
shell, and the root flake publishes them as `packages.blueforest-release` and
`packages.blueforest-changelog`, so that they can be run without the shell
too.

## The root flake

The root flake imports the module of every application out of the tree of the
repository, and composes the aggregate outputs:

```nix
inputs = {
  nixvim.url = "github:nix-community/nixvim";

  # The extension of Zed, which is the theme of the application. It is not
  # a flake, so it is an input without one.
  zed-extension = {
    url = "github:alonsodomin/zed-blueforest-theme";
    flake = false;
  };
};

imports = [
  inputs.devshell.flakeModule
  inputs.home-manager.flakeModules.home-manager
  vscodeModule
  neovimModule
];
```

The applications are not inputs of the root flake. A relative import stays
inside the tree of the repository, so the sources of the applications are
covered by the hash of the lock file, and a consumer that takes the
repository gets them verified. A `path:` input would not: it is a store path
of its own, with no hash, and the consumer of the repository would have to
trust it.

The aggregate modules are explicit. The root flake composes the overlays of
the applications that have one, and the Home Manager and NixOS modules of the
applications that provide them. The theme of bat is a package alone, so it has
no module in the aggregates. Its overlay is part of the one of Yazi, which
carries the theme of bat for the colours of the code preview.

The root flake also owns the pins of the repository. There is one lock file,
the one of the root flake, and `nix flake update` updates it.

## Generated files

The files in `.github/workflows/` are generated from the definitions in
`workflows/` by `actions-nix`. They are not edited by hand: edit the
definitions and run `nix run .#render-workflows`, or let the pre-commit hook of
the development shell render them.

The packaging of the assets of the release lives in `workflows/assets.nix`, and
not in the workflow that uses it, so that the checks of the repository can
package the applications as well, and look at what they produce.

The documentation site is generated from `mkdocs.yml` and `docs/`, but its
sources are hand-written. `mkdocs.yml` lives at the repository root, and the
Markdown files live under `docs/`.
