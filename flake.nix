# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest themes for many tools";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mkdocs-flake = {
      url = "github:applicative-systems/mkdocs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The module that turns the definitions of the workflows into the files
    # of `.github/workflows/`.
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim, for the check that reads the theme of Neovim. The repository
    # owns the pin of it, so that the check of the application is not at the
    # mercy of the release cycle of nixvim.
    nixvim.url = "github:nix-community/nixvim";

    # The applications of the repository. Every one of them is a flake of
    # its own, and the root flake composes the module it publishes.
    #
    # Adding an application is a matter of adding a directory and a line
    # here.
    vscode = {
      url = "path:./modules/vscode";

      # The repository pins the inputs of its applications, so that every
      # application is built with the same nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    bat = {
      url = "path:./modules/bat";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    starship = {
      url = "path:./modules/starship";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    opencode = {
      url = "path:./modules/opencode";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    sbt = {
      url = "path:./modules/sbt";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    neovim = {
      url = "path:./modules/neovim";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.nixvim.follows = "nixvim";
    };

    eza = {
      url = "path:./modules/eza";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    zed = {
      url = "path:./modules/zed";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    yazi = {
      url = "path:./modules/yazi";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";

      # The theme of the code preview of Yazi is the theme of bat, so the
      # two applications share it.
      inputs.bat.follows = "bat";
    };

    kitty = {
      url = "path:./modules/kitty";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    mkdocs = {
      url = "path:./modules/mkdocs";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.mkdocs-flake.follows = "mkdocs-flake";
    };

    claude-code = {
      url = "path:./modules/claude-code";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    btop = {
      url = "path:./modules/btop";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    lazygit = {
      url = "path:./modules/lazygit";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    md-tui = {
      url = "path:./modules/md-tui";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    noctalia = {
      url = "path:./modules/noctalia";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        lib,
        inputs,
        ...
      }:
      {
        imports = [
          # The options that the modules below declare.
          inputs.devshell.flakeModule
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
          inputs.actions-nix.flakeModules.default

          # The modules the applications publish.
          inputs.vscode.flakeModule
          inputs.bat.flakeModule
          inputs.starship.flakeModule
          inputs.opencode.flakeModule
          inputs.sbt.flakeModule
          inputs.neovim.flakeModule
          inputs.eza.flakeModule
          inputs.zed.flakeModule
          inputs.yazi.flakeModule
          inputs.kitty.flakeModule
          inputs.mkdocs.flakeModule
          inputs.claude-code.flakeModule
          inputs.btop.flakeModule
          inputs.lazygit.flakeModule
          inputs.md-tui.flakeModule
          inputs.noctalia.flakeModule
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          # The workflows of the repository, defined in Nix.
          actions-nix.workflows = import ./workflows { inherit lib; };

          # The overlays of every application, applied like nixpkgs
          # applies them.
          overlays.default = lib.composeManyExtensions [
            config.flake.overlays.vscode
            config.flake.overlays.starship
            config.flake.overlays.opencode
            config.flake.overlays.sbt
            config.flake.overlays.neovim
            config.flake.overlays.eza
            config.flake.overlays.zed
            config.flake.overlays.yazi
            config.flake.overlays.kitty
            config.flake.overlays.mkdocs
            config.flake.overlays.claude-code
            config.flake.overlays.btop
            config.flake.overlays.lazygit
            config.flake.overlays.md-tui
            config.flake.overlays.noctalia
          ];

          flakeModules = {
            bat = inputs.bat.flakeModule;
            starship = inputs.starship.flakeModule;
            vscode = inputs.vscode.flakeModule;
            opencode = inputs.opencode.flakeModule;
            sbt = inputs.sbt.flakeModule;
            neovim = inputs.neovim.flakeModule;
            eza = inputs.eza.flakeModule;
            zed = inputs.zed.flakeModule;
            yazi = inputs.yazi.flakeModule;
            kitty = inputs.kitty.flakeModule;
            mkdocs = inputs.mkdocs.flakeModule;
            claude-code = inputs.claude-code.flakeModule;
            btop = inputs.btop.flakeModule;
            lazygit = inputs.lazygit.flakeModule;
            md-tui = inputs.md-tui.flakeModule;
            noctalia = inputs.noctalia.flakeModule;
            default = {
              imports = [
                inputs.bat.flakeModule
                inputs.starship.flakeModule
                inputs.vscode.flakeModule
                inputs.opencode.flakeModule
                inputs.sbt.flakeModule
                inputs.neovim.flakeModule
                inputs.eza.flakeModule
                inputs.zed.flakeModule
                inputs.yazi.flakeModule
                inputs.kitty.flakeModule
                inputs.claude-code.flakeModule
                inputs.btop.flakeModule
                inputs.lazygit.flakeModule
                inputs.md-tui.flakeModule
                inputs.noctalia.flakeModule

                # The module of MkDocs is not here. It imports the module of
                # mkdocs-flake, which declares its arguments, and a module
                # that declares arguments can only be imported once per
                # flake. A consumer that wants the theme of MkDocs imports
                # `flakeModules.mkdocs`, which is the only way to get it.
              ];
            };
          };

          # The aggregate modules carry the modules of the applications that
          # provide one. The modules of VS Code and Zed are not among them:
          # they are imported explicitly by the consumers that want them.
          nixosModules.default = {
            imports = [
              config.flake.nixosModules.starship
              config.flake.nixosModules.opencode
              config.flake.nixosModules.neovim
            ];
          };

          homeModules.default = {
            imports = [
              config.flake.homeModules.starship
              config.flake.homeModules.opencode
              config.flake.homeModules.sbt
              config.flake.homeModules.neovim
              config.flake.homeModules.eza
              config.flake.homeModules.yazi
              config.flake.homeModules.kitty
              config.flake.homeModules.claude-code
              config.flake.homeModules.btop
              config.flake.homeModules.lazygit
              config.flake.homeModules.md-tui
              config.flake.homeModules.noctalia
              config.flake.homeModules.bat
            ];
          };
        };

        perSystem =
          {
            config,
            pkgs,
            ...
          }:
          let
            release = import ./tools/release.nix { inherit pkgs; };
          in
          {
            # The development shell of the repository, declared in TOML.
            #
            # The mkdocs of the documentation flake is the one that carries the
            # theme of Material for MkDocs, which the site of the repository
            # uses; the plain one cannot build it.
            devshells.default =
              let
                devshell = inputs.devshell.lib.importTOML ./devshell.toml { inherit lib; };
                mkdocs = inputs.mkdocs-flake.packages.${pkgs.stdenv.hostPlatform.system}.mkdocs;
              in
              devshell
              // {
                config = devshell.config // {
                  devshell = devshell.config.devshell // {
                    packages = devshell.config.devshell.packages ++ [ mkdocs ];
                  };
                };
              };

            # The helper that releases the repository. It is the same helper
            # that the command of the development shell runs, so that it can be
            # run without the shell too.
            packages.release = release;

            # The hooks of git-hooks.nix are not checked here: the check of the
            # workflows below covers the one that renders them.
            pre-commit.check.enable = false;

            # The formatting of the repository. The formatter and the check
            # that verifies it come with the module.
            treefmt.imports = [ ./treefmt.nix ];

            # The documentation site. Its sources are the Markdown files in
            # `docs/`, and its configuration is the `mkdocs.yml` at the root.
            documentation = {
              mkdocs-root = ./.;
              strict = true;
            };

            # Fails if the workflows of the repository are not valid.
            #
            # The lint does not depend on what is committed, so it runs on
            # every pull request.
            checks = {
              # Fails if the documentation site does not build, or if it
              # carries a broken link or a page missing from the navigation.
              documentation = config.packages.documentation;

              workflows-lint =
                let
                  render =
                    (inputs.actions-nix.lib.evalModule pkgs top.config.flake.actions-nix).config.build.renderWorkflows;
                in
                pkgs.runCommandLocal "workflows-lint-check"
                  {
                    nativeBuildInputs = [
                      pkgs.actionlint
                      pkgs.shellcheck
                    ];
                  }
                  ''
                    mkdir project
                    cd project
                    ${render}/bin/render-workflows --no-prepend-git-root
                    actionlint .github/workflows/*.yml
                    touch $out
                  '';

              # Fails if an application carries a version of its own.
              version = import ./tests/version.nix { inherit pkgs; };

              # Fails if the overlay of the repository does not add the
              # packages of every application.
              overlay = import ./tests/overlay.nix {
                inherit pkgs;
                overlay = top.config.flake.overlays.default;
                expected = [
                  "blueforest-vscode-theme"
                  "blueforest-starship-preset"
                  "blueforest-starship"
                  "blueforest-opencode-theme"
                  "blueforest-sbt-prompt"
                  "blueforest-neovim-theme"
                  "blueforest-eza-theme"
                  "blueforest-zed-theme"
                  "blueforest-yazi-theme"
                  "blueforest-kitty-theme"
                  "blueforest-mkdocs-theme"
                  "blueforest-claude-code-theme"
                  "blueforest-btop-theme"
                  "blueforest-lazygit-theme"
                  "blueforest-md-tui-theme"
                  "blueforest-noctalia-theme"

                  # The theme of bat comes with the one of Yazi, which
                  # carries it for the colours of the code preview.
                  "blueforest-bat-theme"
                ];
              };

              # Fails if the documentation marks a code block with a language
              # that the applications of the repository do not highlight.
              fences = import ./tests/fences.nix {
                inherit pkgs;
                sources = ./docs;
              };

              # Fails if the colours of the theme of Zed are not the colours
              # of the other applications of the repository.
              zed-colours = import ./tests/zed-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.zed pkgs pkgs).blueforest-zed-theme;
                vscode = ./modules/vscode/themes/Blueforest-color-theme.json;
                neovim = ./modules/neovim/themes/blueforest.lua;
              };

              # Fails if the colours of the theme of lazygit are not the
              # colours of the other applications of the repository.
              lazygit-colours = import ./tests/lazygit-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.lazygit pkgs pkgs).blueforest-lazygit-theme;
                vscode = ./modules/vscode/themes/Blueforest-color-theme.json;
                neovim = ./modules/neovim/themes/blueforest.lua;
              };

              # Fails if the colours of the theme of md-tui are not the
              # colours of the other applications of the repository.
              md-tui-colours = import ./tests/md-tui-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.md-tui pkgs pkgs).blueforest-md-tui-theme;
                vscode = ./modules/vscode/themes/Blueforest-color-theme.json;
                neovim = ./modules/neovim/themes/blueforest.lua;
                kitty = ./modules/kitty/themes/blueforest.conf;
              };

              # Fails if the colours of the theme of Noctalia are not the
              # colours of the other applications of the repository.
              noctalia-colours = import ./tests/noctalia-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.noctalia pkgs pkgs).blueforest-noctalia-theme;
                vscode = ./modules/vscode/themes/Blueforest-color-theme.json;
                neovim = ./modules/neovim/themes/blueforest.lua;
                kitty = ./modules/kitty/themes/blueforest.conf;
              };

              # Fails if the swatches of the palettes of the documentation are
              # not the colours of the palette of Noctalia.
              palette-swatches = import ./tests/palette-swatches.nix {
                inherit pkgs;
                docs = ./docs/index.md;
                palette = ./modules/noctalia/themes/blueforest.json;
              };

              # Fails if the colours of the light themes are not the colours
              # of the light palette of Noctalia.
              light-colours = import ./tests/light-colours.nix {
                inherit pkgs;
                vscode = ./modules/vscode/themes/Blueforest-light-color-theme.json;
                opencode = ./modules/opencode/themes/blueforest.json;
                bat = ./modules/bat/themes/BlueForestLight.tmTheme;
                claudeCode = ./modules/claude-code/themes/blueforest-light.json;
                mdTui = ./modules/md-tui/themes/blueforest-light.json;
                neovim = ./modules/neovim/themes/blueforest-light.lua;
                yazi = ./modules/yazi/themes/blueforest-light.yazi/flavor.toml;
                mkdocs = ./modules/mkdocs/themes/blueforest.css;
                palette = ./modules/noctalia/themes/blueforest.json;
              };

              # Fails if the theme of the code preview of Yazi is not the
              # theme of the code preview of bat.
              yazi-tmtheme = import ./tests/yazi-tmtheme.nix {
                inherit pkgs;
                yazi = (top.config.flake.overlays.yazi pkgs pkgs).blueforest-yazi-theme;
                bat = ./modules/bat/themes/BlueForest.tmTheme;
                batLight = ./modules/bat/themes/BlueForestLight.tmTheme;
              };

              # Fails if the asset of the release of Yazi does not carry the
              # colours of the code preview.
              yazi-asset = import ./tests/yazi-asset.nix {
                inherit pkgs;
                applications = import ./workflows/assets.nix;
                modules = ./modules;
              };
            }
            # Fails if the workflows of the repository are not the ones that
            # the definitions in `workflows/` render.
            #
            # The check is skipped on a pull request, where the workflow of
            # the CI renders the files and commits them to the branch: there
            # is nothing to report there.
            // (
              if builtins.getEnv "BLUEFOREST_SKIP_WORKFLOWS_CHECK" == "1" then
                {
                }
              else
                {
                  workflows =
                    let
                      workflows = top.config.flake.actions-nix.workflows;
                      render =
                        (inputs.actions-nix.lib.evalModule pkgs top.config.flake.actions-nix).config.build.renderWorkflows;
                    in
                    pkgs.runCommandLocal "workflows-check" { } ''
                      mkdir project
                      cd project
                      ${render}/bin/render-workflows --no-prepend-git-root
                      for workflow in ${lib.concatStringsSep " " (lib.attrNames workflows)}; do
                        diff ${./.}/"$workflow" "$workflow"
                      done
                      touch $out
                    '';
                }
            );
          };
      }
    );
}
