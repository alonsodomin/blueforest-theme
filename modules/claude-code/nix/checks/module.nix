# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the theme where Claude Code
# reads the themes from, that it selects it, and that it writes nothing when
# the theme or Claude Code itself is not enabled.
#
# The check covers a consumer that selects a theme of its own: the theme of
# the consumer wins over the theme of the repository, because the module
# selects the theme of the repository with `lib.mkDefault`.
#
# The check also covers the conflict with the template of the community
# catalogue of Noctalia for Claude Code: a configuration that enables both
# fails to evaluate.
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
      programs.claude-code.enable = true;
      blueforest-theme.claude-code.enable = true;
    }
  ];

  disabled = evaluate [ ];

  # A consumer that asks for the theme but does not enable Claude Code: the
  # theme has no consumer, so the module writes nothing.
  themeOnly = evaluate [
    {
      blueforest-theme.claude-code.enable = true;
    }
  ];

  # A consumer that brings a theme of its own.
  own = evaluate [
    {
      programs.claude-code.enable = true;
      blueforest-theme.claude-code.enable = true;
      programs.claude-code.settings.theme = "custom:another-theme";
    }
  ];

  # A configuration that enables the theme of the repository and the template
  # of Noctalia for Claude Code: it fails to evaluate.
  conflict =
    if
      (builtins.tryEval
        (evaluate [
          {
            programs.claude-code.enable = true;
            blueforest-theme.claude-code.enable = true;
          }
          {
            programs.noctalia.settings.theme.templates.community_ids = [ "claude-code" ];
          }
        ]).home.username
      ).success
    then
      "no"
    else
      "yes";

  # The path of the theme in the configuration of the user.
  themePath = "${enabled.programs.claude-code.configDir}/themes/blueforest.json";

  result = builtins.toJSON {
    enabled = {
      target = themePath;
      source = enabled.home.file.${themePath}.source;
      theme = enabled.programs.claude-code.settings.theme or "MISSING";
    };

    # The module does not enable Claude Code, so a configuration that does not
    # ask for the theme gets no theme.
    disabled = {
      defined = disabled.home.file ? ${themePath};
      theme = disabled.programs.claude-code.settings.theme or "MISSING";
    };

    themeOnly = {
      defined = themeOnly.home.file ? ${themePath};
      theme = themeOnly.programs.claude-code.settings.theme or "MISSING";
    };

    own = {
      theme = own.programs.claude-code.settings.theme or "MISSING";
    };
  };
in
pkgs.runCommand "blueforest-claude-code-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    inherit conflict result;
  }
  ''
    # The theme ends up in the directory Claude Code reads the themes from,
    # which is the `themes` directory of the configuration directory of
    # Claude Code.
    echo "$result" | jq -e '
      .enabled.target == "/home/blueforest/.claude/themes/blueforest.json"
      and (.disabled.defined | not)
      and (.disabled.theme == "MISSING")
      and (.themeOnly.defined | not)
      and (.themeOnly.theme == "MISSING")
    ' >/dev/null

    # And the theme that ends up installed is the theme of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.source')" ${source}

    # The configuration of Claude Code selects the theme.
    echo "$result" | jq -e '.enabled.theme == "custom:blueforest"' >/dev/null

    # And a consumer that selects a theme of its own keeps it.
    echo "$result" | jq -e '.own.theme == "custom:another-theme"' >/dev/null

    # The template of Noctalia for Claude Code and the theme of the
    # repository cannot be enabled at the same time.
    if [ "$conflict" != "yes" ]; then
      echo "the conflict with the Noctalia template for Claude Code did not fail" >&2
      exit 1
    fi

    touch $out
  ''
