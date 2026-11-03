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
# The check also covers the conflict with the template of the community
# catalogue of Noctalia for bat: a configuration that enables both fails to
# evaluate.
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
      programs.bat.enable = true;
      blueforest.bat.enable = true;
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable bat: the theme
  # has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest.bat.enable = true;
    }
  ];

  # A consumer that brings a setting of its own.
  own = evaluate [
    {
      programs.bat.enable = true;
      blueforest.bat.enable = true;
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
            blueforest.bat.enable = true;
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
