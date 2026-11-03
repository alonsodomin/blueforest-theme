# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
#
# The flavour of the package links to the theme of bat for the colours of the
# code preview, so the link is checked apart from the files of the flavour.
{
  pkgs,
  theme,
  source,
  sourceLight,
  batTheme,
}:
pkgs.runCommand "blueforest-yazi-theme-check" { } ''
  # The package carries the flavour under the name of the flavour and under
  # the name Yazi reads.
  diff -r --exclude=tmtheme.xml ${theme}/blueforest.yazi ${source}
  diff -r --exclude=tmtheme.xml ${theme}/share/yazi/flavors/blueforest.yazi ${source}
  diff -r --exclude=tmtheme.xml ${theme}/blueforest-light.yazi ${sourceLight}
  diff -r --exclude=tmtheme.xml ${theme}/share/yazi/flavors/blueforest-light.yazi ${sourceLight}

  # And the colours of the code preview are the ones of the theme of bat,
  # the variant that matches the flavour.
  test -L ${theme}/blueforest.yazi/tmtheme.xml
  test -L ${theme}/share/yazi/flavors/blueforest.yazi/tmtheme.xml
  test "$(readlink ${theme}/blueforest.yazi/tmtheme.xml)" = \
    "${batTheme}/share/bat/themes/BlueForest.tmTheme"
  test "$(readlink ${theme}/share/yazi/flavors/blueforest.yazi/tmtheme.xml)" = \
    "${batTheme}/share/bat/themes/BlueForest.tmTheme"

  test -L ${theme}/blueforest-light.yazi/tmtheme.xml
  test -L ${theme}/share/yazi/flavors/blueforest-light.yazi/tmtheme.xml
  test "$(readlink ${theme}/blueforest-light.yazi/tmtheme.xml)" = \
    "${batTheme}/share/bat/themes/BlueForestLight.tmTheme"
  test "$(readlink ${theme}/share/yazi/flavors/blueforest-light.yazi/tmtheme.xml)" = \
    "${batTheme}/share/bat/themes/BlueForestLight.tmTheme"

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
