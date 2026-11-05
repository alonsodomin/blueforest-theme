# Fails if the workflows of the repository are not the ones that
# the definitions in `workflows/` render.
#
{
  inputs,
  pkgs,
  lib,
  top,
  ...
}:
let
  workflows = top.config.flake.actions-nix.workflows;
  render =
    (inputs.actions-nix.lib.evalModule pkgs top.config.flake.actions-nix).config.build.renderWorkflows;
in
pkgs.runCommandLocal "workflows-validate" { } ''
  mkdir project
  cd project
  ${render}/bin/render-workflows --no-prepend-git-root
  for workflow in ${lib.concatStringsSep " " (lib.attrNames workflows)}; do
    diff ${inputs.self}/"$workflow" "$workflow" \
      || {
        echo "$workflow is out of sync: run .#render-workflows" >&2
        exit 1
      }
  done
  touch $out
''
