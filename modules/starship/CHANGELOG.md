# Change Log
All notable changes to the BlueForest preset for Starship will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## Unreleased

- The names of the keys of the palettes are the ones of the palette of the
  community catalogue of Noctalia for Starship now, so that the preset paints
  with the palette of Noctalia as well, and with any other palette that
  follows the same vocabulary. The preset names nine of them: `blue`,
  `base`, `text`, `peach`, `flamingo`, `green`, `mantle`, `surface1` and
  `crust`. A palette of your own has to carry those names now
- The preset of the repository can be enabled with a template of the community
  catalogue of Noctalia for Starship now. The template writes the palette and
  the preset names the keys of it. The palette of the repository still
  conflicts with the template, because the two of them write the configuration
  of Starship
- The check of the preset asserts that the palettes carry the keys of the
  community catalogue of Noctalia, and the check of the render renders the
  preset with the palettes of the catalogue, so that the two cannot drift
- The palette ships apart from the preset now. The palettes are
  `blueforest`, the dark variant, and `blueforest-light`, the light variant,
  and they are packaged as `blueforest-starship-palette`, which carries both
  of them
- The preset carries no colour of its own: it names the keys of a palette, so
  that the same preset is painted by either variant. A key the preset names
  and the palette does not define is painted with no colour, so the check of
  the preset compares the two
- The duration of the last command and the Nix shell are at the right of the
  information line now, in that order, and the block of the shell tapers with
  the inverted cap. The prompt is two lines, and the right-handed part of it
  is a segment of the format and not a right prompt of its own: every shell
  places a right prompt somewhere else, and bash has none at all
- The palette lives under `blueforest-theme.starship.palette` now:
  `blueforest-theme.starship.palette.enable` defines the palette of the
  variant in the settings of Starship, and
  `blueforest-theme.starship.palette.variant` selects the variant. The module
  selects the palette as well, so a configuration does not have to name it, and
  a consumer that selects a palette of its own keeps it
- `blueforest-theme.starship.preset.enable` is new, and it installs the
  package that carries the preset. A configuration that enables a template of
  the community catalogue of Noctalia for Starship and the palette of the
  repository fails to evaluate
- The release carries the two palettes as assets of their own, next to the
  preset
- Initial release: the BlueForest preset for Starship, packaged as
  `blueforest-starship-preset` and `blueforest-starship`
- The package that carries the preset declares the licences of what it ships,
  and the attribution of the theme travels with it
