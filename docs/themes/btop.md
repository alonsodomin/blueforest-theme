# BlueForest theme for btop

The theme is a theme file of [btop](https://github.com/aristocratos/btop), the
resource monitor. The name of the file is `blueforest.theme`.

It is the format btop reads: the colours of the interface, of the boxes, of
the meters, and of the graphs. The theme follows the palette of BlueForest, the
one of the other applications of this repository.

The colours are true colour, so the terminal has to support it. A terminal that
does not can ask btop for the 256 colours of the palette with the `lowcolor`
setting of its configuration file.

## How btop reads the theme

btop reads the themes of the user from the `themes` directory of its
configuration directory:

```bash
$XDG_CONFIG_HOME/btop/themes/blueforest.theme
```

which is `~/.config/btop/themes/blueforest.theme` when `XDG_CONFIG_HOME` is
not set.

A theme is selected by name. The name of a theme is the name of its file, and
the selection is the `color_theme` setting of the configuration file of btop:

```bash
color_theme = "blueforest.theme"
```

The configuration file is `~/.config/btop/btop.conf`, the same file that
carries the rest of the configuration of btop.

btop only lists the files whose name ends in `.theme`, so the extension is not
optional. It writes the file it selects into the configuration of btop, and
the options of btop list the themes of the `themes` directory, which is where
the theme of this application is.

## Install with Nix

The theme is part of the configuration of btop, so the Home Manager module
installs it where btop reads the themes from, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.btop
  ];

  programs.btop.enable = true;
}
```

The module does not enable btop: whether the program is installed at all stays
your decision. It writes the theme to
`~/.config/btop/themes/blueforest.theme`, selects it in the configuration of
btop, and it writes nothing when `programs.btop.enable` is false.

The theme is installed and selected with `lib.mkDefault`, so a configuration
that brings a theme or a setting of its own keeps it:

```nix
{
  programs.btop.settings.color_theme = "another.theme";
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-btop-theme`. It carries the theme
under the name of the theme and under the name btop reads:

```text
blueforest.theme
share/btop/themes/blueforest.theme
```

The second path is the one btop reads the themes of the system from: it looks
for them in the `themes` directory next to its binary. A system-wide
installation therefore puts the theme where every user of the system finds it:

```nix
{
  environment.etc."btop/themes/blueforest.theme".source =
    ${pkgs.blueforest-btop-theme}/share/btop/themes/blueforest.theme;
}
```

There is no NixOS module: btop reads no system-wide configuration file, so
there is no place where the selection of the theme would live. The theme of
the user lives in the configuration directory of the user, and that is where
btop reads it from.

## Manual install

Download `blueforest-btop-theme-<version>.theme` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where btop reads the themes from:

```bash
mkdir -p ~/.config/btop/themes
cp blueforest-btop-theme-<version>.theme ~/.config/btop/themes/blueforest.theme
```

Then select the theme in the configuration of btop, `~/.config/btop/btop.conf`:

```bash
echo 'color_theme = "blueforest.theme"' >>~/.config/btop/btop.conf
```

btop reads its configuration every time it starts, so there is nothing to
reload.

## Transparent background

The theme paints the background of the interface with the dark blue of
BlueForest. A terminal with a background of its own can ask btop not to paint
it, with the `theme_background` setting of the configuration file:

```bash
theme_background = False
```

## Invalid themes are ignored

btop ignores a key it does not know, and a colour it cannot resolve, and it
does so silently: the interface falls back to the colours btop ships with. If
the theme does not look right, check that the file is named
`blueforest.theme`, that it is where btop reads the themes from, and that the
configuration of btop selects it.
