# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Yazi.
#
# The theme is a flavour: a directory with the colours of the theme and the
# colours of the code preview, in the format Yazi reads.
#
# Yazi reads the flavours from the `flavors` directory of its configuration
# directory, and the name of a flavour is the name of its directory, without
# the `.yazi` suffix. There is no name to select in the flavour itself, so the
# package carries it twice: under the name of the flavour, so that a consumer
# can read it directly, and under the name Yazi reads, so that a consumer can
# point the configuration directory of Yazi at it.
#
# The flavour paints the code of the preview with a TextMate theme, and that
# theme is the one the repository ships for bat. The package therefore links
# to it, instead of carrying a copy of it that would drift apart from it.
{
  lib,
  pkgs,
  version,

  # The package of the theme of bat, which carries the TextMate theme of the
  # code preview.
  batTheme,
}:
pkgs.runCommand "blueforest-yazi-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for Yazi";
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
    mkdir -p $out/share/yazi/flavors
    cp -r ${../themes/blueforest.yazi} $out/blueforest.yazi
    cp -r ${../themes/blueforest.yazi} $out/share/yazi/flavors/blueforest.yazi
    cp -r ${../themes/blueforest-light.yazi} $out/blueforest-light.yazi
    cp -r ${../themes/blueforest-light.yazi} $out/share/yazi/flavors/blueforest-light.yazi

    # The colours of the code preview are the ones of the theme of bat, so
    # the flavour links to the theme of bat. The store is read-only, so the
    # directories have to be writable to carry the link. Every flavour links
    # to the variant of the theme of bat that matches it.
    chmod u+w $out/blueforest.yazi $out/share/yazi/flavors/blueforest.yazi
    chmod u+w $out/blueforest-light.yazi $out/share/yazi/flavors/blueforest-light.yazi
    ln -s ${batTheme}/share/bat/themes/BlueForest.tmTheme \
      $out/blueforest.yazi/tmtheme.xml
    ln -s ${batTheme}/share/bat/themes/BlueForest.tmTheme \
      $out/share/yazi/flavors/blueforest.yazi/tmtheme.xml
    ln -s ${batTheme}/share/bat/themes/BlueForestLight.tmTheme \
      $out/blueforest-light.yazi/tmtheme.xml
    ln -s ${batTheme}/share/bat/themes/BlueForestLight.tmTheme \
      $out/share/yazi/flavors/blueforest-light.yazi/tmtheme.xml

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
