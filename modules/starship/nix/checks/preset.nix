# SPDX-License-Identifier: MPL-2.0
#
# Checks that the packaged preset is the preset of the repository, and that
# the preset and the palettes agree on the names of the colours.
#
# The preset writes no colour down: it names the keys of a palette, and the
# palette is what gives them a colour. A key the preset names and a palette
# does not define is painted with no colour at all, and Starship reports
# nothing, so the check reads the two files and compares the names.
#
# The two palettes define the same keys, so that the preset paints the same
# segments in both variants.
{
  pkgs,
  preset,
  source,
  palettes,
}:
pkgs.runCommand "blueforest-starship-preset-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.diffutils
      pkgs.gnugrep
      pkgs.gnused
    ];

    paletteDark = palettes.blueforest;
    paletteLight = palettes.blueforest-light;
  }
  ''
    cmp ${preset}/blueforest.toml ${source}
    cmp ${preset}/share/starship/presets/blueforest.toml ${source}

    # The preset names the colours of the palette, and it writes none down.
    if grep -Eq '#[0-9A-Fa-f]{6}' ${source}; then
      echo "the preset carries a literal colour" >&2
      exit 1
    fi

    # Every colour the preset names is a key of both palettes.
    keys=$(grep -oE '(fg|bg):[A-Za-z0-9_-]+' ${source} | sed -E 's/^(fg|bg)://' | sort -u)
    test -n "$keys"
    for palette in "$paletteDark" "$paletteLight"; do
      for key in $keys; do
        if ! grep -qE "^$key[[:space:]]*=" "$palette"; then
          echo "the preset names the key $key, which $palette does not define" >&2
          exit 1
        fi
      done
    done

    # The two palettes define the same keys.
    diff \
      <(sed -n '/^\[palettes\./,$p' "$paletteDark" | grep -oE '^[A-Za-z0-9_-]+' | sort) \
      <(sed -n '/^\[palettes\./,$p' "$paletteLight" | grep -oE '^[A-Za-z0-9_-]+' | sort)

    touch $out
  ''
