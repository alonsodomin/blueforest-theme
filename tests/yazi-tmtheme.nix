# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the code preview of Yazi is the theme of the code
# preview of bat.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: the flavour of Yazi carries a TextMate theme, and it is the theme
# the repository ships for bat. The two of them have to be the same file, or
# the code of the preview of Yazi is painted with a palette that the rest of
# the repository does not use.
{
  pkgs,
  # The theme of the code preview of Yazi.
  yazi,
  # The theme of the code preview of bat.
  bat,
}:
pkgs.runCommand "blueforest-yazi-tmtheme-check" { } ''
  # The two themes are the same file.
  cmp ${yazi} ${bat}

  touch $out
''
