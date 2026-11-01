# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme as a Zed extension.
#
# Zed reads the themes of the extensions it installs, and an extension is a
# directory with a manifest and the themes it provides. This package is that
# directory: the manifest of the extension and the theme of the repository.
#
# The sources are the submodule at `extension/`, which is the repository Zed
# installs the extension from. Nix cannot read the contents of a submodule of
# a git tree, so the checks of the repository run against the working tree,
# where the submodule is checked out.
#
# The manifest keeps the version it has in the extension repository: that
# version is Zed's own, and Zed compares it with the one of the repository to
# decide whether the extension has to be updated.
{
  lib,
  pkgs,
  version,
  source,
}:
pkgs.runCommand "blueforest-zed-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for Zed";
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
    mkdir -p $out/themes
    cp ${source}/extension.toml $out/extension.toml
    cp ${source}/themes/blueforest.json $out/themes/blueforest.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE

    # And the licence of the extension itself, which is the licence of the
    # theme: the theme comes from the extension repository.
    cp ${source}/LICENSE.md $out/share/doc/blueforest/LICENSE.md
  ''
