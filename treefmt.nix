# SPDX-License-Identifier: MPL-2.0
#
# The formatting of the repository.
#
# The configuration lives here, and the root flake only points treefmt-nix at
# it. The formatter and the check that verifies the formatting come with the
# module.
{
  config,
  pkgs,
  ...
}:
{
  settings.on-unmatched = "info";

  settings.excludes = [
    # The repository of the working tree. The checks of the repository copy
    # the tree, and the copy carries the repository with it.
    ".git/"

    # The extension of Zed lives in a repository of its own. Its files are not
    # ours, and they are not formatted here.
    "modules/zed/extension/"
  ];

  # The check of treefmt-nix tells whether the formatters changed anything
  # with git, and the flakes of the repository are checked from the working
  # tree, which carries a repository of its own: the check finds nothing to
  # commit and fails. The check below formats a copy of the tree and fails
  # when a formatter changes a file.
  build.check =
    self:
    pkgs.runCommandLocal "treefmt-check"
      {
        buildInputs = [ config.build.wrapper ];

        meta.description = "Check that the project tree is formatted";
      }
      ''
        set -e

        project="$TMPDIR/project"
        cp -r ${self} "$project"
        chmod -R a+w "$project"
        cd "$project"

        export HOME="$TMPDIR"
        export LANG=C.UTF-8
        export LC_ALL=C.UTF-8

        treefmt --version
        treefmt --no-cache --fail-on-change

        touch $out
      '';

  programs.nixfmt.enable = true;

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

    # Only the JSON files of the repository are formatted.
    includes = [ "*.json" ];

    # .vscode/launch.json is JSONC (it has comments), which prettier cannot
    # parse as json.
    excludes = [ ".vscode/**" ];
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
