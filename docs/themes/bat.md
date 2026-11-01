# BlueForest theme for bat

The theme is a TextMate file named `BlueForest.tmTheme`. The name of the theme
inside bat is `BlueForest`, the name of the file.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables.

## Install without Nix

Download `blueforest-bat-theme-<version>.tmTheme` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases),
put it in the themes directory of bat, and rebuild the cache:

```console
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

The package installs the theme in `/etc/bat` when it is installed in a NixOS
system, and in the configuration directory of the user when it is installed
with Home Manager.
