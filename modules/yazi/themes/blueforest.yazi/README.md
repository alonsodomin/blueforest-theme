# BlueForest

The BlueForest theme for [Yazi](https://github.com/sxyazi/yazi), the terminal
file manager.

It is a flavour: a theme of its own, in a directory of its own, that Yazi
merges with the preset it ships with. The theme of the user takes precedence
over both of them.

## Layout

| File | What it is |
| --- | --- |
| `flavor.toml` | The colours of the flavour, in the format Yazi reads |
| `tmtheme.xml` | The colours of the code preview, as a TextMate theme |

## Usage

Copy the directory into the flavours of Yazi, and select it in the theme of
the user, which is `~/.config/yazi/theme.toml`:

```toml
[flavor]
dark  = "blueforest"
light = "blueforest"
```

Both modes are selected, because the flavour is a dark one.

## Licence

The flavour is licensed under the
[Creative Commons Attribution 4.0 International][cc-by-4.0] licence. It is a
port of BlueForest by [mathias[at]decodified[dot]com][author], published at
<https://github.com/sirthias/BlueForest> under the
[Creative Commons Attribution 3.0 Unported][cc-by-3.0] licence.

[author]: https://github.com/sirthias
[cc-by-3.0]: https://creativecommons.org/licenses/by/3.0/
[cc-by-4.0]: https://creativecommons.org/licenses/by/4.0/
