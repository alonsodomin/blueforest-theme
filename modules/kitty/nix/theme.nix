# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for kitty.
#
# The theme is a configuration file of kitty, the format kitty reads, and the
# name of the theme is the name of the file: blueforest.
#
# kitty reads the themes of the user from the `themes` directory of its
# configuration directory, and it selects one of them with an `include` line
# in its own configuration. The package therefore carries the theme twice:
# under the name of the theme, so that a consumer can read it directly, and
# under the name kitty reads, so that a consumer can include it.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-kitty-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for kitty";
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
    mkdir -p $out/share/kitty/themes
    cp ${../themes/blueforest.conf} $out/blueforest.conf
    cp ${../themes/blueforest.conf} $out/share/kitty/themes/blueforest.conf

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
