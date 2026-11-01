# Releases

A release of the repository is a tag of the form `vMAJOR.MINOR.PATCH`. It
releases every application of the repository at once, into one GitHub release.

The version is not a file of the repository: it comes from the tags. The
packages of the repository carry the revision of the commit they are built
from, never the version of a release.

The changelogs live in `modules/<app>/CHANGELOG.md` and in the root
`CHANGELOG.md`. A changelog that has changes that are not released yet carries
an `Unreleased` section. The release turns that heading into the heading of the
release.

## The release helper

From the development shell:

```console
release
```

or, outside the shell:

```console
nix run .#release
```

The helper asks for the version, checks it against the releases of GitHub,
stamps the changelogs, commits, tags, and pushes. It needs authenticated `gh`
and network access. It pushes, so do not run it unattended.

The push of the tag triggers the release workflow. The workflow:

1. Reads the version from the tag.
2. Runs the checks for the root flake and for every application.
3. Creates the GitHub release as a draft, with the changelog of the version.
4. Lets every application package its theme and upload its asset.
5. Publishes the release when every asset is uploaded.
6. Calls the documentation workflow to deploy the documentation site.

The release is created once, before the applications upload their assets, so
that the release never carries half of its assets.

## Release assets

| Application | Asset |
| --- | --- |
| VS Code | `blueforest-theme-<version>.vsix` |
| bat | `blueforest-bat-theme-<version>.tmTheme` |
| Starship | `blueforest-starship-preset-<version>.toml` |
| OpenCode | `blueforest-opencode-theme-<version>.json` |
| Neovim | `blueforest-neovim-theme-<version>.tar.gz` |
| sbt | `blueforest-sbt-prompt-<version>.tar.gz` |
| eza | `blueforest-eza-theme-<version>.yml` |
| Zed | `blueforest-zed-theme-<version>.tar.gz` |

The VS Code extension is also published to Open VSX and to the VS Marketplace.
`modules/vscode/package.json` carries the placeholder `0.0.0`: the manifest is
patched with the version of the package before the extension is packaged, and
the release workflow patches it with the version of the release.

## Updating the repository

Every flake of the repository has a lock file of its own: the root one, and one
per application. The `update` helper updates all of them:

```console
update
```

A single application can be updated on its own:

```console
update vscode
```

The root flake owns the pins of the repository, so the helper pins the inputs
that an application shares with the root to the revisions the root resolved.
Without that step the two drift apart, because the root and the application
resolve the branch on their own.

Dependabot watches the lock files and opens a pull request for the inputs that
moved upstream. Renovate updates the versions of the actions in
`workflows/lib.nix` and the version of the sbt prompt plugin.

## Adding an application to the release

A new application brings an entry in the table of `workflows/release.nix`,
where the way it is packaged is described, and an entry in the list of
applications in `workflows/lib.nix`. See
[Adding an application](adding-an-application.md).
