# BlueForest theme for OpenCode

The theme is a JSON file named `blueforest.json`. The name of the theme is
`blueforest`, the name of the file.

It is the format OpenCode 2 reads: the tokens of the `base`, shared by every
mode, and the palette of each mode. The theme has a dark variant and a light
one, so it follows the appearance of the terminal.

!!! warning "OpenCode 2 only"

    OpenCode 1 reads `tui.json` instead of `cli.json`, and this theme does not
    support it.

## Install with Nix

The theme is part of the configuration of OpenCode, so the Home Manager module
writes it and selects it:

```nix
{
  imports = [
    blueforest.homeModules.opencode
  ];

  programs.opencode.enable = true;
  blueforest-theme.opencode.enable = true;
}
```

The module does not enable OpenCode: whether the program is installed at all
stays your decision. It writes the theme to
`~/.config/opencode/themes/blueforest.json` and the selection to
`~/.config/opencode/cli.json`.

The switch of the theme is `blueforest-theme.opencode.enable`, and not
`programs.opencode.enable`, so that the theme and the template of the
community catalogue of Noctalia for OpenCode are alternatives: a consumer that
wants the community template keeps `blueforest-theme.opencode.enable` off, and a
consumer that wants this theme turns it on. A configuration that enables both
fails to evaluate: the two of them write the configuration of OpenCode.

If you want the file itself, the package is
`blueforest.packages.${system}.blueforest-opencode-theme`:

```nix
{
  home.packages = [
    blueforest.packages.${system}.blueforest-opencode-theme
  ];
}
```

The NixOS module only adds the overlay. OpenCode reads the configuration of
the user, and there is no system-wide directory it reads.

## Manual install

Download `blueforest-opencode-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The archive carries the theme and the changelog of the application:

```text
CHANGELOG.txt
blueforest.json
```

Put the theme in the themes directory of OpenCode, with the name of the theme:

```bash
mkdir -p ~/.config/opencode/themes
tar -xzf blueforest-opencode-theme-<version>.tar.gz -O blueforest.json \
  > ~/.config/opencode/themes/blueforest.json
```

Select it in `~/.config/opencode/cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "blueforest",
    "mode": "system"
  }
}
```

The `mode` is `system`, so the theme follows the appearance of the terminal. It
can be `dark` or `light` as well, to lock the theme to one of them.

For a theme that belongs to a project, put the file in
`.opencode/themes/blueforest.json` inside the project instead.

## The light variant

The theme carries a light variant as well, next to the dark one, and OpenCode
picks the one that matches the appearance of the terminal.

The light variant is not the dark one with the colours inverted: it is a
palette of its own, with the colours of the light palette of the repository.
The [palette reference](../index.md#colour-palettes) has every colour of it,
with the swatches.

## Invalid themes are ignored

OpenCode ignores a theme it cannot read, and it does so silently: a missing
token or a colour that does not resolve makes it fall back to the theme it
ships with. If the theme does not look right, check that the file is in the
themes directory under the name `blueforest.json` and that the selection in
`cli.json` points at `blueforest`.
