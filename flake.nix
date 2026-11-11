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

    # The extension of Zed, which is the theme of the application.
    #
    # The extension is a repository of its own, and it is not a flake, so it
    # is an input without one. The pin of it lives in the lock file of the
    # repository, and `nix flake update` moves it.
    zed-extension = {
      url = "github:alonsodomin/zed-blueforest-theme";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        lib,
        inputs,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;

        # The module of every application of the repository.
        #
        # The applications are not flakes of their own: the root flake
        # imports their modules directly, out of the tree of the repository.
        # A relative import stays inside the tree, so the sources of the
        # applications are covered by the hash of the lock file of the
        # repository, and a consumer that takes the repository gets them
        # verified. A `path:` input would not: it is a store path of its
        # own, with no hash, and the consumer would have to trust it.
        #
        # Every module carries a key of its own. The module system evaluates
        # a module once, and the key is what tells it that two imports of
        # the same module are the same one: the module of an application is
        # imported by the root flake and, in the case of Yazi, by the module
        # of another application, and the option `flake.overlays.bat` is
        # declared to be unique.
        vscodeModule = (importApply ./modules/vscode/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:vscode";
        };
        batModule = (importApply ./modules/bat/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:bat";
        };
        starshipModule = (importApply ./modules/starship/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:starship";
        };
        opencodeModule = (importApply ./modules/opencode/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:opencode";
        };
        sbtModule = (importApply ./modules/sbt/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:sbt";
        };
        neovimModule = (importApply ./modules/neovim/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:neovim";
        };
        ezaModule = (importApply ./modules/eza/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:eza";
        };
        zedModule =
          (importApply ./modules/zed/flake-module.nix {
            appInputs = inputs;
            extension = inputs."zed-extension";
          })
          // {
            key = "blueforest:zed";
          };
        kittyModule = (importApply ./modules/kitty/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:kitty";
        };
        mkdocsModule = (importApply ./modules/mkdocs/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:mkdocs";
        };
        claude-codeModule =
          (importApply ./modules/claude-code/flake-module.nix { appInputs = inputs; })
          // {
            key = "blueforest:claude-code";
          };
        btopModule = (importApply ./modules/btop/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:btop";
        };
        lazygitModule = (importApply ./modules/lazygit/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:lazygit";
        };
        lazydockerModule = (importApply ./modules/lazydocker/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:lazydocker";
        };
        md-tuiModule = (importApply ./modules/md-tui/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:md-tui";
        };
        noctaliaModule = (importApply ./modules/noctalia/flake-module.nix { appInputs = inputs; }) // {
          key = "blueforest:noctalia";
        };

        # The theme of the code preview of Yazi is the theme of bat, so the
        # two applications share it, and the module of Yazi imports the
        # module of bat.
        yaziModule =
          (importApply ./modules/yazi/flake-module.nix {
            appInputs = inputs;
            inherit batModule;
          })
          // {
            key = "blueforest:yazi";
          };
      in
      {
        imports = [
          # The options that the modules below declare.
          inputs.devshell.flakeModule
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
          inputs.actions-nix.flakeModules.default

          # The modules the applications publish.
          vscodeModule
          batModule
          starshipModule
          opencodeModule
          sbtModule
          neovimModule
          ezaModule
          zedModule
          yaziModule
          kittyModule
          mkdocsModule
          claude-codeModule
          btopModule
          lazygitModule
          lazydockerModule
          md-tuiModule
          noctaliaModule
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
            config.flake.overlays.lazydocker
            config.flake.overlays.md-tui
            config.flake.overlays.noctalia
          ];

          flakeModules = {
            bat = batModule;
            starship = starshipModule;
            vscode = vscodeModule;
            opencode = opencodeModule;
            sbt = sbtModule;
            neovim = neovimModule;
            eza = ezaModule;
            zed = zedModule;
            yazi = yaziModule;
            kitty = kittyModule;
            mkdocs = mkdocsModule;
            claude-code = claude-codeModule;
            btop = btopModule;
            lazygit = lazygitModule;
            lazydocker = lazydockerModule;
            md-tui = md-tuiModule;
            noctalia = noctaliaModule;
            default = {
              imports = [
                batModule
                starshipModule
                vscodeModule
                opencodeModule
                sbtModule
                neovimModule
                ezaModule
                zedModule
                yaziModule
                kittyModule
                claude-codeModule
                btopModule
                lazygitModule
                lazydockerModule
                md-tuiModule
                noctaliaModule

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
              config.flake.homeModules.lazydocker
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
            # The applications of the repository, and the way each one of them
            # is packaged for the release.
            applications = import ./workflows/assets.nix { inherit lib; };

            # The helper that releases the repository. It is the same helper
            # that the command of the development shell runs, so that it can
            # be run without the shell too.
            release = import ./tools/release/default.nix { inherit pkgs; };

            # The helper that shows the changelog of the changes that are
            # not released yet.
            changelog = import ./tools/changelog/default.nix { inherit pkgs; };
          in
          {
            # The development shell of the repository, declared in TOML.
            #
            # The mkdocs of the documentation module is the one that carries
            # the theme of Material for MkDocs, which the site of the
            # repository uses; the plain one of nixpkgs cannot build it.
            devshells.default =
              let
                devshell = inputs.devshell.lib.importTOML ./devshell.toml { inherit lib; };
              in
              devshell
              // {
                config = devshell.config // {
                  devshell = devshell.config.devshell // {
                    packages = devshell.config.devshell.packages ++ [
                      config.documentation.mkdocs-package
                      release
                      changelog
                    ];
                  };
                };
              };

            # The helper that releases the repository, and the one that shows
            # the changelog of the unreleased changes. They are the same
            # helpers that the commands of the development shell run.
            #
            # The names carry the prefix of the repository, because nixpkgs
            # has a `changelog` of its own.
            packages.blueforest-release = release;
            packages.blueforest-changelog = changelog;

            # CoCoGitto, the conventional commit toolbox of the repository.
            # The changelog of a release is generated out of the commits of
            # the repository, and the commits have to follow the
            # conventional commits specification.
            packages.cog = pkgs.cocogitto;

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

              workflows-lint = import ./workflows/checks/lint.nix { inherit inputs pkgs top; };
              workflows-validate = import ./workflows/checks/validate.nix {
                inherit
                  inputs
                  pkgs
                  lib
                  top
                  ;
              };

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
                  "blueforest-starship-palette"
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
                  "blueforest-lazydocker-theme"
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
                vscodeLight = ./modules/vscode/themes/Blueforest-light-color-theme.json;
                neovimLight = ./modules/neovim/themes/blueforest-light.lua;
              };

              # Fails if the colours of the theme of lazygit are not the
              # colours of the other applications of the repository.
              lazygit-colours = import ./tests/lazygit-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.lazygit pkgs pkgs).blueforest-lazygit-theme;
                vscode = ./modules/vscode/themes/Blueforest-color-theme.json;
                neovim = ./modules/neovim/themes/blueforest.lua;
              };

              # Fails if the colours of the theme of lazydocker are not the
              # colours of the other applications of the repository.
              lazydocker-colours = import ./tests/lazydocker-colours.nix {
                inherit pkgs;
                theme = (top.config.flake.overlays.lazydocker pkgs pkgs).blueforest-lazydocker-theme;
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
                vscodeLight = ./modules/vscode/themes/Blueforest-light-color-theme.json;
                neovimLight = ./modules/neovim/themes/blueforest-light.lua;
                kittyLight = ./modules/kitty/themes/blueforest-light.conf;
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
                lazydocker = ./modules/lazydocker/themes/blueforest-light.json;
                neovim = ./modules/neovim/themes/blueforest-light.lua;
                yazi = ./modules/yazi/themes/blueforest-light.yazi/flavor.toml;
                mkdocs = ./modules/mkdocs/themes/blueforest.css;
                zed = "${(top.config.flake.overlays.zed pkgs pkgs).blueforest-zed-theme}/themes/blueforest.json";
                kitty = ./modules/kitty/themes/blueforest-light.conf;
                starship = ./modules/starship/themes/palettes/blueforest-light.toml;
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
                inherit applications;
                modules = ./modules;
              };

              # Fails if the configuration of CoCoGitto does not know every
              # application of the repository.
              cog-packages = import ./tests/cog-packages.nix {
                inherit
                  pkgs
                  lib
                  applications
                  ;
                config = ./cog.toml;
              };

              # Fails if the asset of an application does not carry the
              # files of the theme and the changelog of the release.
              release-assets = import ./tests/release-assets.nix {
                inherit
                  pkgs
                  lib
                  applications
                  ;
                modules = ./modules;

                # The extension of Zed, which the asset of the application
                # carries. The release workflow fetches it out of the
                # repository of the extension, at the revision the lock file
                # of the repository pins.
                extension = inputs."zed-extension";
              };
            };
          };
      }
    );
}
