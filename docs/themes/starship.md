# BlueForest palette and preset for Starship

The theme of Starship comes in two parts:

- The **palette** is a TOML table of colours. There are two variants:
  `blueforest` for the dark terminal and `blueforest-light` for the light one.
- The **preset** is a TOML file named `blueforest.toml`. It names the keys of
  the palette instead of writing the colours down, so the name of the preset is
  `blueforest` and the colours come from whichever palette is selected.

The two are installed apart, so the same preset can be paired with either
palette. The preset also puts the duration of the last command and the Nix
shell on the right prompt.

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
wants a community template keeps the switches off, and a consumer that wants
this theme turns them on. A configuration that enables a template and either
switch fails to evaluate, because the two of them write the configuration of
Starship.

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
        primary = "#0099FF";
        on_primary = "#0A101D";
        secondary = "#91CCFF";
        tertiary = "#FFCC33";
        error = "#FF8080";
        success = "#80FF80";
        surface = "#1B2B40";
        surface_variant = "#273E5C";
        hover = "#375780";
      };
    };
  };

  blueforest-theme.starship.preset.enable = true;
}
```

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

Download the preset and one palette from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases):

- `blueforest-starship-preset-<version>.toml`, the preset.
- `blueforest-starship-palette-<version>.toml`, the dark palette.
- `blueforest-starship-palette-light-<version>.toml`, the light palette.

The preset carries no colour and selects no palette, so both files are needed.
The name of the palette is what joins them, and the line that selects it has to
come before the tables of the preset:

```bash
{
  echo 'palette = "blueforest"'
  cat blueforest-starship-preset-<version>.toml
  cat blueforest-starship-palette-<version>.toml
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
