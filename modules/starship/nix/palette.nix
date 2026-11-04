# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest palettes for Starship.
#
# A palette of Starship is a TOML file that carries a `[palettes.<name>]`
# table, and the name of the palette is the name of the table: blueforest and
# blueforest-light.
#
# The preset of the repository names the keys of the table instead of writing
# the colours down, so the preset and the palette are installed apart: the
# preset is what the prompt is, and the palette is what gives it a colour. The
# package carries the two variants, so that a consumer can read them directly.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-starship-palette-${version}"
  {
    meta = {
      description = "BlueForest palettes for Starship";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0, the palettes it carries are CC BY 4.0.
      license = [
        lib.licenses.mpl20
        lib.licenses.cc-by-40
      ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out
    cp ${../themes/palettes/blueforest.toml} $out/blueforest.toml
    cp ${../themes/palettes/blueforest-light.toml} $out/blueforest-light.toml

    # The attribution of the palettes travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
