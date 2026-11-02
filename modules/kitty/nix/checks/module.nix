# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where kitty reads
# it, that it selects the theme, and that it writes nothing when kitty is
# not enabled.
#
# The check covers a consumer that sets a colour of its own: the colour of
# the consumer wins over the colour of the theme, because the theme is
# included before the settings of kitty are written.
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

  enabled = evaluate { programs.kitty.enable = true; };
  disabled = evaluate { };

  # A consumer that brings a colour of its own.
  own = evaluate {
    programs.kitty.enable = true;
    programs.kitty.settings.background = "#FF0000";
  };

  result = builtins.toJSON {
    enabled = {
      target = "${enabled.xdg.configHome}/kitty/themes/blueforest.conf";
      source = enabled.xdg.configFile."kitty/themes/blueforest.conf".source;
      config = enabled.xdg.configFile."kitty/kitty.conf".text;
    };

    # The module does not enable kitty, so a configuration that does not
    # enable it gets no theme.
    disabled = {
      defined = disabled.xdg.configFile ? "kitty/themes/blueforest.conf";
    };

    own = {
      config = own.xdg.configFile."kitty/kitty.conf".text;
    };
  };
in
pkgs.runCommand "blueforest-kitty-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    inherit result;
  }
  ''
    # The theme ends up in the directory kitty reads the themes from, which
    # is the `themes` directory of the configuration directory of kitty.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.config/kitty/themes/blueforest.conf"
      and (.disabled.defined | not)
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.source')" ${source}

    # The configuration of kitty selects the theme.
    echo "$result" | jq -r '.enabled.config' >"$TMPDIR/kitty.conf"
    grep -q '^include themes/blueforest.conf$' "$TMPDIR/kitty.conf"

    # And the theme comes before the colours of the consumer, so that the
    # consumer wins.
    echo "$result" | jq -r '.own.config' >"$TMPDIR/own.conf"
    grep -q '^include themes/blueforest.conf$' "$TMPDIR/own.conf"
    grep -q '^background #FF0000$' "$TMPDIR/own.conf"

    include_line=$(grep -n '^include themes/blueforest.conf$' "$TMPDIR/own.conf" | cut -d: -f1)
    background_line=$(grep -n '^background #FF0000$' "$TMPDIR/own.conf" | cut -d: -f1)
    test "$include_line" -lt "$background_line"

    touch $out
  ''
