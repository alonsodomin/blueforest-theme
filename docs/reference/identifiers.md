# Identifiers

The names that a configuration needs to refer to the packages, themes, and
modules of the repository.

- The VS Code package is `blueforest-vscode-theme`.
- The VS Code extension is `alonsodomin.blueforest-theme`.
- The theme inside VS Code is `BlueForest`. Select it with
  `"workbench.colorTheme": "BlueForest"`.
- The bat theme is `BlueForest`, the name of the file
  `BlueForest.tmTheme`.
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
