# BlueForest theme for lazydocker

The theme is the `gui.theme` mapping of the configuration file of
[lazydocker](https://github.com/jesseduffield/lazydocker), the simple terminal
UI for Docker and Docker Compose.

lazydocker has no theme file of its own: the theme is part of its configuration,
and the file of this application is a configuration file of lazydocker that
carries it. The name of the file is `blueforest.json`, and the light variant is
`blueforest-light.json`.

It is the format lazydocker reads: the colours of the borders of the panels, of
the selected line, and of the line at the bottom, which carries the keybindings.
The theme follows the palette of BlueForest, the one of the other applications
of this repository.

The colours are true colour, so the terminal has to support it.

## How lazydocker reads the theme

lazydocker reads the configuration of the user from the `lazydocker` directory
of its configuration directory:

```bash
$XDG_CONFIG_HOME/lazydocker/config.yml
```

which is `~/.config/lazydocker/config.yml` when `XDG_CONFIG_HOME` is not set.

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

The file of this application is JSON, and JSON is a subset of YAML: lazydocker
reads it as its own format, and so does every other tool that reads YAML.

lazydocker knows four colours: `activeBorderColor`, the border of the panel
that has the focus and the text of the selected line; `inactiveBorderColor`,
the border of the panels that have no focus; `selectedLineBgColor`, the
background of the selected line; and `optionsTextColor`, the text of the line at
the bottom.

## Install with Nix

The theme is part of the configuration of lazydocker, so the Home Manager module
adds it to the settings of lazydocker:

```nix
{
  imports = [
    blueforest.homeModules.lazydocker
  ];

  programs.lazydocker.enable = true;
  blueforest-theme.lazydocker.enable = true;
}
```

The module does not enable lazydocker: whether the program is installed at all
stays your decision. It adds the theme to the settings of lazydocker, and it
writes nothing when `programs.lazydocker.enable` is false or when
`blueforest-theme.lazydocker.enable` is false.

The switch of the theme is `blueforest-theme.lazydocker.enable`, and not
`programs.lazydocker.enable`, so that every theme of the repository is turned on
and off on its own.

Every colour of the theme is a default one, so a configuration that brings a
colour of its own keeps it, and keeps the rest of the theme as well:

```nix
{
  programs.lazydocker.settings.gui.theme.activeBorderColor = [ "#FF0000" ];
}
```

The theme has a variant per mode, and `blueforest-theme.lazydocker.variant`
selects the one that is installed: the dark one, which is named `blueforest`, or
the light one, which is named `blueforest-light`:

```nix
{
  programs.lazydocker.enable = true;
  blueforest-theme.lazydocker.enable = true;
  blueforest-theme.lazydocker.variant = "light";
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-lazydocker-theme`. It carries the theme
under the name of the theme and under the name of the directory of the themes
of lazydocker:

```text
blueforest.json
blueforest-light.json
share/lazydocker/themes/blueforest.json
share/lazydocker/themes/blueforest-light.json
```

lazydocker reads no system-wide configuration file, so there is no place where
the theme of the system would live: there is no NixOS module, and the theme
of the user lives in the configuration directory of the user.

## Manual install

Download `blueforest-lazydocker-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The archive carries the theme and the changelog of the application:

```text
CHANGELOG.txt
dark/blueforest.json
light/blueforest-light.json
```

Put the theme where lazydocker reads its configuration:

```bash
mkdir -p ~/.config/lazydocker
tar -xzf blueforest-lazydocker-theme-<version>.tar.gz -O dark/blueforest.json \
  > ~/.config/lazydocker/config.yml
```

If you already have a configuration file, the theme is the `gui.theme` key of
it, so copy the mapping of the file under the `gui` key of your own:

```yaml
# ~/.config/lazydocker/config.yml
gui:
  theme:
    activeBorderColor:
      - "#0099FF"
      - bold
    # ...
```

lazydocker reads its configuration every time it starts, so there is nothing to
reload.

## The statuses of the containers are not part of the theme

lazydocker paints the status of a container with the colours it ships with: the
green of a running container, the red of an exited one, and so on. The theme
only paints the borders of the panels, the selected line, and the line at the
bottom, so the statuses keep the colours of lazydocker.

## Invalid themes are ignored

lazydocker ignores a key it does not know, and a colour it cannot resolve, and it
does so silently: the interface falls back to the colours lazydocker ships with.
If the theme does not look right, check that the file is where lazydocker reads
its configuration from, and that the colours of the theme are the ones of the
file.
