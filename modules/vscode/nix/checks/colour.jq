# The colour the theme paints a scope with.
#
# The most specific rule of the theme wins, and the last rule of the theme
# wins when two of them are equally specific. That is the way the editor
# resolves the scopes of a token.
def colour($scope):
  [ .tokenColors
    | to_entries[]
    | .key as $index
    | .value as $rule
    | (if ($rule.scope | type) == "array" then $rule.scope else [$rule.scope] end)[]
    | . as $selector
    | ($selector | split(".")) as $selectorPath
    | ($scope | split(".")) as $scopePath
    | select(($selectorPath | length) <= ($scopePath | length))
    | select([range(0; $selectorPath | length)] | all(. as $i | $selectorPath[$i] == $scopePath[$i]))
    | {
        index: $index,
        depth: ($selectorPath | length),
        colour: $rule.settings.foreground
      }
  ]
  | sort_by([.depth, .index])
  | last
  | .colour;

colour($scope) // "none"
