# BlueForest theme for MkDocs

The theme is a stylesheet for [MkDocs](https://www.mkdocs.org/), with
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/). The name
of the file is `blueforest.css`.

It recolours the code blocks of the site: the background, the foreground, and
the colours of the tokens of the syntax highlighting. The theme follows the
palette of BlueForest, the one of the other applications of this repository.

The stylesheet applies to the dark scheme of Material alone. The light scheme
keeps the palette of Material, which is the one the site is readable with.

## How MkDocs reads the theme

MkDocs reads the stylesheets of a site from its `extra_css` option, and it
copies them into the site it builds:

```yaml
extra_css:
  - assets/stylesheets/blueforest.css
```

The path is relative to the directory of the sources of the site, which is the
`docs_dir` of the project, `docs` by default. The file therefore has to be at
`docs/assets/stylesheets/blueforest.css`.

## Install with Nix

The theme is part of the documentation of a project, and the module of this
repository installs it in the sources of the site before MkDocs builds it.

The module needs [mkdocs-flake](https://github.com/applicative-systems/mkdocs-flake),
which is the module that builds a documentation site with Nix. The module of
this repository imports it, so a consumer that imports the module needs no
`mkdocs-flake` input of its own.

A project that uses flake-parts imports the module of this repository:

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-theme";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        imports = [ inputs.blueforest.flakeModules.mkdocs ];

        perSystem = { ... }: {
          # The sources of the site, and where they are.
          documentation = {
            mkdocs-root = ./.;
            strict = true;
          };
        };
      }
    );
}
```

The site is then the `documentation` package of the flake:

```bash
nix build .#documentation
```

The options of the module are `blueforest.mkdocs.*`, and they are set in the
`perSystem` of the flake, next to the options of the documentation:

```nix
perSystem = { ... }: {
  blueforest.mkdocs.enable = true;
};
```

| Option | Default | Description |
| --- | --- | --- |
| `blueforest.mkdocs.enable` | `true` | Whether to install the stylesheet in the sources of the site |
| `blueforest.mkdocs.docsDir` | `"docs"` | The directory of the sources of the site, relative to the root of the project |
| `blueforest.mkdocs.path` | `"assets/stylesheets/blueforest.css"` | The path of the stylesheet inside the sources of the site |

The hook that installs the stylesheet is appended to the hook of the consumer,
so a project that needs to prepare the sources of the site keeps working:

```nix
perSystem = { ... }: {
  documentation.mkdocs-preBuildHook = ''
    mkdir -p docs/static
  '';
};
```

A project that does not use flake-parts takes the package of the theme and
the package of MkDocs, and installs the stylesheet in the sources of the site
itself:

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-theme";
  inputs.mkdocs-flake.url = "github:applicative-systems/mkdocs-flake";

  outputs =
    { nixpkgs, blueforest, mkdocs-flake, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.documentation = pkgs.runCommand "my-docs" { } ''
        cp -rL ${./docs} docs
        chmod -R u+w docs
        cp ${./mkdocs.yml} ./mkdocs.yml

        install -Dm644 ${blueforest.packages.${system}.blueforest-mkdocs-theme}/blueforest.css \
          docs/assets/stylesheets/blueforest.css

        ${mkdocs-flake.packages.${system}.mkdocs}/bin/mkdocs build --strict --site-dir $out
      '';
    };
}
```

The package of the theme is `blueforest.packages.<system>.blueforest-mkdocs-theme`,
and it carries the stylesheet at its root:

```text
blueforest.css
share/doc/blueforest/NOTICE.md
share/doc/blueforest/LICENSE
```

## Manual install

Download `blueforest-mkdocs-theme-<version>.css` from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
put it in the sources of the site, where `extra_css` points at it:

```bash
mkdir -p docs/assets/stylesheets
cp blueforest-mkdocs-theme-<version>.css docs/assets/stylesheets/blueforest.css
```

The path has to be the one of the `extra_css` option of `mkdocs.yml`, and the
file has to be inside the `docs_dir` of the project: MkDocs only copies the
files that are inside it.

## The stylesheet is ignored when it is missing

MkDocs ignores a stylesheet it cannot read, and it does so silently: the site
is built without it. If the code blocks do not look right, check that the file
is at the path of `extra_css`, that it is inside the `docs_dir` of the
project, and that the site is built in the dark scheme: the theme only
recolours the dark one.
