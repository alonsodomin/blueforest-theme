# Releases

A release of the repository is a tag of the form `vMAJOR.MINOR.PATCH`. It
releases every application of the repository at once, into one GitHub release.

The version is not a file of the repository: it comes from the tags. The
packages of the repository carry the revision of the commit they are built
from, never the version of a release.

## The changelog

The changelog of a release is written by
[CoCoGitto](https://github.com/cocogitto/cocogitto), out of the commits of
the repository. The changelogs live in the repository: the one of the
repository at the root, and the one of every application in its own
directory.

The commits of the repository follow the
[conventional commits](https://www.conventionalcommits.org) specification, and
the scope of a commit is the application it touches:

```text
feat(bat): add the light variant of the theme
fix(neovim): correct the colour of the operators
docs(repo): document the release process
```

The commits that are not of an application carry the scope `repo`.

The changelog of an application holds the commits that touch it, and the
changelog of the repository holds the commits that touch none of them, and
the versions of the applications that changed.

The configuration of the tool is `cog.toml`: the prefix of the tags, the
scopes the commits may carry, the template of the changelog, and the
applications of the monorepo.

## Making a release

The release is made by the helper of the development shell:

```bash
release
```

or, outside the shell:

```bash
nix run .#release
```

The helper runs `cog bump --auto`, which computes the version of every
application that changed, writes the changelogs, commits them, and tags the
release. It asks before it pushes the branch and the tags, and the push of
the tag of the release triggers the release workflow.

The release workflow:

1. Checks that the commits of the release follow the conventional commits
   specification, the same way the commits of a pull request do.
2. Runs the checks for the root flake and for every application.
3. Creates the GitHub release as a draft, with the section of the changelog
   of the repository that belongs to the version.
4. Lets every application read its own version, package its theme and upload
   its asset.
5. Publishes the release when every asset is uploaded.
6. Calls the documentation workflow to deploy the documentation site.

The release is created once, before the applications upload their assets, so
that the release never carries half of its assets.

### The versions

The repository has a version of its own, the one of its tag, and every
application has a version of its own, which is bumped when the application
changes. The tag of an application carries the name of the application before
the prefix, `bat-v0.2.0`, and the tag of the repository carries the prefix
alone, `v0.5.0`.

The workflow reads the version of an application with
[CoCoGitto](https://github.com/cocogitto/cocogitto), which knows the tags of
the monorepo:

```bash
cog get-version --package bat -f $(cog get-version |& tail -1) |& tail -1
```

The version of the repository is the fallback of the applications that have no
tag of their own yet. The version of the asset of an application is the
version of the application, and not the version of the repository: an
application that did not change keeps the version it had.

### The guard of the tags

A tag of a release is made by the helper, which writes the changelog of the
release with it. The development shell installs a `pre-push` hook that stops
the push of a tag of a release when the user did not confirm it, and tells
them that the release is made with `nix run .#release`.

## The changelog of the unreleased changes

The changelog of the changes that are not released yet is shown by a command
of the development shell:

```bash
changelog
```

or, outside the shell:

```bash
nix run .#blueforest-changelog
```

The command writes the changelog to `$PRJ_DATA_DIR/changelog/CHANGELOG.md`,
which is `.data/changelog/CHANGELOG.md` by default, and prints it.

## Release assets

Every application is one asset: the archive of the theme, with the variants of
the theme and the changelog of the application.

| Application | Asset |
| --- | --- |
| VS Code | `blueforest-theme-<version>.vsix` |
| bat | `blueforest-bat-theme-<version>.tar.gz` |
| Starship | `blueforest-starship-theme-<version>.tar.gz` |
| OpenCode | `blueforest-opencode-theme-<version>.tar.gz` |
| Neovim | `blueforest-neovim-theme-<version>.tar.gz` |
| sbt | `blueforest-sbt-prompt-<version>.tar.gz` |
| eza | `blueforest-eza-theme-<version>.tar.gz` |
| Zed | `blueforest-zed-theme-<version>.tar.gz` |
| Yazi | `blueforest-yazi-theme-<version>.tar.gz` |
| kitty | `blueforest-kitty-theme-<version>.tar.gz` |
| MkDocs | `blueforest-mkdocs-theme-<version>.tar.gz` |
| Claude Code | `blueforest-claude-code-theme-<version>.tar.gz` |
| btop | `blueforest-btop-theme-<version>.tar.gz` |
| lazygit | `blueforest-lazygit-theme-<version>.tar.gz` |
| md-tui | `blueforest-md-tui-theme-<version>.tar.gz` |
| Noctalia | `blueforest-noctalia-theme-<version>.tar.gz` |

The archive holds the variants of the theme in a directory per variant, `dark`
and `light`, and the changelog of the application in `CHANGELOG.txt`:

```text
blueforest-bat-theme-1.2.3.tar.gz
├── CHANGELOG.txt
├── dark/BlueForest.tmTheme
└── light/BlueForestLight.tmTheme
```

The applications that read their theme from a directory of their own keep that
layout, because the files of the archive are installed where the application
reads them from: the theme of Neovim is at `colors/` and `lua/`, the extension
of Zed at `extension.toml` and `themes/`, the prompt of sbt at `plugins/`, and
the flavours of Yazi at `blueforest.yazi/` and `blueforest-light.yazi/`.

The extension of VS Code is the exception: the asset is the extension itself,
because that is what the marketplaces take.

The VS Code extension is also published to Open VSX and to the VS Marketplace.
`modules/vscode/package.json` carries the placeholder `0.0.0`: the manifest is
patched with the version of the package before the extension is packaged, and
the release workflow patches it with the version of the release.

## Updating the repository

The repository is a flake, and the applications are modules of it, so there is
one lock file: the one of the root flake. It is updated with the standard
command of Nix:

```bash
nix flake update
```

The root flake owns the pins of the repository, and the modules of the
applications read the inputs they need from them.

Dependabot watches the lock file and opens a pull request for the inputs that
moved upstream. Renovate updates the versions of the actions in
`workflows/lib.nix` and the version of the sbt prompt plugin.

The commits of Dependabot follow the conventional commits specification, so
that the changelog of a release can be generated out of them: they carry the
prefix `chore(repo)`, which the configuration of Dependabot declares.

## Adding an application to the release

A new application brings an entry in the table of `workflows/assets.nix`,
where the files of its theme and the way it is packaged are described, an entry
in the list of applications in `workflows/lib.nix`, and a package in
`cog.toml`, with the path of the application and the path of its changelog.
See [Adding an application](adding-an-application.md).
