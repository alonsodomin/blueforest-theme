# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the code preview of Yazi is the theme of the code
# preview of bat.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: the flavour of Yazi paints the code of its preview with a TextMate
# theme, and it is the theme the repository ships for bat. The flavour links
# to the theme of bat, so the two of them cannot drift apart.
#
# There is a flavour per mode, and every one of them links to the variant of
# the theme of bat that matches it.
{
  pkgs,
  # The package of the theme of Yazi.
  yazi,
  # The theme of the code preview of bat.
  bat,
  # The light variant of the theme of the code preview of bat.
  batLight,
}:
pkgs.runCommand "blueforest-yazi-tmtheme-check" { } ''
  # The flavour of Yazi links to the theme of bat.
  test -L ${yazi}/share/yazi/flavors/blueforest.yazi/tmtheme.xml

  # And the theme it links to is the one of bat.
  cmp ${yazi}/share/yazi/flavors/blueforest.yazi/tmtheme.xml ${bat}

  # And so does the light flavour, with the light theme of bat.
  test -L ${yazi}/share/yazi/flavors/blueforest-light.yazi/tmtheme.xml
  cmp ${yazi}/share/yazi/flavors/blueforest-light.yazi/tmtheme.xml ${batLight}

  touch $out
''
