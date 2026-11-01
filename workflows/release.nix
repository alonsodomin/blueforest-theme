# SPDX-License-Identifier: MPL-2.0
#
# The workflow that releases the applications of the repository.
#
# A release of the repository is a tag of the form vMAJOR.MINOR.PATCH, and it
# releases every application of the repository at once, into one GitHub
# release.
#
# The workflow runs on the push of such a tag. It reads the version of the
# tag, checks the repository, creates the release of GitHub with the
# changelog of the version, and then lets every application package itself
# and upload its asset to that release. The release is published when every
# application is done, so that it never carries half of its assets.
{
  lib,
}:
let
  common = import ./lib.nix;

  inherit (lib) listToAttrs mapAttrs' nameValuePair;

  # The version of the release, as the expression that reads it.
  versionExpr = "\${{ needs.version.outputs.version }}";

  # The tag of the release.
  tagExpr = "v${versionExpr}";

  # The applications of the repository, and the way each one of them is
  # packaged. The asset of an application is the file it uploads to the
  # release of GitHub.
  applications = [
    {
      app = "vscode";
      title = "VS Code";
      asset = "dist/blueforest-theme-$VERSION.vsix";
      steps = [
        {
          uses = common.actions.setupNode;
          "with".node-version = 24;
        }
      ];
      package = ''
        mkdir -p dist
        cd modules/vscode
        jq --indent 2 --arg version "$VERSION" '.version = $version' \
          package.json >package.json.tmp
        mv package.json.tmp package.json

        # The manifest has to carry the version of the release before the
        # archive is built: vsce packages a manifest that still carries the
        # placeholder without complaining about it.
        if ! jq -e --arg version "$VERSION" \
          '.version == $version and $version != ""' package.json >/dev/null; then
          echo "the manifest does not carry the version $VERSION" >&2
          exit 1
        fi

        npx --yes @vscode/vsce package --no-dependencies \
          --out "../../dist/blueforest-theme-$VERSION.vsix"
      '';
      # The extension is published to the marketplaces as well.
      publish = [
        {
          name = "Publish to Open VSX";
          env = {
            OVSX_PAT = "\${{ secrets.OVSX_PAT }}";
          };
          run = "npx --yes ovsx publish \"dist/blueforest-theme-$VERSION.vsix\" -p \"$OVSX_PAT\"";
        }
        {
          name = "Publish to the VS Marketplace";
          env = {
            VSCE_PAT = "\${{ secrets.VSCE_PAT }}";
          };
          run = "npx --yes @vscode/vsce publish --packagePath \"dist/blueforest-theme-$VERSION.vsix\" -p \"$VSCE_PAT\"";
        }
      ];
    }
    {
      app = "bat";
      title = "bat";
      asset = "dist/blueforest-bat-theme-$VERSION.tmTheme";
      package = ''
        mkdir -p dist
        cp modules/bat/themes/BlueForest.tmTheme \
          "dist/blueforest-bat-theme-$VERSION.tmTheme"
      '';
    }
    {
      app = "starship";
      title = "Starship";
      asset = "dist/blueforest-starship-preset-$VERSION.toml";
      package = ''
        mkdir -p dist
        cp modules/starship/themes/blueforest.toml \
          "dist/blueforest-starship-preset-$VERSION.toml"
      '';
    }
    {
      app = "opencode";
      title = "OpenCode";
      asset = "dist/blueforest-opencode-theme-$VERSION.json";
      package = ''
        mkdir -p dist
        cp modules/opencode/themes/blueforest.json \
          "dist/blueforest-opencode-theme-$VERSION.json"
      '';
    }
    {
      app = "neovim";
      title = "Neovim";
      asset = "dist/blueforest-neovim-theme-$VERSION.tar.gz";
      package = ''
        mkdir -p dist staging/colors staging/lua/lualine/themes
        cp modules/neovim/themes/blueforest.lua staging/colors/blueforest.lua
        cp modules/neovim/themes/lualine-blueforest.lua \
          staging/lua/lualine/themes/blueforest.lua
        tar -czf "dist/blueforest-neovim-theme-$VERSION.tar.gz" -C staging .
      '';
    }
    {
      app = "sbt";
      title = "sbt";
      asset = "dist/blueforest-sbt-prompt-$VERSION.tar.gz";
      package = ''
        mkdir -p dist staging/plugins
        cp modules/sbt/config/sbt-prompt.sbt staging/plugins/sbt-prompt.sbt
        cp modules/sbt/config/blueforest-prompt.sbt staging/blueforest-prompt.sbt
        tar -czf "dist/blueforest-sbt-prompt-$VERSION.tar.gz" -C staging .
      '';
    }
    {
      app = "eza";
      title = "eza";
      asset = "dist/blueforest-eza-theme-$VERSION.yml";
      package = ''
        mkdir -p dist
        cp modules/eza/themes/blueforest.yml \
          "dist/blueforest-eza-theme-$VERSION.yml"
      '';
    }
    {
      app = "zed";
      title = "Zed";
      asset = "dist/blueforest-zed-theme-$VERSION.tar.gz";
      package = ''
        mkdir -p dist staging/themes
        cp modules/zed/extension/extension.toml staging/extension.toml
        cp modules/zed/extension/themes/blueforest.json \
          staging/themes/blueforest.json
        tar -czf "dist/blueforest-zed-theme-$VERSION.tar.gz" -C staging .
      '';
    }
    {
      app = "yazi";
      title = "Yazi";
      asset = "dist/blueforest-yazi-theme-$VERSION.tar.gz";
      package = ''
        mkdir -p dist staging
        cp -r modules/yazi/themes/blueforest.yazi \
          "staging/blueforest.yazi"
        tar -czf "dist/blueforest-yazi-theme-$VERSION.tar.gz" -C staging .
      '';
    }
  ];

  applicationsByApp = listToAttrs (
    map (definition: {
      name = definition.app;
      value = definition;
    }) applications
  );

  # The job of one application: it packages the theme and uploads it to the
  # release of GitHub, which the job below has created already.
  mkJob =
    {
      title,
      asset,
      steps ? [ ],
      package,
      publish ? [ ],
      ...
    }:
    {
      name = "${title}: Package";
      needs = [
        "version"
        "create-release"
      ];
      runs-on = "ubuntu-latest";
      steps = [
        common.checkout
      ]
      ++ steps
      ++ [
        {
          name = "Package the theme";
          env = {
            VERSION = versionExpr;
          };
          run = package;
        }
        {
          name = "Upload the asset to the release";
          env = {
            GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
            TAG = tagExpr;
            VERSION = versionExpr;
          };
          run = "gh release upload \"$TAG\" \"${asset}\" --clobber";
        }
      ]
      ++ publish;
    };

  # The release of GitHub. It is created here, once, before the applications
  # upload their assets to it, so that the applications never create it
  # themselves and never race for it.
  createRelease = {
    name = "Create the release";
    needs = [
      "version"
      "checks"
    ];
    runs-on = "ubuntu-latest";
    steps = [
      common.checkout
      {
        name = "Collect the changelog";
        env = {
          VERSION = versionExpr;
        };
        run = ''
          version="$VERSION"

          # The body of the section of a changelog that belongs to the
          # version of the release.
          extract() {
            awk -v heading="## $version - [" '
              index($0, heading) == 1 { inside = 1; next }
              inside && /^## / { exit }
              inside && !started && $0 ~ /^[[:space:]]*$/ { next }
              inside { started = 1; print }
            ' "$1"
          }

          {
            printf '## Blueforest %s\n\n' "$version"
          } >notes.md

          found=0

          body=$(extract CHANGELOG.md)
          if [ -n "$body" ]; then
            printf '%s\n\n' "$body" >>notes.md
            found=1
          fi

          for file in modules/*/CHANGELOG.md; do
            body=$(extract "$file")
            if [ -z "$body" ]; then
              continue
            fi
            app=$(basename "$(dirname "$file")")
            printf '### %s\n\n%s\n\n' "$app" "$body" >>notes.md
            found=1
          done

          if [ "$found" != "1" ]; then
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
          VERSION = versionExpr;
        };
        run = ''
          if gh release view "$TAG" >/dev/null 2>&1; then
            echo "The release $TAG exists already."
            gh release edit "$TAG" --notes-file notes.md
          else
            gh release create "$TAG" --draft \
              --title "Blueforest $VERSION" --notes-file notes.md
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
    # The version of the release, which is the version of the tag.
    version = {
      name = "Version";
      runs-on = "ubuntu-latest";
      outputs.version = "\${{ steps.version.outputs.version }}";
      steps = [
        {
          id = "version";
          name = "Read the tag";
          run = ''
            tag="$GITHUB_REF_NAME"
            if [[ ! "$tag" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
              echo "The tag of a release is vMAJOR.MINOR.PATCH, not: $tag" >&2
              exit 1
            fi
            echo "version=''${tag#v}" >>"$GITHUB_OUTPUT"
          '';
        }
      ];
    };

    # The repository is checked before the release is created, so that a
    # broken tag does not leave a release behind.
    #
    # The flakes are checked from the working tree, and not from the git
    # tree: the extension of Zed is a submodule of the repository, and Nix
    # cannot read the contents of a submodule of a git tree. The checkout of
    # the workflow brings the submodules with it.
    checks = {
      name = "Checks (\${{ matrix.flake }})";
      runs-on = "ubuntu-latest";
      strategy = {
        fail-fast = false;
        matrix.flake = [
          "path:."
        ]
        ++ map (application: "path:./modules/${application}") common.applications;
      };
      steps = [
        common.checkout
        common.installNix
        {
          name = "Run flake checks";
          run = "nix flake check \${{ matrix.flake }}";
        }
      ];
    };

    # The release of GitHub, with the changelog of the version.
    create-release = createRelease;

    # The release is published when every application is done, so that it
    # never carries half of its assets.
    publish-release = {
      name = "Publish the release";
      needs = [ "version" ] ++ (map (definition: definition.app) applications);
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
        id-token = "write";
      };
    };
  }
  # The applications, one job each, and the release they upload their
  # assets to.
  // mapAttrs' (app: definition: nameValuePair app (mkJob definition)) applicationsByApp;
}
