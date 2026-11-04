# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where Noctalia reads
# the palettes from, that it selects the theme, and that it writes nothing when
# the theme or Noctalia itself is not enabled.
#
# The check covers a consumer that brings a palette or a selection of its own:
# they win over the ones of the repository, because the module writes both with
# `lib.mkDefault`.
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

  enabled = evaluate {
    programs.noctalia.enable = true;
    blueforest-theme.noctalia.enable = true;
  };

  disabled = evaluate { };

  # A consumer that asks for the theme but does not enable Noctalia: the
  # palette has no consumer, so the module writes nothing.
  themeOnly = evaluate { blueforest-theme.noctalia.enable = true; };

  # A consumer that brings a palette and a selection of its own.
  own = evaluate {
    programs.noctalia.enable = true;
    blueforest-theme.noctalia.enable = true;
    programs.noctalia.customPalettes.blueforest = "the palette of the consumer";
    xdg.configFile."noctalia/blueforest.toml".text = ''
      [theme]
      source = "builtin"
    '';
  };

  result = builtins.toJSON {
    enabled = {
      target = "${enabled.xdg.configHome}/noctalia/palettes/blueforest.json";
      palette = enabled.xdg.configFile."noctalia/palettes/blueforest.json".source;
      selection = enabled.xdg.configFile."noctalia/blueforest.toml".text;
    };

    # The module does not enable Noctalia, so a configuration that does not
    # enable it gets no theme.
    disabled = {
      palette = disabled.xdg.configFile ? "noctalia/palettes/blueforest.json";
      selection = disabled.xdg.configFile ? "noctalia/blueforest.toml";
    };

    # The theme alone does not install anything either.
    themeOnly = {
      palette = themeOnly.xdg.configFile ? "noctalia/palettes/blueforest.json";
      selection = themeOnly.xdg.configFile ? "noctalia/blueforest.toml";
    };

    own = {
      palette = own.xdg.configFile."noctalia/palettes/blueforest.json".source;
      selection = own.xdg.configFile."noctalia/blueforest.toml".text;
    };
  };
in
pkgs.runCommand "blueforest-noctalia-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit result;
  }
  ''
    # The palette ends up in the directory Noctalia reads the palettes from,
    # which is the `palettes` directory of the configuration directory of
    # Noctalia.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.config/noctalia/palettes/blueforest.json"
      and (.disabled.palette | not)
      and (.disabled.selection | not)
      and (.themeOnly.palette | not)
      and (.themeOnly.selection | not)
    ' >/dev/null

    # And the palette that ends up installed is the palette of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.palette')" ${source}

    # The selection file selects the palette by name.
    echo "$result" | jq -r '.enabled.selection' >"$TMPDIR/blueforest.toml"
    grep -q '^source = "custom"$' "$TMPDIR/blueforest.toml"
    grep -q '^custom_palette = "blueforest"$' "$TMPDIR/blueforest.toml"

    # And a consumer that brings a palette or a selection of its own keeps it.
    grep -qx 'the palette of the consumer' \
      "$(echo "$result" | jq -r '.own.palette')"

    echo "$result" | jq -r '.own.selection' >"$TMPDIR/own.toml"
    grep -q '^source = "builtin"$' "$TMPDIR/own.toml"
    ! grep -q '^custom_palette' "$TMPDIR/own.toml"

    touch $out
  ''
