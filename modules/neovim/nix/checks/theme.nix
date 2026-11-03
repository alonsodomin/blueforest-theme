# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository, and
# that Neovim and lualine read it.
{
  pkgs,
  # The package of the theme.
  theme,
  # The plugin of lualine, which reads a theme of its own.
  lualine,
  # The files of the repository the package carries.
  sources,
}:
pkgs.runCommand "blueforest-neovim-theme-check"
  {
    nativeBuildInputs = [
      pkgs.neovim
      pkgs.luajitPackages.luacheck
    ];

    # The probe reads the paths of the packages from the environment.
    BLUEFOREST_THEME = theme.outPath;
    BLUEFOREST_LUALINE = lualine.outPath;
  }
  ''
    # The files of the package are the files of the repository.
    cmp ${theme}/colors/blueforest.lua ${sources.colorscheme}
    cmp ${theme}/lua/lualine/themes/blueforest.lua ${sources.lualine}
    cmp ${theme}/colors/blueforest-light.lua ${sources.colorschemeLight}
    cmp ${theme}/lua/lualine/themes/blueforest-light.lua ${sources.lualineLight}

    # The attribution of the theme travels with the package.
    test -f ${theme}/share/doc/blueforest/NOTICE.md
    test -f ${theme}/share/doc/blueforest/LICENSE

    # The sources of the theme are clean Lua.
    luacheck --std luajit --globals vim --no-color --no-cache ${sources.colorscheme}
    luacheck --std luajit --globals vim --no-color --no-cache ${sources.lualine}
    luacheck --std luajit --globals vim --no-color --no-cache ${sources.colorschemeLight}
    luacheck --std luajit --globals vim --no-color --no-cache ${sources.lualineLight}
    luacheck --std luajit --globals vim --no-color --no-cache ${./probe.lua}

    # And Neovim reads the theme, and lualine reads its own.
    export HOME=$TMPDIR
    nvim --headless -u NONE -l ${./probe.lua}

    touch $out
  ''
