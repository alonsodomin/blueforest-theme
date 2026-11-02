# BlueForest prompt for sbt

The prompt is the `BlueforestTheme` of the
[sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin. This repository
does not define the prompt: it declares the plugin and selects its theme.

The plugin is declared as:

```scala
addSbtPlugin("com.github.alonsodomin" % "sbt-prompt" % "3.0.0")
```

and the prompt is selected with:

```scala
import com.github.alonsodomin.sbt.prompt.SbtPrompt.autoImport._

promptTheme := BlueforestTheme
```

The theme is `PromptThemes.BlueforestTheme` in the upstream repository. See the
[sbt-prompt repository](https://github.com/alonsodomin/sbt-prompt) for the
prompt and the theme themselves.

The prompt uses true colour and Nerd Font glyphs, so the terminal has to
support both.

## Install with Nix

The Home Manager module installs the plugin declaration and the theme
selection in the global configuration of both generations of sbt:

```nix
{
  imports = [
    blueforest.homeModules.sbt
  ];

  programs.sbt.enable = true;
}
```

The module does not enable sbt: it only writes the files when
`programs.sbt.enable` is true. It writes both generations, because a consumer
may run either of them.

| File | sbt 1.x | sbt 2.x |
| --- | --- | --- |
| Plugin | `~/.sbt/1.0/plugins/sbt-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/plugins/sbt-prompt.sbt` |
| Theme | `~/.sbt/1.0/blueforest-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/blueforest-prompt.sbt` |

The sbt 1 paths are relative to `programs.sbt.baseUserConfigPath`, which is
`.sbt` by default. The sbt 2 paths follow the XDG base directory specification.

The package `blueforest-sbt-prompt` carries the same files under `share/sbt/`:

```text
share/sbt/plugins/sbt-prompt.sbt
share/sbt/blueforest-prompt.sbt
```

Adding the package to `home.packages` alone is not enough: Home Manager does
not copy the files into the configuration of sbt. The module is the supported
way to install them.

There is no NixOS module: sbt reads the configuration of the user, and there is
no system-wide directory it reads.

## Manual install

For a single project, declare the plugin in `project/plugins.sbt` and select
the theme in `build.sbt`:

```scala
// project/plugins.sbt
addSbtPlugin("com.github.alonsodomin" % "sbt-prompt" % "3.0.0")
```

```scala
// build.sbt
import com.github.alonsodomin.sbt.prompt.SbtPrompt.autoImport._

promptTheme := BlueforestTheme
```

For every project of the user, write the same files into the global
configuration of sbt. The location depends on the generation of sbt:

| File | sbt 1.x | sbt 2.x |
| --- | --- | --- |
| Plugin | `~/.sbt/1.0/plugins/sbt-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/plugins/sbt-prompt.sbt` |
| Theme | `~/.sbt/1.0/blueforest-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/blueforest-prompt.sbt` |

sbt 2 follows the XDG base directory specification. When `XDG_CONFIG_HOME` is
not set, it falls back to `~/.config`.

Every release of the repository attaches `blueforest-sbt-prompt-<version>.tar.gz`.
It carries the two files in the layout of the global configuration of sbt:

```text
plugins/sbt-prompt.sbt
blueforest-prompt.sbt
```
