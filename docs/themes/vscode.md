# BlueForest theme for VS Code

The theme is a VS Code colour theme. Once installed, it appears as
**BlueForest** in the theme picker, and its extension identifier is
`alonsodomin.blueforest-theme`.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables.

## Install from Open VSX

!!! tip "Recommended"

    Install the theme from [Open VSX](https://open-vsx.org/extension/alonsodomin/blueforest-theme).
    Open VSX is the recommended source for VS Code-compatible editors,
    including VSCodium.

Open the Extensions view of your editor and search for **BlueForest**, or open
the [Open VSX page](https://open-vsx.org/extension/alonsodomin/blueforest-theme)
and select **Install**.

!!! note "Microsoft VS Code"
    Microsoft VS Code ships with the VS Marketplace. If you use it and cannot
    use Open VSX, install the theme from the Marketplace section below.

## Install from the VS Marketplace

The theme is also published to the
[VS Marketplace](https://marketplace.visualstudio.com/items?itemName=alonsodomin.blueforest-theme).
Open the Extensions view of VS Code and search for **BlueForest**, or run:

```console
code --install-extension alonsodomin.blueforest-theme
```

## Install from a release

Every release of the repository attaches the packaged extension as
`blueforest-theme-<version>.vsix`. Download it from the
[GitHub releases](https://github.com/alonsodomin/blueforest-theme/releases) and
install it with the CLI of your editor:

```console
code --install-extension ./blueforest-theme-<version>.vsix
```

For VSCodium, replace `code` with `codium`.

## Install with Nix

The module of the application adds the overlay that provides
`pkgs.blueforest-vscode-theme`. It does not enable or configure an editor, so
that which editor installs the theme, and whether it is installed at all,
stays your decision.

With Home Manager:

```nix
{
  imports = [
    blueforest.homeModules.vscode
  ];

  programs.vscode = {
    enable = true;
    extensions = [
      pkgs.blueforest-vscode-theme
    ];
  };
}
```

The same module works for VSCodium through its profile:

```nix
programs.vscodium = {
  enable = true;
  profiles.default.extensions = [
    pkgs.blueforest-vscode-theme
  ];
};
```

On NixOS, import `blueforest.nixosModules.vscode` and add the extension to
`programs.vscode.extensions`. If you use VSCodium, also set
`programs.vscode.package = pkgs.vscodium;`.

If you only want the package, it is also available as
`blueforest.packages.${system}.blueforest-vscode-theme`.

## Select the theme

Open the theme picker with `Ctrl+K Ctrl+T` and select **BlueForest**, or set it
in your settings:

```json
{
  "workbench.colorTheme": "BlueForest"
}
```
