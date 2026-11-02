# BlueForest theme for Zed

The theme is a Zed theme, and it is part of the
[zed-blueforest-theme](https://github.com/alonsodomin/zed-blueforest-theme)
extension. Once installed, it appears as **BlueForest - Dark** in the theme
picker.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables.

## Install from the Extension Gallery

!!! tip "Recommended"

    Install the theme from the Extension Gallery of Zed. The extension is
    published there, and Zed keeps it up to date.

Open the Extension Gallery with `cmd-shift-x` (`ctrl-shift-x`), or with the
`zed: extensions` command of the command palette, and search for
**Blueforest Theme**.

The extension lives in a repository of its own,
[alonsodomin/zed-blueforest-theme](https://github.com/alonsodomin/zed-blueforest-theme),
because that is how Zed ships extensions: the editor clones the repository and
reads the theme from it. That repository is a submodule of this one, so every
change of the extension is reviewed here.

## Install from a release

Every release of the repository attaches the extension as
`blueforest-zed-theme-<version>.tar.gz`. It carries the manifest of the
extension and the theme, in the layout Zed installs an extension in. Unpack it
in the extensions directory of Zed:

```console
mkdir -p ~/.local/share/zed/extensions/installed/blueforest-theme
tar -xzf blueforest-zed-theme-<version>.tar.gz \
  -C ~/.local/share/zed/extensions/installed/blueforest-theme
```

The extensions directory is `~/.local/share/zed/extensions` on Linux,
`~/Library/Application Support/Zed/extensions` on macOS, and
`%LOCALAPPDATA%\Zed\extensions` on Windows.

## Install with Nix

!!! info

    The theme is part of an extension that is published to the Extension
    Gallery of Zed, which is the recommended way to install it. Installing it
    with Nix is meant for developing and testing the theme.

The Home Manager module writes the theme to the themes directory of Zed, which
is where Zed reads the themes of the user from:

```nix
{
  imports = [
    blueforest.homeModules.zed
  ];
}
```

The module does not enable Zed: it only adds the theme to the configuration of
an editor the consumer already installed. Zed watches that directory, so the
theme is picked up without restarting the editor.

If you only want the package, it is also available as
`blueforest.packages.${system}.blueforest-zed-theme`. It carries the
extension, which is the manifest and the theme:

```text
extension.toml
themes/blueforest.json
```

## Select the theme

Open the theme picker with `cmd-k cmd-t` (`ctrl-k ctrl-t`) and select
**BlueForest - Dark**, or set it in your settings:

```json
{
  "theme": "BlueForest - Dark"
}
```
