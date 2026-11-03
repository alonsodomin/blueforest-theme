# SPDX-License-Identifier: MPL-2.0
#
# Checks that Noctalia reads the palette of the repository and that it accepts
# the file that selects it.
#
# Noctalia ignores a palette it cannot read, and it does so silently: a palette
# without the `terminal` object is rejected, and the shell falls back to the
# palette it ships with. The check therefore reads the palette with Noctalia
# itself, and looks at the tokens that come out of it.
#
# Noctalia is a shell, and a shell cannot be rendered in a build. The palette
# is expanded by the command line of Noctalia, `noctalia theme`, which is the
# same code that expands it when the shell starts, and the file that selects
# the palette is validated by `noctalia config validate`.
#
# The palette carries a dark and a light variant, and the check expands both:
# a palette with a single variant leaves the light mode of the shell with a
# hybrid of the two, because Noctalia expands the missing variant from the one
# it has.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-noctalia-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.noctalia
    ];
  }
  ''
    work="$TMPDIR/work"
    config="$TMPDIR/config"
    mkdir -p "$work" "$config/noctalia/palettes"

    # Noctalia reads the palettes of the user from the `palettes` directory of
    # its configuration directory.
    cp ${source} "$config/noctalia/palettes/blueforest.json"

    # And it selects one of them with the `source` and `custom_palette`
    # settings of its configuration. The module writes them in a file of their
    # own, which Noctalia merges with the rest of the configuration.
    cat >"$config/noctalia/blueforest.toml" <<'TOML'
    [theme]
    source = "custom"
    custom_palette = "blueforest"
    TOML

    # The file that selects the palette is valid for Noctalia.
    noctalia config validate "$config/noctalia/blueforest.toml"

    # Both variants carry every role of the interface and every colour of the
    # terminal, so that Noctalia does not paint a missing one as transparent
    # black.
    jq -e '
      def roles: [
        "mPrimary", "mOnPrimary", "mSecondary", "mOnSecondary", "mTertiary",
        "mOnTertiary", "mError", "mOnError", "mSurface", "mOnSurface",
        "mSurfaceVariant", "mOnSurfaceVariant", "mOutline", "mShadow",
        "mHover", "mOnHover"
      ];

      all(.dark, .light;
        (. as $mode
         | (roles | all(. as $key | ($mode[$key] | type) == "string"))
           and ($mode.terminal.normal | length == 8)
           and ($mode.terminal.bright | length == 8)
           and ([ "foreground", "background", "selectionFg", "selectionBg", "cursorText", "cursor" ]
                | all(. as $key | ($mode.terminal[$key] | type) == "string"))))
    ' "$config/noctalia/palettes/blueforest.json" >/dev/null

    # Noctalia expands the palette into the tokens of its interface, and every
    # role of the palette is the role of BlueForest.
    noctalia theme --theme-json "$config/noctalia/palettes/blueforest.json" \
      --dark -o "$work/dark.json"
    noctalia theme --theme-json "$config/noctalia/palettes/blueforest.json" \
      --light -o "$work/light.json"

    # The dark variant is the dark palette of BlueForest.
    jq -e '
      .primary == "#0099ff"
      and .on_primary == "#141f2e"
      and .secondary == "#91ccff"
      and .on_secondary == "#141f2e"
      and .tertiary == "#ffcc33"
      and .on_tertiary == "#141f2e"
      and .error == "#ff8080"
      and .on_error == "#141f2e"
      and .surface == "#141f2e"
      and .on_surface == "#d0d0d0"
      and .surface_variant == "#1c2d42"
      and .on_surface_variant == "#91ccff"
      and .outline_variant == "#333333"
      and .shadow == "#0a101d"
      and .hover == "#375780"
      and .on_hover == "#d0d0d0"
      and .terminal_background == "#141f2e"
      and .terminal_foreground == "#d0d0d0"
    ' "$work/dark.json" >/dev/null

    # And the light variant is the light palette of BlueForest.
    jq -e '
      .primary == "#0099ff"
      and .on_primary == "#141f2e"
      and .secondary == "#3a5f8a"
      and .on_secondary == "#efefef"
      and .tertiary == "#b3871f"
      and .on_tertiary == "#141f2e"
      and .error == "#dc322f"
      and .on_error == "#efefef"
      and .surface == "#efefef"
      and .on_surface == "#141f2e"
      and .surface_variant == "#e7e7e7"
      and .on_surface_variant == "#56697d"
      and .outline_variant == "#7f8fa3"
      and .shadow == "#141f2e"
      and .hover == "#d0d0d0"
      and .on_hover == "#141f2e"
      and .terminal_background == "#efefef"
      and .terminal_foreground == "#141f2e"
    ' "$work/light.json" >/dev/null

    # No token of either variant is missing, and the two variants are not the
    # same palette: a dark-only palette would expand into a hybrid of the two
    # in light mode.
    jq -e 'all(.[]; . != null)' "$work/dark.json" >/dev/null
    jq -e 'all(.[]; . != null)' "$work/light.json" >/dev/null
    ! cmp -s "$work/dark.json" "$work/light.json"

    touch $out
  ''
