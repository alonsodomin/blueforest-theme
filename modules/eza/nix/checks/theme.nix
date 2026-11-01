# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-eza-theme-check" { } ''
  # The package carries the theme under the name of the theme and under the
  # name eza reads.
  cmp ${theme}/blueforest.yml ${source}
  cmp ${theme}/share/eza/theme.yml ${source}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
