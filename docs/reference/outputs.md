# Outputs

The root flake exposes the outputs of every application, together with the
combined ones.

| Output | Description |
| --- | --- |
| `packages.<system>.default` | The theme as a VS Code extension package |
| `packages.<system>.blueforest-vscode-theme` | The theme as a VS Code extension package |
| `packages.<system>.vscode-integration-check` | The check that builds VSCodium |
| `packages.<system>.blueforest-bat-theme` | The theme for bat |
| `packages.<system>.blueforest-starship-preset` | The preset for Starship |
| `packages.<system>.blueforest-starship` | Starship with the preset bundled |
| `packages.<system>.blueforest-opencode-theme` | The theme for OpenCode |
| `packages.<system>.blueforest-sbt-prompt` | The prompt for sbt |
| `packages.<system>.blueforest-neovim-theme` | The theme for Neovim |
| `packages.<system>.blueforest-eza-theme` | The theme for eza |
| `packages.<system>.blueforest-zed-theme` | The theme for Zed, as an extension |
| `packages.<system>.neovim-nixvim-check` | The check that builds an editor with nixvim |
| `packages.<system>.documentation` | The documentation site as a static site |
| `packages.<system>.render-workflows` | The program that renders the workflows of the repository |
| `overlays.default` | Adds the packages of the VS Code, Starship, OpenCode, sbt, Neovim, eza, and Zed applications to a nixpkgs instance |
| `overlays.vscode` | Adds `pkgs.blueforest-vscode-theme` to a nixpkgs instance |
| `overlays.bat` | Adds `pkgs.blueforest-bat-theme` to a nixpkgs instance. The aggregate does not compose it |
| `overlays.starship` | Adds `pkgs.blueforest-starship-preset` and `pkgs.blueforest-starship` to a nixpkgs instance |
| `overlays.opencode` | Adds `pkgs.blueforest-opencode-theme` to a nixpkgs instance |
| `overlays.sbt` | Adds `pkgs.blueforest-sbt-prompt` to a nixpkgs instance |
| `overlays.neovim` | Adds `pkgs.blueforest-neovim-theme` to a nixpkgs instance |
| `overlays.eza` | Adds `pkgs.blueforest-eza-theme` to a nixpkgs instance |
| `overlays.zed` | Adds `pkgs.blueforest-zed-theme` to a nixpkgs instance |
| `nixosModules.default`, `homeModules.default` | The modules of the applications that provide one |
| `nixosModules.vscode`, `homeModules.vscode` | The module of the VS Code theme |
| `nixosModules.starship`, `homeModules.starship` | The module of the Starship preset |
| `nixosModules.opencode`, `homeModules.opencode` | The module of the OpenCode theme |
| `homeModules.sbt` | The module of the sbt prompt |
| `homeModules.eza` | The module of the eza theme |
| `homeModules.zed` | The module of the Zed theme |
| `nixosModules.neovim`, `homeModules.neovim` | The module of the Neovim theme |
| `nixvimModules.neovim` | The module of the Neovim theme, for nixvim |
| `checks.<system>.<app>-<check>` | The checks of every application |
| `devShells.default` | The development shell of the repository |
| `extensions.<system>.open-vsx.alonsodomin.blueforest-theme` | The same shape `nix-vscode-extensions` uses |

The application flake exposes the same outputs, without the ones of the other
applications: `overlays.default`, `nixosModules.default` and
`homeModules.default` are the ones of the application itself, where it
provides them. It also publishes the module of the application, so that the
root flake can compose it:

| Output | Description |
| --- | --- |
| `flakeModule` | The module of the application, for the root flake |
| `flakeModules.default` | The same module, under the name of the convention |

The module of an application takes the inputs of that application as a static
argument, so a consumer that imports it needs no `devshell`, `home-manager` or
`nixvim` input of its own. The `inputs` of the module are the inputs of the
consumer, so the packages of the application are built with the nixpkgs of the
consumer.
