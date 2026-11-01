# Workflows

The GitHub Actions workflows are defined in Nix under `workflows/`, and the
files in `.github/workflows/` are rendered from those definitions by
[`actions-nix`](https://github.com/nialov/actions.nix).

The files in `.github/workflows/` are generated. Never edit them by hand: edit
the definitions and run:

```console
nix run .#render-workflows
```

The pre-commit hook of the development shell does the same and stages the
result. Commit the rendered files with the definitions.

## The definitions

| Definition | Rendered file | Purpose |
| --- | --- | --- |
| `workflows/ci.nix` | `.github/workflows/ci.yml` | Checks the repository and renders the workflows for pull requests |
| `workflows/docs.nix` | `.github/workflows/docs.yml` | Builds the documentation site and deploys it to GitHub Pages |
| `workflows/release.nix` | `.github/workflows/release.yml` | Packages and publishes a release |

`workflows/lib.nix` holds the applications, the actions, and the pieces the
workflows share. The versions of the actions live there too, so that Renovate
updates them in one place.

`workflows/default.nix` maps each definition to the file it renders.

## Checks

The `workflows` check renders the workflows into a scratch directory and
compares them with the committed files. It fails when they differ. On a pull
request the CI sets `BLUEFOREST_SKIP_WORKFLOWS_CHECK=1`, because the CI render
job commits the rendered files to the branch instead.

The `workflows-lint` check renders the workflows and runs `actionlint` over the
result. It runs on every pull request, and it catches invalid expressions,
unknown inputs, and invalid job dependencies.

## The CI workflow

The CI runs on pushes to `master` and on pull requests. It has three jobs:

- **Render the workflows** runs on pull requests from the repository itself. It
  renders the workflows and commits the result to the branch. It skips pull
  requests from forks, because their token is read-only.
- **Checks** runs `nix flake check --impure` for the root flake and for every
  application, against the working tree, so that the submodule of the
  extension of Zed is part of it. It sets the environment variables that
  enable the expensive editor checks, and skips the workflow comparison on
  pull requests.
- **Merge gate** waits for the checks, and fails when they did not pass.

## The merge gate

The **Merge gate** job is the one the repository is configured with as a
**required status check**, under **Settings → Branches → Branch protection
rules**. The check is named *Merge gate*, and a pull request cannot be merged
until it succeeds.

The job depends on the **Checks** job, and it runs even when the checks fail,
because a required check that is never reported leaves the pull request waiting
for a status that never comes. The job reads the result of the checks it needs
and fails when that result is not `success`.

## The documentation workflow

The documentation workflow builds the site with
`nix build .#documentation`, uploads it with `actions/upload-pages-artifact`,
and deploys it with `actions/deploy-pages`. It runs on pushes to `master`, on
manual dispatch, and when the release workflow calls it.

The repository must have GitHub Pages configured with **GitHub Actions** as its
source. The site is published at
<https://alonsodomin.github.io/blueforest-theme/>.

## The release workflow

The release workflow runs on the push of a `vMAJOR.MINOR.PATCH` tag. It checks
the repository, creates the GitHub release with the changelog of the version,
and lets every application package itself and upload its asset to the release.
The release is published when every application is done, and the documentation
workflow is called as the last step.

See [Releases](releases.md) for the release process.

## Renovate and Dependabot

Dependabot watches the lock files, and Renovate updates the versions of the
actions in `workflows/lib.nix` and the version of the sbt prompt plugin. The
configuration of Renovate is in `renovate.json5`; the configuration of
Dependabot is in `.github/dependabot.yml`.

Renovate cannot run commands in the hosted application, so the CI renders the
workflows for its pull requests.
