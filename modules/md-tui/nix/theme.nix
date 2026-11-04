# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for md-tui.
#
# The theme is a palette of md-tui, the format md-tui reads, and the name of
# the theme is the name of the file: blueforest.json.
#
# md-tui saves the palettes of the user in the `themes` directory of its
# configuration directory, and it selects one of them with the name of the
# file. The package therefore carries the theme twice: under the name of the
# theme, so that a consumer can read it directly, and in the directory where
# md-tui looks for the palettes, so that a consumer can install it.
#
# The colours are the ones of BlueForest: the blue of the keywords, the amber
# of the operators, the green of the strings, the red of the numbers, the pale
# yellow of the variables, and the dark blue of the background.
#
# md-tui reads every colour of a palette, and it ignores a palette it cannot
# read silently: the interface falls back to the colours it ships with. Every
# colour md-tui knows is set here, so that nothing is left to chance.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-md-tui-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for md-tui";
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
    mkdir -p $out/share/mdt/themes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/mdt/themes/blueforest.json
    cp ${../themes/blueforest-light.json} $out/blueforest-light.json
    cp ${../themes/blueforest-light.json} $out/share/mdt/themes/blueforest-light.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
