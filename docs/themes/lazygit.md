# BlueForest theme for lazygit

The theme is the `gui.theme` mapping of the configuration file of
[lazygit](https://github.com/jesseduffield/lazygit), the terminal UI for git.

lazygit has no theme file of its own: the theme is part of its configuration,
and the file of this application is a configuration file of lazygit that
carries it. The name of the file is `blueforest.json`.

It is the format lazygit reads: the colours of the interface, of the borders
of the windows, of the selected line, and of the commits that are marked. The
theme follows the palette of BlueForest, the one of the other applications of
this repository.

The colours are true colour, so the terminal has to support it.

## How lazygit reads the theme

lazygit reads the configuration of the user from the `lazygit` directory of
its configuration directory:

```bash
$XDG_CONFIG_HOME/lazygit/config.yml
```

which is `~/.config/lazygit/config.yml` when `XDG_CONFIG_HOME` is not set.

The theme is the `gui.theme` key of that file:

```yaml
gui:
  theme:
    activeBorderColor:
      - "#0099FF"
      - bold
    inactiveBorderColor:
      - "#333333"
    # ...
```

The file of this application is JSON, and JSON is a subset of YAML: lazygit
reads it as its own format, and so does every other tool that reads YAML.

The theme is a mapping since lazygit v0.44. An older lazygit expects a name
in that key, and it says so when it reads the file.

## Install with Nix

The theme is part of the configuration of lazygit, so the Home Manager module
adds it to the settings of lazygit:

```nix
{
  imports = [
    blueforest.homeModules.lazygit
  ];

  programs.lazygit.enable = true;
  blueforest-theme.lazygit.enable = true;
}
```

The module does not enable lazygit: whether the program is installed at all
stays your decision. It adds the theme to the settings of lazygit, and it
writes nothing when `programs.lazygit.enable` is false or when
`blueforest-theme.lazygit.enable` is false.

The switch of the theme is `blueforest-theme.lazygit.enable`, and not
`programs.lazygit.enable`, so that every theme of the repository is turned on
and off on its own.

Every colour of the theme is a default one, so a configuration that brings a
colour of its own keeps it, and keeps the rest of the theme as well:

```nix
{
  programs.lazygit.settings.gui.theme.activeBorderColor = [ "#FF0000" ];
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-lazygit-theme`. It carries the theme
under the name of the theme and under the name of the directory of the themes
of lazygit:

```text
blueforest.json
share/lazygit/themes/blueforest.json
```

lazygit reads no system-wide configuration file, so there is no place where
the theme of the system would live: there is no NixOS module, and the theme
of the user lives in the configuration directory of the user.

## Manual install

Download `blueforest-lazygit-theme-<version>.json` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where lazygit reads its configuration:

```bash
mkdir -p ~/.config/lazygit
cp blueforest-lazygit-theme-<version>.json ~/.config/lazygit/config.yml
```

If you already have a configuration file, the theme is the `gui.theme` key of
it, so copy the mapping of the file under the `gui` key of your own:

```yaml
# ~/.config/lazygit/config.yml
gui:
  theme:
    activeBorderColor:
      - "#0099FF"
      - bold
    # ...
```

lazygit reads its configuration every time it starts, so there is nothing to
reload.

## The colours of the diffs are not part of the theme

lazygit renders the diffs with git, or with the diff renderer of your choice,
so the colours of the diffs are the ones of git and not the ones of this
theme. The [kitty theme](kitty.md) of the repository carries the colours of
the syntax of BlueForest, and the [bat theme](bat.md) carries them for a
diff renderer that reads a TextMate theme.

## The theme assumes a dark terminal

The colours of the theme are the ones of a dark terminal. lazygit asks the
terminal whether its background is dark or light, and it uses the colours of
the theme either way.

If your terminal has a light background, tell lazygit about it with the
`gui.colorScheme` setting of its configuration file, and it will pick the
colours that suit it:

```yaml
gui:
  colorScheme: light
```

## Invalid themes are ignored

lazygit ignores a key it does not know, and a colour it cannot resolve, and it
does so silently: the interface falls back to the colours lazygit ships with.
If the theme does not look right, check that the file is where lazygit reads
its configuration from, and that the colours of the theme are the ones of the
file.
