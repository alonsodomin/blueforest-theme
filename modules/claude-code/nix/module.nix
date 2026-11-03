# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest theme for Claude Code.
#
# Claude Code reads the custom themes of the user from the `themes` directory
# of its configuration directory, and it selects one of them with the `theme`
# setting of its settings file, whose value is `custom:<slug>`, where the slug
# is the name of the file without its extension. This module writes the theme
# there and selects it.
#
# The module is inert unless `blueforest.claude-code.enable` is true: it does
# not enable Claude Code, it only adds the theme to the configuration of a
# Claude Code that the consumer already enabled.
#
# The switch is the one of this repository, and not `programs.claude-code.enable`,
# so that the theme and the template of the community catalogue of Noctalia
# for Claude Code are alternatives. A consumer that enables both gets an
# error, because the two of them write the same settings of Claude Code.
#
# The theme is selected with `lib.mkDefault`, so a consumer that selects a
# theme of its own keeps it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  # The ids of the templates of Noctalia that the consumer enabled. The
  # configuration of Noctalia is one opaque value, and it may be an attribute
  # set, a string or a path: only the attribute set carries the ids, and the
  # others are read as "no template enabled", so that the assertion never
  # fires on a configuration it cannot read.
  enabledTemplates =
    let
      noctalia = (config.programs or { }).noctalia or { };
      settings = noctalia.settings or { };
      templates =
        if !(lib.isAttrs settings) then
          { }
        else if !(lib.isAttrs (settings.theme or null)) then
          { }
        else if !(lib.isAttrs (settings.theme.templates or null)) then
          { }
        else
          settings.theme.templates;
    in
    (templates.builtin_ids or [ ]) ++ (templates.community_ids or [ ]);
in
{
  options.blueforest.claude-code = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the BlueForest theme for Claude Code.";
    };
  };

  config = lib.mkMerge [
    {
      # The template of Noctalia for Claude Code writes the same settings of
      # Claude Code, so the two of them cannot be enabled at the same time.
      assertions = [
        {
          assertion = !(config.blueforest.claude-code.enable && lib.elem "claude-code" enabledTemplates);
          message = ''
            The BlueForest theme for Claude Code and the Noctalia template for
            Claude Code are both enabled, and the two of them write the
            settings of Claude Code. Disable the template in the configuration
            of Noctalia (remove "claude-code" from `[theme.templates]
            community_ids`), or set `blueforest.claude-code.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest.claude-code.enable && cfg.enable) {
      # The theme, in the directory Claude Code reads the themes from.
      home.file."${cfg.configDir}/themes/blueforest.json".source = ../themes/blueforest.json;

      # The selection of the theme, in the settings of Claude Code.
      programs.claude-code.settings.theme = lib.mkDefault "custom:blueforest";
    })
  ];
}
