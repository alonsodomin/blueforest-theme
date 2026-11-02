# SPDX-License-Identifier: MPL-2.0
#
# Checks that the code blocks of the documentation are marked with a language
# that the applications of the repository highlight.
#
# The check spans applications, so it belongs to the repository and not to one
# of them: the marker of a block decides whether every application paints it
# or leaves it alone.
{
  pkgs,
  # The Markdown files of the documentation.
  sources,
}:
let
  # The markers the documentation may use.
  #
  # `bash` is the marker of the shell blocks, and it is the one that the
  # editor of VS Code, the preview of VS Code, Pygments, bat, Neovim, Zed and
  # Shiki all know. A marker that only a few of them know leaves the blocks
  # plain in the others: `console`, for instance, is an alias of the session
  # lexer of Pygments and of the session grammar of Shiki, and nothing else
  # knows it.
  markers = [
    "bash"
    "json"
    "lua"
    "nix"
    "scala"
    "text"
    "toml"
    "vim"
    "yaml"
  ];

  # The list of the markers, one per line, for the check to read.
  markersList = pkgs.writeText "blueforest-markers" (builtins.concatStringsSep "\n" markers + "\n");
in
pkgs.runCommand "blueforest-fences-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
  }
  ''
    # The marker of every code block of the documentation. The closing fence
    # of a block carries no marker, so it is not one of them.
    grep -rhoE '^`{3}[a-zA-Z0-9_+-]+' ${sources} | cut -c4- | sort -u >"$TMPDIR/markers"

    # Every one of them is a marker the applications of the repository know.
    while read -r marker; do
      if ! grep -qxF "$marker" ${markersList}; then
        echo "the documentation marks a code block with '$marker', which the applications of the repository do not highlight:" >&2
        exit 1
      fi
    done <"$TMPDIR/markers"

    touch $out
  ''
