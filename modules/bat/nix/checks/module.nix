# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where bat reads the
# themes from, that it selects the theme, and that it writes nothing when the
# theme or bat itself is not enabled.
#
# The check covers a consumer that brings a theme or a setting of its own:
# they win over the ones of the repository, because the module writes both
# with `lib.mkDefault`.
#
# The check covers the variants of the theme: the dark one and the light one
# are two themes, and the switch of the variant selects the one that is
# installed.
#
# The check also covers the conflict with the template of the community
# catalogue of Noctalia for bat: a configuration that enables both fails to
# evaluate.
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
      programs.bat.enable = true;
      blueforest-theme.bat.enable = true;
    }
  ];

  # A consumer that asks for the light variant of the theme.
  light = evaluate [
    {
      programs.bat.enable = true;
      blueforest-theme.bat.enable = true;
      blueforest-theme.bat.variant = "light";
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable bat: the theme
  # has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest-theme.bat.enable = true;
    }
  ];

  # A consumer that brings a setting of its own.
  own = evaluate [
    {
      programs.bat.enable = true;
      blueforest-theme.bat.enable = true;
      programs.bat.config.theme = "Another";
    }
  ];

  # A configuration that enables the theme of the repository and the template
  # of Noctalia for bat: it fails to evaluate.
  conflict =
    if
      (builtins.tryEval
        (evaluate [
          {
            programs.bat.enable = true;
            blueforest-theme.bat.enable = true;
          }
          {
            programs.noctalia.settings.theme.templates.community_ids = [ "bat" ];
          }
        ]).home.username
      ).success
    then
      "no"
    else
      "yes";

  result = builtins.toJSON {
    enabled = {
      target = "${enabled.xdg.configHome}/bat/themes/BlueForest.tmTheme";
      source = enabled.xdg.configFile."bat/themes/BlueForest.tmTheme".source;
      config = enabled.xdg.configFile."bat/config".text;
    };

    # The light variant is a theme of its own, and it is the one that is
    # installed when the consumer asks for it.
    light = {
      target = "${light.xdg.configHome}/bat/themes/BlueForestLight.tmTheme";
      source = light.xdg.configFile."bat/themes/BlueForestLight.tmTheme".source;
      config = light.xdg.configFile."bat/config".text;
      darkInstalled = light.xdg.configFile ? "bat/themes/BlueForest.tmTheme";
    };

    # The module does not enable bat, so a configuration that does not ask
    # for the theme gets no files.
    disabled = {
      defined = disabled.xdg.configFile ? "bat/themes/BlueForest.tmTheme";
      config = disabled.xdg.configFile ? "bat/config";
    };

    themeOnly = {
      defined = themeOnly.xdg.configFile ? "bat/themes/BlueForest.tmTheme";
      config = themeOnly.xdg.configFile ? "bat/config";
    };

    own = {
      config = own.xdg.configFile."bat/config".text;
    };
  };
in
pkgs.runCommand "blueforest-bat-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit conflict result;
  }
  ''
    # The theme ends up in the directory bat reads the themes from, which
    # is the `themes` directory of the configuration directory of bat.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.config/bat/themes/BlueForest.tmTheme"
      and (.disabled.defined | not)
      and (.disabled.config | not)
      and (.themeOnly.defined | not)
      and (.themeOnly.config | not)
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.source')" ${source}

    # The configuration of bat selects the theme.
    echo "$result" | jq -r '.enabled.config' >"$TMPDIR/bat.conf"
    grep -q '^--theme=BlueForest$' "$TMPDIR/bat.conf"

    # The light variant is installed instead of the dark one, and it is the
    # one that is selected.
    echo "$result" | jq -e '
      .light.target == "/home/blueforest/.config/bat/themes/BlueForestLight.tmTheme"
      and (.light.darkInstalled | not)
    ' >/dev/null
    cmp "$(echo "$result" | jq -r '.light.source')" ${sourceLight}
    echo "$result" | jq -r '.light.config' >"$TMPDIR/light.conf"
    grep -q '^--theme=BlueForestLight$' "$TMPDIR/light.conf"

    # And a consumer that selects a theme of its own keeps it.
    echo "$result" | jq -r '.own.config' >"$TMPDIR/own.conf"
    grep -q '^--theme=Another$' "$TMPDIR/own.conf"

    # The template of Noctalia for bat and the theme of the repository
    # cannot be enabled at the same time.
    if [ "$conflict" != "yes" ]; then
      echo "the conflict with the Noctalia template for bat did not fail" >&2
      exit 1
    fi

    touch $out
  ''
