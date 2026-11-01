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
  #
  # The flakes are checked from the working tree, and not from the git tree:
  # the extension of Zed is a submodule of the repository, and Nix cannot
  # read the contents of a submodule of a git tree. The checkout of the
  # workflow brings the submodules with it.
  flakes = [ "path:." ] ++ map (application: "path:./modules/${application}") common.applications;
in
{
  name = "CI";
  on = {
    push.branches = [ "master" ];
    pull_request.branches = [ "master" ];
  };
  jobs = {
    # The workflows of the repository are rendered from their definitions, so
    # a pull request that changes them has to carry the rendered files as
    # well. The application that updates the actions of the workflows opens
    # such pull requests, and it cannot render them itself.
    render = {
      name = "Render the workflows";
      "if" =
        "github.event_name == 'pull_request' && github.event.pull_request.head.repo.full_name == github.repository";
      runs-on = "ubuntu-latest";
      permissions = {
        contents = "write";
      };
      steps = [
        {
          uses = common.actions.checkout;

          # The branch of the pull request, and not the merge of it, because
          # the result is committed to that branch.
          "with".ref = "\${{ github.event.pull_request.head.ref }}";
        }
        common.installNix
        {
          name = "Render the workflows";
          run = "nix run .#render-workflows";
        }
        {
          name = "Commit the workflows";
          run = ''
            if git diff --quiet -- .github/workflows; then
              echo "The workflows are already rendered."
              exit 0
            fi
            git config user.name "github-actions[bot]"
            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
            git commit --all --message "Render the workflows"
            # The ''${ is the escape of an indented string: it writes the
            # expression of GitHub, and not an interpolation of Nix.
            git push origin "HEAD:refs/heads/''${github.event.pull_request.head.ref }}"
          '';
        }
      ];
    };

    checks = {
      name = "Checks (\${{ matrix.flake }})";

      # The workflows are rendered before the checks run, so that the check
      # that compares them with the committed ones runs against a branch that
      # carries the rendered files.
      needs = [ "render" ];

      # The render only runs on pull requests from the repository itself, and
      # a job whose dependency is skipped is skipped with it. The checks run
      # anyway, because they are the ones that tell whether the pull request
      # is any good.
      "if" = "always()";

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
          #
          # The check that the workflows are the ones the definitions render
          # is skipped on a pull request: the job above renders them and
          # commits them to the branch, so there is nothing to report there.
          env = {
            BLUEFOREST_SKIP_WORKFLOWS_CHECK = "\${{ github.event_name == 'pull_request' && '1' || '' }}";
            BLUEFOREST_VSCODE_INTEGRATION_CHECK = "1";
            BLUEFOREST_NEOVIM_NIXVIM_CHECK = "1";
          };
        }
      ];
    };
  };
}
