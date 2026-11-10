-- The light variant of the BlueForest theme for lualine.
--
-- A port of BlueForest by mathias[at]decodified[dot]com, published at
-- <https://github.com/sirthias/BlueForest> under the CC BY 3.0 licence, and
-- distributed here under the CC BY 4.0 licence. See NOTICE.md.
--
-- lualine reads a table of colours rather than a colourscheme, so the palette
-- of the theme is written down here for the fourth time. The colours are the
-- ones of the colourscheme: the light background of the editor, the amber of
-- the operators and the teal of the functions.
--
-- The name of the theme is `blueforest-light`, the name of the file it is
-- loaded from. lualine finds it on its own: the `auto` theme looks the theme
-- up by the name of the colourscheme, which is `blueforest-light` as well.
--
-- Every mode carries its own colour for the section of the mode, and the
-- sections a mode does not describe fall back to `normal`, which is what
-- lualine does with a section a mode does not describe.
return {
  normal = {
    a = { fg = "#141F2E", bg = "#FFCC33" },
    b = { fg = "#141F2E", bg = "#1B7A70" },
    c = { fg = "#E8ECF2", bg = "#1E5C1E" },
  },
  insert = {
    a = { fg = "#E8ECF2", bg = "#1E5C1E" },
  },
  visual = {
    a = { fg = "#E8ECF2", bg = "#3A5F8A" },
  },
  replace = {
    a = { fg = "#E8ECF2", bg = "#B02A28" },
  },
  command = {
    a = { fg = "#E8ECF2", bg = "#1B2B40" },
  },
  terminal = {
    a = { fg = "#E8ECF2", bg = "#1B7A70" },
  },
  inactive = {
    a = { fg = "#56697D", bg = "#E0E4EA" },
    b = { fg = "#56697D", bg = "#E0E4EA" },
    c = { fg = "#56697D", bg = "#E0E4EA" },
  },
}
