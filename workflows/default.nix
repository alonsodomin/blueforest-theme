# SPDX-License-Identifier: MPL-2.0
#
# The workflows of the repository, defined in Nix.
#
# The files of `.github/workflows/` are rendered from these definitions. They
# are not edited by hand: `nix run .#render-workflows` writes them, and the
# check of the repository fails when they are not the ones these definitions
# render.
#
# The workflows of Renovate are not here: the application updates the actions
# of the workflows, and the CI renders them again for its pull requests.
{
  lib,
}:
let
  ci = import ./ci.nix { inherit lib; };
  docs = import ./docs.nix { inherit lib; };
  release = import ./release.nix { inherit lib; };
in
{
  ".github/workflows/ci.yml" = ci;
  ".github/workflows/docs.yml" = docs;
  ".github/workflows/release.yml" = release;
}
