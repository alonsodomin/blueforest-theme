# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for lazygit.
#
# The theme is a configuration file of lazygit that carries the theme, the
# format lazygit reads, and the name of the theme is the name of the file:
# blueforest.json.
#
# The file is JSON, and JSON is a subset of YAML: lazygit reads its
# configuration with a YAML parser, and it reads this file as its own format.
# The file is JSON for the sake of Nix, which reads it at evaluation time, so
# that the Home Manager module carries the very same colours as the file.
#
# lazygit has no theme file of its own: the theme is the `gui.theme` mapping of
# the configuration file, and the file of the theme carries it under that key.
#
# The colours are the ones of BlueForest: the blue of the keywords, the amber
# of the operators, the green of the strings, the red of the numbers, the pale
# yellow of the variables, and the dark blue of the background.
#
# lazygit ignores a key it does not know, and a colour it cannot resolve, and
# it does so silently: the interface falls back to the colours lazygit ships
# with. Every key lazygit knows is set here, so that nothing is left to
# chance.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-lazygit-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for lazygit";
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
    mkdir -p $out/share/lazygit/themes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/lazygit/themes/blueforest.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
