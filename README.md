# Blueforest Theme

[![Mozilla Public License 2.0](https://img.shields.io/badge/MPL--2.0-blue?logo=mozilla&logoColor=white)](LICENSE)
[![Creative Commons Attribution 4.0 International](https://img.shields.io/badge/CC_BY_4.0-lightgrey?logo=creativecommons&logoColor=black)](LICENSES/CC-BY-4.0.txt)

A dark blue theme inspired by the
[Blueforest IntelliJ](https://github.com/sirthias/BlueForest) theme, with ports
for several tools.

The full documentation, including installation instructions for every
application, is at
**<https://alonsodomin.github.io/blueforest-theme/>**.

| Application | Documentation |
| --- | --- |
| VS Code | [Install from Open VSX](https://alonsodomin.github.io/blueforest-theme/themes/vscode/) |
| bat | <https://alonsodomin.github.io/blueforest-theme/themes/bat/> |
| Neovim | <https://alonsodomin.github.io/blueforest-theme/themes/neovim/> |
| Starship | <https://alonsodomin.github.io/blueforest-theme/themes/starship/> |
| OpenCode | <https://alonsodomin.github.io/blueforest-theme/themes/opencode/> |
| sbt | <https://alonsodomin.github.io/blueforest-theme/themes/sbt/> |

## Installation

Every theme can be installed without Nix, and every theme is also available
through the repository's flake. The [documentation](https://alonsodomin.github.io/blueforest-theme/)
explains both ways for each application. The VS Code theme is published to
[Open VSX](https://open-vsx.org/extension/alonsodomin/blueforest-theme), which
is the recommended source for VS Code-compatible editors.

## Hacking

The repository is a Nix flake monorepo with one self-contained flake per
application. See the [Hacking section](https://alonsodomin.github.io/blueforest-theme/hacking/)
for the repository layout, the development shell, the checks, the workflows,
and the release process.

## License

The theme, its images, and its documentation are licensed under the
[Creative Commons Attribution 4.0 International licence](LICENSES/CC-BY-4.0.txt).
The code that packages them is licensed under the
[Mozilla Public License 2.0](LICENSE). [NOTICE.md](NOTICE.md) carries the
attribution of the original BlueForest theme and the licence of every path in
the repository.

The theme is a port of [BlueForest](https://github.com/sirthias/BlueForest) by
mathias[at]decodified[dot]com, licensed under the
[Creative Commons Attribution 3.0 Unported licence](https://creativecommons.org/licenses/by/3.0/).
