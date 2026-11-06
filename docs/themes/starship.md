# BlueForest palette and preset for Starship

The theme of Starship comes in two parts:

- The **palette** is a TOML table of colours. There are two variants:
  `blueforest` for the dark terminal and `blueforest-light` for the light one.
- The **preset** is a TOML file named `blueforest.toml`. It names the keys of
  the palette instead of writing the colours down, so the name of the preset is
  `blueforest` and the colours come from whichever palette is selected.

The two are installed apart, so the same preset can be paired with either
palette. The prompt is two lines: the information line, and the line of the
character. The duration of the last command and the Nix shell are at the right
of the information line.

## The names of the colours

The names of the keys of the palette are the ones of the palette of the
[community catalogue of Noctalia](https://github.com/noctalia-dev/community-templates)
for Starship, so the preset paints with the palette of Noctalia as well, and
with any other palette that follows the same vocabulary. The preset names nine
of them, and every one of them paints a part of the prompt:

| Key of the palette | What it paints                        |
| ------------------ | ------------------------------------- |
| `blue`             | the block of the system and the user  |
| `base`             | the text of that block                |
| `text`             | the directory                         |
| `peach`            | the branch, the status, the duration  |
| `flamingo`         | the languages that failed, the root user |
| `green`            | the languages that worked             |
| `mantle`           | the background of the directory       |
| `surface1`         | the background of the branch          |
| `crust`            | the background of the languages       |

The other keys of the palette carry the colours of the terminal of BlueForest,
under the names of the catalogue, so that the palette is a drop-in for the one
of Noctalia.

## Install with Nix

The repository packages them separately:

- `blueforest-starship-palette` carries `blueforest.toml` and
  `blueforest-light.toml` at its root, one per variant.
- `blueforest-starship-preset` carries the preset at its root and in
  `share/starship/presets/blueforest.toml`, where Starship looks for its
  presets.
- `blueforest-starship` is Starship with the preset bundled, so that
  `programs.starship.presets` can select it by name.

The overlay leaves `pkgs.starship` untouched.

`blueforest-theme.starship.palette.enable` defines the palette of the variant
in the settings of Starship and selects it, so there is nothing to select by
hand. `blueforest-theme.starship.preset.enable` installs the package that
carries the preset. Neither of them enables Starship.

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship.enable = true;

  blueforest-theme.starship = {
    palette = {
      enable = true; # define the palette of the variant and select it
      variant = "dark"; # or "light"
    };
    preset.enable = true; # install the preset
  };

  programs.starship.presets = [ "blueforest" ];
}
```

The selection of the palette is a default one, so a consumer that selects a
palette of its own keeps it. A palette that the module does not define has to
be defined by the consumer too, or the prompt comes out with no colour at all.

The switch is `blueforest-theme.starship.palette.enable` and not
`programs.starship.enable`, so that the theme and the templates of the
community catalogue of Noctalia for Starship are alternatives: a consumer that
wants a community template keeps the switch of the palette off, and a consumer
that wants this theme turns it on. A configuration that enables the palette and
a template fails to evaluate, because the two of them write the configuration
of Starship. The preset of the repository can be enabled with a template: it
is a package that carries the prompt, and the prompt names the keys of the
palette that the template writes.

### Only the palette

The palette can be defined without the preset, and painted by a preset of your
own:

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship.enable = true;

  blueforest-theme.starship.palette = {
    enable = true;
    variant = "light";
  };
}
```

### Only the preset

The preset can be installed without the palette of the repository, so that a
palette of your own defines the colours the preset names. The name of the
palette is `blueforest`, because that is the name the preset names, and it has
to be selected as well:

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship = {
    enable = true;
    presets = [ "blueforest" ];

    settings = {
      palette = "blueforest";

      palettes.blueforest = {
        blue = "#0099FF";
        base = "#0A101D";
        text = "#91CCFF";
        peach = "#FFCC33";
        flamingo = "#FF8080";
        green = "#80FF80";
        mantle = "#1B2B40";
        surface1 = "#273E5C";
        crust = "#375780";
      };
    };
  };

  blueforest-theme.starship.preset.enable = true;
}
```

A palette of your own has to define the nine keys that the preset names, and
nothing else: a key the preset names and the palette does not define is painted
with no colour at all, and Starship reports nothing.

## The palette of Noctalia

The names of the keys are the ones of the palette of the community catalogue of
Noctalia for Starship, so the preset of the repository paints with the palette
of Noctalia as well. The catalogue writes that palette into the configuration
of Starship and selects it, and the prompt of this repository is painted with
the colours of the palette of Noctalia, whatever palette the shell is running.

A consumer that wants the template of the catalogue and the preset of this
repository enables the preset and the template, and leaves the switch of the
palette off:

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship = {
    enable = true;
    presets = [ "blueforest" ];
  };

  blueforest-theme.starship.preset.enable = true;

  # The template of the catalogue, "starship" of the built-in ones or
  # "starship-m3" of the community ones.
  programs.noctalia.settings.theme.templates.builtin_ids = [ "starship" ];
}
```

The template writes the configuration of Starship, so it needs a file it can
write: a configuration that Home Manager manages is a link into the store, and
the store is read-only. A consumer that lets Home Manager write the
configuration of Starship uses the palette of the repository instead, and
leaves the template off.

If you only want the files, read them directly without replacing the Starship
package. The preset needs a palette, so read one of them as well:

```nix
programs.starship = {
  enable = true;
  settings =
    let
      read = file: builtins.fromTOML (builtins.readFile file);
    in
    (read "${pkgs.blueforest-starship-preset}/blueforest.toml")
    // (read "${pkgs.blueforest-starship-palette}/blueforest.toml")
    // {
      palette = "blueforest";
    };
};
```

The packages are also available as
`blueforest.packages.${system}.blueforest-starship-preset`,
`blueforest.packages.${system}.blueforest-starship-palette` and
`blueforest.packages.${system}.blueforest-starship`.

## Manual install

Download `blueforest-starship-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The archive carries the preset, the palettes and the changelog of the
release:

```text
CHANGELOG.txt
blueforest.toml
dark/blueforest.toml
light/blueforest-light.toml
```

The preset carries no colour and selects no palette, so the preset and a
palette are both needed. The name of the palette is what joins them, and the
line that selects it has to come before the tables of the preset:

```bash
{
  echo 'palette = "blueforest"'
  tar -xzf blueforest-starship-theme-<version>.tar.gz -O blueforest.toml
  tar -xzf blueforest-starship-theme-<version>.tar.gz -O dark/blueforest.toml
} >~/.config/starship.toml
```

`palette = "blueforest-light"` selects the light variant instead. If you
already have a configuration, merge the sections you want into it instead of
replacing it, and keep the `palette` line at the top. You can also keep the
files elsewhere and point `STARSHIP_CONFIG` at the merged file:

```bash
export STARSHIP_CONFIG="$HOME/.config/blueforest-starship.toml"
```

## Nerd Font

The prompt uses Nerd Font glyphs, so the terminal needs a Nerd Font installed
and selected.
