# BlueForest theme for Yazi

The theme is a **flavour**, a directory named `blueforest.yazi`, in the format
[Yazi](https://github.com/sxyazi/yazi) reads:

```text
blueforest.yazi/
├── flavor.toml    # the colours of the theme
└── tmtheme.xml    # the colours of the code preview
```

A flavour is a theme of its own. Yazi merges it with the preset it ships
with, and the theme of the user takes precedence over both of them. The name
of the flavour is the name of its directory, without the `.yazi` suffix:
`blueforest`.

The colours are true colour, so the terminal has to support it.

## How Yazi reads the theme

Yazi reads the flavours from the `flavors` directory of its configuration
directory:

```console
$XDG_CONFIG_HOME/yazi/flavors/blueforest.yazi/
```

which is `~/.config/yazi/flavors/blueforest.yazi/` when `XDG_CONFIG_HOME` is
not set. The `YAZI_CONFIG_HOME` variable takes precedence over it: when it is
set, Yazi reads the flavours from `<YAZI_CONFIG_HOME>/flavors/`.

A flavour is only used when the theme of the user selects it. The theme of
the user is `~/.config/yazi/theme.toml`, and it selects the flavour like
this:

```toml
[flavor]
dark  = "blueforest"
light = "blueforest"
```

Both modes are selected, because the flavour is a dark one.

## Install with Nix

The theme is part of the configuration of Yazi, so the Home Manager module
installs the flavour where Yazi reads it, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.yazi
  ];

  programs.yazi.enable = true;
}
```

The module does not enable Yazi: whether the program is installed at all stays
your decision. It writes the flavour to
`~/.config/yazi/flavors/blueforest.yazi/`, and it writes nothing when
`programs.yazi.enable` is false.

Home Manager has an option of its own for the theme of Yazi,
`programs.yazi.theme`, which writes the file the selection goes into. The
theme of this application is a default one, so a consumer that sets that
option keeps their own theme. Such a consumer selects the flavour by adding
the `flavor` section to it:

```nix
{
  programs.yazi.theme = {
    flavor = {
      dark = "blueforest";
      light = "blueforest";
    };
  };
}
```

If you want the files themselves, the package is
`blueforest.packages.${system}.blueforest-yazi-theme`. It carries the
flavour under the name of the flavour and under the name Yazi reads:

```text
blueforest.yazi/
share/yazi/flavors/blueforest.yazi/
```

There is no NixOS module: Yazi reads the theme from the configuration
directory of the user, and there is no system-wide directory it reads.

## Manual install

Download `blueforest-yazi-theme-<version>.tar.gz` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
unpack it into the directory Yazi reads the flavours from:

```console
mkdir -p ~/.config/yazi/flavors
tar -xzf blueforest-yazi-theme-<version>.tar.gz -C ~/.config/yazi/flavors
```

Then select the flavour in the theme of the user:

```console
cat >~/.config/yazi/theme.toml <<'EOF'
[flavor]
dark  = "blueforest"
light = "blueforest"
EOF
```

## The code preview

The flavour carries a TextMate theme, `tmtheme.xml`, and Yazi paints the code
of the preview with it. It is the theme the repository ships for
[bat](bat.md), so the code of the preview has the colours of the rest of the
repository.

## When the flavour is applied

Yazi asks the terminal about its background colour when it starts, and it
applies the flavour when the terminal answers. Most terminals answer, and the
flavour is there right away. A terminal that does not answer leaves Yazi with
the preset it ships with, until the flavour is applied by other means.
