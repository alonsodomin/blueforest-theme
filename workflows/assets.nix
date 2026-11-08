# SPDX-License-Identifier: MPL-2.0
#
# The packaging of the applications of the repository.
#
# The release workflow packages every application and uploads its asset to
# the release of GitHub. The definitions of the packaging are here, and not
# in the workflow itself, so that the check of the repository can package
# the applications as well, and look at what they produce.
#
# The asset of an application is the file it uploads to the release of
# GitHub: the archive of the theme, with the variants of the theme and the
# changelog of the release.
#
# The archive holds the variants of the theme in a directory per variant,
# `dark` and `light`, and the changelog of the release in `CHANGELOG.txt`.
# The applications that read their theme from a directory of their own keep
# that layout, because the files of the archive are installed where the
# application reads them from.
#
# The packaging of an application reads the themes of the repository, so it
# runs at the root of it.
{
  lib,
}:
let
  common = import ./lib.nix;

  # The script that copies a file of a theme into the staging directory of
  # the archive.
  #
  # A directory is copied as a whole, and a file is copied into the
  # directory of its path.
  mkCopy = file: ''
    mkdir -p "staging/${builtins.dirOf file.dst}"
    ${if file.directory or false then "cp -r" else "cp"} "${file.src}" "staging/${file.dst}"
  '';

  # The packaging of an application whose theme is packed into an archive.
  #
  # The archive carries the variants of the theme and the changelog of the
  # application, which the release writes into the repository.
  #
  # The archive holds the files under their own names, and not under the
  # "./" of the staging directory, so that a file of the archive can be
  # unpacked on its own.
  mkPackage = application: ''
    rm -rf staging
    mkdir -p dist staging
    ${lib.concatMapStringsSep "\n" mkCopy application.files}

    # The changelog of the application, when it has one.
    if [ -f "modules/${application.app}/CHANGELOG.md" ]; then
      cp "modules/${application.app}/CHANGELOG.md" "staging/CHANGELOG.txt"
    fi

    tar -czf "dist/blueforest-${application.app}-theme-$VERSION.tar.gz" \
      -C staging --files-from <(ls -A staging)
  '';

  applications = [
    {
      app = "vscode";
      title = "VS Code";

      # The extension is the asset of the application: the marketplaces take
      # it, and it carries the variants of the theme.
      asset = "dist/blueforest-theme-$VERSION.vsix";
      files = [ ];

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
      files = [
        {
          src = "modules/bat/themes/BlueForest.tmTheme";
          dst = "dark/BlueForest.tmTheme";
        }
        {
          src = "modules/bat/themes/BlueForestLight.tmTheme";
          dst = "light/BlueForestLight.tmTheme";
        }
      ];
    }
    {
      app = "starship";
      title = "Starship";
      files = [
        {
          src = "modules/starship/themes/blueforest.toml";
          dst = "blueforest.toml";
        }
        {
          src = "modules/starship/themes/palettes/blueforest.toml";
          dst = "dark/blueforest.toml";
        }
        {
          src = "modules/starship/themes/palettes/blueforest-light.toml";
          dst = "light/blueforest-light.toml";
        }
      ];
    }
    {
      app = "opencode";
      title = "OpenCode";
      files = [
        {
          src = "modules/opencode/themes/blueforest.json";
          dst = "blueforest.json";
        }
      ];
    }
    {
      app = "neovim";
      title = "Neovim";
      files = [
        {
          src = "modules/neovim/themes/blueforest.lua";
          dst = "colors/blueforest.lua";
        }
        {
          src = "modules/neovim/themes/lualine-blueforest.lua";
          dst = "lua/lualine/themes/blueforest.lua";
        }
        {
          src = "modules/neovim/themes/blueforest-light.lua";
          dst = "colors/blueforest-light.lua";
        }
        {
          src = "modules/neovim/themes/lualine-blueforest-light.lua";
          dst = "lua/lualine/themes/blueforest-light.lua";
        }
      ];
    }
    {
      app = "sbt";
      title = "sbt";
      files = [
        {
          src = "modules/sbt/config/sbt-prompt.sbt";
          dst = "plugins/sbt-prompt.sbt";
        }
        {
          src = "modules/sbt/config/blueforest-prompt.sbt";
          dst = "blueforest-prompt.sbt";
        }
      ];
    }
    {
      app = "eza";
      title = "eza";
      files = [
        {
          src = "modules/eza/themes/blueforest.yml";
          dst = "dark/blueforest.yml";
        }
      ];
    }
    {
      app = "zed";
      title = "Zed";

      # The extension of Zed is a repository of its own, and it is pinned by
      # the lock file of the repository. The release fetches it at the
      # revision the lock file pins, and the archive carries the manifest of
      # the extension and the theme it declares.
      files = [
        {
          src = "extension/extension.toml";
          dst = "extension.toml";
        }
        {
          src = "extension/themes/blueforest.json";
          dst = "themes/blueforest.json";
        }
      ];

      steps = [
        {
          name = "Fetch the extension of Zed";
          run = ''
            rev=$(jq -r '.nodes."zed-extension".locked.rev' flake.lock)
            if [ -z "$rev" ] || [ "$rev" = "null" ]; then
              echo "the lock file does not pin the extension of Zed" >&2
              exit 1
            fi

            mkdir -p extension
            curl -fsSL "https://github.com/alonsodomin/zed-blueforest-theme/archive/$rev.tar.gz" \
              | tar -xz --strip-components=1 -C extension
          '';
        }
      ];
    }
    {
      app = "yazi";
      title = "Yazi";
      files = [
        {
          src = "modules/yazi/themes/blueforest.yazi";
          dst = "blueforest.yazi";
          directory = true;
        }
        {
          src = "modules/yazi/themes/blueforest-light.yazi";
          dst = "blueforest-light.yazi";
          directory = true;
        }

        # The colours of the code preview are the ones of the theme of bat,
        # so the archive carries it. The archive is unpacked by hand, so it
        # cannot carry a link to the store: it carries the theme itself.
        # Every flavour carries the variant of the theme of bat that matches
        # it.
        {
          src = "modules/bat/themes/BlueForest.tmTheme";
          dst = "blueforest.yazi/tmtheme.xml";
        }
        {
          src = "modules/bat/themes/BlueForestLight.tmTheme";
          dst = "blueforest-light.yazi/tmtheme.xml";
        }
      ];
    }
    {
      app = "kitty";
      title = "kitty";
      files = [
        {
          src = "modules/kitty/themes/blueforest.conf";
          dst = "dark/blueforest.conf";
        }
        {
          src = "modules/kitty/themes/blueforest-light.conf";
          dst = "light/blueforest-light.conf";
        }
      ];
    }
    {
      app = "mkdocs";
      title = "MkDocs";
      files = [
        {
          src = "modules/mkdocs/themes/blueforest.css";
          dst = "blueforest.css";
        }
      ];
    }
    {
      app = "claude-code";
      title = "Claude Code";
      files = [
        {
          src = "modules/claude-code/themes/blueforest.json";
          dst = "dark/blueforest.json";
        }
        {
          src = "modules/claude-code/themes/blueforest-light.json";
          dst = "light/blueforest-light.json";
        }
      ];
    }
    {
      app = "btop";
      title = "btop";
      files = [
        {
          src = "modules/btop/themes/blueforest.theme";
          dst = "dark/blueforest.theme";
        }
      ];
    }
    {
      app = "lazygit";
      title = "lazygit";
      files = [
        {
          src = "modules/lazygit/themes/blueforest.json";
          dst = "dark/blueforest.json";
        }
      ];
    }
    {
      app = "md-tui";
      title = "md-tui";
      files = [
        {
          src = "modules/md-tui/themes/blueforest.json";
          dst = "dark/blueforest.json";
        }
        {
          src = "modules/md-tui/themes/blueforest-light.json";
          dst = "light/blueforest-light.json";
        }
      ];
    }
    {
      app = "noctalia";
      title = "Noctalia";
      files = [
        {
          src = "modules/noctalia/themes/blueforest.json";
          dst = "blueforest.json";
        }
      ];
    }
  ];
in
lib.map (
  application:
  if application ? asset then
    application
  else
    application
    // {
      asset = "dist/blueforest-${application.app}-theme-$VERSION.tar.gz";
      package = mkPackage application;
    }
) applications
