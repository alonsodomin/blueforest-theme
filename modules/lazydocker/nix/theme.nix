# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for lazydocker.
#
# The theme is a configuration file of lazydocker that carries the theme, the
# format lazydocker reads, and the name of the theme is the name of the file:
# blueforest.json, and blueforest-light.json for the light variant.
#
# The file is JSON, and JSON is a subset of YAML: lazydocker reads its
# configuration with a YAML parser, and it reads this file as its own format.
# The file is JSON for the sake of Nix, which reads it at evaluation time, so
# that the Home Manager module carries the very same colours as the file.
#
# lazydocker has no theme file of its own: the theme is the `gui.theme` mapping
# of the configuration file, and the file of the theme carries it under that
# key.
#
# The colours are the ones of BlueForest: the blue of the keywords, the amber
# of the operators, the green of the strings, the red of the numbers, the pale
# yellow of the variables, and the dark blue of the background.
#
# lazydocker knows four colours, and every one of them is set here: the border
# of the window that has the focus, the border of the windows that have no
# focus, the background of the selected line, and the text of the line at the
# bottom. A key lazydocker does not know is ignored, and a colour it cannot
# resolve is painted as the default colour, so nothing is left to chance.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-lazydocker-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for lazydocker";
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
    mkdir -p $out/share/lazydocker/themes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/lazydocker/themes/blueforest.json
    cp ${../themes/blueforest-light.json} $out/blueforest-light.json
    cp ${../themes/blueforest-light.json} $out/share/lazydocker/themes/blueforest-light.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
