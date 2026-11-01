# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for eza.
#
# The theme is a YAML file, the format eza reads, and the name of the theme is
# the name of the file: blueforest.
#
# eza reads a single theme file, `theme.yml`, from the configuration directory
# of the user, or from the directory the `EZA_CONFIG_DIR` variable points at.
# There is no directory of themes and no name to select, so the package
# carries the theme twice: under the name of the theme, so that a consumer can
# read it directly, and under the name eza reads, so that a consumer can point
# `EZA_CONFIG_DIR` at it.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-eza-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for eza";
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
    mkdir -p $out/share/eza
    cp ${../themes/blueforest.yml} $out/blueforest.yml
    cp ${../themes/blueforest.yml} $out/share/eza/theme.yml

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
