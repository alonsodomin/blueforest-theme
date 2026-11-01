# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-yazi-theme-check" { } ''
  # The package carries the flavour under the name of the flavour and under
  # the name Yazi reads.
  diff -r ${theme}/blueforest.yazi ${source}
  diff -r ${theme}/share/yazi/flavors/blueforest.yazi ${source}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
