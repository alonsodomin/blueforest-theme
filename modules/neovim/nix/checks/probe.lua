-- SPDX-License-Identifier: MPL-2.0
--
-- The probe of the theme check.
--
-- It reads the paths of the packages from the environment, so that the check
-- does not have to write them into the script.
--
-- The theme is a plugin, so it is put on the runtimepath the way Home
-- Manager puts it there, and lualine is put there as well.

local theme = assert(os.getenv("BLUEFOREST_THEME"), "the theme of the package is not set")
local lualine = assert(os.getenv("BLUEFOREST_LUALINE"), "lualine is not set")

vim.opt.runtimepath:append(theme)
vim.opt.runtimepath:append(lualine)

-- Neovim reads a colourscheme from the `colors` directory of the
-- runtimepath, and the name of the theme is the name of the file.
vim.cmd.colorscheme("blueforest")
assert(vim.g.colors_name == "blueforest", "the colourscheme did not set its name")

-- bufferline derives the backgrounds of its states from Normal, and the theme
-- mirrors that derivation. Set it up so the derived groups are checked too.
local bufferline = assert(os.getenv("BLUEFOREST_BUFFERLINE"), "bufferline is not set")
vim.opt.runtimepath:append(bufferline)
require("bufferline").setup({
  options = { separator_style = "slope", diagnostics = "nvim_lsp" },
})

-- bufferline applies its groups as defaults, so it does not restyle them when
-- the colourscheme changes under it; clear the derived bodies and re-fire the
-- event so they are derived again for the mode that is now loaded.
local function refresh_bufferline()
  for _, group in ipairs({ "BufferLineBackground", "BufferLineBufferVisible" }) do
    vim.api.nvim_set_hl(0, group, {})
  end
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })
end

-- Every themed marker sits on the background bufferline derives for its state,
-- so a marker cannot repaint the tab around it.
local function assert_bufferline_backgrounds()
  for _, level in ipairs({ "Error", "Warning", "Info", "Hint" }) do
    for _, form in ipairs({ "", "Visible" }) do
      local body_group = form == "" and "BufferLineBackground" or "BufferLineBufferVisible"
      local body = vim.api.nvim_get_hl(0, { name = body_group }).bg
      for _, group in ipairs({
        "BufferLine" .. level .. form,
        "BufferLine" .. level .. "Diagnostic" .. form,
      }) do
        local got = vim.api.nvim_get_hl(0, { name = group }).bg
        assert(got == body, string.format("%s.bg is %s, not the body %s", group, tostring(got), tostring(body)))
      end
    end
  end
end

-- The colours of the theme are the ones of the repository.
local expected = {
  Normal = { fg = 0xd0d0d0, bg = 0x141f2e },
  Comment = { fg = 0xa0ffa0 },
  String = { fg = 0x80ff80 },
  DiagnosticError = { fg = 0xff8080 },
  RainbowDelimiterRed = { fg = 0xdc322f },
  RainbowDelimiterViolet = { fg = 0xa2cff5 },
  NeoTreeRootName = { fg = 0xffcc33 },
  NeoTreeDirectoryIcon = { fg = 0x91ccff },

  -- The groups of nvim-navic, which the plugin reads from the colourscheme.
  -- One per colour of the breadcrumbs, so every role is proved to resolve.
  NavicText = { fg = 0xd0d0d0 },
  NavicSeparator = { fg = 0x3a5f8a },
  NavicIconsModule = { fg = 0x91ccff },
  NavicIconsFunction = { fg = 0xa2cff5 },
  NavicIconsVariable = { fg = 0xfffab1 },
  NavicIconsEnum = { fg = 0xf7ff66 },
  NavicIconsString = { fg = 0x80ff80 },
  NavicIconsNumber = { fg = 0xff8080 },
  NavicIconsBoolean = { fg = 0x0099ff },
  NavicIconsArray = { fg = 0x808000 },
  NavicIconsNull = { fg = 0xa0ffa0 },
  NavicIconsOperator = { fg = 0xffcc33 },

  -- The markers of bufferline, one group per severity and form: the marker of
  -- the buffer wears the base or the visible group, and its count wears the
  -- diagnostic one. Every one is asserted, so a severity cannot go unstyled,
  -- and their background is the one bufferline derives for the state, so a
  -- marker cannot repaint the tab around it.
  BufferLineError = { fg = 0xff8080, bg = 0x0f1722 },
  BufferLineErrorVisible = { fg = 0xff8080, bg = 0x121c2a },
  BufferLineErrorDiagnostic = { fg = 0xff8080, bg = 0x0f1722 },
  BufferLineErrorDiagnosticVisible = { fg = 0xff8080, bg = 0x121c2a },
  BufferLineWarning = { fg = 0xffcc33, bg = 0x0f1722 },
  BufferLineWarningVisible = { fg = 0xffcc33, bg = 0x121c2a },
  BufferLineWarningDiagnostic = { fg = 0xffcc33, bg = 0x0f1722 },
  BufferLineWarningDiagnosticVisible = { fg = 0xffcc33, bg = 0x121c2a },
  BufferLineInfo = { fg = 0x0099ff, bg = 0x0f1722 },
  BufferLineInfoVisible = { fg = 0x0099ff, bg = 0x121c2a },
  BufferLineInfoDiagnostic = { fg = 0x0099ff, bg = 0x0f1722 },
  BufferLineInfoDiagnosticVisible = { fg = 0x0099ff, bg = 0x121c2a },
  BufferLineHint = { fg = 0x91ccff, bg = 0x0f1722 },
  BufferLineHintVisible = { fg = 0x91ccff, bg = 0x121c2a },
  BufferLineHintDiagnostic = { fg = 0x91ccff, bg = 0x0f1722 },
  BufferLineHintDiagnosticVisible = { fg = 0x91ccff, bg = 0x121c2a },

  -- The groups of the shell, which the other applications of the repository
  -- paint with the same colours: the command is a function, the arguments
  -- are parameters, and the variables are variables.
  ["@comment"] = { fg = 0xa0ffa0 },
  ["@function.call"] = { fg = 0xa2cff5 },
  ["@keyword.conditional"] = { fg = 0x0099ff },
  ["@number"] = { fg = 0xff8080 },
  ["@operator"] = { fg = 0xffcc33 },
  ["@punctuation.bracket"] = { fg = 0xe7e7e7 },
  ["@string"] = { fg = 0x80ff80 },
  ["@variable"] = { fg = 0xfffab1 },
  ["@variable.parameter"] = { fg = 0xe7e7e7 },
}

