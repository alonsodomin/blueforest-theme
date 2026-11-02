# SPDX-License-Identifier: MPL-2.0
#
# Checks that the stylesheet of the package is the stylesheet of the
# repository, and that it only recolours the dark scheme.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-mkdocs-theme-check" { } ''
  cmp ${theme}/blueforest.css ${source}

  # The stylesheet is an override of the dark scheme: the light scheme keeps
  # the palette of Material.
  grep -q '\[data-md-color-scheme="slate"\]' ${theme}/blueforest.css
  ! grep -q 'data-md-color-scheme="default"' ${theme}/blueforest.css

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
