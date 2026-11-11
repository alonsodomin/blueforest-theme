# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
  sourceLight,
}:
pkgs.runCommand "blueforest-lazydocker-theme-check" { } ''
  # The package carries the theme under the name of the theme and under the
  # name lazydocker reads, and it carries the light variant as well.
  cmp ${theme}/blueforest.json ${source}
  cmp ${theme}/share/lazydocker/themes/blueforest.json ${source}
  cmp ${theme}/blueforest-light.json ${sourceLight}
  cmp ${theme}/share/lazydocker/themes/blueforest-light.json ${sourceLight}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
