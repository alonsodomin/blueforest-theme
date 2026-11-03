# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Claude Code.
#
# The theme is a custom theme of Claude Code, the format Claude Code reads,
# and the name of the theme is the name of the file: blueforest.
#
# Claude Code reads the custom themes of the user from the `themes` directory
# of its configuration directory, and it selects one of them with the `theme`
# setting of `settings.json`, whose value is `custom:<slug>`, where the slug
# is the name of the file without its extension. The package therefore carries
# the theme twice: under the name of the theme, so that a consumer can read it
# directly, and under the name Claude Code reads, so that a consumer can
# install it.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-claude-code-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for Claude Code";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0, the theme it carries is CC BY 4.0.
      license = [
        lib.licenses.mpl20
        lib.licenses.cc-by-40
      ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/claude/themes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/claude/themes/blueforest.json
    cp ${../themes/blueforest-light.json} $out/blueforest-light.json
    cp ${../themes/blueforest-light.json} $out/share/claude/themes/blueforest-light.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
