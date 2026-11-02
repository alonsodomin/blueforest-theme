# BlueForest theme for kitty

The theme is a configuration file of kitty named `blueforest.conf`. The name
of the theme is `blueforest`, the name of the file.

It is the format [kitty](https://github.com/kovidgoyal/kitty) reads: the
colours of the interface of the terminal, and the sixteen colours of the
terminal itself.

The colours are true colour, so the terminal has to support it.

## How kitty reads the theme

kitty reads the themes of the user from the `themes` directory of its
configuration directory:

```console
$XDG_CONFIG_HOME/kitty/themes/blueforest.conf
```

which is `~/.config/kitty/themes/blueforest.conf` when `XDG_CONFIG_HOME` is
not set.

A theme is not selected by name. kitty has no option for it: the theme is
selected with an `include` line in the configuration of kitty, and the last
include of a colour wins:

```console
include themes/blueforest.conf
```

The path of the `include` is relative to the directory of the configuration
file that includes it, which is the configuration directory of kitty.

The file is a theme of kitty as well: it carries the metadata that the
`themes` kitten reads, so `kitty +kitten themes` lists it under the name
`BlueForest`, with its author, its licence, and a short description of it.

## Install with Nix

The theme is part of the configuration of kitty, so the Home Manager module
installs it where kitty reads it from, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.kitty
  ];

  programs.kitty.enable = true;
}
```

The module does not enable kitty: whether the program is installed at all
stays your decision. It writes the theme to
`~/.config/kitty/themes/blueforest.conf`, adds the `include` line that selects
it to the configuration of kitty, and it writes nothing when
`programs.kitty.enable` is false.

The `include` line comes before the options that Home Manager writes for
kitty, and before the ones you write, so a colour you set wins over the
colour of the theme.

If you want the file itself, the package is
`blueforest.packages.${system}.blueforest-kitty-theme`. It carries the theme
under the name of the theme and under the name kitty reads:

```text
blueforest.conf
share/kitty/themes/blueforest.conf
```

A system-wide installation includes the theme from the system-wide
configuration of kitty, `/etc/xdg/kitty/kitty.conf`. kitty merges it before
the configuration of the user, so the colours of the user win over the ones
of the theme:

```nix
{
  environment.etc."xdg/kitty/kitty.conf".text = ''
    include ${pkgs.blueforest-kitty-theme}/share/kitty/themes/blueforest.conf
  '';
}
```

There is no NixOS module: the theme of the user lives in the configuration
directory of the user, and that is where the themes kitten finds it.

## Manual install

Download `blueforest-kitty-theme-<version>.conf` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where kitty reads the themes from:

```console
mkdir -p ~/.config/kitty/themes
cp blueforest-kitty-theme-<version>.conf ~/.config/kitty/themes/blueforest.conf
```

Then select the theme in the configuration of kitty, `~/.config/kitty/kitty.conf`:

```console
echo 'include themes/blueforest.conf' >>~/.config/kitty/kitty.conf
```

kitty reads its configuration every time it starts, so there is nothing to
reload.

## Invalid themes are ignored

kitty ignores a configuration key it does not know, and a colour it cannot
resolve, and it does so silently: the terminal falls back to the colours
kitty ships with. If the theme does not look right, check that the file is
named `blueforest.conf`, that it is where kitty reads the themes from, and
that the configuration of kitty includes it.

## The themes kitten

`kitty +kitten themes` lists the themes of the `themes` directory, and it
writes the one you select into the configuration of kitty. It replaces the
`include` line of the configuration, so the theme it selects takes the place
of the one of this application. The module writes the configuration of kitty
again on the next activation, and the theme of this application is back.
