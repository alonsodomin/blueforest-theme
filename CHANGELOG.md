# Change Log

All notable changes to the BlueForest theme will be documented in this file.

The theme has a configuration for several tools, and every configuration has
its own changelog:

| Application | Changelog                                  |
| ----------- | ------------------------------------------ |
| VS Code    | [modules/vscode/CHANGELOG.md](modules/vscode/CHANGELOG.md) |
| bat        | [modules/bat/CHANGELOG.md](modules/bat/CHANGELOG.md) |
| btop       | [modules/btop/CHANGELOG.md](modules/btop/CHANGELOG.md) |
| Neovim     | [modules/neovim/CHANGELOG.md](modules/neovim/CHANGELOG.md) |
| Starship   | [modules/starship/CHANGELOG.md](modules/starship/CHANGELOG.md) |
| OpenCode   | [modules/opencode/CHANGELOG.md](modules/opencode/CHANGELOG.md) |
| sbt        | [modules/sbt/CHANGELOG.md](modules/sbt/CHANGELOG.md) |
| eza        | [modules/eza/CHANGELOG.md](modules/eza/CHANGELOG.md) |
| Zed        | [modules/zed/CHANGELOG.md](modules/zed/CHANGELOG.md) |
| Yazi       | [modules/yazi/CHANGELOG.md](modules/yazi/CHANGELOG.md) |
| kitty      | [modules/kitty/CHANGELOG.md](modules/kitty/CHANGELOG.md) |
| MkDocs     | [modules/mkdocs/CHANGELOG.md](modules/mkdocs/CHANGELOG.md) |
| Claude Code | [modules/claude-code/CHANGELOG.md](modules/claude-code/CHANGELOG.md) |
| lazygit    | [modules/lazygit/CHANGELOG.md](modules/lazygit/CHANGELOG.md) |
| md-tui     | [modules/md-tui/CHANGELOG.md](modules/md-tui/CHANGELOG.md) |
| Noctalia   | [modules/noctalia/CHANGELOG.md](modules/noctalia/CHANGELOG.md) |

Every configuration of the repository shares one version, which comes from the
tags of the repository: a release is a tag of the form `vMAJOR.MINOR.PATCH`.

## Unreleased

- The themes of bat, of Claude Code and of md-tui have a light variant now,
  and the switch of the variant selects the one that is installed
- The themes have a light variant now. The theme of VS Code is the reference
  of the effort, and it is published with the extension as **BlueForest
  Light**: the colours of the light palette of the repository, with the
  swatches of the documentation
- The theme of OpenCode carries a light variant as well, in the same file, and
  it follows the appearance of the terminal
- The palettes of the documentation site are shown with swatches, so that
  every colour of them is seen and not only read. A check verifies that the
  swatches are the colours of the palette of Noctalia
- The options of the repository live under `blueforest-theme` now, and not
  under `blueforest`. The options of the module of MkDocs are the ones that
  changed name: `blueforest.mkdocs.enable`, `blueforest.mkdocs.docsDir` and
  `blueforest.mkdocs.path` are `blueforest-theme.mkdocs.enable`,
  `blueforest-theme.mkdocs.docsDir` and `blueforest-theme.mkdocs.path` now.
  The old names are gone, and a configuration that uses them fails to
  evaluate
- Every theme of the repository has a switch of its own,
  `blueforest-theme.<application>.enable`, and it is off by default. The switch is
  separate from `programs.<application>.enable`, so that the theme of one
  application can be turned on without the themes of the others, and so that
  the theme and a template of the community catalogue of Noctalia are
  alternatives. The switch does not apply to VS Code, to Zed, and to MkDocs
- A configuration that enables the theme of the repository and a template of
  the community catalogue of Noctalia for the same application fails to
  evaluate. The applications with a template are bat, btop, Claude Code,
  kitty, OpenCode, and Starship
- The palette of Noctalia carries a light variant as well, which is a palette
  of its own and not a copy of the dark one. The package carries the palette
  in the format 2 of the community palette registry as well, and the file of
  the format 2 is generated from the canonical one
- The theme of bat has a Home Manager module now, which installs it in the
  directory bat reads the themes from and selects it in the configuration of
  bat
- The Home Manager module of Starship selects the preset of the repository and
  the package that carries it
- The pull requests of Renovate and Dependabot are merged on their own, when
  the merge gate of the CI has passed. Renovate marks them for the auto-merge
  of GitHub itself, and the workflow of the repository marks the ones of
  Dependabot, because Dependabot cannot do it
- The aggregate NixOS and Home Manager modules of the repository no longer
  carry the modules of VS Code and Zed. A consumer that wants them imports
  `blueforest.nixosModules.vscode`, `blueforest.homeModules.vscode` or
  `blueforest.homeModules.zed` explicitly
- The module of the theme of MkDocs is only a flake module, under the name
  `flakeModules.mkdocs`, and it is not part of `flakeModules.default`. The
  module of mkdocs-flake declares arguments, and a module that declares
  arguments can only be imported once per flake
- The extension of the theme of Zed is a submodule that tracks the branch
  `main` of its repository
- The development shell generates and serves the documentation site with
  `generate-docs`, `serve-docs` and `watch-docs`. The site is written under
  `$PRJ_DATA_DIR`, which is `.data` by default, and the directory is ignored by
  git
