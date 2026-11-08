# SPDX-License-Identifier: MPL-2.0
#
# The workflow that releases the applications of the repository.
#
# A release of the repository is a tag of the form vMAJOR.MINOR.PATCH, and it
# releases every application of the repository at once, into one GitHub
# release.
#
# The workflow runs on the push of such a tag. It checks the commits of the
# release, checks the repository, generates the changelog of the release,
# creates the release of GitHub with it, and then lets every application
# package itself and upload its asset to that release. The release is
# published when every application is done, so that it never carries half of
# its assets.
{
  lib,
}:
let
  common = import ./lib.nix;

  inherit (lib) listToAttrs mapAttrs' nameValuePair;

  # The tag of the release. Every job of the workflow knows it.
  tagExpr = "\${{ github.ref_name }}";

  # The applications of the repository, and the way each one of them is
  # packaged. The asset of an application is the file it uploads to the
  # release of GitHub: the archive of the theme, with the variants of the
  # theme and the changelog of the release.
  applications = import ./assets.nix { inherit lib; };

  applicationsByApp = listToAttrs (
    map (definition: {
      name = definition.app;
      value = definition;
    }) applications
  );

  # The job of one application: it packages the theme and uploads it to the
  # release of GitHub, which the job below has created already.
  #
  # The version of the asset of an application is the version of the
  # application, which is the version of the tag of the application,
  # `bat-v0.5.0`. CoCoGitto reads the tags of the monorepo, so it knows the
  # version of every application, and the version of the repository is the
  # fallback of the applications that have no tag of their own yet.
  mkJob =
    {
      title,
      app,
      asset,
      steps ? [ ],
      package,
      publish ? [ ],
      ...
    }:
    {
      name = "${title}: Package";
      needs = [ "create-release" ];
      runs-on = "ubuntu-latest";
      steps = [
        # The whole history of the repository, with every tag: CoCoGitto
        # walks the history from HEAD to find the tags of the applications.
        common.checkoutFull

        # CoCoGitto, which reads the version of the application.
        {
          name = "Install CoCoGitto";
          uses = common.actions.cocogitto;
          "with" = {
            "install-only" = true;
          };
        }
        {
          name = "Read the version of the application";
          id = "version";
          run = ''
            version=$(cog get-version --package ${app} -f "$(cog get-version |& tail -1)" |& tail -1)

            if [ -z "$version" ]; then
              echo "The version of ${app} is empty" >&2
              exit 1
            fi

            echo "version=$version" >>"$GITHUB_OUTPUT"
          '';
        }
      ]
      ++ steps
      ++ [
        {
          name = "Package the theme";
          env = {
            VERSION = "\${{ steps.version.outputs.version }}";
          };
          run = package;
        }
        {
          name = "Upload the asset to the release";
          env = {
            GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
            TAG = tagExpr;
            VERSION = "\${{ steps.version.outputs.version }}";
          };
          run = ''
            gh release upload "$TAG" "${asset}" --clobber
          '';
        }
      ]
      ++ publish;
    };

  # The release of GitHub. It is created here, once, before the applications
  # upload their assets to it, so that the applications never create it
  # themselves and never race for it.
  #
  # The body of the release is the section of the changelog of the
  # repository that belongs to the version of the release. The changelog is
  # written by the release itself, into the repository.
  createRelease = {
    name = "Create the release";
    needs = [
      "conventional"
      "checks"
    ];
    runs-on = "ubuntu-latest";
    steps = [
      common.checkout
      {
        name = "Collect the notes of the release";
        env = {
          TAG = tagExpr;
        };
        run = ''
          version="''${TAG#v}"

          # The section of the changelog that belongs to the version of the
          # release. It ends at the separator of the next one.
          awk -v heading="## [v$version](" '
            index($0, heading) == 1 { inside = 1; print; next }
            inside && /^## / { exit }
            inside && /^- - -$/ { exit }
            inside { print }
          ' CHANGELOG.md >notes.md

          if [ ! -s notes.md ]; then
            echo "There is no changelog for $version" >&2
            exit 1
          fi
        '';
      }
      {
        name = "Create the release";
        env = {
          GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
          TAG = tagExpr;
        };
        run = ''
          version="''${TAG#v}"

          if gh release view "$TAG" >/dev/null 2>&1; then
            echo "The release $TAG exists already."
            gh release edit "$TAG" --notes-file notes.md
          else
            gh release create "$TAG" --draft \
              --title "Blueforest $version" --notes-file notes.md
          fi
        '';
      }
    ];
  };
in
{
  name = "Release";
  on.push.tags = [ "v*" ];
  jobs = {
    # The commits of the release have to follow the conventional commits
    # specification, the same way the commits of a pull request do.
    #
    # The release is made by CoCoGitto, which writes the commits of the
    # release itself, so the check is about the commits that went into it.
    conventional = {
      name = "Conventional commits";
      runs-on = "ubuntu-latest";
      steps = [
        # The whole history of the repository, with every tag: the range of
        # the commits of the release starts at the tag of the release before
        # this one.
        common.checkoutFull
        {
          name = "Read the release before this one";
          id = "previous";
          run = ''
            # The release of the repository before this one. The tag of this
            # release is on HEAD, so it is not one of them.
            previous=$(git tag --list 'v*' --sort=-version:refname \
              | grep -E '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' \
              | grep -v -x "$GITHUB_REF_NAME" \
              | head -n1 || true)

            if [ -n "$previous" ]; then
              echo "range=$previous..HEAD" >>"$GITHUB_OUTPUT"
            else
              echo "range=.." >>"$GITHUB_OUTPUT"
            fi
          '';
        }
        {
          name = "Check the commits of the release";
          uses = common.actions.cocogitto;
          "with" = {
            command = "check";
            args = "--ignore-merge-commits \${{ steps.previous.outputs.range }}";
          };
        }
      ];
    };

    # The repository is checked before the release is created, so that a
    # broken tag does not leave a release behind.
    #
    # The root flake checks every application at once, because it composes
    # the module of every one of them.
    #
    # The flake is checked from the working tree, and not from the git tree,
    # so that the sources of the release are the ones that are checked.
    checks = {
      name = "Checks";
      runs-on = "ubuntu-latest";
      steps = [
        common.checkout
        common.installNix
        {
          name = "Run flake checks";

          # The root flake checks every application at once, because it
          # composes the module of every one of them.
          #
          # The flake is checked from the working tree, and not from the git
          # tree, so that the sources of the release are the ones that are
          # checked.
          run = "nix flake check \"path:.\"";
        }
      ];
    };

    # The release of GitHub, with the notes of the release.
    create-release = createRelease;

    # The release is published when every application is done, so that it
    # never carries half of its assets.
    publish-release = {
      name = "Publish the release";
      needs = map (definition: definition.app) applications;
      runs-on = "ubuntu-latest";
      steps = [
        {
          name = "Publish the release";
          env = {
            GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
            TAG = tagExpr;
          };
          run = "gh release edit \"$TAG\" --draft=false";
        }
      ];
    };

    # The documentation site is deployed once the release is published, so
    # that the site of a release is the site of the code the release carries.
    docs = {
      name = "Documentation";
      needs = [ "publish-release" ];
      uses = "./.github/workflows/docs.yml";
      permissions = {
        contents = "read";
        pages = "write";
        "id-token" = "write";
      };
    };
  }
  # The applications, one job each, and the release they upload their
  # assets to.
  // mapAttrs' (app: definition: nameValuePair app (mkJob definition)) applicationsByApp;
}
