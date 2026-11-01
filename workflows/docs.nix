# SPDX-License-Identifier: MPL-2.0
#
# The workflow that builds and deploys the documentation site.
#
# The site is built with the same package the root flake exposes as
# `packages.documentation`, so the deployed site is the one the checks build.
# It is deployed to GitHub Pages with the official Pages actions.
#
# The workflow runs on pushes to `master`, on manual dispatch, and when the
# release workflow calls it as its last step.
{
  lib,
}:
let
  common = import ./lib.nix;
in
{
  name = "Documentation";

  on = {
    push.branches = [ "master" ];
    workflow_dispatch = { };
    workflow_call = { };
  };

  permissions = {
    contents = "read";
    pages = "write";
    id-token = "write";
  };

  # GitHub Pages deployments are serialised, and a deployment that is already
  # running is not cancelled by a newer one.
  concurrency = {
    group = "pages";
    cancel-in-progress = false;
  };

  jobs = {
    build = {
      name = "Build the documentation";
      runs-on = "ubuntu-latest";
      steps = [
        common.checkout
        common.installNix
        {
          uses = common.actions.configurePages;
        }
        {
          name = "Build the documentation";
          run = "nix build .#documentation";
        }
        {
          name = "Stage the site";
          run = "cp -rL result site";
        }
        {
          name = "Upload the site";
          uses = common.actions.uploadPagesArtifact;
          "with".path = "site";
        }
      ];
    };

    deploy = {
      name = "Deploy the documentation";
      needs = [ "build" ];
      runs-on = "ubuntu-latest";
      environment = {
        name = "github-pages";
        url = "\${{ steps.deployment.outputs.page_url }}";
      };
      steps = [
        {
          id = "deployment";
          name = "Deploy to GitHub Pages";
          uses = common.actions.deployPages;
        }
      ];
    };
  };
}
