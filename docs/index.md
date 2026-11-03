# BlueForest Theme

A dark blue theme inspired by the
[BlueForest IntelliJ theme](https://github.com/sirthias/BlueForest), optimised
for syntax highlighting in a wide range of languages.

![BlueForest theme screenshot](assets/screenshot.png)

The theme is available for the following applications:

| Application | Documentation                  |
| ----------- | ------------------------------ |
| bat         | [bat](themes/bat.md)           |
| btop        | [btop](themes/btop.md)         |
| Claude Code | [Claude Code](themes/claude-code.md) |
| eza         | [eza](themes/eza.md)           |
| kitty       | [kitty](themes/kitty.md)       |
| lazygit     | [lazygit](themes/lazygit.md)   |
| md-tui      | [md-tui](themes/md-tui.md)     |
| MkDocs      | [MkDocs](themes/mkdocs.md)     |
| Neovim      | [Neovim](themes/neovim.md)     |
| Noctalia    | [Noctalia](themes/noctalia.md) |
| OpenCode    | [OpenCode](themes/opencode.md) |
| sbt         | [sbt](themes/sbt.md)           |
| Starship    | [Starship](themes/starship.md) |
| VS Code     | [VS Code](themes/vscode.md)    |
| Yazi        | [Yazi](themes/yazi.md)         |
| Zed         | [Zed](themes/zed.md)           |

Every application has its own installation page. Each page explains how to
install the theme with Nix, how to install it by hand, and how to select it
once it is installed.

## Colour palettes

The repository has two colour palettes: a dark one and a light one. They are
the same palette, painted for two different surroundings, and they share the
same accent, `#0099FF`, the blue of the name.

The [Noctalia palette](themes/noctalia.md) carries both of them, and it is the
reference of the colours of the other applications: every theme of the
repository paints the terminal with the sixteen colours of the palette of its
own variant, and the colours of the dark variant are the ones of the VS Code
theme and of the Neovim theme.

### The dark palette

The dark palette is the one BlueForest was designed for. Its background is
`#141F2E`, a deep navy, and its text is `#D0D0D0`, a soft grey. The interface
roles of the palette are:

| Role | Colour | Role | Colour |
| --- | --- | --- | --- |
| Primary | `#0099FF` | On primary | `#141F2E` |
| Secondary | `#91CCFF` | On secondary | `#141F2E` |
| Tertiary | `#FFCC33` | On tertiary | `#141F2E` |
| Error | `#FF8080` | On error | `#141F2E` |
| Surface | `#141F2E` | On surface | `#D0D0D0` |
| Surface variant | `#1C2D42` | On surface variant | `#91CCFF` |
| Outline | `#333333` | Shadow | `#0A101D` |
| Hover | `#375780` | On hover | `#D0D0D0` |

The colours of the terminal are the ANSI ones, and they are the same sixteen
that every application of the repository paints with:

| Colour | Normal | Bright |
| --- | --- | --- |
| Black | `#1B2B40` | `#56697D` |
| Red | `#B02A28` | `#FF8080` |
| Green | `#219186` | `#80FF80` |
| Yellow | `#B3871F` | `#FFCC33` |
| Blue | `#0099FF` | `#91CCFF` |
| Magenta | `#C57633` | `#DDBB88` |
| Cyan | `#1B7A70` | `#4FD6A0` |
| White | `#7F8FA3` | `#D0D0D0` |

The foreground of the terminal is `#D0D0D0`, its background is `#141F2E`, the
selection is `#375780` on `#141F2E`, and the cursor is `#D0D0D0` on `#141F2E`.

### The light palette

The light palette is not a copy of the dark one with the colours inverted: it
is a palette of its own, with colours that keep their meaning and read well
on a light surface. Its background is `#EFEFEF`, a soft white, and its text is
`#141F2E`, the navy of the dark palette. The accent stays the same, so that a
name, a border, or a link looks the same in both of them.

| Role | Colour | Role | Colour |
| --- | --- | --- | --- |
| Primary | `#0099FF` | On primary | `#141F2E` |
| Secondary | `#3A5F8A` | On secondary | `#EFEFEF` |
| Tertiary | `#B3871F` | On tertiary | `#141F2E` |
| Error | `#DC322F` | On error | `#EFEFEF` |
| Surface | `#EFEFEF` | On surface | `#141F2E` |
| Surface variant | `#E7E7E7` | On surface variant | `#56697D` |
| Outline | `#7F8FA3` | Shadow | `#141F2E` |
| Hover | `#D0D0D0` | On hover | `#141F2E` |

The colours of the terminal of the light palette are darker than the ones of
the dark palette, because a light background needs more contrast:

| Colour | Normal | Bright |
| --- | --- | --- |
| Black | `#1B2B40` | `#333333` |
| Red | `#B02A28` | `#DC322F` |
| Green | `#1E5C1E` | `#22AA44` |
| Yellow | `#808000` | `#B3871F` |
| Blue | `#3A5F8A` | `#0099FF` |
| Magenta | `#C57633` | `#CB4B16` |
| Cyan | `#1B7A70` | `#219186` |
| White | `#7F8FA3` | `#56697D` |

The foreground of the terminal is `#141F2E`, its background is `#EFEFEF`, the
selection is `#141F2E` on `#D0D0D0`, and the cursor is `#141F2E` on `#EFEFEF`.

Every pair of a role and of its counterpart clears a contrast ratio of 3.0, so
that the text of the interface reads well in both of the palettes.

## Installing

The recommended way to install the theme depends on the application. The
[VS Code theme](themes/vscode.md) is published to
[Open VSX](https://open-vsx.org/extension/alonsodomin/blueforest-theme),
which is the recommended source for VS Code-compatible editors. The other
themes are published as assets of the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases),
and every one of them can also be installed with Nix.

The repository is a Nix flake, and the [installation page](installation.md)
explains how to take the whole flake, a single application, or the overlay
alone.

## Supported languages

The theme has syntax highlighting for:

- Bash
- C / C++
- C#
- Elm
- Fish (shell)
- GLSL
- Golang
- Groovy
- Haskell
- HTML
- Java
- JavaScript
- JSON
- Kotlin
- Markdown
- Nix
- Powershell
- PureScript
- Python
- Ruby
- Rust
- Scala
- Smithy
- Swift
- TOML
- TypeScript
- XML
- YAML

## Hacking

The repository is a Nix flake monorepo, and every application is a flake of
its own. If you want to work on the theme itself, read the
[Hacking section](hacking/index.md). It covers the repository layout, the
development shell, the checks, the workflows, and the release process.

## License

The theme, its images, and its documentation are licensed under the
[Creative Commons Attribution 4.0 International licence](license.md). The code
that packages the theme is licensed under the
[Mozilla Public License 2.0](license.md).
