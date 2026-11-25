-- The BlueForest theme for Neovim.
--
-- A port of BlueForest by mathias[at]decodified[dot]com, published at
-- <https://github.com/sirthias/BlueForest> under the CC BY 3.0 licence, and
-- distributed here under the CC BY 4.0 licence. See NOTICE.md.
--
-- The colours are the ones of the theme: the palette is written down here,
-- and every highlight group is read from it by the module both variants
-- share.
--
-- The name of the theme is `blueforest`, the name of the file it is loaded
-- from: `:colorscheme blueforest`.
local theme = require("blueforest")

theme.setup({
  name = "blueforest",
  background = "dark",

  palette = {
    fg = "#D0D0D0",
    bg = "#141F2E",
    bg_dark = "#0A101D",
    bg_light = "#1b2b40",
    bg_input = "#1c2d42",
    bg_sel = "#3a5f8a",
    bg_hover = "#375780",
    bg_border = "#333333",

    accent = "#0099FF",
    accent_light = "#91CCFF",
    function_blue = "#a2cff5",

    comment = "#a0ffa0",
    string = "#80ff80",
    number = "#FF8080",
    operator = "#ffcc33",
    identifier = "#F7FF66",
    variable = "#fffab1",
    parameter = "#e7e7e7",
    type = "#808000",
    tag = "#91ccff",
    attribute = "#fffab1",
    library = "#FFCC33",

    diff_add = "#219186",
    diff_del = "#dc322f",
    diff_chg = "#c57633",
    diff_header = "#E0EDDD",

    status = "#1e5c1e",
    status_nofolder = "#273e5c",
    status_debug = "#c57633",
    status_remote = "#800000",

    misc = "#ddbb88",
    plain = "#efefef",
  },
})
