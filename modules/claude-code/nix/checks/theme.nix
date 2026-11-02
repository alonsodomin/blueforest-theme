# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository, and
# that Claude Code reads it.
#
# Claude Code ignores a theme it cannot read, and it ignores a token it does
# not know, and it does so silently: the interface falls back to the colours
# of the built-in theme. The check therefore reads the theme with the very
# same rules Claude Code reads it with, and looks at what comes out of it.
{
  pkgs,
  source,
  theme,
}:
let
  # The tokens Claude Code reads, and the ones it does not.
  #
  # The list is the reference of Claude Code: the tokens of the interface, the
  # ones of the diffs, the ones of the messages, and the ones of the usage
  # meter. The shimmer variants, the colours of the subagents and the colours
  # of the rainbow are not among them: the theme of the repository does not
  # override them.
  known = [
    # The text and the accents.
    "claude"
    "text"
    "inverseText"
    "inactive"
    "subtle"
    "suggestion"
    "permission"
    "remember"

    # The states.
    "success"
    "error"
    "warning"
    "merged"

    # The input box and the modes.
    "promptBorder"
    "planMode"
    "autoAccept"
    "bashBorder"
    "ide"
    "fastMode"
    "effortUltra"

    # The diffs.
    "diffAdded"
    "diffRemoved"
    "diffAddedDimmed"
    "diffRemovedDimmed"
    "diffAddedWord"
    "diffRemovedWord"

    # The messages.
    "userMessageBackground"
    "userMessageBackgroundHover"
    "bashMessageBackgroundColor"
    "memoryBackgroundColor"
    "selectionBg"
    "composerSidebarBackground"

    # The usage meter and the labels.
    "rate_limit_fill"
    "rate_limit_empty"
    "briefLabelYou"
    "briefLabelClaude"
  ];

  # The colours of the theme.
  inherit ((builtins.fromJSON (builtins.readFile source))) overrides;
in
pkgs.runCommand "blueforest-claude-code-theme-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];

    known = builtins.toJSON known;
    overrides = builtins.toJSON overrides;
  }
  ''
    # The theme of the package is the theme of the repository.
    cmp ${theme}/blueforest.json ${source}
    cmp ${theme}/share/claude/themes/blueforest.json ${source}

    # And the attribution of the theme travels with it.
    test -f ${theme}/share/doc/blueforest/NOTICE.md
    test -f ${theme}/share/doc/blueforest/LICENSE

    # The theme is one Claude Code reads: it has a name, it has a base, and it
    # has the overrides of the colours.
    jq -e '
      has("name")
      and has("base")
      and has("overrides")
      and (.overrides | type == "object")
    ' ${source} >/dev/null

    # The base is one of the built-in themes of Claude Code.
    jq -e '
      .base
      | . == "dark"
        or . == "light"
        or . == "dark-daltonized"
        or . == "light-daltonized"
        or . == "dark-ansi"
        or . == "light-ansi"
    ' ${source} >/dev/null

    # Every token of the theme is one Claude Code knows. A token it does not
    # know is ignored, and the theme is then a theme with a hole in it.
    unknown=$(echo "$overrides" | jq -r --argjson known "$known" '
      keys_unsorted[]
      | select(. as $token | $known | index($token) | not)
    ')
    if [ -n "$unknown" ]; then
      echo "the theme has tokens Claude Code does not read:" >&2
      echo "$unknown" >&2
      exit 1
    fi

    # And every colour of the theme is one Claude Code can resolve. A colour
    # it cannot resolve is ignored, and the token keeps the colour of the
    # built-in theme.
    bad=$(echo "$overrides" | jq -r '
      to_entries[]
      | select(.value | test("^#[0-9a-fA-F]{6}$") | not)
      | .key
    ')
    if [ -n "$bad" ]; then
      echo "the theme has colours Claude Code cannot resolve:" >&2
      echo "$bad" >&2
      exit 1
    fi

    touch $out
  ''
