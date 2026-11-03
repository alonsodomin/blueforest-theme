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

    # The palette carries every role of the interface and every colour of the
    # terminal, so that Noctalia does not paint a missing one as transparent
    # black.
    jq -e '
      .dark as $d
      | (
          [
            "mPrimary",
            "mOnPrimary",
            "mSecondary",
            "mOnSecondary",
            "mTertiary",
            "mOnTertiary",
            "mError",
            "mOnError",
            "mSurface",
            "mOnSurface",
            "mSurfaceVariant",
            "mOnSurfaceVariant",
            "mOutline",
            "mShadow",
            "mHover",
            "mOnHover"
          ]
          | all(. as $key | ($d[$key] | type) == "string")
        )
        and ($d.terminal.normal | length == 8)
        and ($d.terminal.bright | length == 8)
        and ($d.terminal.foreground | type == "string")
        and ($d.terminal.background | type == "string")
        and ($d.terminal.selectionFg | type == "string")
        and ($d.terminal.selectionBg | type == "string")
        and ($d.terminal.cursorText | type == "string")
        and ($d.terminal.cursor | type == "string")
    ' "$config/noctalia/palettes/blueforest.json" >/dev/null

    # Noctalia expands the palette into the tokens of its interface, and every
    # role of the palette is the role of BlueForest.
    noctalia theme --theme-json "$config/noctalia/palettes/blueforest.json" \
      --dark -o "$work/tokens.json"

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
    ' "$work/tokens.json" >/dev/null

    touch $out
  ''
