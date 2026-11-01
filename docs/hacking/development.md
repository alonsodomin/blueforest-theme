# Development

The repository has one development shell for everything:

```console
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

  release - Interactive release helper
  update  - Update the lock files of the repository and of every application
```

## Formatting

```console
nix fmt
```

The formatter is `treefmt`, configured in `treefmt.nix`. It runs:

- `nixfmt` for Nix
- `deadnix` and `statix` for Nix
- `taplo` for TOML
- `prettier` for JSON, JSON5 and YAML
- `xmllint` for XML and SVG
- `stylua` for Lua
- `shfmt` and `shellcheck` for shell

The shell is bash and uses tabs. `shellcheck` must pass.

Two parts of the repository are not formatted: the extension of Zed, which
lives in a repository of its own, and the workflows, which are rendered from
their definitions.

## Checks

The fast checks are:

```console
nix flake check "path:."
```

The root flake checks every application at once, and every application can be
checked on its own the way a consumer that installs only one of them gets it:

```console
nix flake check "path:./modules/vscode"
nix flake check "path:./modules/bat"
nix flake check "path:./modules/neovim"
nix flake check "path:./modules/starship"
nix flake check "path:./modules/opencode"
nix flake check "path:./modules/sbt"
nix flake check "path:./modules/eza"
nix flake check "path:./modules/zed"
```

The `path:` prefix matters: the flakes are checked from the working tree, and
not from the git tree. The extension of Zed is a submodule of the repository,
and Nix cannot read the contents of a submodule of a git tree, so the
submodule has to be checked out for the checks to see it.

A single check can be built on its own:

```console
nix build "path:.#checks.x86_64-linux.<name>"
```

The names include `version`, `overlay`, `treefmt`, `workflows`,
`workflows-lint`, `vscode-extension`, `vscode-configuration`, `bat-theme`,
`bat-theme-home`, `bat-theme-nixos`, `neovim-theme`, `neovim-configuration`,
`neovim-module`, `starship-preset`, `starship-render`, `starship-wrapper`,
`starship-module`, `opencode-theme`, `opencode-configuration`,
`opencode-module`, `sbt-package`, `sbt-module`, `eza-theme`, `eza-render`,
`eza-module`, `zed-extension`, `zed-theme`, `zed-module`, `zed-colours`, and
`documentation`.

Root flake evaluation sees the working tree, so the changes of the working
tree are part of it. `git add` new files before running `nix flake check` or
`nix build "path:.#..."`, so that the tree and the submodule agree with the
repository.

### The expensive editor checks

Two checks build an editor, so they are only run on purpose:

- `BLUEFOREST_VSCODE_INTEGRATION_CHECK=1` builds VSCodium with the theme.
- `BLUEFOREST_NEOVIM_NIXVIM_CHECK=1` builds a Neovim with nixvim and the theme.

Both need `--impure`, because they read the environment:

```console
BLUEFOREST_VSCODE_INTEGRATION_CHECK=1 \
BLUEFOREST_NEOVIM_NIXVIM_CHECK=1 \
nix flake check --impure "path:."
```

They can also be built on their own:

```console
nix build "path:.#vscode-integration-check"
nix build "path:.#neovim-nixvim-check"
```

The CI runs them, so that the theme is checked against the editors it is made
for.

### The workflows checks

The `workflows` check renders the workflows into a scratch directory and
compares them with the committed files. It fails when the rendered files are
not the committed ones. It is skipped when
`BLUEFOREST_SKIP_WORKFLOWS_CHECK=1`, which the CI does on a pull request,
where the workflow of the CI renders the files and commits them to the branch.

The `workflows-lint` check renders the workflows and runs `actionlint` over the
result. It does not depend on what is committed, so it runs on every pull
request.

## Trying the theme

The extension of VS Code is built by Nix:

```console
nix build "path:.#blueforest-vscode-theme"
```

The result holds the extension in `share/vscode/extensions`. An editor reads
the extensions of a profile from a directory of its own, which it writes to,
so the extension is linked into one:

```console
mkdir -p .vscode-exts
ln -sfn "$(nix build "path:.#blueforest-vscode-theme" --print-out-paths)/share/vscode/extensions"/* .vscode-exts/
code --extensions-dir="$PWD/.vscode-exts"
```

To try a change to the theme without building it, point the editor at the
directory of the extension instead:

```console
code --extensionDevelopmentPath="$PWD/modules/vscode"
```

## Documentation

The documentation site is built with MkDocs:

```console
nix build .#documentation
```

The result is a static site in `result/`.

To work on the documentation with a live reload:

```console
nix run .#watch-documentation
```

The site is configured by `mkdocs.yml` at the repository root, and its sources
are the Markdown files under `docs/`. The root flake builds the site with
`--strict`, so broken internal links and pages missing from the navigation fail
the check.

## Workflows

The workflows of the repository are defined in Nix under `workflows/` and
rendered into `.github/workflows/`. Render them with:

```console
nix run .#render-workflows
```

The pre-commit hook of the development shell does the same and stages the
result. Do not edit `.github/workflows/*.yml` by hand.

See [Workflows](workflows.md) for the details.
