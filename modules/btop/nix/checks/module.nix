# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where btop reads the
# themes from, that it selects the theme, and that it writes nothing when the
# theme or btop itself is not enabled.
#
# The check covers a consumer that selects a theme of its own: the theme of
# the consumer wins over the theme of the repository, because the module
# selects the theme of the repository with `lib.mkDefault`.
#
# The check also covers the conflict with the template of the community
# catalogue of Noctalia for btop: a configuration that enables both fails to
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
      programs.btop.enable = true;
      blueforest-theme.btop.enable = true;
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable btop: the theme
  # has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest-theme.btop.enable = true;
    }
  ];

  # A consumer that selects a theme of its own.
  own = evaluate [
    {
      programs.btop.enable = true;
      blueforest-theme.btop.enable = true;
      programs.btop.settings.color_theme = "another.theme";
    }
  ];

  # A configuration that enables the theme of the repository and the template
  # of Noctalia for btop: it fails to evaluate.
  conflict =
    if
      (builtins.tryEval
        (evaluate [
          {
            programs.btop.enable = true;
            blueforest-theme.btop.enable = true;
          }
          {
            programs.noctalia.settings.theme.templates.builtin_ids = [ "btop" ];
          }
        ]).home.username
      ).success
    then
      "no"
    else
      "yes";

  result = builtins.toJSON {
    enabled = {
      target = "${enabled.xdg.configHome}/btop/themes/blueforest.theme";
      source = enabled.xdg.configFile."btop/themes/blueforest.theme".source;
      config = enabled.xdg.configFile."btop/btop.conf".text;
    };

    # The module does not enable btop, so a configuration that does not ask
    # for the theme gets no theme.
    disabled = {
      defined = disabled.xdg.configFile ? "btop/themes/blueforest.theme";
      config = disabled.xdg.configFile ? "btop/btop.conf";
    };

    themeOnly = {
      defined = themeOnly.xdg.configFile ? "btop/themes/blueforest.theme";
      config = themeOnly.xdg.configFile ? "btop/btop.conf";
    };

    own = {
      config = own.xdg.configFile."btop/btop.conf".text;
    };
  };
in
pkgs.runCommand "blueforest-btop-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit conflict result;
  }
  ''
    # The theme ends up in the directory btop reads the themes from, which
    # is the `themes` directory of the configuration directory of btop.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.config/btop/themes/blueforest.theme"
      and (.disabled.defined | not)
      and (.disabled.config | not)
      and (.themeOnly.defined | not)
      and (.themeOnly.config | not)
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.source')" ${source}

    # The configuration of btop selects the theme.
    echo "$result" | jq -r '.enabled.config' >"$TMPDIR/btop.conf"
    grep -q '^color_theme = "blueforest.theme"$' "$TMPDIR/btop.conf"

    # And a consumer that selects a theme of its own keeps it.
    echo "$result" | jq -r '.own.config' >"$TMPDIR/own.conf"
    grep -q '^color_theme = "another.theme"$' "$TMPDIR/own.conf"

    # The template of Noctalia for btop and the theme of the repository
    # cannot be enabled at the same time.
    if [ "$conflict" != "yes" ]; then
      echo "the conflict with the Noctalia template for btop did not fail" >&2
      exit 1
    fi

    touch $out
  ''
