# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for btop.
#
# The theme is a theme file of btop, the format btop reads, and the name of
# the theme is the name of the file: blueforest.theme.
#
# btop reads the themes of the user from the `themes` directory of its
# configuration directory, and it reads the themes of the system from the
# `themes` directory next to its binary. The package therefore carries the
# theme twice: under the name of the theme, so that a consumer can read it
# directly, and under the name btop reads, so that a consumer can install it
# where btop finds it.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-btop-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for btop";
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
    mkdir -p $out/share/btop/themes
    cp ${../themes/blueforest.theme} $out/blueforest.theme
    cp ${../themes/blueforest.theme} $out/share/btop/themes/blueforest.theme

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
