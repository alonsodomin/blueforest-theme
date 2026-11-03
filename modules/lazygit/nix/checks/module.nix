# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module adds the theme to the settings of
# lazygit, and that it writes nothing when lazygit is not enabled.
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
      programs.lazygit.enable = true;
      blueforest.lazygit.enable = true;
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable lazygit: the theme
  # has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest.lazygit.enable = true;
    }
  ];

  # A consumer that brings a colour of its own.
  own = evaluate [
    {
      programs.lazygit.enable = true;
      blueforest.lazygit.enable = true;
      programs.lazygit.settings.gui.theme.activeBorderColor = [ "#FF0000" ];
    }
  ];

  # The theme of the repository, as lazygit reads it.
  theme = (builtins.fromJSON (builtins.readFile source)).gui.theme;

  # The configuration file of lazygit, which Home Manager writes.
  config = enabled.home.file."/home/blueforest/.config/lazygit/config.yml".source;

  result = builtins.toJSON {
    enabled = enabled.programs.lazygit.settings.gui.theme;
    disabled = {
      defined = disabled.programs.lazygit.settings ? gui;
    };
    themeOnly = {
      defined = themeOnly.programs.lazygit.settings ? gui;
    };
    own = own.programs.lazygit.settings.gui.theme;
    expected = theme;
  };
in
pkgs.runCommand "blueforest-lazygit-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit result;
  }
  ''
    # The theme of the repository is in the settings of lazygit.
    echo "$result" | jq -e '
      .enabled == .expected
      and (.disabled.defined | not)
      and (.themeOnly.defined | not)
    ' >/dev/null

    # And a consumer that brings a colour of its own keeps it, and keeps the
    # rest of the theme as well.
    echo "$result" | jq -e '
      .own.activeBorderColor == ["#FF0000"]
      and ((.own | del(.activeBorderColor)) == (.expected | del(.activeBorderColor)))
    ' >/dev/null

    # The configuration file of lazygit carries the colours of the theme.
    grep -q '#0099FF' ${config}
    grep -q '#273e5c' ${config}
    grep -q '#D0D0D0' ${config}

    touch $out
  ''
