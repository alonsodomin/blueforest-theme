# BlueForest theme for Claude Code

The theme is a custom theme of
[Claude Code](https://github.com/anthropics/claude-code), the terminal agent of
Anthropic. The name of the file is `blueforest.json`.

It recolours the interface of Claude Code: the brand accent, the text, the
states, the input box, the diffs, the messages and the usage meter. The theme
follows the palette of BlueForest, the one of the other applications of this
repository.

The theme is based on the built-in `dark` theme of Claude Code, and it
overrides the colours of the tokens it knows. The colours Claude Code uses for
the subagents and for the rainbow of the `ultrathink` mode are not overridden,
so they keep the ones of the built-in theme.

## How Claude Code reads the theme

Claude Code reads the custom themes of the user from the `themes` directory of
its configuration directory:

```console
$HOME/.claude/themes/blueforest.json
```

A theme is selected by name. The name of a custom theme is its slug, which is
the name of the file without its extension, and the selection is the `theme`
setting of the settings file:

```json
{
  "theme": "custom:blueforest"
}
```

The settings file is `~/.claude/settings.json`, the same file that carries the
rest of the configuration of Claude Code.

Claude Code watches the `themes` directory and reloads it when a file is added
or changed, so a theme that is installed while a session is running is picked
up without a restart. The directory itself has to exist when Claude Code
starts: a directory that is created afterwards needs a restart of the session.

## Install with Nix

The theme is part of the configuration of Claude Code, so the Home Manager
module installs it where Claude Code reads the themes from, and selects it:

```nix
{
  imports = [
    blueforest.homeModules.claude-code
  ];

  programs.claude-code.enable = true;
}
```

The module does not enable Claude Code: whether the program is installed at
all stays your decision. It writes the theme to
`~/.claude/themes/blueforest.json`, selects it in the settings of Claude Code,
and it writes nothing when `programs.claude-code.enable` is false.

The theme is selected with `lib.mkDefault`, so a configuration that selects a
theme of its own keeps it:

```nix
{
  programs.claude-code.settings.theme = "custom:another-theme";
}
```

If you want the file itself, the package is
`blueforest.packages.<system>.blueforest-claude-code-theme`. It carries the
theme under the name of the theme and under the name Claude Code reads:

```text
blueforest.json
share/claude/themes/blueforest.json
```

There is no NixOS module: the theme of the user lives in the configuration
directory of the user, and that is where Claude Code reads the themes from.

## Manual install

Download `blueforest-claude-code-theme-<version>.json` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it where Claude Code reads the themes from:

```console
mkdir -p ~/.claude/themes
cp blueforest-claude-code-theme-<version>.json ~/.claude/themes/blueforest.json
```

Then select the theme in the settings of Claude Code, `~/.claude/settings.json`:

```json
{
  "theme": "custom:blueforest"
}
```

The `/theme` command of Claude Code lists the themes of the `themes` directory
and selects one of them, and it writes the selection in the settings file. It
replaces the theme the module selects, and the module writes the settings
again on the next activation, and the theme of this application is back.

## Invalid themes are ignored

Claude Code ignores a theme it cannot read, and it ignores a token it does not
know, and it does so silently: the interface falls back to the colours of the
built-in theme. If the interface does not look right, check that the file is
named `blueforest.json`, that it is where Claude Code reads the themes from,
and that the settings select `custom:blueforest`.