for group, colours in pairs(expected) do
  local hl = vim.api.nvim_get_hl(0, { name = group })
  for what, colour in pairs(colours) do
    assert(hl[what] == colour, string.format("%s.%s is %s, not %s", group, what, tostring(hl[what]), tostring(colour)))
  end
end

assert_bufferline_backgrounds()

-- lualine reads its theme from the `lua/lualine/themes` directory of the
-- runtimepath.
local loader = require("lualine.utils.loader")
local lualineTheme = loader.load_theme("blueforest")
assert(lualineTheme.normal.a.bg == "#ffcc33", "lualine did not read the theme of the repository")

-- And lualine finds the theme on its own, because the name of the theme is
-- the name of the colourscheme.
local auto = require("lualine.themes.auto")
assert(auto.normal.a.bg == "#ffcc33", "lualine did not find the theme on its own")

-- The statusline is painted with it.
require("lualine").setup({ options = { theme = "blueforest" } })
local statusline = vim.api.nvim_get_hl(0, { name = "lualine_a_normal" })
assert(statusline.bg == 0xffcc33, "the statusline is not painted with the theme")

-- And every mode carries its own colour for the section of the mode, which
-- lualine paints with the highlight group of that mode.
local darkModes = {
  insert = 0x80ff80,
  visual = 0x3a5f8a,
  replace = 0xff8080,
  command = 0xf7ff66,
  terminal = 0x219186,
}
for mode, colour in pairs(darkModes) do
  local hl = vim.api.nvim_get_hl(0, { name = "lualine_a_" .. mode })
  assert(hl.bg == colour, string.format("lualine_a_%s is %s, not %s", mode, tostring(hl.bg), tostring(colour)))
end

-- The light variant is a colourscheme of its own, and Neovim reads it.
vim.cmd.colorscheme("blueforest-light")
assert(vim.g.colors_name == "blueforest-light", "the light colourscheme did not set its name")
assert(vim.o.background == "light", "the light colourscheme did not set the mode of the editor")

