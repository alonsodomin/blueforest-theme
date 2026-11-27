# BlueForest theme for Neovim

The theme is a plugin that carries the colourschemes of Neovim, the themes of
lualine, and the Lua module the colourschemes share.

```text
colors/blueforest.lua
colors/blueforest-light.lua
lua/blueforest.lua
lua/lualine/themes/blueforest.lua
lua/lualine/themes/blueforest-light.lua
```

The name of the colourscheme is `blueforest`, and lualine finds its theme on
its own because the name of the lualine theme is `blueforest` as well.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables. The
theme describes the groups of Neovim, the captures of Tree-sitter, the
diagnostics of the language servers, the signs of Git, and the groups of the
plugins that are common enough to be worth a colour.

It also describes the seven `RainbowDelimiter*` groups, because the
rainbow-delimiters plugin reads their colours from the colourscheme.

It also describes the `Navic*` groups of nvim-navic, the breadcrumbs of the
winbar: a `NavicIcons*` group per symbol kind, plus `NavicText` and
`NavicSeparator`, each wearing the colour of the syntax role it names. The
plugin paints them only when its `highlight` option is on, so a breadcrumb
takes `require("nvim-navic").setup({ highlight = true })`.

## Install with Nix

The theme comes as a module of nixvim, which is imported into the
configuration of nixvim. nixvim builds an instance of nixpkgs of its own, so
the module adds the overlay of the theme to the nixpkgs of nixvim and
installs the theme among the plugins of the editor:

```nix
{
  imports = [
    nixvim.nixosModules.default   # or nixvim.homeModules.default
  ];

  programs.nixvim = {
    imports = [ blueforest.nixvimModules.neovim ];
    enable = true;
    colorscheme = "blueforest";
  };
}
```

The module does not select the colourscheme: `colorscheme` above is what
selects it, and you can select another one in your own configuration.

## The light variant

The package carries a light variant of the theme as well, `blueforest-light`,
with the colours of the light palette of the repository. It is a colourscheme
of its own, so it is selected the same way, with `colorscheme =
"blueforest-light";` in nixvim or `vim.cmd.colorscheme("blueforest-light")` in
a configuration you write by hand.

It sets the mode of the editor to `light` as well, so the editor follows the
colours of the theme. The theme of lualine comes with it, and lualine finds it
on its own, the way it finds the dark one.

The [palette reference](../index.md#colour-palettes) has every colour of the
light variant, with the swatches.

The theme has no switch of its own: importing the nixvim module installs it,
and `colorscheme` selects it. A configuration that does not want the theme
does not import the module.

If you wire the plugin by hand, the package is
`blueforest.packages.${system}.blueforest-neovim-theme`:

```nix
{
  home.packages = [
    blueforest.packages.${system}.blueforest-neovim-theme
  ];
}
```

## Manual install

Download `blueforest-neovim-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The archive carries the variants of the theme and the changelog of the
release, in the layout Neovim reads a plugin from:

```text
CHANGELOG.txt
colors/blueforest.lua
colors/blueforest-light.lua
lua/blueforest.lua
lua/lualine/themes/blueforest.lua
lua/lualine/themes/blueforest-light.lua
```

Extract it into a package directory of the Neovim runtimepath:

```bash
plugin_dir="$HOME/.local/share/nvim/site/pack/blueforest/start/blueforest-neovim-theme"
mkdir -p "$plugin_dir"
tar -xzf blueforest-neovim-theme-<version>.tar.gz -C "$plugin_dir"
```

With `lazy.nvim`, add the directory as a local plugin:

```lua
{
  dir = vim.fn.expand("~/.local/share/nvim/site/pack/blueforest/start/blueforest-neovim-theme"),
  name = "blueforest",
}
```

Select the colourscheme in your configuration:

```lua
vim.cmd.colorscheme("blueforest")
```

or, from Vimscript:

```vim
colorscheme blueforest
```

## The statusline

No configuration is needed for lualine to find the theme: it looks the theme
up by the name of the colourscheme. The sections of the statusline are the
configuration of lualine, and the ones this theme was made with are:

```lua
require("lualine").setup({
  options = {
    theme = "blueforest",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "diagnostics" },
    lualine_x = { "filename" },
    lualine_y = { "filetype" },
    lualine_z = { "position" },
  },
})
```
