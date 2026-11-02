# BlueForest theme for eza

The theme is a YAML file named `blueforest.yml`. The name of the theme is
`blueforest`, the name of the file.

It is the format [eza](https://github.com/eza-community/eza) reads: the colour
of every kind of file, of every permission, of the sizes, of the owners, of
the links, of the state of the Git repository, and of the rest of the output.

The colours are true colour, so the terminal has to support it.

## How eza reads the theme

eza reads **one** theme file, and it is always named `theme.yml`. There is no
directory of themes and no name to select: the file is the theme. eza looks
for it in the configuration directory of the user:

```console
$XDG_CONFIG_HOME/eza/theme.yml
```

which is `~/.config/eza/theme.yml` when `XDG_CONFIG_HOME` is not set. The
`EZA_CONFIG_DIR` variable takes precedence over it: when it is set, eza reads
the theme from `<EZA_CONFIG_DIR>/theme.yml` instead.

## Install with Nix

The theme is part of the configuration of eza, so the Home Manager module
writes it where eza reads it from:

```nix
{
  imports = [
    blueforest.homeModules.eza
  ];

  programs.eza.enable = true;
}
```

The module does not enable eza: whether the program is installed at all stays
your decision. It writes the theme to `~/.config/eza/theme.yml`, and it writes
nothing when `programs.eza.enable` is false.

Home Manager has an option of its own for the theme of eza,
`programs.eza.theme`, which writes the same file. The theme of this
application is a default one, so a consumer that sets that option keeps its
own theme.

If you want the file itself, the package is
`blueforest.packages.${system}.blueforest-eza-theme`. It carries the theme
under the name of the theme and under the name eza reads:

```text
blueforest.yml
share/eza/theme.yml
```

For a system-wide installation, point eza at the package with the variable
that takes precedence over the configuration directory of the user:

```nix
{
  environment.variables.EZA_CONFIG_DIR = "${pkgs.blueforest-eza-theme}/share/eza";
}
```

There is no NixOS module: eza reads the theme from the configuration directory
of the user, and there is no system-wide directory it reads.

## Manual install

Download `blueforest-eza-theme-<version>.yml` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where eza reads the theme from, under the name eza expects:

```console
mkdir -p ~/.config/eza
cp blueforest-eza-theme-<version>.yml ~/.config/eza/theme.yml
```

That is all: eza reads the file every time it runs, so there is nothing to
select and nothing to reload.

## Invalid themes are ignored

eza ignores a theme it cannot read, and it does so silently: a malformed file,
or a colour that does not resolve, makes it fall back to the theme it ships
with. If the theme does not look right, check that the file is named
`theme.yml` and that it is where eza reads it from.
