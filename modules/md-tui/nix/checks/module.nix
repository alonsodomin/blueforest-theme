# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where md-tui reads
# the palettes from, that it selects it, and that it writes nothing when the
# theme is not enabled.
#
# The check covers a consumer that selects a theme of its own: the selection
# of the consumer wins over the selection of the repository, because the
# module writes it with `lib.mkDefault`.
{
  pkgs,
  homeManager,
  module,
  source,
}:
let
  # The identity of the user of the configuration, so that the paths of the
  # files are known.
  identity = {
    home.username = "blueforest";
    home.homeDirectory = "/home/blueforest";
    home.stateVersion = "26.11";
  };

  evaluate =
    extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        identity
        extra
      ];
    }).config;

  enabled = evaluate { blueforest-theme.md-tui.enable = true; };
  disabled = evaluate { };

  # A consumer that selects a theme of its own.
  own = evaluate {
    blueforest-theme.md-tui.enable = true;
    home.file.".config/mdt/selected-theme".text = "another\n";
  };

  result = builtins.toJSON {
    enabled = {
      palette = enabled.home.file.".config/mdt/themes/blueforest.json".source;
      selection = enabled.home.file.".config/mdt/selected-theme".text;
    };

    # The module does not enable md-tui, so a configuration that does not ask
    # for the theme gets no files.
    disabled = {
      palette = disabled.home.file ? ".config/mdt/themes/blueforest.json";
      selection = disabled.home.file ? ".config/mdt/selected-theme";
    };

    own = {
      selection = own.home.file.".config/mdt/selected-theme".text;
    };
  };
in
pkgs.runCommand "blueforest-md-tui-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit result;
  }
  ''
    # The theme ends up in the directory md-tui reads the palettes from,
    # which is the `themes` directory of the configuration directory of
    # md-tui.
    echo "$result" | jq -e '
      .enabled.palette != null
      and (.disabled.palette | not)
      and (.disabled.selection | not)
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.palette')" ${source}

    # The selection of the theme names the theme of the repository.
    echo "$result" | jq -r '.enabled.selection' >"$TMPDIR/selected-theme"
    grep -q '^blueforest$' "$TMPDIR/selected-theme"

    # And a consumer that selects a theme of its own keeps it.
    echo "$result" | jq -r '.own.selection' >"$TMPDIR/own"
    grep -q '^another$' "$TMPDIR/own"

    touch $out
  ''
