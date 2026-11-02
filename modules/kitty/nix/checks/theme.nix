# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-kitty-theme-check" { } ''
  # The package carries the theme under the name of the theme and under the
  # name kitty reads.
  cmp ${theme}/blueforest.conf ${source}
  cmp ${theme}/share/kitty/themes/blueforest.conf ${source}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
