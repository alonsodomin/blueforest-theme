# BlueForest theme for OpenCode

The theme is a JSON file named `blueforest.json`. The name of the theme is
`blueforest`, the name of the file.

It is the format OpenCode 2 reads: the tokens of the `base`, shared by every
mode, and the palette of the `dark` mode. It is a dark theme, so it defines
that mode only.

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
}
```

The module does not enable OpenCode: whether the program is installed at all
stays your decision. It writes the theme to
`~/.config/opencode/themes/blueforest.json` and the selection to
`~/.config/opencode/cli.json`.

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

Download `blueforest-opencode-theme-<version>.json` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it in the themes directory of OpenCode, with the name of the theme:

```console
mkdir -p ~/.config/opencode/themes
cp blueforest-opencode-theme-<version>.json ~/.config/opencode/themes/blueforest.json
```

Select it in `~/.config/opencode/cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "blueforest",
    "mode": "dark"
  }
}
```

For a theme that belongs to a project, put the file in
`.opencode/themes/blueforest.json` inside the project instead.

## Invalid themes are ignored

OpenCode ignores a theme it cannot read, and it does so silently: a missing
token or a colour that does not resolve makes it fall back to the theme it
ships with. If the theme does not look right, check that the file is in the
themes directory under the name `blueforest.json` and that the selection in
`cli.json` points at `blueforest`.
