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
{
  lib,
  pkgs,
  version,
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

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
