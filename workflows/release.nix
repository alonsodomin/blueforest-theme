# SPDX-License-Identifier: MPL-2.0
#
# The workflow that releases the applications of the repository.
{
  lib,
}:
let
  common = import ./lib.nix;

  inherit (lib)
    foldl'
    listToAttrs
    mapAttrs'
    nameValuePair
    optional
    optionalAttrs
    ;

  # The version of the package job, as the expression that reads it.
  versionExpr = "\${{ steps.setup.outputs.version }}";

  # The applications that the repository releases, and the details that are
  # specific to each one of them.
  applications = [
    {
      app = "vscode";
      title = "VS Code";
      dispatch = "publishVSCode";
      dispatchDefault = true;

      # The extension takes its version from its manifest, not from a VERSION
      # file.
      versionCommand = "jq -r .version ./modules/vscode/package.json";

      setupSteps = [
        {
          uses = common.actions.setupNode;
          "with".node-version = 24;
        }
        {
          name = "Install dependencies";
          working-directory = "modules/vscode";
          run = "npm i";
        }
        {
          name = "Setup package path";
          id = "package-name";
          working-directory = "modules/vscode";
          run = "echo \"packageName=$(node -e \"console.log(require('./package.json').name + '-' + require('./package.json').version + '.vsix')\")\" >> \"$GITHUB_OUTPUT\"";
        }
      ];

      # The extension names its package after its manifest, so the name of the
      # package travels to the other jobs in the output of the package job.
      packageName = "\${{ steps.package-name.outputs.packageName }}";
      publishesPackageName = true;
      uploadPath = name: "./modules/vscode/${name}";
      assets = name: "./${name}";
      package = "npx @vscode/vsce package --out \${{ steps.package-name.outputs.packageName }}";

      # The extension is published to the marketplaces as well.
      publish = prefix: {
        OVSX = {
          name = "Publish to Open VSX";
          "if" =
            "needs.${prefix}-check.result == 'success' && needs.${prefix}-package.result == 'success' && inputs.publishOVSX != false";
          run = "npx ovsx publish ./\${{ needs.${prefix}-package.outputs.packageName }} -p \${{ secrets.OVSX_PAT }}";
        };
        MS = {
          name = "Publish to VS marketplace";
          "if" =
            "!cancelled() && needs.${prefix}-check.result == 'success' && needs.${prefix}-package.result == 'success' && (needs.${prefix}-publishOVSX.result == 'success' || needs.${prefix}-publishOVSX.result == 'skipped') && inputs.publishMS != false";
          run = "npx @vscode/vsce publish --packagePath ./\${{ needs.${prefix}-package.outputs.packageName }} -p \${{ secrets.VSCE_PAT }}";
        };
      };
    }
    {
      app = "bat";
      title = "bat";
      dispatch = "publishBat";
      packageName = "blueforest-bat-theme";
      package = "cp modules/bat/themes/BlueForest.tmTheme ./blueforest-bat-theme-${versionExpr}.tmTheme";
    }
    {
      app = "starship";
      title = "Starship";
      dispatch = "publishStarship";
      packageName = "blueforest-starship-preset";
      package = "cp modules/starship/themes/blueforest.toml ./blueforest-starship-preset-${versionExpr}.toml";
    }
    {
      app = "opencode";
      title = "OpenCode";
      dispatch = "publishOpencode";
      packageName = "blueforest-opencode-theme";
      package = "cp modules/opencode/themes/blueforest.json ./blueforest-opencode-theme-${versionExpr}.json";
    }
    {
      app = "neovim";
      title = "Neovim";
      dispatch = "publishNeovim";
      packageName = "blueforest-neovim-theme";

      # The theme is a plugin: the colourscheme goes into the `colors`
      # directory, and the theme of lualine into the `lua/lualine/themes` one,
      # which are where Neovim and lualine read them from.
      package = ''
        mkdir -p ./blueforest-neovim-theme-${versionExpr}/colors
        mkdir -p ./blueforest-neovim-theme-${versionExpr}/lua/lualine/themes
        cp modules/neovim/themes/blueforest.lua \
          ./blueforest-neovim-theme-${versionExpr}/colors/blueforest.lua
        cp modules/neovim/themes/lualine-blueforest.lua \
          ./blueforest-neovim-theme-${versionExpr}/lua/lualine/themes/blueforest.lua
        tar -czf ./blueforest-neovim-theme-${versionExpr}.tar.gz \
          ./blueforest-neovim-theme-${versionExpr}
      '';
    }
  ];

  applicationsByApp = listToAttrs (
    map (definition: {
      name = definition.app;
      value = definition;
    }) applications
  );

  # The jobs of one application.
  mkJobs =
    {
      app,
      title,
      dispatch,
      versionCommand ? "cat modules/${app}/VERSION",
      setupSteps ? [ ],
      packageName,
      publishesPackageName ? false,
      uploadPath ? name: "./${name}-*",
      assets ? name: "./${name}-*",
      package,
      publish ? _: { },
      publishGHIf ? "github.event_name == 'release' || inputs.publishGH == true",
      ...
    }:
    let
      checkJob = "${app}-check";
      packageJob = "${app}-package";

      # The name of the package, as the jobs that consume the artifact see it.
      publishedName =
        if publishesPackageName then "\${{ needs.${packageJob}.outputs.packageName }}" else packageName;
    in
    {
      ${checkJob} = (common.checkFlake "./modules/${app}") // {
        name = "${title}: Check";

        # A GitHub release only releases the application its tag belongs to.
        "if" = "inputs.${dispatch} == true || startsWith(github.event.release.tag_name || '', '${app}/')";
      };

      ${packageJob} = {
        name = "${title}: Package";
        needs = [ checkJob ];
        runs-on = "ubuntu-latest";
        outputs = {
          tag = "\${{ steps.setup.outputs.tag }}";
          version = "\${{ steps.setup.outputs.version }}";
        }
        // optionalAttrs publishesPackageName { packageName = packageName; };
        steps = [
          common.checkout
        ]
        ++ setupSteps
        ++ [
          {
            name = "Setup";
            id = "setup";
            run = ''
              version=$(${versionCommand})
              echo "tag: ${app}/$version"
              echo "tag=${app}/$version" >> "$GITHUB_OUTPUT"
              echo "version=$version" >> "$GITHUB_OUTPUT"
            '';
          }
          {
            name = "Package the theme";
            run = package;
          }
          {
            uses = common.actions.uploadArtifact;
            "with" = {
              name = packageName;
              path = uploadPath packageName;
              "if-no-files-found" = "error";
            };
          }
        ];
      };

      "${app}-publishGH" = {
        name = "${title}: Publish to GitHub releases";
        needs = [
          checkJob
          packageJob
        ];

        # An explicit condition replaces the implicit one, so the results of
        # the jobs it needs are part of it. A GitHub release publishes the
        # application its tag belongs to, and a manual trigger does it when
        # the input says so.
        "if" =
          "needs.${checkJob}.result == 'success' && needs.${packageJob}.result == 'success' && (${publishGHIf})";
        runs-on = "ubuntu-latest";
        steps = [
          common.checkout
          {
            uses = common.actions.downloadArtifact;
            "with".name = publishedName;
          }

          # The release may already exist, for example when it was published
          # by hand to release the theme. Only the assets are added in that
          # case.
          {
            name = "Create Release";
            env = {
              GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
              TAG = "\${{ needs.${packageJob}.outputs.tag }}";
              VERSION = "\${{ needs.${packageJob}.outputs.version }}";
            };
            run = ''
              if gh release view "$TAG" >/dev/null 2>&1; then
                echo "The release $TAG exists already."
              else
                gh release create "$TAG" --title "Release $VERSION" --generate-notes
              fi
            '';
          }
          {
            name = "Upload assets to a Release";
            env = {
              GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
              TAG = "\${{ needs.${packageJob}.outputs.tag }}";
            };
            run = "gh release upload \"$TAG\" ${assets publishedName} --clobber";
          }
        ];
      };
    }
    // mapAttrs' (
      kind: definition:
      nameValuePair "${app}-publish${kind}" {
        name = "${title}: ${definition.name}";
        needs = [
          checkJob
          packageJob
        ]
        ++ optional (kind == "MS") "${app}-publishOVSX";
        "if" = definition."if";
        runs-on = "ubuntu-latest";
        steps = [
          common.checkout
          {
            uses = common.actions.downloadArtifact;
            "with".name = publishedName;
          }
          {
            name = definition.name;
            run = definition.run;
          }
        ];
      }
    ) (publish app);
in
{
  name = "Release";
  on = {
    release.types = [ "published" ];
    workflow_dispatch.inputs =
      mapAttrs' (
        app: definition:
        nameValuePair definition.dispatch {
          description = "Publish the ${definition.title} theme";
          type = "boolean";
          required = true;
          default = definition.dispatchDefault or false;
        }
      ) applicationsByApp
      // {
        publishMS = {
          description = "Publish to the Microsoft Marketplace";
          type = "boolean";
          required = true;
          default = true;
        };
        publishOVSX = {
          description = "Publish to Open VSX";
          type = "boolean";
          required = true;
          default = true;
        };
        publishGH = {
          description = "Publish to GitHub Releases";
          type = "boolean";
          required = true;
          default = true;
        };
      };
  };
  jobs = foldl' (jobs: definition: jobs // mkJobs definition) { } applications;
}
