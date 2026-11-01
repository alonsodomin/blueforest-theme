# Change Log

All notable changes to the BlueForest theme will be documented in this file.

The theme has a configuration for several tools, and every configuration has
its own changelog:

| Application | Changelog                                  |
| ----------- | ------------------------------------------ |
| VS Code    | [modules/vscode/CHANGELOG.md](modules/vscode/CHANGELOG.md) |
| bat        | [modules/bat/CHANGELOG.md](modules/bat/CHANGELOG.md) |
| Neovim     | [modules/neovim/CHANGELOG.md](modules/neovim/CHANGELOG.md) |
| Starship   | [modules/starship/CHANGELOG.md](modules/starship/CHANGELOG.md) |
| OpenCode   | [modules/opencode/CHANGELOG.md](modules/opencode/CHANGELOG.md) |
| sbt        | [modules/sbt/CHANGELOG.md](modules/sbt/CHANGELOG.md) |

Every configuration of the repository shares one version, which comes from the
tags of the repository: a release is a tag of the form `vMAJOR.MINOR.PATCH`.

## Unreleased

- The version of the repository comes from its tags, and the `VERSION` files
  are gone: a release is a tag of the form `vMAJOR.MINOR.PATCH`, and it
  releases every application of the repository at once
- The packages of the repository carry the revision of the commit they are
  built from, and never the version of a release
- The release helper is one flow for the whole repository: it asks for the
  version, checks it against the releases of GitHub, stamps the changelogs,
  commits, tags and pushes. There is no script per application any more
- The release workflow creates the GitHub release first, with the changelog of
  the version, and the applications upload their assets to it afterwards, so
  that the release never carries half of its assets
- The repository holds a configuration of the theme per application, each of
  them in a directory of its own
- The applications are flakes of their own, which publish a module that the
  root flake composes
- The Home Manager modules are now called `homeModules`, the way Home Manager
  calls them
- The configurations of the theme are licensed under CC BY 4.0 International,
  and the code that packages them under MPL-2.0
- The BlueForest theme now includes a Starship preset, packaged as
  `blueforest-starship-preset` and `blueforest-starship`
- The BlueForest theme now includes a theme for OpenCode, packaged as
  `blueforest-opencode-theme`. It is the format OpenCode 2 reads, and the
  Home Manager module selects it through the settings of the terminal
- The BlueForest theme now includes a prompt for sbt, packaged as
  `blueforest-sbt-prompt`. It installs the
  [sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin and selects
  its `BlueforestTheme`, which is defined upstream
- The BlueForest theme now includes a theme for Neovim, packaged as
  `blueforest-neovim-theme`. It is a plugin that carries the colourscheme of
  Neovim and the theme of lualine, and the Home Manager module adds it to the
  plugins of the editor
- The theme for Neovim has a module for nixvim as well, which installs it among
  the plugins of the editor and selects the colourscheme. The repository owns
  the pin of nixvim, and the CI runs the check that builds an editor with the
  theme
- The theme for OpenCode has a yellow hue for the variables and the emphasis,
  and the categorical palette of the agents counts it
- The overlay of the repository adds the packages of every application again:
  it was composed by hand, which lost one of the two arguments an overlay
  takes, and it did not add anything
- The module of every application takes the inputs of that application as a
  static argument, so that a consumer that imports it needs no `devshell`,
  `home-manager` or `nixvim` input of its own. The packages of an application
  are built with the nixpkgs of the consumer, and its checks with the
  Home Manager and the nixvim of the application
- There is one development shell for the repository instead of one per
  application. The definition is the `devshell.toml` of the root, and it
  carries the tools of every application
- The check that nixvim reads the theme is a package of its own, so that
  `nix build .#neovim-nixvim-check` works as the documentation says
- The release helper stops the release when the user aborts, instead of
  committing the version anyway
- `release all` releases every application, bat included, so that every
  application carries the version of the repository
- The release workflow of bat checks the application before publishing it, and
  the workflows of bat and Neovim create the release when it does not exist yet
- The workflows of the repository are defined in Nix now, in `workflows/`, and
  rendered into the files of `.github/workflows/`. The release workflow is one
  for every application instead of one per application, and a check verifies
  that the rendered files are the committed ones and that they are valid
- The input that publishes to GitHub releases now applies to every application
  instead of the VS Code extension alone, and a GitHub release publishes the
  extension to GitHub releases as well, which it did not before
- Renovate updates the versions of the actions that the workflows use, because
  Dependabot only reads workflow files, which are generated. The application
  brings its own credential, so the repository holds no secret for it, and the
  CI renders the workflows for its pull requests
- Renovate updates the version of the sbt prompt plugin as well, which is in
  the declaration of the plugin, in the check that pins it and in the
  documentation of the application
- The changelog of an application that is not released yet carries an
  `Unreleased` section, which the release turns into the section of the
  release
- The scripts of the applications share a library, so that they do not repeat
  the version and the changelog
- The applications pin the same nixpkgs and the same Home Manager as the
  repository, so that the check of an application tests the same inputs as
  the check of the repository
- The attribution of the prompt for sbt travels with the package in
  `share/doc/blueforest/`, where the attribution of the other themes does
- The overlay of the repository is checked to leave the programs of nixpkgs
  alone, the editor of nixpkgs included
- The theme for VS Code and the theme for bat have a README of their own, like
  the other applications
