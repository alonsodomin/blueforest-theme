-- The light variant of the BlueForest theme for Neovim.
--
-- A port of BlueForest by mathias[at]decodified[dot]com, published at
-- <https://github.com/sirthias/BlueForest> under the CC BY 3.0 licence, and
-- distributed here under the CC BY 4.0 licence. See NOTICE.md.
--
-- The colours are the ones of the theme: the palette is written down here,
-- and every highlight group is read from it by the module both variants
-- share.
--
-- The name of the theme is `blueforest-light`, the name of the file it is loaded
-- from: `:colorscheme blueforest-light`.
local theme = require("blueforest")

theme.setup({
  name = "blueforest-light",
  background = "light",

  palette = {
    fg = "#141F2E",
    bg = "#E8ECF2",
    bg_dark = "#E0E4EA",
    bg_light = "#E8ECF2",
    bg_input = "#E0E4EA",
    bg_sel = "#3A5F8A",
    bg_hover = "#C9CDD3",
    bg_border = "#7F8FA3",
    accent = "#3A5F8A",
    accent_light = "#1B7A70",
    function_blue = "#1B7A70",
    comment = "#56697D",
    string = "#1E5C1E",
    number = "#B02A28",
    operator = "#C57633",
    identifier = "#1B2B40",
    variable = "#333333",
    parameter = "#333333",
    type = "#808000",
    tag = "#219186",
    attribute = "#333333",
    library = "#FFCC33",
    diff_add = "#1E5C1E",
    diff_del = "#B02A28",
    diff_chg = "#C57633",
    diff_header = "#141F2E",
    status = "#1E5C1E",
    status_nofolder = "#3A5F8A",
    status_debug = "#C57633",
    status_remote = "#B02A28",
    misc = "#CB4B16",
    plain = "#141F2E",
  },
})
