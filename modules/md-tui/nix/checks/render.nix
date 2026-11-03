# SPDX-License-Identifier: MPL-2.0
#
# Checks that md-tui reads the theme of the repository and paints with it.
#
# md-tui ignores a palette it cannot read, and it does so silently: the
# interface falls back to the colours it ships with. The check therefore
# reads what md-tui painted, and looks for the colours of the theme in it.
#
# The check looks for the colours of the theme on the words they paint, and
# not only for the colours themselves: a theme that paints the colour of the
# links on the words of the code is a theme that is not the theme of the
# repository.
#
# md-tui is a terminal program, and it needs a terminal to run in. The check
# gives it one with `script`, which allocates a pseudo terminal and runs
# md-tui in it. The colours of the theme are true colour, so the terminal has
# to support it.
#
# md-tui waits for a key that never comes, so the check sends it the one that
# quits it, once it has painted the interface.
#
# md-tui reads the palette of the theme and the selection of it from the
# configuration directory of the user, which the check points at a scratch
# one.
{
  pkgs,
  source,
}:
pkgs.runCommand "blueforest-md-tui-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.util-linux
      pkgs.md-tui
    ];
  }
  ''
    work="$TMPDIR/work"
    themed="$TMPDIR/themed"
    tree="$TMPDIR/tree"
    plain="$TMPDIR/plain"

    export HOME="$TMPDIR"

    mkdir -p "$work/themed/.config/mdt/themes" "$work/plain/.config/mdt" \
      "$work/document"

    # The palette of the theme, and the selection of it.
    cp ${source} "$work/themed/.config/mdt/themes/blueforest.json"
    printf 'blueforest\n' >"$work/themed/.config/mdt/selected-theme"

    # The document md-tui renders. It carries an element of every kind whose
    # colour the theme paints: a heading, the inline styles, a link, inline
    # code, a quote, a table and a code block. The words of the document are
    # the ones the check looks for, and every one of them is painted with a
    # colour of its own.
    cat >"$work/document/blueforest.md" << 'MARKDOWN'
    # Heading one

    Some *italic* and **bold** and ~~struck~~ words, and a
    [link](https://example.com) in it, and `inline` code.

    > A quote
    > on two lines.

    | Column | Other |
    | ------ | ----- |
    | value  | 2     |

    ```rust
    fn main() {
        let greeting = "hello";
    }
    ```
    MARKDOWN

    # md-tui is run in a pseudo terminal, and it is sent the key that quits
    # it once it has painted the interface.
    render() {
      local home="$1"
      local out="$2"
      local document="$3"

      (
        sleep 2

        # md-tui may have quit already, and the pipe may be closed: the
        # error of the write is of no use.
        printf 'q' 2>/dev/null || true
      ) | HOME="$home" COLORTERM=truecolor TERM=xterm-256color \
        timeout 30 script -qec \
        "stty rows 40 cols 120; cd $work/document && mdt $document" \
        /dev/null >"$out" 2>&1 || true
    }

    # The word of the document, and the colours that paint it. The word
    # follows the sequence of escapes that sets the colours, and the sequence
    # carries the attributes of the text after them.
    painted() {
      local out="$1"
      local colours="$2"
      local word="$3"

      grep -aqE "$(printf '\033\\[38;2;%s' "$colours")(;[0-9]+)*m''${word}" "$out"
    }

    render "$work/themed" "$themed" "blueforest.md"

    # The heading is painted with the colour of the text on the colour of the
    # banner.
    painted "$themed" "20;31;46;48;2;0;153;255" "Heading one"

    # The inline styles are painted with the colour of each one of them.
    painted "$themed" "160;255;160" "italic"
    painted "$themed" "208;208;208" "bold"
    painted "$themed" "86;105;125" "struck"

    # The link is painted with the colour of the links.
    painted "$themed" "145;204;255" "link"

    # The inline code is painted with the colour of the code on the colour
    # of its background.
    painted "$themed" "128;255;128;48;2;27;43;64" "inline"

    # The header of the table is painted with the colour of the headers,
    # after the border of the table.
    painted "$themed" "255;204;51;48;2;27;43;64" ".*Column"

    # And the code block is painted with the colours of the syntax: the
    # keyword is blue, the function is the pale blue, and the string is the
    # green, all of them on the colour of the background of the block.
    painted "$themed" "0;153;255;48;2;27;43;64" "fn"
    painted "$themed" "162;207;245;48;2;27;43;64" "main"
    painted "$themed" "128;255;128;48;2;27;43;64" '"hello"'

    # The file tree is painted with the colour of the names of the files,
    # the colour of the path of the directory, and the colour of the count
    # of the pages.
    render "$work/themed" "$tree" ""

    painted "$tree" "208;208;208" "blueforest.md"
    painted "$tree" "86;105;125" "./blueforest.md"
    painted "$tree" "145;204;255" ".*1/1"

    # Without the theme, md-tui paints with the colours it ships with, and
    # none of them is one of ours: they are the sixteen colours of the
    # terminal, and not a true colour at all.
    render "$work/plain" "$plain" "blueforest.md"

    ! grep -aq '38;2;' "$plain"
    ! grep -aq '48;2;' "$plain"

    touch $out
  ''
