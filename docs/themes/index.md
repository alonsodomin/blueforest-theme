# Themes

Every application has its own page. The page explains how to install the theme
with Nix, how to install it by hand, and how to select it once it is
installed.

| Application | Recommended installation                             |
| ----------- | ---------------------------------------------------- |
| VS Code     | [Open VSX](vscode.md) or [Nix](vscode.md)            |
| bat         | [Nix](bat.md) or [release asset](bat.md)             |
| Neovim      | [Nix](neovim.md) or [release asset](neovim.md)       |
| Starship    | [Nix](starship.md) or [release asset](starship.md)   |
| OpenCode    | [Nix](opencode.md) or [release asset](opencode.md)   |
| sbt         | [Nix](sbt.md) or [upstream plugin](sbt.md)           |
| eza         | [Nix](eza.md) or [release asset](eza.md)             |
| Zed         | [Extension Gallery](zed.md) or [Nix](zed.md)         |
| Yazi        | [Nix](yazi.md) or [release asset](yazi.md)           |
| kitty       | [Nix](kitty.md) or [release asset](kitty.md)         |

The release assets are attached to the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases).
The theme for VS Code and the theme for Zed are published to a registry, which
is the recommended way to install them; the Nix route of their pages is meant
for developing and testing the theme.

The [installation page](../installation.md) explains how to use the flake as a
whole, and the [outputs reference](../reference/outputs.md) lists the packages
and modules it provides.
