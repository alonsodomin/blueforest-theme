# SPDX-License-Identifier: MPL-2.0
#
# Checks that the extension of the package is the extension Zed reads.
#
# The manifest declares the theme and the id of the extension, which is the
# name of the directory Zed installs the extension in. The theme is the format
# Zed reads: a family of themes with a name, and one dark theme in it.
{
  pkgs,
  theme,
}:
pkgs.runCommand "blueforest-zed-theme-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
  }
  ''
    # The manifest of the extension declares the theme, and the id of the
    # extension is the name of the directory Zed installs it in.
    grep -q '^id = "blueforest-theme"$' ${theme}/extension.toml
    grep -q '^schema_version = 1$' ${theme}/extension.toml
    grep -q '^themes = \["themes/blueforest.json"\]$' ${theme}/extension.toml

    # The theme is the format Zed reads.
    jq -e '."$schema" == "https://zed.dev/schema/themes/v0.2.0.json"' \
      ${theme}/themes/blueforest.json >/dev/null

    jq -e '.name == "BlueForest"' ${theme}/themes/blueforest.json >/dev/null

    jq -e '.themes | length == 1' ${theme}/themes/blueforest.json >/dev/null

    jq -e '.themes[0].name == "BlueForest - Dark"' \
      ${theme}/themes/blueforest.json >/dev/null

    jq -e '.themes[0].appearance == "dark"' \
      ${theme}/themes/blueforest.json >/dev/null

    touch $out
  ''
