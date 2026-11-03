# SPDX-License-Identifier: MPL-2.0
#
# The colours of the roles of a theme of OpenCode, with the references
# resolved.
#
# A theme of OpenCode is a tree of semantic tokens, and every one of them
# ends up as a colour. The values of the tree are either colours themselves
# or references to other colours of the tree, and a reference is a path from
# the root of the theme.
#
# The tree a mode sees is the tree of the base with the tree of the mode over
# it, so a role of the base that the mode does not override keeps the colour
# of the base, and a role the mode overrides has the colour of the mode.
#
# The check reads the colours this library resolves, and compares them with
# the ones the other ports of the repository use for the same role.
{
  lib,
  # The theme, as it was read.
  theme,
}:
let
  # Whether a value is a reference to another colour.
  isReference = value: lib.isString value && lib.hasPrefix "$" value;

  # The path of a reference, without the "$".
  refPath = value: lib.filter (part: part != "") (lib.splitString "." (lib.removePrefix "$" value));

  # The value at a path of the tree, with the references resolved on the way.
  #
  # A reference is a path from the root of the theme, so it is always
  # resolved against the root, and never against the node the walk is at.
  lookup =
    root: node: parts: depth:
    if depth > 16 then
      null
    else if parts == [ ] then
      node
    else if !lib.isAttrs node then
      null
    else
      let
        value = node.${lib.head parts} or null;
        rest = lib.tail parts;
      in
      if value == null then
        null
      else if isReference value then
        # The reference points at another colour, which may be a tree of
        # colours itself.
        let
          resolved = lookup root root (refPath value) (depth + 1);
        in
        if rest == [ ] then resolved else lookup root resolved rest (depth + 1)
      else
        lookup root value rest (depth + 1);

  # The tree of a mode: the tokens of the base, with the tokens of the mode
  # over them.
  #
  # The order of the arguments matters: `recursiveUpdate` gives the right
  # hand side the precedence, so the mode has to come second for its tokens
  # to win over the ones of the base.
  merged = mode: lib.recursiveUpdate theme.base mode;

  # The colour of every role of a tree, with the path of the role as the key.
  #
  # The roles whose name starts with a "$" are the states of a role, and
  # OpenCode reads them, so they are roles of their own.
  flatten =
    prefix: value:
    if lib.isAttrs value then
      lib.concatLists (lib.mapAttrsToList (name: child: flatten (prefix ++ [ name ]) child) value)
    else
      [
        {
          path = lib.concatStringsSep "." prefix;
          inherit value;
        }
      ];

  # The colours of the roles of one mode, with the references resolved.
  colours =
    name: mode:
    let
      tree = merged mode;

      # Every role of the tree, with the references resolved.
      roles = flatten [ ] tree;
    in
    {
      inherit name;
      roles = map (role: {
        inherit (role) path;
        colour = if isReference role.value then lookup tree tree (refPath role.value) 0 else role.value;
      }) roles;
    };

  # The modes of the theme.
  modes = lib.filterAttrs (name: _: name == "light" || name == "dark") theme;
in
{
  # The colours of the roles of every mode.
  modes = lib.mapAttrsToList colours modes;
}
