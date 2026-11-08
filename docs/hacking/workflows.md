# Workflows

The GitHub Actions workflows are defined in Nix under `workflows/`, and the
files in `.github/workflows/` are rendered from those definitions by
[`actions-nix`](https://github.com/nialov/actions.nix).

The files in `.github/workflows/` are generated. Never edit them by hand: edit
the definitions and run:

```bash
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

The `workflows-validate` check renders the workflows into a scratch directory
and compares them with the committed files. It fails when they differ, and it
runs on every event. On a pull request the CI renders the files and commits
them to the branch, so the check reports the ones that are still out of sync.

The `workflows-lint` check renders the workflows and runs `actionlint` over the
result. It runs on every pull request, and it catches invalid expressions,
unknown inputs, and invalid job dependencies.

## The CI workflow

The CI runs on pushes to `master` and on pull requests. It has four jobs:

- **Render the workflows** runs on pull requests from the repository itself. It
  renders the workflows and commits the result to the branch. It skips pull
  requests from forks, because their token is read-only.
- **Checks** runs `nix flake check --impure` for the root flake, against the
  working tree. The root flake checks every application at once, because it
  composes the module of every one of them. It sets the environment variables
  that enable the expensive editor checks, and skips the workflow comparison
  on pull requests.
- **Conventional commits** checks the commit messages of the pull request, or
  of the push, with `cog check`. The changelog of a release is written out of
  them, so a commit that does not follow the conventional commits
  specification never reaches the branch.
- **Merge gate** waits for the checks, and fails when they did not pass.

## The merge gate

The **Merge gate** job is the one the repository is configured with as a
**required status check**, under **Settings → Branches → Branch protection
rules**. The check is named *Merge gate*, and a pull request cannot be merged
until it succeeds.

The job depends on the **Checks** and the **Conventional commits** jobs, and it
runs even when they fail, because a required check that is never reported
leaves the pull request waiting for a status that never comes. The job reads
the result of the checks it needs and fails when that result is not `success`.

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
that the commits of the release follow the conventional commits specification,
checks the repository, creates the GitHub release with the section of the
changelog of the repository that belongs to the version, and lets every
application read its own version, package itself and upload its asset to the
release. The release is published when every application is done, and the
documentation workflow is called as the last step.

See [Releases](releases.md) for the release process.

## Renovate and Dependabot

Dependabot watches the lock files, and Renovate updates the versions of the
actions in `workflows/lib.nix` and the version of the sbt prompt plugin. The
configuration of Renovate is in `renovate.json5`; the configuration of
Dependabot is in `.github/dependabot.yml`.

Renovate cannot run commands in the hosted application, so the CI renders the
workflows for its pull requests.

Both of them open their pull requests with the auto-merge enabled, so they are
merged on their own when the checks of the repository have passed. The merge
gate of the CI is the check that has to pass, and it is the only one the
repository requires.

Renovate marks the pull requests for the auto-merge of GitHub itself.
Dependabot cannot do it, so the workflow of `workflows/dependabot.nix` marks
them instead: it runs `gh pr merge --auto` on the pull requests of Dependabot,
and on no other. The merge is a squash one, because the rules of the
repository do not allow the merge commits that the linear history of the
branch forbids.
