# SPDX-License-Identifier: MPL-2.0
#
# Turns the canonical palette of the repository into the format 2 that the
# community palette registry of Noctalia requires.
#
# The canonical file is format 1: the `m`-prefixed camelCase names that every
# released Noctalia reads. Format 2 names every key after the colour role it
# sets, and it is what the registry accepts. The two files carry the same
# colours, and the check of the repository renders this file from the
# canonical one, so the two cannot drift.
#
# The filter is the inverse of the `upgradeFixedPaletteModeJson` of Noctalia,
# which upgrades a format 1 file to format 2 when it reads it.

def to_format_2:
  {
    primary: .mPrimary,
    on_primary: .mOnPrimary,
    secondary: .mSecondary,
    on_secondary: .mOnSecondary,
    tertiary: .mTertiary,
    on_tertiary: .mOnTertiary,
    error: .mError,
    on_error: .mOnError,
    surface: .mSurface,
    on_surface: .mOnSurface,
    surface_container: .mSurfaceVariant,
    on_surface_variant: .mOnSurfaceVariant,
    outline_variant: .mOutline,
    shadow: .mShadow,
    hover: .mHover,
    on_hover: .mOnHover,
    terminal: {
      normal: .terminal.normal,
      bright: .terminal.bright,
      foreground: .terminal.foreground,
      background: .terminal.background,
      selection_fg: .terminal.selectionFg,
      selection_bg: .terminal.selectionBg,
      cursor_text: .terminal.cursorText,
      cursor: .terminal.cursor
    }
  };

{
  version: 2,
  dark: (.dark | to_format_2),
  light: (.light | to_format_2)
}
