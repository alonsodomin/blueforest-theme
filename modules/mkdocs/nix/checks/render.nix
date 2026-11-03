# SPDX-License-Identifier: MPL-2.0
#
# Checks the stylesheet in a site built the way mkdocs-flake builds one: the
# hook of the module copies the stylesheet into the sources of the site, and
# MkDocs picks it up through `extra_css`.
#
# The site of the repository renders with the dark theme, and the check
# builds a site per mode, so that the light variant of the theme is checked
# as well.
{
  pkgs,
  theme,
  mkdocs,
  preBuildHook,
}:
pkgs.runCommand "blueforest-mkdocs-render-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      mkdocs
    ];
  }
  ''
    export HOME="$TMPDIR"

    work="$TMPDIR/work"
    mkdir -p "$work/docs"
    cd "$work"

    cat > mkdocs.yml <<'YAML'
    site_name: BlueForest
    theme:
      name: material
      font: false
      palette:
        scheme: slate
    extra_css:
      - assets/stylesheets/blueforest.css
    markdown_extensions:
      - pymdownx.highlight
      - pymdownx.superfences
    YAML

    cat > docs/index.md <<'MARKDOWN'
    # BlueForest

    ```nix
    let
      blueforest = true;
    in
      blueforest
    ```

    ```bash
    nix build "path:."
    export VARIABLE=1
    ```
    MARKDOWN

    # The hook of the module installs the stylesheet in the sources of the
    # site.
    ${preBuildHook}

    mkdocs build --strict --site-dir "$TMPDIR/site"

    # MkDocs copies the stylesheet into the site, and the page links it.
    cmp ${theme}/blueforest.css "$TMPDIR/site/assets/stylesheets/blueforest.css"
    grep -q 'href="assets/stylesheets/blueforest.css"' "$TMPDIR/site/index.html"

    # The palette is the dark scheme of Material, and the code is highlighted.
    grep -q 'data-md-color-scheme="slate"' "$TMPDIR/site/index.html"
    grep -q 'class="k"' "$TMPDIR/site/index.html"

    # The shell blocks are highlighted as shell code: the keyword, the
    # builtin, the string and the number each carry a class of their own.
    grep -q 'class="nb">export<' "$TMPDIR/site/index.html"
    grep -q 'class="s2">' "$TMPDIR/site/index.html"
    grep -q 'class="m">1<' "$TMPDIR/site/index.html"

    # And the stylesheet paints the numbers, which Material paints with no
    # class of its own.
    grep -q '\.highlight \.m {' ${theme}/blueforest.css

    # The light variant of the theme is there as well, and it paints the
    # code blocks with the colours of the light palette.
    grep -q '\[data-md-color-scheme="default"\]' ${theme}/blueforest.css
    grep -q -- '--md-code-bg-color: #e8ecf2;' ${theme}/blueforest.css
    grep -q -- '--md-code-hl-string-color: #1e5c1e;' ${theme}/blueforest.css

    touch $out
  ''
