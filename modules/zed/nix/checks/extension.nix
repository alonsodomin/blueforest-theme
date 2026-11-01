# SPDX-License-Identifier: MPL-2.0
#
# Checks that the package carries the extension of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-zed-extension-check" { } ''
  # The package is the extension: the manifest and the theme.
  cmp ${theme}/extension.toml ${source}/extension.toml
  cmp ${theme}/themes/blueforest.json ${source}/themes/blueforest.json

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE
  test -f ${theme}/share/doc/blueforest/LICENSE.md

  touch $out
''
