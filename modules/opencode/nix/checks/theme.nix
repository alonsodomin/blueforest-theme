# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository, and
# that the theme is one OpenCode reads.
{
  lib,
  pkgs,
  theme,
  source,
}:
let
  # The theme of the repository, the tokens it misses, and the references of
  # it that do not resolve.
  parsed = builtins.fromJSON (builtins.readFile source);

  shape = import ./lib/shape.nix {
    inherit lib;
    theme = parsed;
  };

  references = import ./lib/references.nix {
    inherit lib;
    theme = parsed;
  };
in
pkgs.runCommand "blueforest-opencode-theme-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    missingTokens = builtins.toJSON shape.missingTokens;
    missingAliases = builtins.toJSON shape.missingAliases;
    modes = builtins.toJSON references.modes;
  }
  ''
    # The theme of the package is the theme of the repository.
    cmp ${theme}/blueforest.json ${source}
    cmp ${theme}/share/opencode/themes/blueforest.json ${source}

    # The theme is one OpenCode 2 reads: the tokens of the base, and a
    # palette per mode.
    jq -e 'has("$schema") and has("base") and (has("dark") or has("light"))' ${source} >/dev/null

    # Every token OpenCode reads is there. A theme that misses one is a
    # theme OpenCode ignores, and it ignores it silently.
    count=$(echo "$missingTokens" | jq 'length')
    if [ "$count" -ne 0 ]; then
      echo "the theme does not have the tokens OpenCode reads:" >&2
      echo "$missingTokens" | jq -r '.[] | join(".")' >&2
      exit 1
    fi

    # And so is every alias of the hues.
    count=$(echo "$missingAliases" | jq 'length')
    if [ "$count" -ne 0 ]; then
      echo "the theme does not have the aliases of the hues:" >&2
      echo "$missingAliases" | jq -r '.[] | join(".")' >&2
      exit 1
    fi

    # Every mode of the theme is checked on its own: the modes do not
    # inherit from each other, so a reference that resolves in one of them
    # may not resolve in the other.
    echo "$modes" | jq -r '.[] | .name' | while read -r mode; do
      unresolved=$(echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .unresolved | length')
      if [ "$unresolved" -ne 0 ]; then
        echo "the $mode theme has references that do not resolve to a colour:" >&2
        echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .unresolved[]' >&2
        exit 1
      fi

      unresolved=$(echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .unresolvedHues | length')
      if [ "$unresolved" -ne 0 ]; then
        echo "the $mode theme has aliases that do not resolve to a hue:" >&2
        echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .unresolvedHues[]' >&2
        exit 1
      fi

      missing=$(echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .missingHues | length')
      if [ "$missing" -ne 0 ]; then
        echo "the $mode theme has hues it does not have:" >&2
        echo "$modes" | jq -r --arg mode "$mode" '.[] | select(.name == $mode) | .missingHues[]' >&2
        exit 1
      fi
    done

    touch $out
  ''
