{
  inputs,
  pkgs,
  top,
  ...
}:
let
  render =
    (inputs.actions-nix.lib.evalModule pkgs top.config.flake.actions-nix).config.build.renderWorkflows;
in
pkgs.runCommandLocal "workflows-lint-check"
  {
    nativeBuildInputs = [
      pkgs.actionlint
      pkgs.shellcheck
    ];
  }
  ''
    mkdir project
    cd project
    ${render}/bin/render-workflows --no-prepend-git-root
    actionlint .github/workflows/*.yml
    touch $out
  ''
