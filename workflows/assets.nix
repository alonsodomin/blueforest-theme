# SPDX-License-Identifier: MPL-2.0
#
# The packaging of the applications of the repository.
#
# The release workflow packages every application and uploads its asset to the
# release of GitHub. The definitions of the packaging are here, and not in the
# workflow itself, so that the check of the repository can package the
# applications as well, and look at what they produce.
#
# The asset of an application is the file it uploads to the release of
# GitHub. The packaging of an application reads the themes of the repository,
# so it runs at the root of it.
let
  common = import ./lib.nix;
in
[
  {
    app = "vscode";
    title = "VS Code";
    assets = [ "dist/blueforest-theme-$VERSION.vsix" ];
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
    assets = [
      "dist/blueforest-bat-theme-$VERSION.tmTheme"
      "dist/blueforest-bat-theme-light-$VERSION.tmTheme"
    ];
    package = ''
      mkdir -p dist
      cp modules/bat/themes/BlueForest.tmTheme \
        "dist/blueforest-bat-theme-$VERSION.tmTheme"
      cp modules/bat/themes/BlueForestLight.tmTheme \
        "dist/blueforest-bat-theme-light-$VERSION.tmTheme"
    '';
  }
  {
    app = "starship";
    title = "Starship";
    assets = [ "dist/blueforest-starship-preset-$VERSION.toml" ];
    package = ''
      mkdir -p dist
      cp modules/starship/themes/blueforest.toml \
        "dist/blueforest-starship-preset-$VERSION.toml"
    '';
  }
  {
    app = "opencode";
    title = "OpenCode";
    assets = [ "dist/blueforest-opencode-theme-$VERSION.json" ];
    package = ''
      mkdir -p dist
      cp modules/opencode/themes/blueforest.json \
        "dist/blueforest-opencode-theme-$VERSION.json"
    '';
  }
  {
    app = "neovim";
    title = "Neovim";
    assets = [ "dist/blueforest-neovim-theme-$VERSION.tar.gz" ];
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
    assets = [ "dist/blueforest-sbt-prompt-$VERSION.tar.gz" ];
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
    assets = [ "dist/blueforest-eza-theme-$VERSION.yml" ];
    package = ''
      mkdir -p dist
      cp modules/eza/themes/blueforest.yml \
        "dist/blueforest-eza-theme-$VERSION.yml"
    '';
  }
  {
    app = "zed";
    title = "Zed";
    assets = [ "dist/blueforest-zed-theme-$VERSION.tar.gz" ];
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
    assets = [ "dist/blueforest-yazi-theme-$VERSION.tar.gz" ];
    package = ''
      mkdir -p dist staging
      cp -r modules/yazi/themes/blueforest.yazi \
        "staging/blueforest.yazi"
      cp -r modules/yazi/themes/blueforest-light.yazi \
        "staging/blueforest-light.yazi"

      # The colours of the code preview are the ones of the theme of bat, so
      # the asset carries it. The asset is unpacked by hand, so it cannot
      # carry a link to the store: it carries the theme itself. Every flavour
      # carries the variant of the theme of bat that matches it.
      cp modules/bat/themes/BlueForest.tmTheme \
        "staging/blueforest.yazi/tmtheme.xml"
      cp modules/bat/themes/BlueForestLight.tmTheme \
        "staging/blueforest-light.yazi/tmtheme.xml"

      tar -czf "dist/blueforest-yazi-theme-$VERSION.tar.gz" -C staging .
    '';
  }
  {
    app = "kitty";
    title = "kitty";
    assets = [ "dist/blueforest-kitty-theme-$VERSION.conf" ];
    package = ''
      mkdir -p dist
      cp modules/kitty/themes/blueforest.conf \
        "dist/blueforest-kitty-theme-$VERSION.conf"
    '';
  }
  {
    app = "mkdocs";
    title = "MkDocs";
    assets = [ "dist/blueforest-mkdocs-theme-$VERSION.css" ];
    package = ''
      mkdir -p dist
      cp modules/mkdocs/themes/blueforest.css \
        "dist/blueforest-mkdocs-theme-$VERSION.css"
    '';
  }
  {
    app = "claude-code";
    title = "Claude Code";
    assets = [
      "dist/blueforest-claude-code-theme-$VERSION.json"
      "dist/blueforest-claude-code-theme-light-$VERSION.json"
    ];
    package = ''
      mkdir -p dist
      cp modules/claude-code/themes/blueforest.json \
        "dist/blueforest-claude-code-theme-$VERSION.json"
      cp modules/claude-code/themes/blueforest-light.json \
        "dist/blueforest-claude-code-theme-light-$VERSION.json"
    '';
  }
  {
    app = "btop";
    title = "btop";
    assets = [ "dist/blueforest-btop-theme-$VERSION.theme" ];
    package = ''
      mkdir -p dist
      cp modules/btop/themes/blueforest.theme \
        "dist/blueforest-btop-theme-$VERSION.theme"
    '';
  }
  {
    app = "lazygit";
    title = "lazygit";
    assets = [ "dist/blueforest-lazygit-theme-$VERSION.json" ];
    package = ''
      mkdir -p dist
      cp modules/lazygit/themes/blueforest.json \
        "dist/blueforest-lazygit-theme-$VERSION.json"
    '';
  }
  {
    app = "md-tui";
    title = "md-tui";
    assets = [
      "dist/blueforest-md-tui-theme-$VERSION.json"
      "dist/blueforest-md-tui-theme-light-$VERSION.json"
    ];
    package = ''
      mkdir -p dist
      cp modules/md-tui/themes/blueforest.json \
        "dist/blueforest-md-tui-theme-$VERSION.json"
      cp modules/md-tui/themes/blueforest-light.json \
        "dist/blueforest-md-tui-theme-light-$VERSION.json"
    '';
  }
  {
    app = "noctalia";
    title = "Noctalia";
    assets = [ "dist/blueforest-noctalia-theme-$VERSION.json" ];
    package = ''
      mkdir -p dist
      cp modules/noctalia/themes/blueforest.json \
        "dist/blueforest-noctalia-theme-$VERSION.json"
    '';
  }
]
