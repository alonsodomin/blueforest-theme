# BlueForest theme for Noctalia

The theme is a palette of [Noctalia](https://noctalia.dev), the Wayland shell
and bar. The name of the file is `blueforest.json`, and the name of the palette
is the name of the file.

It is the format Noctalia reads: the sixteen roles of the interface and the
sixteen colours of the terminal. The palette follows the colours of BlueForest,
the ones of the other applications of this repository, and it paints the
terminal with the same colours as the [kitty theme](kitty.md).

The palette carries a dark variant and a light variant. The dark one is the
palette BlueForest was designed for, and the light one is a palette of its own:
the accent stays the same, and the rest of the colours are darker, so that they
read well on a light surface. The [documentation of the repository](../index.md)
describes the two of them, with all of their colours.

Noctalia picks the variant that matches the mode of the shell, so the shell
follows the light and the dark mode of the system without any further work.

## How Noctalia reads the palette

Noctalia reads the palettes of the user from the `palettes` directory of its
configuration directory:

```bash
$XDG_CONFIG_HOME/noctalia/palettes/blueforest.json
```

which is `~/.config/noctalia/palettes/blueforest.json` when `XDG_CONFIG_HOME`
is not set.

A palette is selected by name, with the `source` and `custom_palette` settings
of the configuration:

```toml
[theme]
source = "custom"
custom_palette = "blueforest"
```

Noctalia merges every `*.toml` file of its configuration directory, sorted by
name, and the file of the module, `blueforest.toml`, sorts before `config.toml`.
A setting that the consumer writes in `config.toml` therefore wins over the
selection of the module.

Noctalia also writes the settings that the shell changes at runtime to
`~/.local/state/noctalia/settings.toml`, which overrides every configuration
file. Changing the theme from the settings of the shell therefore wins over the
selection of this theme.

## Install with Nix

The theme is part of the configuration of Noctalia, so the Home Manager module
installs it where Noctalia reads the palettes from, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.noctalia
  ];

  programs.noctalia.enable = true;
  blueforest-theme.noctalia.enable = true;
}
```

The module does not enable Noctalia: whether the shell is installed at all
stays your decision. It writes the palette to
`~/.config/noctalia/palettes/blueforest.json`, selects it in
`~/.config/noctalia/blueforest.toml`, and it writes nothing when
`programs.noctalia.enable` is false or when `blueforest-theme.noctalia.enable` is
false.

The switch of the theme is `blueforest-theme.noctalia.enable`, and not
`programs.noctalia.enable`, so that the palette and a template of the
community catalogue of Noctalia are alternatives: a consumer that wants the
community template keeps `blueforest-theme.noctalia.enable` off, and a consumer that
wants this palette turns it on.

The palette and the selection are installed with `lib.mkDefault`, so a
configuration that brings a palette or a selection of its own keeps it:

```nix
{
  programs.noctalia.customPalettes.blueforest = ./my-palette.json;
  xdg.configFile."noctalia/blueforest.toml".text = ''
    [theme]
    source = "builtin"
    builtin = "Catppuccin"
  '';
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-noctalia-theme`. It carries the theme
under the name of the theme and in the directory Noctalia reads the palettes
from:

```text
blueforest.json
share/noctalia/palettes/blueforest.json
```

There is no NixOS module: Noctalia reads no system-wide configuration file, so
there is no place where the selection of the theme would live. The palette of
the user lives in the configuration directory of the user, and that is where
Noctalia reads it from.

## The format 2 of the palette

The palette of the repository is written in the format that every released
Noctalia reads: the `m`-prefixed names of the roles of the interface, and the
names of the colours of the terminal.

The community palette registry of Noctalia asks for the format 2, which names
every key after the colour role it sets. The package carries the palette in
both formats, and the file of the format 2 is generated from the file of the
format 1, so that the two of them cannot drift:

```text
blueforest.json
blueforest-v2.json
share/noctalia/palettes/blueforest.json
```

The file of the format 2 is the one to publish to the registry. Every released
Noctalia reads the format 1, and upgrades it to the format 2 when it reads it,
so the palette of the user is the file of the format 1.

## Manual install

Download `blueforest-noctalia-theme-<version>.json` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where Noctalia reads the palettes from:

```bash
mkdir -p ~/.config/noctalia/palettes
cp blueforest-noctalia-theme-<version>.json \
  ~/.config/noctalia/palettes/blueforest.json
```

Then select the palette in the configuration of Noctalia,
`~/.config/noctalia/config.toml`:

```toml
[theme]
source = "custom"
custom_palette = "blueforest"
```

Noctalia watches its configuration directory, so there is nothing to reload.

## Invalid palettes are ignored

Noctalia ignores a palette it cannot read, and it does so silently. A palette
without the `terminal` object is rejected, and the shell falls back to the
palette it ships with; a role of the interface or a colour of the terminal that
is missing or malformed is painted as transparent black. If the theme does not
look right, check that the file is named `blueforest.json`, that it is where
Noctalia reads the palettes from, and that the configuration of Noctalia selects
it.

A palette with a single variant is not invalid, but the shell expands the
missing variant from the one it has, which mixes the colours of the two. The
palette of the repository carries both of them.
