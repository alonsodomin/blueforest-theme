# Development

The repository has one development shell for everything:

```bash
nix develop
```

The shell prints a menu with the commands it provides:

```text
🔨 Welcome to blueforest

[[general commands]]

  menu    - prints this menu

[formatters]

  nixfmt  - Nix code formatter

[utilities]

  changelog - Show the changelog of the changes that are not released yet
  release   - Release the repository
```

## Formatting

```bash
nix fmt
```

The formatter is `treefmt`, configured in `treefmt.nix`. It runs:

- `nixfmt` for Nix
- `deadnix` and `statix` for Nix
- `taplo` for TOML
- `prettier` for JSON, JSON5, YAML and CSS
- `stylelint` for CSS
- `xmllint` for XML and SVG
- `stylua` for Lua
- `shfmt` and `shellcheck` for shell

The shell is bash and uses tabs. `shellcheck` must pass.

The workflows are not formatted: they are rendered from their definitions.

## Checks

The fast checks are:

```bash
nix flake check "path:."
```

The root flake checks every application at once, because it composes the
module of every one of them.

The `path:` prefix matters: the flake is checked from the working tree, and
not from the git tree, so that the changes that are not committed yet are the
ones that are checked.

A single check can be built on its own:

```bash
nix build "path:.#checks.x86_64-linux.<name>"
```

The names include `version`, `overlay`, `treefmt`, `workflows-validate`,
`workflows-lint`, `vscode-extension`, `vscode-configuration`, `bat-theme`,
`bat-theme-home`, `bat-theme-nixos`, `bat-module`, `neovim-theme`,
`neovim-configuration`, `neovim-module`, `starship-preset`, `starship-palette`,
`starship-render`, `starship-wrapper`, `starship-module`, `opencode-theme`,
`opencode-configuration`,
`opencode-module`, `sbt-package`, `sbt-module`, `eza-theme`, `eza-render`,
`eza-module`, `zed-extension`, `zed-theme`, `zed-module`, `zed-colours`,
`yazi-theme`, `yazi-render`, `yazi-module`, `yazi-tmtheme`, `yazi-asset`,
`kitty-theme`, `kitty-parse`, `kitty-module`, `mkdocs-theme`, `mkdocs-render`,
`btop-theme`, `btop-render`, `btop-module`, `lazygit-theme`,
`lazygit-render`, `lazygit-module`, `lazygit-colours`, `md-tui-theme`,
`md-tui-render`, `md-tui-module`, `md-tui-colours`, `noctalia-theme`,
`noctalia-palette-v2`, `noctalia-render`, `noctalia-module`, `noctalia-colours`,
`palette-swatches`, `light-colours`, `cog-packages`, `release-assets`, and
`documentation`.

Root flake evaluation sees the working tree. `git add` new files before
running `nix flake check` or `nix build "path:.#..."`, so that the tree and
the repository agree.

### The expensive editor checks

Two checks build an editor, so they are only run on purpose:

- `BLUEFOREST_VSCODE_INTEGRATION_CHECK=1` builds VSCodium with the theme.
- `BLUEFOREST_NEOVIM_NIXVIM_CHECK=1` builds a Neovim with nixvim and the theme.

Both need `--impure`, because they read the environment:

```bash
BLUEFOREST_VSCODE_INTEGRATION_CHECK=1 \
BLUEFOREST_NEOVIM_NIXVIM_CHECK=1 \
nix flake check --impure "path:."
```

They can also be built on their own:

```bash
nix build "path:.#vscode-integration-check"
nix build "path:.#neovim-nixvim-check"
```

The CI runs them, so that the theme is checked against the editors it is made
for.

### The workflows checks

The `workflows-validate` check renders the workflows into a scratch directory
and compares them with the committed files. It fails when the rendered files
are not the committed ones, and it runs on every event. On a pull request the
CI renders the files and commits them to the branch, so the check reports the
ones that are still out of sync.

The `workflows-lint` check renders the workflows and runs `actionlint` over the
result. It does not depend on what is committed, so it runs on every pull
request.

## Trying the theme

The extension of VS Code is built by Nix:

```bash
nix build "path:.#blueforest-vscode-theme"
```

The result holds the extension in `share/vscode/extensions`. An editor reads
the extensions of a profile from a directory of its own, which it writes to,
so the extension is linked into one:

```bash
mkdir -p .vscode-exts
ln -sfn "$(nix build "path:.#blueforest-vscode-theme" --print-out-paths)/share/vscode/extensions"/* .vscode-exts/
code --extensions-dir="$PWD/.vscode-exts"
```

To try a change to the theme without building it, point the editor at the
directory of the extension instead:

```bash
code --extensionDevelopmentPath="$PWD/modules/vscode"
```

## Documentation

The documentation site is built with MkDocs:

```bash
nix build .#documentation
```

The result is a static site in `result/`.

To work on the documentation with a live reload:

```bash
nix run .#watch-documentation
```

The site is configured by `mkdocs.yml` at the repository root, and its sources
are the Markdown files under `docs/`. The root flake builds the site with
`--strict`, so broken internal links and pages missing from the navigation fail
the check.

The development shell generates and serves the site with `generate-docs`,
`serve-docs` and `watch-docs`. See [Documentation](documentation.md) for the
details.

### The code blocks of the documentation

The code blocks of the documentation are marked with the language they are
written in, so that every application of the repository highlights them. The
shell blocks are marked `bash`, which is the marker that the editor of VS
Code, the preview of VS Code, Pygments, bat, Neovim, Zed and Shiki all know.

A marker that only a few of them know leaves the blocks plain in the others.
`console`, for instance, is an alias of the session lexer of Pygments and of
the session grammar of Shiki, and nothing else knows it: a block marked with
it comes out as a single piece of text in the site, in the editor of VS Code
and in every other application.

The `fences` check of the repository fails when a block carries a marker the
applications do not know.

## Workflows

The workflows of the repository are defined in Nix under `workflows/` and
rendered into `.github/workflows/`. Render them with:

```bash
nix run .#render-workflows
```

The pre-commit hook of the development shell does the same and stages the
result. Do not edit `.github/workflows/*.yml` by hand.

See [Workflows](workflows.md) for the details.
