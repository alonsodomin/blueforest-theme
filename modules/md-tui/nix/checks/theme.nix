# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-md-tui-theme-check" { } ''
  # The package carries the theme under the name of the theme and under the
  # name md-tui reads.
  cmp ${theme}/blueforest.json ${source}
  cmp ${theme}/share/mdt/themes/blueforest.json ${source}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
