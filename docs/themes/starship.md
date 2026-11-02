# BlueForest preset for Starship

The preset is a TOML file named `blueforest.toml`. The name of the preset is
`blueforest`, the name of the file.

## Install with Nix

The preset is packaged twice:

- `blueforest-starship-preset` carries the preset at its root and in
  `share/starship/presets/blueforest.toml`, where Starship looks for its
  presets.
- `blueforest-starship` is Starship with the preset bundled, so that
  `programs.starship.presets` can select it by name.

The overlay leaves `pkgs.starship` untouched. With the module applied, enable
Starship and select the bundled package and preset:

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship = {
    enable = true;
    package = pkgs.blueforest-starship;
    presets = [ "blueforest" ];
  };
}
```

If you only want the preset file, read it directly without replacing the
Starship package:

```nix
programs.starship = {
  enable = true;
  settings = builtins.fromTOML (
    builtins.readFile "${pkgs.blueforest-starship-preset}/blueforest.toml"
  );
};
```

The package is also available as
`blueforest.packages.${system}.blueforest-starship-preset`.

## Manual install

Download `blueforest-starship-preset-<version>.toml` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
use it as the configuration of Starship:

```console
mkdir -p ~/.config
cp blueforest-starship-preset-<version>.toml ~/.config/starship.toml
```

The preset is a complete Starship configuration. If you already have a
configuration, merge the sections you want into it instead of replacing it.
You can also keep the file elsewhere and point `STARSHIP_CONFIG` at it:

```console
export STARSHIP_CONFIG="$HOME/.config/blueforest-starship.toml"
```

## Nerd Font

The prompt uses Nerd Font glyphs, so the terminal needs a Nerd Font installed
and selected.
