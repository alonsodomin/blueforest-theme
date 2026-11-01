# SPDX-License-Identifier: MPL-2.0
#
# The formatting of the repository.
#
# The configuration lives here, and the root flake only points treefmt-nix at
# it. The formatter and the check that verifies the formatting come with the
# module.
{
  settings.on-unmatched = "info";

  settings.excludes = [
    # The extension of Zed lives in a repository of its own. Its files are not
    # ours, and they are not formatted here.
    #
    # The pattern ends with a star, because the patterns of treefmt are
    # compiled without a separator: a star crosses the directories, and a
    # pattern that ends with a slash matches nothing.
    "modules/zed/extension/*"

    # The workflows are rendered from their definitions, and the check of the
    # workflows compares the rendering with what is committed. Formatting them
    # would make the two differ.
    ".github/workflows/*"
  ];

  # The tree that the check of the module formats. It is the tree of the
  # repository without the repository of the working tree, because the check
  # tells whether the formatters changed anything with git, and the copy of
  # the working tree carries the repository with it: the check would find
  # nothing to commit.
  projectRoot = builtins.path {
    path = ./.;
    name = "root";

    filter = path: _: baseNameOf path != ".git";
  };

  # The formatter of Nix runs after the linters of Nix, which rewrite the
  # sources: the formatters of a file run in the order of their priority, and
  # the linters have none. Without this, the result of a run is not the result
  # of the next one.
  programs.nixfmt = {
    enable = true;

    priority = 10;
  };

  programs.taplo.enable = true;

  # The Lua sources of the themes. The settings are the ones of LazyVim, which
  # the theme of Neovim is written for.
  programs.stylua = {
    enable = true;

    settings = {
      indent_type = "Spaces";
      indent_width = 2;
      column_width = 120;
      sort_requires.enabled = true;
    };
  };

  programs.prettier = {
    enable = true;

    # The JSON, the JSON5 and the YAML files of the repository are formatted.
    includes = [
      "*.json"
      "*.json5"
      "*.yaml"
      "*.yml"
    ];

    settings = {
      # The launch configuration of the extension is JSONC: it has comments,
      # which the parser of JSON cannot read.
      overrides = [
        {
          files = [ ".vscode/launch.json" ];
          options.parser = "jsonc";
        }
      ];
    };
  };

  # The TextMate themes of the repository are XML files. The theme of bat is
  # not named `.xml`, and the badge of the licence is an SVG file.
  programs.xmllint = {
    enable = true;

    includes = [
      "*.xml"
      "*.tmTheme"
      "*.svg"
    ];
  };

  # The Nix sources of the repository carry no dead code.
  programs.deadnix.enable = true;

  # The lints of statix, with the exception of the repeated keys: the checks
  # of the applications declare the options of Home Manager one by one, and
  # the lint reads that as a repeated key.
  programs.statix = {
    enable = true;

    disabled-lints = [ "repeated_keys" ];
  };

  programs.shfmt = {
    enable = true;

    # The scripts of the repository are indented with tabs.
    indent_size = 0;
  };

  # shellcheck exits non-zero on findings, which makes treefmt fail the run.
  programs.shellcheck = {
    enable = true;

    excludes = [ ".envrc" ];
  };

  # The scripts of the applications share a library, and the shellcheck
  # follows the sources, so that the library is checked in the context of the
  # scripts that use it. The sources are looked for from the root of the
  # repository, which is where the directives of the scripts point at them.
  settings.formatter.shellcheck.options = [
    "-x"
    "-P"
    "."
  ];
}
