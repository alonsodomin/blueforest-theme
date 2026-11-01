# BlueForest theme for Neovim

The theme is a plugin that carries two files: the colourscheme of Neovim and
the theme of lualine.

```text
colors/blueforest.lua
lua/lualine/themes/blueforest.lua
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

## Install without Nix

Download `blueforest-neovim-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
extract it into a package directory of the Neovim runtimepath:

```console
plugin_dir="$HOME/.local/share/nvim/site/pack/blueforest/start/blueforest-theme"
mkdir -p "$plugin_dir"
tar -xzf blueforest-neovim-theme-<version>.tar.gz -C "$plugin_dir"
```

With `lazy.nvim`, add the directory as a local plugin:

```lua
{
  dir = vim.fn.expand("~/.local/share/nvim/site/pack/blueforest/start/blueforest-theme"),
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

## Install with Nix

The Home Manager module adds the theme to the plugins of Neovim. It does not
enable Neovim, and it does not select the colourscheme: those belong to your
own configuration.

```nix
{
  imports = [
    blueforest.homeModules.neovim
  ];

  programs.neovim.enable = true;
}
```

The module adds the theme with `lib.mkDefault`, so it does not replace the
plugins you add yourself.

If you wire the plugin by hand, the package is
`blueforest.packages.${system}.blueforest-neovim-theme`:

```nix
{
  home.packages = [
    blueforest.packages.${system}.blueforest-neovim-theme
  ];
}
```

The NixOS module only adds the overlay. Neovim reads the configuration of the
user, and there is no system-wide directory it reads.

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

## nixvim

[nixvim](https://github.com/nix-community/nixvim) builds an instance of
nixpkgs of its own, so the overlay of the consumer does not reach it. The
theme therefore comes with a module of nixvim, which is imported into the
configuration of nixvim:

```nix
{
  imports = [
    nixvim.nixosModules.default   # or nixvim.homeModules.default
  ];

  programs.nixvim = {
    imports = [ blueforest.nixvimModules.neovim ];
    enable = true;
  };
}
```

The module adds the overlay of the theme to the nixpkgs of nixvim, installs
the theme among the plugins of the editor, and selects the colourscheme. It
only offers `blueforest` as the default: you can select another colourscheme
in your own configuration.
