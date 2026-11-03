# SPDX-License-Identifier: MPL-2.0
#
# Makes the BlueForest theme for OpenCode available to the consumer's
# configuration.
#
# The module does not enable OpenCode: the theme is part of the configuration
# of OpenCode, and Home Manager writes that configuration only when the
# program is enabled. A consumer that wants the theme enables the program and
# the theme:
#
#   programs.opencode.enable = true;
#   blueforest-theme.opencode.enable = true;
#
# The module does not touch `programs.opencode.package` either: the OpenCode
# of the consumer is the one it wants.
#
# The switch is the one of this repository, and not `programs.opencode.enable`,
# so that the theme and the template of the community catalogue of Noctalia
# for OpenCode are alternatives. A consumer that enables both gets an error,
# because the two of them write the same configuration of OpenCode.
#
# The overlay of the application is passed to the module, so that the theme
# the consumer gets is the one of the application, with its version.
{
  overlay,
}:
{
  config,
  lib,
  ...
}:
let
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
  options.blueforest-theme.opencode = {
    enable = lib.mkEnableOption "the BlueForest theme for OpenCode";
  };

  config = lib.mkMerge [
    {
      nixpkgs.overlays = [ overlay ];
    }

    {
      # The template of Noctalia for OpenCode writes the same configuration
      # of OpenCode, so the two of them cannot be enabled at the same time.
      assertions = [
        {
          assertion = !(config.blueforest-theme.opencode.enable && lib.elem "opencode" enabledTemplates);
          message = ''
            The BlueForest theme for OpenCode and the Noctalia template for
            OpenCode are both enabled, and the two of them write the
            configuration of OpenCode. Disable the template in the
            configuration of Noctalia (remove "opencode" from
            `[theme.templates] community_ids`), or set
            `blueforest-theme.opencode.enable = false`.'';
        }
      ];
    }

    (lib.mkIf (config.blueforest-theme.opencode.enable && config.programs.opencode.enable) {
      programs.opencode = {
        # The theme, under the name OpenCode reads the name of the theme
        # from: the name of the file.
        themes.blueforest = lib.mkDefault ../../themes/blueforest.json;

        # The selection of the theme, in the file OpenCode 2 reads at
        # runtime. The theme has a variant per mode, so it follows the
        # appearance of the terminal.
        cli.theme = lib.mkDefault {
          name = "blueforest";
          mode = "system";
        };
      };
    })
  ];
}
