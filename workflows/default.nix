# SPDX-License-Identifier: MPL-2.0
#
# The workflows of the repository, defined in Nix.
#
# The files of `.github/workflows/` are rendered from these definitions. They
# are not edited by hand: `nix run .#render-workflows` writes them, and the
# check of the repository fails when they are not the ones these definitions
# render.
{
  lib,
}:
let
  ci = import ./ci.nix { inherit lib; };
  release = import ./release.nix { inherit lib; };
  renovate = import ./renovate.nix { inherit lib; };
in
{
  ".github/workflows/ci.yml" = ci;
  ".github/workflows/release.yml" = release;
  ".github/workflows/renovate.yml" = renovate;
}
