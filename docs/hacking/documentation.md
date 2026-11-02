# Documentation

The documentation of the repository is a site built with
[MkDocs](https://www.mkdocs.org/) and
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/). Its
sources are the Markdown files under `docs/`, and its configuration is
`mkdocs.yml` at the root of the repository.

The development shell has three commands for it:

| Command | What it does |
| --- | --- |
| `generate-docs` | Generates the site under the data directory of the project |
| `serve-docs` | Generates the site and serves it locally |
| `watch-docs` | Serves the site locally and generates it again on every change |

## Generating the site

`generate-docs` runs `mkdocs build` and writes the site under the data
directory of the project:

```bash
generate-docs
```

The data directory is the one the development shell exports as
`PRJ_DATA_DIR`, which is `.data` by default. The site is therefore written to
`.data/site`. The directory is ignored by git, so the generated site never ends
up in a commit.

The site is built in strict mode, like the `documentation` check of the
repository: a broken link, a page that is missing from the navigation, or a
warning of MkDocs fails the build.

## Serving the site

`serve-docs` generates the site and serves it locally, so that it can be
browsed at <http://localhost:8000/>:

```bash
serve-docs
```

The server does not watch the sources: it serves the site it generated when it
started, and it does not generate it again.

## Watching the sources

`watch-docs` serves the site locally and generates it again whenever a source
of the documentation changes:

```bash
watch-docs
```

It watches the sources of the site and the configuration of MkDocs, it
generates the site again on every change, and it reloads the browser of the
reader. This is the command to use while writing the documentation.

## The checks

The `documentation` check of the repository builds the site the way the
documentation workflow builds it, and it fails when the site cannot be built.
The check is part of `nix flake check`.

The site of the repository is published at
<https://alonsodomin.github.io/blueforest-theme/>, and the documentation
workflow builds it and deploys it on every push to `master`. See
[Workflows](workflows.md) for the details.

See [Development](development.md) for the rest of the development shell.
