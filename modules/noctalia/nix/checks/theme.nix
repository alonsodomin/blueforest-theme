# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository, in both
# of its formats.
{
  pkgs,
  theme,
  source,
  sourceV2,
}:
pkgs.runCommand "blueforest-noctalia-theme-check" { } ''
  # The package carries the theme under the name of the theme and in the
  # directory Noctalia reads the palettes from.
  cmp ${theme}/blueforest.json ${source}
  cmp ${theme}/share/noctalia/palettes/blueforest.json ${source}

  # And it carries the same theme in format 2, which the registry of the
  # community palettes of Noctalia requires.
  cmp ${theme}/blueforest-v2.json ${sourceV2}

  # And the attribution of the theme travels with it.
  test -f ${theme}/share/doc/blueforest/NOTICE.md
  test -f ${theme}/share/doc/blueforest/LICENSE

  touch $out
''
