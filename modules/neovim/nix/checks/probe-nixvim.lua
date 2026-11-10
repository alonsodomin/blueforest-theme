-- SPDX-License-Identifier: MPL-2.0
--
-- The probe of the nixvim check.
--
-- It writes what the editor found in the file the check reads. The editor is
-- started with the configuration of nixvim, so the colourscheme has been
-- applied and the plugins have been set up by the time this runs.
--
-- The theme has a variant per mode, and both of them are looked at: the dark
-- colourscheme, which is the one the configuration selects, and the light
-- one, which is a colourscheme of its own.

local function colour(hl, what)
  local value = hl[what]
  if value == nil then
    return nil
  end
  return string.format("%06x", value)
end

local function group(name)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  return {
    fg = colour(hl, "fg"),
    bg = colour(hl, "bg"),
  }
end

-- The dark colourscheme is the one the configuration of nixvim selects, and
-- lualine paints the statusline with the theme of the repository.
local result = {
  colorsName = vim.g.colors_name,
  normal = group("Normal"),
  rainbow = group("RainbowDelimiterRed"),
  lualine = group("lualine_a_normal"),
  modes = {
    insert = group("lualine_a_insert"),
    visual = group("lualine_a_visual"),
    replace = group("lualine_a_replace"),
    command = group("lualine_a_command"),
    terminal = group("lualine_a_terminal"),
  },
}

-- The light variant is a colourscheme of its own, and Neovim reads it.
vim.cmd.colorscheme("blueforest-light")
result.light = {
  colorsName = vim.g.colors_name,
  normal = group("Normal"),
  rainbow = group("RainbowDelimiterRed"),
}

-- lualine reads the theme of the statusline from the `lua/lualine/themes`
-- directory of the runtimepath, and the light variant of it is there.
local loader = require("lualine.utils.loader")
local lightTheme = loader.load_theme("blueforest-light")
result.light.lualine = {
  bg = lightTheme.normal.a.bg,
}
result.light.modes = {
  insert = { bg = lightTheme.insert.a.bg },
  visual = { bg = lightTheme.visual.a.bg },
  replace = { bg = lightTheme.replace.a.bg },
  command = { bg = lightTheme.command.a.bg },
  terminal = { bg = lightTheme.terminal.a.bg },
}

-- And lualine finds it on its own, because the name of the theme is the name
-- of the colourscheme. The theme is cached by lualine, and it was loaded
-- with the dark colourscheme, so the cache is dropped first.
package.loaded["lualine.themes.auto"] = nil
local auto = require("lualine.themes.auto")
result.light.auto = {
  bg = auto.normal.a.bg,
}

local path = assert(os.getenv("BLUEFOREST_RESULT"), "the file of the result is not set")
local file = assert(io.open(path, "w"))
file:write(vim.json.encode(result))
file:close()
