# SPDX-License-Identifier: MPL-2.0
#
# Checks the format 2 palette of the repository, the one the community palette
# registry of Noctalia requires.
#
# The format 2 file is generated from the canonical format 1 file, so the
# check renders it again and compares the result with the committed file: the
# two cannot drift. The rest of the check is the rulebook of the registry: the
# version, the roles and the terminal colours that every palette carries, the
# colours themselves, and the contrast of the pairs that the registry checks.
{
  pkgs,
  source,
  sourceV2,
  format2,
}:
pkgs.runCommand "blueforest-noctalia-palette-v2-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  }
  ''
    work="$TMPDIR/work"
    mkdir -p "$work"

    # The format 2 file is the one the filter renders from the canonical
    # file, so the two files cannot drift.
    jq -f ${format2} ${source} >"$work/blueforest-v2.json"
    cmp "$work/blueforest-v2.json" ${sourceV2}

    # The palette names its format, and it carries both variants.
    jq -e '.version == 2 and (.dark | type) == "object" and (.light | type) == "object"' \
      ${sourceV2} >/dev/null

    # Every role of the interface and every colour of the terminal is there,
    # in both variants.
    jq -e '
      def roles: [
        "primary", "on_primary", "secondary", "on_secondary", "tertiary",
        "on_tertiary", "error", "on_error", "surface", "on_surface",
        "surface_container", "on_surface_variant", "outline_variant",
        "shadow", "hover", "on_hover"
      ];
      def ansi: [ "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" ];

      all(.dark, .light;
        (. as $mode
         | (roles | all(. as $role | ($mode[$role] | type) == "string"))
           and (($mode.terminal.normal | keys | sort) == (ansi | sort))
           and (($mode.terminal.bright | keys | sort) == (ansi | sort))
           and ([ "foreground", "background", "selection_fg", "selection_bg", "cursor_text", "cursor" ]
                | all(. as $key | ($mode.terminal[$key] | type) == "string"))))
    ' ${sourceV2} >/dev/null

    # The palette carries no key the registry does not know.
    jq -e '
      def mode_keys: [
        "primary", "on_primary", "secondary", "on_secondary", "tertiary",
        "on_tertiary", "error", "on_error", "surface", "on_surface",
        "surface_container", "on_surface_variant", "outline_variant",
        "shadow", "hover", "on_hover", "terminal"
      ];
      def terminal_keys: [
        "normal", "bright", "foreground", "background",
        "selection_fg", "selection_bg", "cursor_text", "cursor"
      ];
      def ansi_keys: [ "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" ];

      ((keys | sort) == [ "dark", "light", "version" ])
      and (all(.dark, .light;
        (. as $mode
         | (($mode | keys | sort) == (mode_keys | sort))
           and (($mode.terminal | keys | sort) == (terminal_keys | sort))
           and (($mode.terminal.normal | keys | sort) == (ansi_keys | sort))
           and (($mode.terminal.bright | keys | sort) == (ansi_keys | sort)))))
    ' ${sourceV2} >/dev/null

    # Every colour is six hexadecimal digits, with no alpha channel.
    jq -e '
      [ .. | strings | select(test("^#[0-9A-Fa-f]")) ]
      | all(. as $colour | $colour | test("^#[0-9A-Fa-f]{6}$"))
    ' ${sourceV2} >/dev/null

    # The contrast of the pairs of the registry is at least 2.0, and the
    # check warns below 3.0. Every pair of the palette clears 3.0.
    jq -e '
      def hex_to_dec:
        explode
        | reduce .[] as $c (0;
            . * 16
            + (if $c >= 48 and $c <= 57 then
                 $c - 48
               elif $c >= 65 and $c <= 70 then
                 $c - 55
               elif $c >= 97 and $c <= 102 then
                 $c - 87
               else
                 error("not a hexadecimal digit")
               end));

      def luminance:
        ltrimstr("#")
        | [ .[0:2], .[2:4], .[4:6] ]
        | map(
            hex_to_dec / 255
            | if . <= 0.03928 then
                . / 12.92
              else
                pow((. + 0.055) / 1.055; 2.4)
              end
          )
        | 0.2126 * .[0] + 0.7152 * .[1] + 0.0722 * .[2];

      def contrast($a; $b):
        ($a | luminance) as $la
        | ($b | luminance) as $lb
        | (if $la > $lb then $la else $lb end) as $hi
        | (if $la > $lb then $lb else $la end) as $lo
        | ($hi + 0.05) / ($lo + 0.05);

      . as $palette
      | [ [ "on_primary", "primary" ],
          [ "on_secondary", "secondary" ],
          [ "on_tertiary", "tertiary" ],
          [ "on_error", "error" ],
          [ "on_surface", "surface" ],
          [ "on_surface_variant", "surface_container" ],
          [ "on_hover", "hover" ] ] as $pairs
      | [ "dark", "light" ] as $modes
      | [
          $modes[] as $mode
          | $pairs[] as $pair
          | contrast($palette[$mode][$pair[0]]; $palette[$mode][$pair[1]]) >= 3.0
        ]
      | all
    ' ${sourceV2} >/dev/null

    touch $out
  ''
