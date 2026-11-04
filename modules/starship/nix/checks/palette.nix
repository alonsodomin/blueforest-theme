# SPDX-License-Identifier: MPL-2.0
#
# Checks that the packaged palettes are the palettes of the repository.
{
  pkgs,
  palette,
  palettes,
}:
pkgs.runCommand "blueforest-starship-palette-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    cmp ${palette}/blueforest.toml ${palettes.blueforest}
    cmp ${palette}/blueforest-light.toml ${palettes.blueforest-light}

    # The attribution of the palettes travels with the package.
    test -f ${palette}/share/doc/blueforest/NOTICE.md
    test -f ${palette}/share/doc/blueforest/LICENSE

    touch $out
  ''
