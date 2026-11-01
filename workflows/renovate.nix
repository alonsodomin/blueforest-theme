# SPDX-License-Identifier: MPL-2.0
#
# The workflow that lets Renovate update the actions of the workflows.
{
  lib,
}:
let
  common = import ./lib.nix;
in
{
  name = "Renovate";
  on = {
    schedule = [ { cron = "0 5 * * 1"; } ];
    workflow_dispatch = { };
  };
  jobs.renovate = {
    name = "Renovate";
    runs-on = "ubuntu-latest";
    permissions = {
      contents = "write";
      pull-requests = "write";
    };
    steps = [
      common.checkout
      common.installNix
      {
        uses = common.actions.setupNode;
        "with".node-version = 24;
      }

      # Renovate runs outside of its container, because the task that renders
      # the workflows after an update needs Nix.
      {
        name = "Install Renovate";
        run = "npm install -g renovate";
      }
      {
        name = "Run Renovate";
        run = "renovate --platform=github --repository=\${{ github.repository }}";
        env = {
          RENOVATE_TOKEN = "\${{ secrets.RENOVATE_TOKEN }}";

          # The commands of the post-upgrade tasks are allowed by the
          # administrator of Renovate, which here is the repository itself.
          RENOVATE_ALLOWED_COMMANDS = "^nix run .#render-workflows$";
        };
      }
    ];
  };
}
