# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Noctalia.
#
# The theme is a palette of Noctalia, the format Noctalia reads, and the name
# of the theme is the name of the file: blueforest.json.
#
# Noctalia reads the palettes of the user from the `palettes` directory of its
# configuration directory, and it selects one of them with the `custom_palette`
# setting of its configuration file. The package therefore carries the theme
# twice: under the name of the theme, so that a consumer can read it directly,
# and in the directory where Noctalia looks for the palettes, so that a
# consumer can install it.
#
# The palette is the format of the community palettes of Noctalia: the sixteen
# roles of the interface with the `m` prefix, and the colours of the terminal.
# Noctalia rejects a palette that does not carry the terminal colours, so the
# block is not optional.
#
# The package also carries the same palette in format 2, the format that names
# every key after the colour role it sets and that the community palette
# registry of Noctalia requires. Every released Noctalia reads format 1, so
# that is the file the package installs; format 2 is there for the registry
# and for the releases that read it.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-noctalia-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for Noctalia";
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
    mkdir -p $out/share/noctalia/palettes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/noctalia/palettes/blueforest.json

    # The same palette in format 2, which the registry of the community
    # palettes of Noctalia requires.
    cp ${../themes/blueforest-v2.json} $out/blueforest-v2.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