- The shell blocks of the documentation are marked `bash`, the marker every
  application of the repository highlights. They were marked `console`, which
  only Pygments and Shiki know, so they came out plain in the site and in
  every editor but those two
- The shell tokens are painted with the same colours in every application of
  the repository: the command is a function, the arguments are parameters,
  the punctuation is punctuation, and the variables are variables
- The BlueForest theme now includes a theme for btop, packaged as
  `blueforest-btop-theme`. It is the theme file btop reads, and the Home
  Manager module installs it in the directory btop reads the themes from, and
  selects it in the configuration of btop
- The BlueForest theme now includes a theme for lazygit, packaged as
  `blueforest-lazygit-theme`. lazygit has no theme file of its own, so the
  theme is the `gui.theme` mapping of its configuration file, and the Home
  Manager module adds it to the settings of lazygit, colour by colour
- The BlueForest theme now includes a theme for md-tui, packaged as
  `blueforest-md-tui-theme`. It is the palette md-tui reads from the `themes`
  directory of its configuration directory, and the Home Manager module
  installs it there and selects it
- The BlueForest theme now includes a theme for Noctalia, packaged as
  `blueforest-noctalia-theme`. It is the palette Noctalia reads from the
  `palettes` directory of its configuration directory, and the Home Manager
  module installs it there and selects it in a file of its own, so that the
  rest of the configuration of the shell is untouched
- The theme of Yazi depends on the theme of bat, instead of carrying a copy of
  it. The flavour of Yazi links to the TextMate theme of bat for the colours
  of the code preview, the package of the theme of Yazi carries the package of
  the theme of bat, and the overlay of Yazi adds the package of the theme of
  bat as well
- The keys of a JSON document are painted with the colour of the types in the
  theme of bat, like the theme of VS Code does, and the strings keep the
  colour of the strings
- The BlueForest theme now includes a theme for Claude Code, packaged as
  `blueforest-claude-code-theme`. It is the custom theme Claude Code reads,
  and the Home Manager module installs it in the directory Claude Code reads
  the themes from, and selects it in the settings of Claude Code
- The BlueForest theme now includes a theme for MkDocs, packaged as
  `blueforest-mkdocs-theme`. It is the stylesheet that recolours the code
  blocks of Material for MkDocs in the dark scheme, and the flake-parts module
  of the application installs it in the sources of the documentation before
  MkDocs builds the site
- The documentation of the repository is built by the module of the application,
  so that the site carries the theme of the repository itself
- The CSS files of the repository are formatted with `prettier` and linted with
  `stylelint`
- Every theme page documents the installation with Nix before the manual
  installation. The pages of VS Code and Zed lead with the registry of their
  editor, and their installation with Nix is marked as the one for developing
  and testing the theme. The page of VS Code documents the installation with
  `nix-vscode-extensions`, which installs the published extension
- The BlueForest theme now includes a theme for kitty, packaged as
  `blueforest-kitty-theme`. It is the configuration file kitty reads, and the
  Home Manager module installs it in the directory kitty reads the themes
  from, and selects it in the configuration of kitty
- The BlueForest theme now includes a theme for Yazi, packaged as
  `blueforest-yazi-theme`. It is a flavour, the format Yazi reads, and it
  carries the colours of the code preview as well. The Home Manager module
  installs the flavour in the directory Yazi reads the flavours from, and it
  selects it in the theme of the user
- The BlueForest theme now includes a theme for Zed, packaged as
  `blueforest-zed-theme`. It is part of the `zed-blueforest-theme` extension,
  which lives in a repository of its own because that is how Zed ships
  extensions, and the Home Manager module writes the theme to the themes
  directory of Zed, which is where Zed reads the themes of the user from
- The BlueForest theme now includes a theme for eza, packaged as
  `blueforest-eza-theme`. It is the YAML file eza reads, and the Home Manager
  module installs it in the configuration directory of eza, which is where eza
  reads the theme from
- The theme for bat is installed in the configuration directory of bat, which
  is where bat reads the themes from, and the cache of bat is rebuilt, so that
  the theme is picked up without further work
- The Starship package that carries the preset declares the licences of what
  it ships, and the attribution of the theme travels with it
- The VS Code extension does not ship the Nix expressions of the application
  any more, and a check verifies it
- The development shell does not build the extension by hand any more: the
  extension is built by Nix, and the tools of the packaging are not in the
  shell
- The version of a package of the repository comes from the revision of the
  commit alone, and the release stamps the version of the release into the
  manifest of the extension before it is packaged, and checks that the
  manifest carries it, so that an extension that still carries the
  placeholder is never published
- The release helper tells a remote that could not be reached from a tag that
  is already there, and it keeps the changes made to a changelog while the
  release was being confirmed
- The version comes from the tags of the repository, and the `VERSION` files
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
- The documentation is now an MkDocs site configured by `mkdocs.yml` at the
  root, with user-facing pages under `docs/` and a separate `Hacking` section
  for the repository layout, development, workflows, and releases. The
  READMEs are short entry points that link to it
- The documentation workflow builds the site with
  `nix build .#documentation` and deploys it to GitHub Pages. The release
  workflow calls it as its last step, and the root flake checks the site with
  `mkdocs build --strict`
- The code blocks of the documentation site use the BlueForest palette in dark
  mode, and keep the palette of Material in light mode
