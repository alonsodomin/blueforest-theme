# SPDX-License-Identifier: MPL-2.0
#
# The workflow that enables the auto-merge of the pull requests of Dependabot.
#
# Dependabot cannot enable the auto-merge of its own pull requests, so the
# workflow does it for them: it marks the pull request for the auto-merge of
# GitHub, and GitHub merges it when the checks that the repository requires
# have passed. The merge gate of the CI is the one that has to pass.
#
# The workflow only touches the pull requests of Dependabot, and it never runs
# the code of them: it marks them for the auto-merge and nothing else.
_: {
  name = "Dependabot auto-merge";

  on = {
    pull_request.branches = [ "master" ];
  };

  # The token of a workflow that Dependabot triggers is read-only by
  # default, and the permissions below are the ones it needs to mark a pull
  # request for the auto-merge.
  permissions = {
    contents = "write";
    pull-requests = "write";
  };

  jobs = {
    dependabot = {
      name = "Enable auto-merge";

      # The pull requests of anybody else are left alone.
      "if" = "github.event.pull_request.user.login == 'dependabot[bot]'";

      runs-on = "ubuntu-latest";
      steps = [
        {
          name = "Enable auto-merge";

          # The merge is a rebase one, because the rules of the repository do
          # not allow the merge commits that the linear history of the branch
          # forbids.
          #
          # The rebase keeps the message of the commit of the pull request,
          # and that message is conventional: Dependabot writes it with the
          # prefix of `.github/dependabot.yml`.
          run = "gh pr merge --auto --rebase \"$PR_URL\"";
          env = {
            PR_URL = "\${{ github.event.pull_request.html_url }}";
            GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
          };
        }
      ];
    };
  };
}
