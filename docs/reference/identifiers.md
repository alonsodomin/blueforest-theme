# Identifiers

The names that a configuration needs to refer to the packages, themes, and
modules of the repository.

- The VS Code package is `blueforest-vscode-theme`.
- The VS Code extension is `alonsodomin.blueforest-theme`.
- The theme inside VS Code is `BlueForest`. Select it with
  `"workbench.colorTheme": "BlueForest"`.
- The bat theme is `BlueForest`, the name of the file
  `BlueForest.tmTheme`.
- The btop package is `blueforest-btop-theme`. The btop theme is
  `blueforest.theme`, the name of the file, which btop reads from
  `$XDG_CONFIG_HOME/btop/themes/`. Select it with
  `color_theme = "blueforest.theme"` in the configuration of btop.
- The Starship packages are `blueforest-starship-preset` and
  `blueforest-starship`.
- The Starship preset is `blueforest`. Select it with
  `programs.starship.presets = [ "blueforest" ];`.
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
- The Claude Code package is `blueforest-claude-code-theme`. The Claude Code
  theme is `blueforest`, the name of the file `blueforest.json`, which Claude
  Code reads from `$HOME/.claude/themes/`. Select it with
  `"theme": "custom:blueforest"` in `$HOME/.claude/settings.json`.
- The MkDocs package is `blueforest-mkdocs-theme`. The MkDocs stylesheet is
  `blueforest`, the name of the file `blueforest.css`, which MkDocs reads
  through the `extra_css` option of its configuration. The theme only
  recolours the dark scheme of Material for MkDocs.
