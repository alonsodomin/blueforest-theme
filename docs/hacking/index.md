# Hacking

This section is for people who work on the repository itself. It is separate
from the installation pages: it describes the repository layout, the
development shell, the checks, the workflows, and the release process.

The repository is a Nix flake monorepo. Every application is a flake of its
own, and the root flake composes them.

Start with the [development shell](development.md):

```console
nix develop
```

The shell is the same for the whole repository. It carries the tools of every
application, the release tooling, and the formatters.

- [Repository layout](repository.md) explains how the applications and the
  root flake fit together.
- [Development](development.md) covers formatting, checks, and the
  documentation build.
- [Workflows](workflows.md) explains how the GitHub Actions files are
  generated.
- [Releases](releases.md) covers versions, changelogs, and the release
  process.
- [Adding an application](adding-an-application.md) is the checklist for a new
  port of the theme.
