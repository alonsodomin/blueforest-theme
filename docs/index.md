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
| Primary | `#0099FF` <span class="blueforest-swatch" style="background-color:#0099FF"></span> | On primary | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Secondary | `#91CCFF` <span class="blueforest-swatch" style="background-color:#91CCFF"></span> | On secondary | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Tertiary | `#FFCC33` <span class="blueforest-swatch" style="background-color:#FFCC33"></span> | On tertiary | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Error | `#FF8080` <span class="blueforest-swatch" style="background-color:#FF8080"></span> | On error | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Surface | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> | On surface | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> |
| Surface variant | `#1C2D42` <span class="blueforest-swatch" style="background-color:#1C2D42"></span> | On surface variant | `#91CCFF` <span class="blueforest-swatch" style="background-color:#91CCFF"></span> |
| Outline | `#333333` <span class="blueforest-swatch" style="background-color:#333333"></span> | Shadow | `#0A101D` <span class="blueforest-swatch" style="background-color:#0A101D"></span> |
| Hover | `#375780` <span class="blueforest-swatch" style="background-color:#375780"></span> | On hover | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> |

The colours of the terminal are the ANSI ones, and they are the same sixteen
that every application of the repository paints with:

| Colour | Normal | Bright |
| --- | --- | --- |
| Black | `#1B2B40` <span class="blueforest-swatch" style="background-color:#1B2B40"></span> | `#56697D` <span class="blueforest-swatch" style="background-color:#56697D"></span> |
| Red | `#B02A28` <span class="blueforest-swatch" style="background-color:#B02A28"></span> | `#FF8080` <span class="blueforest-swatch" style="background-color:#FF8080"></span> |
| Green | `#219186` <span class="blueforest-swatch" style="background-color:#219186"></span> | `#80FF80` <span class="blueforest-swatch" style="background-color:#80FF80"></span> |
| Yellow | `#B3871F` <span class="blueforest-swatch" style="background-color:#B3871F"></span> | `#FFCC33` <span class="blueforest-swatch" style="background-color:#FFCC33"></span> |
| Blue | `#0099FF` <span class="blueforest-swatch" style="background-color:#0099FF"></span> | `#91CCFF` <span class="blueforest-swatch" style="background-color:#91CCFF"></span> |
| Magenta | `#C57633` <span class="blueforest-swatch" style="background-color:#C57633"></span> | `#DDBB88` <span class="blueforest-swatch" style="background-color:#DDBB88"></span> |
| Cyan | `#1B7A70` <span class="blueforest-swatch" style="background-color:#1B7A70"></span> | `#4FD6A0` <span class="blueforest-swatch" style="background-color:#4FD6A0"></span> |
| White | `#7F8FA3` <span class="blueforest-swatch" style="background-color:#7F8FA3"></span> | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> |

The colours of the terminal itself are:

| Element | Colour |
| --- | --- |
| Foreground | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> |
| Background | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Selection | `#375780` <span class="blueforest-swatch" style="background-color:#375780"></span> on `#141F2E` |
| Cursor | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> on `#141F2E` |

### The light palette

The light palette is not a copy of the dark one with the colours inverted: it
is a palette of its own, with colours that keep their meaning and read well
on a light surface. Its background is `#EFEFEF`, a soft white, and its text is
`#141F2E`, the navy of the dark palette. The accent stays the same, so that a
name, a border, or a link looks the same in both of them.

| Role | Colour | Role | Colour |
| --- | --- | --- | --- |
| Primary | `#0099FF` <span class="blueforest-swatch" style="background-color:#0099FF"></span> | On primary | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Secondary | `#3A5F8A` <span class="blueforest-swatch" style="background-color:#3A5F8A"></span> | On secondary | `#EFEFEF` <span class="blueforest-swatch" style="background-color:#EFEFEF"></span> |
| Tertiary | `#B3871F` <span class="blueforest-swatch" style="background-color:#B3871F"></span> | On tertiary | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Error | `#DC322F` <span class="blueforest-swatch" style="background-color:#DC322F"></span> | On error | `#EFEFEF` <span class="blueforest-swatch" style="background-color:#EFEFEF"></span> |
| Surface | `#EFEFEF` <span class="blueforest-swatch" style="background-color:#EFEFEF"></span> | On surface | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Surface variant | `#E7E7E7` <span class="blueforest-swatch" style="background-color:#E7E7E7"></span> | On surface variant | `#56697D` <span class="blueforest-swatch" style="background-color:#56697D"></span> |
| Outline | `#7F8FA3` <span class="blueforest-swatch" style="background-color:#7F8FA3"></span> | Shadow | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Hover | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> | On hover | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |

The colours of the terminal of the light palette are darker than the ones of
the dark palette, because a light background needs more contrast:

| Colour | Normal | Bright |
| --- | --- | --- |
| Black | `#1B2B40` <span class="blueforest-swatch" style="background-color:#1B2B40"></span> | `#333333` <span class="blueforest-swatch" style="background-color:#333333"></span> |
| Red | `#B02A28` <span class="blueforest-swatch" style="background-color:#B02A28"></span> | `#DC322F` <span class="blueforest-swatch" style="background-color:#DC322F"></span> |
| Green | `#1E5C1E` <span class="blueforest-swatch" style="background-color:#1E5C1E"></span> | `#22AA44` <span class="blueforest-swatch" style="background-color:#22AA44"></span> |
| Yellow | `#808000` <span class="blueforest-swatch" style="background-color:#808000"></span> | `#B3871F` <span class="blueforest-swatch" style="background-color:#B3871F"></span> |
| Blue | `#3A5F8A` <span class="blueforest-swatch" style="background-color:#3A5F8A"></span> | `#0099FF` <span class="blueforest-swatch" style="background-color:#0099FF"></span> |
| Magenta | `#C57633` <span class="blueforest-swatch" style="background-color:#C57633"></span> | `#CB4B16` <span class="blueforest-swatch" style="background-color:#CB4B16"></span> |
| Cyan | `#1B7A70` <span class="blueforest-swatch" style="background-color:#1B7A70"></span> | `#219186` <span class="blueforest-swatch" style="background-color:#219186"></span> |
| White | `#7F8FA3` <span class="blueforest-swatch" style="background-color:#7F8FA3"></span> | `#56697D` <span class="blueforest-swatch" style="background-color:#56697D"></span> |

The colours of the terminal itself are:

| Element | Colour |
| --- | --- |
| Foreground | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> |
| Background | `#EFEFEF` <span class="blueforest-swatch" style="background-color:#EFEFEF"></span> |
| Selection | `#D0D0D0` <span class="blueforest-swatch" style="background-color:#D0D0D0"></span> on `#141F2E` |
| Cursor | `#141F2E` <span class="blueforest-swatch" style="background-color:#141F2E"></span> on `#EFEFEF` |

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
