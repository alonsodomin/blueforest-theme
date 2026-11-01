# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where eza reads it,
# and that it writes nothing when eza is not enabled.
#
# Home Manager has an option of its own for the theme of eza, and the check
# covers a consumer that uses it: their theme wins over the one of this
# application, and the two of them do not collide.
{
  lib,
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

  enabled = evaluate { programs.eza.enable = true; };
  disabled = evaluate { };

  # A consumer that brings a theme of its own.
  own = evaluate {
    programs.eza.enable = true;
    programs.eza.theme = {
      filekinds.normal.foreground = "Red";
    };
  };

  result = builtins.toJSON {
    enabled = {
      target = "${enabled.xdg.configHome}/eza/theme.yml";
      source = enabled.xdg.configFile."eza/theme.yml".source;
    };

    # The module does not enable eza, so a configuration that does not enable
    # it gets no theme.
    disabled = {
      defined = disabled.xdg.configFile ? "eza/theme.yml";
    };

    own = {
      target = "${own.xdg.configHome}/eza/theme.yml";
    };
  };
in
pkgs.runCommand "blueforest-eza-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    inherit result;

    # The file Home Manager writes for the theme of the consumer.
    ownFile = own.xdg.configFile."eza/theme.yml".source;
  }
  ''
    # The theme ends up in the configuration directory of eza, which is where
    # eza reads the theme from.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.config/eza/theme.yml"
      and (.disabled.defined | not)
      and .own.target == "/home/blueforest/.config/eza/theme.yml"
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.source')" ${source}

    # The theme of a consumer that brings one of its own is the one of the
    # consumer, and the two of them do not collide.
    grep -q 'Red' "$ownFile"
    ! grep -q '0099ff' "$ownFile"

    touch $out
  ''
