# Outputs

The root flake exposes the outputs of every application, together with the
combined ones.

| Output | Description |
| --- | --- |
| `checks.<system>.<app>-<check>` | The checks of every application |
| `devShells.default` | The development shell of the repository |
| `extensions.<system>.open-vsx.alonsodomin.blueforest-theme` | The same shape `nix-vscode-extensions` uses |
| `flakeModules.bat` | The module of the bat theme, for flake-parts |
| `flakeModules.btop` | The module of the btop theme, for flake-parts |
| `flakeModules.claude-code` | The module of the Claude Code theme, for flake-parts |
| `flakeModules.default` | The modules of every application, except the one of MkDocs |
| `flakeModules.lazygit` | The module of the lazygit theme, for flake-parts |
| `flakeModules.lazydocker` | The module of the lazydocker theme, for flake-parts |
| `flakeModules.md-tui` | The module of the md-tui theme, for flake-parts |
| `flakeModules.mkdocs` | The module of the MkDocs theme, for flake-parts |
| `flakeModules.noctalia` | The module of the Noctalia theme, for flake-parts |
| `homeModules.bat` | The module of the bat theme |
| `homeModules.btop` | The module of the btop theme |
| `homeModules.eza` | The module of the eza theme |
| `homeModules.kitty` | The module of the kitty theme |
| `homeModules.lazygit` | The module of the lazygit theme |
| `homeModules.lazydocker` | The module of the lazydocker theme |
| `homeModules.md-tui` | The module of the md-tui theme |
| `homeModules.noctalia` | The module of the Noctalia theme |
| `homeModules.claude-code` | The module of the Claude Code theme |
| `homeModules.sbt` | The module of the sbt prompt |
| `homeModules.yazi` | The module of the Yazi flavour |
| `homeModules.zed` | The module of the Zed theme |
| `nixosModules.default`, `homeModules.default` | The modules of the applications that provide one. The modules of VS Code and Zed are not among them: they are imported explicitly |
| `nixosModules.neovim`, `homeModules.neovim` | The module of the Neovim theme |
| `nixosModules.opencode`, `homeModules.opencode` | The module of the OpenCode theme |
| `nixosModules.starship`, `homeModules.starship` | The module of the Starship palette and preset |
| `nixosModules.vscode`, `homeModules.vscode` | The module of the VS Code theme |
| `nixvimModules.neovim` | The module of the Neovim theme, for nixvim |
| `overlays.bat` | Adds `pkgs.blueforest-bat-theme` to a nixpkgs instance. The aggregate does not compose it |
| `overlays.btop` | Adds `pkgs.blueforest-btop-theme` to a nixpkgs instance |
| `overlays.claude-code` | Adds `pkgs.blueforest-claude-code-theme` to a nixpkgs instance |
| `overlays.default` | Adds the packages of the VS Code, Starship, OpenCode, sbt, Neovim, eza, Zed, Yazi, kitty, MkDocs, Claude Code, btop, lazygit, lazydocker, md-tui, Noctalia, and bat applications to a nixpkgs instance |
| `overlays.eza` | Adds `pkgs.blueforest-eza-theme` to a nixpkgs instance |
| `overlays.kitty` | Adds `pkgs.blueforest-kitty-theme` to a nixpkgs instance |
| `overlays.lazygit` | Adds `pkgs.blueforest-lazygit-theme` to a nixpkgs instance |
| `overlays.lazydocker` | Adds `pkgs.blueforest-lazydocker-theme` to a nixpkgs instance |
| `overlays.md-tui` | Adds `pkgs.blueforest-md-tui-theme` to a nixpkgs instance |
| `overlays.mkdocs` | Adds `pkgs.blueforest-mkdocs-theme` to a nixpkgs instance |
| `overlays.noctalia` | Adds `pkgs.blueforest-noctalia-theme` to a nixpkgs instance |
| `overlays.neovim` | Adds `pkgs.blueforest-neovim-theme` to a nixpkgs instance |
| `overlays.opencode` | Adds `pkgs.blueforest-opencode-theme` to a nixpkgs instance |
| `overlays.sbt` | Adds `pkgs.blueforest-sbt-prompt` to a nixpkgs instance |
| `overlays.starship` | Adds `pkgs.blueforest-starship-preset`, `pkgs.blueforest-starship-palette` and `pkgs.blueforest-starship` to a nixpkgs instance |
| `overlays.vscode` | Adds `pkgs.blueforest-vscode-theme` to a nixpkgs instance |
| `overlays.yazi` | Adds `pkgs.blueforest-yazi-theme` and `pkgs.blueforest-bat-theme` to a nixpkgs instance |
| `overlays.zed` | Adds `pkgs.blueforest-zed-theme` to a nixpkgs instance |
| `packages.<system>.blueforest-bat-theme` | The theme for bat |
| `packages.<system>.blueforest-btop-theme` | The theme for btop |
| `packages.<system>.blueforest-claude-code-theme` | The theme for Claude Code |
| `packages.<system>.blueforest-eza-theme` | The theme for eza |
| `packages.<system>.blueforest-kitty-theme` | The theme for kitty |
| `packages.<system>.blueforest-lazygit-theme` | The theme for lazygit |
| `packages.<system>.blueforest-lazydocker-theme` | The theme for lazydocker |
| `packages.<system>.blueforest-md-tui-theme` | The theme for md-tui |
| `packages.<system>.blueforest-mkdocs-theme` | The theme for MkDocs |
| `packages.<system>.blueforest-noctalia-theme` | The theme for Noctalia |
| `packages.<system>.blueforest-neovim-theme` | The theme for Neovim |
| `packages.<system>.blueforest-opencode-theme` | The theme for OpenCode |
| `packages.<system>.blueforest-sbt-prompt` | The prompt for sbt |
| `packages.<system>.blueforest-starship` | Starship with the preset bundled |
| `packages.<system>.blueforest-starship-palette` | The palettes for Starship |
| `packages.<system>.blueforest-starship-preset` | The preset for Starship |
| `packages.<system>.blueforest-vscode-theme` | The theme as a VS Code extension package |
| `packages.<system>.blueforest-yazi-theme` | The theme for Yazi, as a flavour |
| `packages.<system>.blueforest-zed-theme` | The theme for Zed, as an extension |
| `packages.<system>.blueforest-changelog` | The program that shows the changelog of the unreleased changes |
| `packages.<system>.blueforest-release` | The program that releases the repository |
| `packages.<system>.cog` | CoCoGitto, the conventional commit toolbox of the repository |
| `packages.<system>.documentation` | The documentation site as a static site |
| `packages.<system>.neovim-nixvim-check` | The check that builds an editor with nixvim |
| `packages.<system>.render-workflows` | The program that renders the workflows of the repository |
| `packages.<system>.vscode-integration-check` | The check that builds VSCodium |

The root flake publishes the module of every application under its own name,
so that a consumer that wants one of them alone does not have to take the
others:

| Output | Description |
| --- | --- |
| `flakeModules.<app>` | The module of the application, for flake-parts |
| `flakeModules.default` | The modules of every application, except the one of MkDocs |

The module of an application takes the inputs of that application as a static
argument, so a consumer that imports it needs no `devshell`, `home-manager` or
`nixvim` input of its own. The `inputs` of the module are the inputs of the
consumer, so the packages of the application are built with the nixpkgs of the
consumer.

Every module carries a key of its own, so that the module system evaluates it
once when it is imported by more than one place.

The module of the MkDocs theme is the exception: it is a helper that installs
the stylesheet in the sources of a documentation site. It takes the
`mkdocs-flake` input of the consumer when it has one, and the one of the
application otherwise, so a consumer that imports it needs no `mkdocs-flake`
input of its own. It is not part of `flakeModules.default`, because the module
of `mkdocs-flake` declares arguments, and a module that declares arguments can
only be imported once per flake. A consumer that wants the theme of MkDocs
imports `flakeModules.mkdocs`, which is the only way to get it.
