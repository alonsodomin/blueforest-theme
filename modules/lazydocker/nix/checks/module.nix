# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module adds the theme to the settings of
# lazydocker, and that it writes nothing when lazydocker is not enabled.
#
# The check covers a consumer that brings a colour of its own: the colour of
# the consumer wins over the colour of the theme, and the rest of the theme
# survives, because the module sets every colour of the theme with
# `lib.mkDefault`.
{
  pkgs,
  homeManager,
  module,
  source,
  sourceLight,
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
      ]
      ++ extra;
    }).config;

  enabled = evaluate [
    {
      programs.lazydocker.enable = true;
      blueforest-theme.lazydocker.enable = true;
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable lazydocker: the theme
  # has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest-theme.lazydocker.enable = true;
    }
  ];

  # A consumer that asks for the light variant of the theme.
  light = evaluate [
    {
      programs.lazydocker.enable = true;
      blueforest-theme.lazydocker.enable = true;
      blueforest-theme.lazydocker.variant = "light";
    }
  ];

  # A consumer that brings a colour of its own.
  own = evaluate [
    {
      programs.lazydocker.enable = true;
      blueforest-theme.lazydocker.enable = true;
      programs.lazydocker.settings.gui.theme.activeBorderColor = [ "#FF0000" ];
    }
  ];

  # The theme of the repository, as lazydocker reads it.
  theme = (builtins.fromJSON (builtins.readFile source)).gui.theme;
  themeLight = (builtins.fromJSON (builtins.readFile sourceLight)).gui.theme;

  # The configuration file of lazydocker, which Home Manager writes.
  config = enabled.home.file."/home/blueforest/.config/lazydocker/config.yml".source;

  result = builtins.toJSON {
    enabled = enabled.programs.lazydocker.settings.gui.theme;
    disabled = {
      defined = disabled.programs.lazydocker.settings ? gui;
    };
    themeOnly = {
      defined = themeOnly.programs.lazydocker.settings ? gui;
    };
    light = light.programs.lazydocker.settings.gui.theme;
    own = own.programs.lazydocker.settings.gui.theme;
    expected = theme;
    expectedLight = themeLight;
  };
in
pkgs.runCommand "blueforest-lazydocker-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit result;
  }
  ''
    # The theme of the repository is in the settings of lazydocker.
    echo "$result" | jq -e '
      .enabled == .expected
      and (.disabled.defined | not)
      and (.themeOnly.defined | not)
    ' >/dev/null

    # The light variant is the one that is selected when the consumer asks for
    # it.
    echo "$result" | jq -e '.light == .expectedLight' >/dev/null

    # And a consumer that brings a colour of its own keeps it, and keeps the
    # rest of the theme as well.
    echo "$result" | jq -e '
      .own.activeBorderColor == ["#FF0000"]
      and ((.own | del(.activeBorderColor)) == (.expected | del(.activeBorderColor)))
    ' >/dev/null

    # The configuration file of lazydocker carries the colours of the theme.
    grep -q '#0099FF' ${config}
    grep -q '#273e5c' ${config}
    grep -q '#91CCFF' ${config}

    touch $out
  ''
