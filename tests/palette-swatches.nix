# SPDX-License-Identifier: MPL-2.0
#
# Checks that the swatches of the palettes of the documentation are the
# colours of the palette of Noctalia.
#
# The check spans the documentation and the application of Noctalia, so it
# belongs to the repository and not to one of them.
#
# The palette of Noctalia is the reference of the colours of the repository,
# and the documentation shows every colour of it with a swatch next to its
# hexadecimal value. The swatch and the value have to be the same colour, and
# every colour of the palette has to be shown, so that the documentation
# cannot drift away from the palette.
{
  pkgs,
  # The page of the documentation that carries the palettes.
  docs,
  # The canonical palette of the repository.
  palette,
}:
pkgs.runCommand "blueforest-palette-swatches-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  }
  ''
    # The swatches of a page, as the value and the colour of the box. The
    # value comes first, and the box is filled with the colour of the value.
    swatches() {
      grep -oE '`#[0-9A-Fa-f]{6}` <span class="blueforest-swatch" style="background-color:#[0-9A-Fa-f]{6}"></span>' "$1" \
        | sed -E 's/`#([0-9A-Fa-f]{6})`.*background-color:#([0-9A-Fa-f]{6})".*/\1 \2/'
    }

    # The colours of a variant of the palette, without the hash, so that
    # they can be compared with the swatches.
    colours() {
      jq -r ".$1 | .. | strings | select(test(\"^#[0-9A-Fa-f]{6}$\"))" ${palette} \
        | tr 'a-f' 'A-F' | cut -c2- | sort -u
    }

    # The page is split in the two sections of the palettes: the dark one
    # comes first, and the light one after its heading.
    awk '/^### The light palette$/ { light = 1 } !light' ${docs} >"$TMPDIR/dark.md"
    awk '/^### The light palette$/ { light = 1 } light' ${docs} >"$TMPDIR/light.md"

    # The swatch of a value is filled with the colour of the value.
    swatches ${docs} \
      | awk '$1 != $2 {
          printf "the swatch of %s is filled with %s\n", $1, $2 > "/dev/stderr";
          bad = 1
        }
        END { exit bad }'

    # And the swatches of every section are the colours of its palette.
    for variant in dark light; do
      colours "$variant" >"$TMPDIR/$variant-palette"
      swatches "$TMPDIR/$variant.md" | cut -d' ' -f2 | tr 'a-f' 'A-F' | sort -u \
        >"$TMPDIR/$variant-swatches"

      missing="$(comm -23 "$TMPDIR/$variant-palette" "$TMPDIR/$variant-swatches")"
      if [ -n "$missing" ]; then
        echo "the palette of $variant has colours that the documentation does not show:" >&2
        echo "$missing" >&2
        exit 1
      fi

      extra="$(comm -13 "$TMPDIR/$variant-palette" "$TMPDIR/$variant-swatches")"
      if [ -n "$extra" ]; then
        echo "the documentation shows colours that the palette of $variant does not have:" >&2
        echo "$extra" >&2
        exit 1
      fi
    done

    touch $out
  ''
