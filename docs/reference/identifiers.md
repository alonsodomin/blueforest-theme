# Identifiers

The names that a configuration needs to refer to the packages, themes, and
modules of the repository.

## Switches

Every theme of the repository has a switch of its own, and the switch is off
by default:

| Switch | Theme |
| --- | --- |
| `blueforest.bat.enable` | The theme of bat |
| `blueforest.btop.enable` | The theme of btop |
| `blueforest.claude-code.enable` | The theme of Claude Code |
| `blueforest.eza.enable` | The theme of eza |
| `blueforest.kitty.enable` | The theme of kitty |
| `blueforest.lazygit.enable` | The theme of lazygit |
| `blueforest.md-tui.enable` | The theme of md-tui |
| `blueforest.neovim.enable` | The theme of Neovim |
| `blueforest.noctalia.enable` | The palette of Noctalia |
| `blueforest.opencode.enable` | The theme of OpenCode |
| `blueforest.sbt.enable` | The prompt of sbt |
| `blueforest.starship.enable` | The preset of Starship |
| `blueforest.yazi.enable` | The flavour of Yazi |

The themes of VS Code, of Zed, and of MkDocs have no switch: they are
installed as a package, as an extension, and as a stylesheet.

A theme and a template of the community catalogue of Noctalia are
alternatives, because the two of them write the configuration of the same
application. A configuration that enables both fails to evaluate.

## Names

- The VS Code package is `blueforest-vscode-theme`.
- The VS Code extension is `alonsodomin.blueforest-theme`.
- The theme inside VS Code is `BlueForest`. Select it with
  `"workbench.colorTheme": "BlueForest"`.
- The bat theme is `BlueForest`, the name of the file
  `BlueForest.tmTheme`. Select it with `programs.bat.config.theme =
  "BlueForest";`, or let the module `blueforest.homeModules.bat` select it
  with `blueforest.bat.enable = true;`.
- The btop package is `blueforest-btop-theme`. The btop theme is
  `blueforest.theme`, the name of the file, which btop reads from
  `$XDG_CONFIG_HOME/btop/themes/`. Select it with
  `color_theme = "blueforest.theme"` in the configuration of btop.
- The Starship packages are `blueforest-starship-preset` and
  `blueforest-starship`.
- The Starship preset is `blueforest`. Select it with
  `programs.starship.presets = [ "blueforest" ];`, or let the module
  `blueforest.homeModules.starship` select it with
  `blueforest.starship.enable = true;`.
- The OpenCode package is `blueforest-opencode-theme`.
- The OpenCode theme is `blueforest`, the name of the file. Select it with
  `programs.opencode.cli.theme = { name = "blueforest"; mode = "dark"; };`.
- The sbt package is `blueforest-sbt-prompt`. The module
  `blueforest.homeModules.sbt` installs it when `programs.sbt.enable = true`.
- The sbt prompt is the `BlueforestTheme` of the
  [sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin. There is no
  option to select another theme: the module selects that one.
- The Neovim package is `blueforest-neovim-theme`.
- The Neovim colourscheme is `blueforest`, the name of the file. Select it
  with `vim.cmd.colorscheme("blueforest")`.
- The lualine theme is `blueforest` as well, and lualine finds it on its own.
- The eza package is `blueforest-eza-theme`. The eza theme is `blueforest`,
  the name of the file. eza reads it as `theme.yml`, from
  `$XDG_CONFIG_HOME/eza/` or from the directory `EZA_CONFIG_DIR` points at,
  and there is no name to select.
- The Zed package is `blueforest-zed-theme`. The Zed extension is
  `blueforest-theme`, the id of its manifest, and the theme is
  `BlueForest - Dark`, the name it has in the theme picker of Zed. The
  extension lives in its own repository,
  [alonsodomin/zed-blueforest-theme](https://github.com/alonsodomin/zed-blueforest-theme),
  which is a submodule of the application.
- The Yazi package is `blueforest-yazi-theme`. The Yazi flavour is
  `blueforest`, the name of the directory `blueforest.yazi`, which Yazi reads
  from `$XDG_CONFIG_HOME/yazi/flavors/`. Select it with
  `[flavor] dark = "blueforest"` in the theme of the user.
- The kitty package is `blueforest-kitty-theme`. The kitty theme is
  `blueforest`, the name of the file `blueforest.conf`, which kitty reads
  from `$XDG_CONFIG_HOME/kitty/themes/`. Select it with
  `include themes/blueforest.conf` in the configuration of kitty. The
  `themes` kitten lists it under the name `BlueForest`.
- The lazygit package is `blueforest-lazygit-theme`. The lazygit theme is the
  `gui.theme` mapping of the configuration file of lazygit, and the file of
  the theme is `blueforest.json`, which lazygit reads as
  `$XDG_CONFIG_HOME/lazygit/config.yml`. The module
  `blueforest.homeModules.lazygit` adds it to the settings of lazygit when
  `programs.lazygit.enable = true`.
- The md-tui package is `blueforest-md-tui-theme`. The md-tui theme is
  `blueforest`, the name of the file `blueforest.json`, which md-tui reads
  from `$HOME/.config/mdt/themes/`. Select it with `blueforest.md-tui.enable =
  true;`, which makes the module write the theme and the selection of it.
- The Noctalia package is `blueforest-noctalia-theme`. The Noctalia palette is
  `blueforest`, the name of the file `blueforest.json`, which Noctalia reads
  from `$XDG_CONFIG_HOME/noctalia/palettes/`. Select it with
  `[theme] source = "custom"` and `custom_palette = "blueforest"` in the
  configuration of Noctalia. The module `blueforest.homeModules.noctalia`
  writes the palette and the selection when `programs.noctalia.enable = true`
  and `blueforest.noctalia.enable = true`. The package carries the palette in
  the format 2 of the community palette registry as well, under the name
  `blueforest-v2.json`.
- The Claude Code package is `blueforest-claude-code-theme`. The Claude Code
  theme is `blueforest`, the name of the file `blueforest.json`, which Claude
  Code reads from `$HOME/.claude/themes/`. Select it with
  `"theme": "custom:blueforest"` in `$HOME/.claude/settings.json`.
- The MkDocs package is `blueforest-mkdocs-theme`. The MkDocs stylesheet is
  `blueforest`, the name of the file `blueforest.css`, which MkDocs reads
  through the `extra_css` option of its configuration. The theme only
  recolours the dark scheme of Material for MkDocs.
