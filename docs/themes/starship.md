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

The module selects the package that carries the preset and the preset itself,
so the two of them are not needed in the configuration:

```nix
{
  imports = [
    blueforest.homeModules.starship
  ];

  programs.starship.enable = true;
  blueforest.starship.enable = true;
}
```

The module does not enable Starship: whether the program is installed at all
stays your decision. It writes nothing when `programs.starship.enable` is false
or when `blueforest.starship.enable` is false.

The switch of the preset is `blueforest.starship.enable`, and not
`programs.starship.enable`, so that the preset and the templates of the
community catalogue of Noctalia for Starship are alternatives: a consumer that
wants a community template keeps `blueforest.starship.enable` off, and a
consumer that wants this preset turns it on. A configuration that enables both
fails to evaluate: the two of them write the configuration of Starship.

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

```bash
mkdir -p ~/.config
cp blueforest-starship-preset-<version>.toml ~/.config/starship.toml
```

The preset is a complete Starship configuration. If you already have a
configuration, merge the sections you want into it instead of replacing it.
You can also keep the file elsewhere and point `STARSHIP_CONFIG` at it:

```bash
export STARSHIP_CONFIG="$HOME/.config/blueforest-starship.toml"
```

## Nerd Font

The prompt uses Nerd Font glyphs, so the terminal needs a Nerd Font installed
and selected.
