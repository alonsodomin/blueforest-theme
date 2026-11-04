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
#
# The names of the keys are the ones of the palette of the community
# catalogue of Noctalia for Starship, so that the preset paints with the
# palette of the catalogue as well. The check compares the keys of the
# palettes with the ones of that catalogue, so that the two cannot drift:
#
#   https://github.com/noctalia-dev/community-templates/blob/main/starship/starship.toml
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

        # The keys of the community catalogue of Noctalia for Starship.
        cat >"$TMPDIR/community-keys" <<'EOF'
    base
    black
    blue
    crust
    cyan
    flamingo
    green
    lavender
    magenta
    mantle
    maroon
    mauve
    overlay0
    overlay1
    overlay2
    peach
    pink
    red
    rosewater
    sapphire
    sky
    subtext0
    subtext1
    surface0
    surface1
    surface2
    teal
    text
    white
    yellow
    EOF

        # The two palettes define the same keys.
        diff \
          <(sed -n '/^\[palettes\./,$p' "$paletteDark" | grep -oE '^[A-Za-z0-9_-]+' | sort) \
          <(sed -n '/^\[palettes\./,$p' "$paletteLight" | grep -oE '^[A-Za-z0-9_-]+' | sort)

        # And they define the keys of the catalogue, so that the preset paints
        # with the palette of the catalogue as well.
        for palette in "$paletteDark" "$paletteLight"; do
          sed -n '/^\[palettes\./,$p' "$palette" | grep -oE '^[A-Za-z0-9_-]+' | sort \
            >"$TMPDIR/palette-keys"
          if ! diff "$TMPDIR/community-keys" "$TMPDIR/palette-keys"; then
            echo "the palette does not carry the keys of the community catalogue of Noctalia" >&2
            exit 1
          fi
        done

        touch $out
  ''
