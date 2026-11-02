# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for MkDocs.
#
# The theme is a stylesheet, and the name of the theme is the name of the
# file: blueforest. It overrides the colours of the code blocks of Material
# for MkDocs in the dark scheme, and leaves the light scheme alone.
#
# MkDocs reads the stylesheet from the sources of the site, through
# `extra_css`, so the package carries it at the root: a consumer copies it
# into the directory of the site.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-mkdocs-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for MkDocs";
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
    mkdir -p $out
    cp ${../themes/blueforest.css} $out/blueforest.css

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
