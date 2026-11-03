# Themes

Every application has its own page. The page explains how to install the theme
with Nix, how to install it by hand, and how to select it once it is
installed.

| Application | Recommended installation                             |
| ----------- | ---------------------------------------------------- |
| bat         | [Nix](bat.md) or [release asset](bat.md)             |
| btop        | [Nix](btop.md) or [release asset](btop.md)           |
| Claude Code | [Nix](claude-code.md) or [release asset](claude-code.md) |
| eza         | [Nix](eza.md) or [release asset](eza.md)             |
| kitty       | [Nix](kitty.md) or [release asset](kitty.md)         |
| lazygit     | [Nix](lazygit.md) or [release asset](lazygit.md)     |
| md-tui      | [Nix](md-tui.md) or [release asset](md-tui.md)       |
| MkDocs      | [Nix](mkdocs.md) or [release asset](mkdocs.md)       |
| Neovim      | [Nix](neovim.md) or [release asset](neovim.md)       |
| Noctalia    | [Nix](noctalia.md) or [release asset](noctalia.md)   |
| OpenCode    | [Nix](opencode.md) or [release asset](opencode.md)   |
| sbt         | [Nix](sbt.md) or [upstream plugin](sbt.md)           |
| Starship    | [Nix](starship.md) or [release asset](starship.md)   |
| VS Code     | [Open VSX](vscode.md) or [Nix](vscode.md)            |
| Yazi        | [Nix](yazi.md) or [release asset](yazi.md)           |
| Zed         | [Extension Gallery](zed.md) or [Nix](zed.md)         |

The release assets are attached to the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The theme for VS Code and the theme for Zed are published to a registry, which
is the recommended way to install them; the Nix route of their pages is meant
for developing and testing the theme.

Every theme of the repository has a switch of its own,
`blueforest-theme.<application>.enable`, and it is off by default. The switch is
separate from `programs.<application>.enable`, so that a theme and a template
of the community catalogue of Noctalia are alternatives, and so that a
configuration that wants the theme of one application only does not get the
themes of all of them.

The [installation page](../installation.md) explains how to use the flake as a
whole, and the [outputs reference](../reference/outputs.md) lists the packages
and modules it provides.