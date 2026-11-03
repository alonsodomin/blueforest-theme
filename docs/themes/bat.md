# BlueForest theme for bat

The theme is a TextMate file named `BlueForest.tmTheme`. The name of the theme
inside bat is `BlueForest`, the name of the file.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables.

The theme of [Yazi](yazi.md) paints the code of its preview with it, so the
two of them are the same file.

## Install with Nix

The package `blueforest-bat-theme` puts the theme where bat looks for it. Two
things are left to you: bat itself has to be enabled, and the theme has to be
selected.

On NixOS:

```nix
{
  environment.systemPackages = [
    blueforest.packages.${system}.blueforest-bat-theme
  ];

  programs.bat = {
    enable = true;
    settings.theme = "BlueForest";
  };
}
```

With Home Manager:

```nix
{
  home.packages = [
    blueforest.packages.${system}.blueforest-bat-theme
  ];

  programs.bat = {
    enable = true;
    config.theme = "BlueForest";
  };
}
```

The package installs the theme in the configuration directory of bat, which is
where bat reads the themes from, and rebuilds the cache of bat, without which
bat does not pick the theme up. The setup hook does both when the package is
installed, so the theme is available without further work.

The Home Manager module does the same, and it selects the theme for you:

```nix
{
  imports = [
    blueforest.homeModules.bat
  ];

  programs.bat.enable = true;
  blueforest-theme.bat.enable = true;
}
```

The module does not enable bat: whether the program is installed at all stays
your decision. It writes the theme to `~/.config/bat/themes/BlueForest.tmTheme`
and selects it in the configuration of bat, and it writes nothing when
`programs.bat.enable` is false or when `blueforest-theme.bat.enable` is false.

The theme and the selection are installed with `lib.mkDefault`, so a
configuration that brings a theme or a setting of its own keeps it:

```nix
{
  programs.bat.config.theme = "Another";
}
```

The switch of the theme is `blueforest-theme.bat.enable`, and not
`programs.bat.enable`, so that the theme and the template of the community
catalogue of Noctalia for bat are alternatives: a consumer that wants the
community template keeps `blueforest-theme.bat.enable` off, and a consumer that
wants this theme turns it on. A configuration that enables both fails to
evaluate: the two of them write the configuration of bat.

There is no NixOS module: bat reads the themes from the configuration directory
of the user, and there is no system-wide directory it reads.

## Manual install

Download `blueforest-bat-theme-<version>.tmTheme` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases),
put it in the themes directory of bat, and rebuild the cache:

```bash
theme_dir="$(bat --config-dir)/themes"
mkdir -p "$theme_dir"
cp blueforest-bat-theme-<version>.tmTheme "$theme_dir/BlueForest.tmTheme"
bat cache --build
```

`bat --config-dir` is platform-dependent. On Linux it is usually
`~/.config/bat`, on macOS `~/Library/Application Support/bat`, and on Windows
`%APPDATA%\bat`. The command above asks bat for the right directory.

Select the theme with `--theme=BlueForest`, with the `BAT_THEME` environment
variable, or in the configuration file of bat (usually
`~/.config/bat/config`):

```text
--theme="BlueForest"
```
