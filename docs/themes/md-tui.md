# BlueForest theme for md-tui

The theme is a palette of [md-tui](https://github.com/henriklovhaug/md-tui),
the terminal viewer for Markdown. The name of the file is `blueforest.json`,
and the name of the file is the name of the theme.

It is the format md-tui reads: the colours of the interface, of the headings,
of the code, of the links, of the quotes, of the tables, of the file tree, and
of the syntax of the code blocks. The theme follows the palette of BlueForest,
the one of the other applications of this repository.

The colours are true colour, so the terminal has to support it.

## How md-tui reads the theme

md-tui reads the palettes of the user from the `themes` directory of its
configuration directory:

```bash
$HOME/.config/mdt/themes/blueforest.json
```

The palette is selected by name, and the selection is the `selected-theme` file
of the configuration directory, whose value is the name of the palette:

```bash
blueforest
```

md-tui reads the configuration directory of the user from `$HOME/.config`, and
it ignores `XDG_CONFIG_HOME`: the theme goes to `~/.config/mdt`, and not to
`$XDG_CONFIG_HOME/mdt`.

The palette carries every colour md-tui knows: md-tui reads a palette as a
whole, and it ignores one that does not have every colour of it. The syntax
of the code blocks is part of the palette, so the theme also carries the
colours of the syntax of BlueForest.

## Install with Nix

The theme is part of the configuration of md-tui, so the Home Manager module
installs it where md-tui reads the palettes from, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.md-tui
  ];

  blueforest-theme.md-tui.enable = true;
}
```

The module does not enable md-tui: whether the program is installed at all
stays your decision. It writes the theme to
`~/.config/mdt/themes/blueforest.json`, selects it in
`~/.config/mdt/selected-theme`, and it writes nothing when
`blueforest-theme.md-tui.enable` is false.

## The light variant

The palette has a light variant, `blueforest-light`, with the colours of the
light palette of the repository. The switch of the variant selects the one
that is installed:

```nix
{
  blueforest-theme.md-tui.enable = true;
  blueforest-theme.md-tui.variant = "light";
}
```

The variant is `dark` by default, and the dark palette is the one it installs.
The [palette reference](../index.md#colour-palettes) has every colour of the
light variant, with the swatches.

Home Manager has no module for md-tui, so the switch of this module is
`blueforest-theme.md-tui.enable` and not `programs.md-tui.enable`: the option of
Home Manager would clash with the one of this module if Home Manager ever
gained a module of its own.

The theme and the selection are written with `lib.mkDefault`, so a
configuration that brings a palette or a selection of its own keeps it:

```nix
{
  home.file.".config/mdt/selected-theme".text = "another\n";
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-md-tui-theme`. It carries the theme
under the name of the theme and under the name md-tui reads:

```text
blueforest.json
share/mdt/themes/blueforest.json
```

The second path is the one md-tui reads the palettes of the user from, so a
consumer that installs the package by hand puts it there:

```nix
{
  home.file.".config/mdt/themes/blueforest.json".source =
    "${pkgs.blueforest-md-tui-theme}/share/mdt/themes/blueforest.json";
}
```

There is no NixOS module: md-tui reads no system-wide configuration file, so
there is no place where the selection of the theme would live. The theme of
the user lives in the configuration directory of the user, and that is where
md-tui reads it from.

## Manual install

Download `blueforest-md-tui-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The archive carries the variants of the theme and the changelog of the
release:

```text
CHANGELOG.txt
dark/blueforest.json
light/blueforest-light.json
```

Put the palettes where md-tui reads them from:

```bash
mkdir -p ~/.config/mdt/themes
tar -xzf blueforest-md-tui-theme-<version>.tar.gz -C ~/.config/mdt/themes \
  --strip-components=1 \
  dark/blueforest.json light/blueforest-light.json
```

Then select the theme, with the `selected-theme` file of the configuration
directory:

```bash
echo blueforest >~/.config/mdt/selected-theme
```

md-tui also selects a theme on its own: the `T` key opens the chooser of the
themes, where the palettes of the `themes` directory are listed under their
name, and the selection is remembered across runs.

## Invalid themes are ignored

md-tui ignores a palette it cannot read, and it does so silently: the
interface falls back to the colours it ships with. If the theme does not look
right, check that the file is named `blueforest.json`, that it is where md-tui
reads the palettes from, that the `selected-theme` file names it, and that the
palette carries every colour md-tui knows.