-- And its colours are the ones of the light palette of the repository.
local expectedLight = {
  Normal = { fg = 0x141f2e, bg = 0xe8ecf2 },
  Comment = { fg = 0x56697d },
  String = { fg = 0x1e5c1e },
  DiagnosticError = { fg = 0xb02a28 },
  RainbowDelimiterRed = { fg = 0xb02a28 },
  RainbowDelimiterViolet = { fg = 0x1b7a70 },
  NeoTreeRootName = { fg = 0xc57633 },
  NeoTreeDirectoryIcon = { fg = 0x1b7a70 },

  -- The groups of nvim-navic, in the light palette.
  NavicText = { fg = 0x141f2e },
  NavicSeparator = { fg = 0x3a5f8a },
  NavicIconsModule = { fg = 0x1b7a70 },
  NavicIconsFunction = { fg = 0x1b7a70 },
  NavicIconsVariable = { fg = 0x333333 },
  NavicIconsEnum = { fg = 0x1b2b40 },
  NavicIconsString = { fg = 0x1e5c1e },
  NavicIconsNumber = { fg = 0xb02a28 },
  NavicIconsBoolean = { fg = 0x3a5f8a },
  NavicIconsArray = { fg = 0x808000 },
  NavicIconsNull = { fg = 0x56697d },
  NavicIconsOperator = { fg = 0xc57633 },

  -- The markers of bufferline, in the light palette, over the backgrounds
  -- bufferline derives for a bright Normal.
  BufferLineError = { fg = 0xb02a28, bg = 0xcccfd4 },
  BufferLineErrorVisible = { fg = 0xb02a28, bg = 0xd5d9de },
  BufferLineErrorDiagnostic = { fg = 0xb02a28, bg = 0xcccfd4 },
  BufferLineErrorDiagnosticVisible = { fg = 0xb02a28, bg = 0xd5d9de },
  BufferLineWarning = { fg = 0xc57633, bg = 0xcccfd4 },
  BufferLineWarningVisible = { fg = 0xc57633, bg = 0xd5d9de },
  BufferLineWarningDiagnostic = { fg = 0xc57633, bg = 0xcccfd4 },
  BufferLineWarningDiagnosticVisible = { fg = 0xc57633, bg = 0xd5d9de },
  BufferLineInfo = { fg = 0x3a5f8a, bg = 0xcccfd4 },
  BufferLineInfoVisible = { fg = 0x3a5f8a, bg = 0xd5d9de },
  BufferLineInfoDiagnostic = { fg = 0x3a5f8a, bg = 0xcccfd4 },
  BufferLineInfoDiagnosticVisible = { fg = 0x3a5f8a, bg = 0xd5d9de },
  BufferLineHint = { fg = 0x1b7a70, bg = 0xcccfd4 },
  BufferLineHintVisible = { fg = 0x1b7a70, bg = 0xd5d9de },
  BufferLineHintDiagnostic = { fg = 0x1b7a70, bg = 0xcccfd4 },
  BufferLineHintDiagnosticVisible = { fg = 0x1b7a70, bg = 0xd5d9de },

  ["@comment"] = { fg = 0x56697d },
  ["@function.call"] = { fg = 0x1b7a70 },
  ["@keyword.conditional"] = { fg = 0x3a5f8a },
  ["@number"] = { fg = 0xb02a28 },
  ["@operator"] = { fg = 0xc57633 },
  ["@punctuation.bracket"] = { fg = 0x333333 },
  ["@string"] = { fg = 0x1e5c1e },
  ["@variable"] = { fg = 0x333333 },
  ["@variable.parameter"] = { fg = 0x333333 },
}

for group, colours in pairs(expectedLight) do
  local hl = vim.api.nvim_get_hl(0, { name = group })
  for what, colour in pairs(colours) do
    assert(hl[what] == colour, string.format("%s.%s is %s, not %s", group, what, tostring(hl[what]), tostring(colour)))
  end
end

refresh_bufferline()
assert_bufferline_backgrounds()

-- And lualine reads the light variant of its own theme as well.
local lualineLight = loader.load_theme("blueforest-light")
assert(lualineLight.normal.a.bg == "#FFCC33", "lualine did not read the light theme of the repository")

-- And lualine finds it on its own, because the name of the theme is the name
-- of the colourscheme. The theme is cached by lualine, and it was loaded
-- with the dark colourscheme, so the cache is dropped first.
package.loaded["lualine.themes.auto"] = nil
local autoLight = require("lualine.themes.auto")
assert(autoLight.normal.a.bg == "#FFCC33", "lualine did not find the light theme on its own")

-- And the light variant carries the colours of its modes as well.
require("lualine").setup({ options = { theme = "blueforest-light" } })
local lightModes = {
  insert = 0x1e5c1e,
  visual = 0x3a5f8a,
  replace = 0xb02a28,
  command = 0x1b2b40,
  terminal = 0x1b7a70,
}
for mode, colour in pairs(lightModes) do
  local hl = vim.api.nvim_get_hl(0, { name = "lualine_a_" .. mode })
  assert(hl.bg == colour, string.format("lualine_a_%s is %s, not %s", mode, tostring(hl.bg), tostring(colour)))
end

print("the theme of the repository is the theme Neovim and lualine read")
