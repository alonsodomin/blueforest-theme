# SPDX-License-Identifier: MPL-2.0
#
# The workflow that checks the repository.
{
  lib,
}:
let
  common = import ./lib.nix;

  # The root flake checks every application at once, and each application is
  # checked on its own as well.
  flakes = [ "." ] ++ map (application: "./modules/${application}") common.applications;
in
{
  name = "CI";
  on = {
    push.branches = [ "master" ];
    pull_request.branches = [ "master" ];
  };
  jobs.checks = {
    name = "Checks (\${{ matrix.flake }})";
    runs-on = "ubuntu-latest";
    strategy = {
      fail-fast = false;
      matrix.flake = flakes;
    };
    steps = [
      common.checkout
      common.installNix
      {
        name = "Run flake checks";
        run = "nix flake check --impure \${{ matrix.flake }}";

        # The checks that build an editor are expensive, so they are only run
        # on purpose. The CI runs them anyway, because they are the ones that
        # prove that the theme is really installed.
        env = {
          BLUEFOREST_VSCODE_INTEGRATION_CHECK = "1";
          BLUEFOREST_NEOVIM_NIXVIM_CHECK = "1";
        };
      }
    ];
  };
}
