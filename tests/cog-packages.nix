# SPDX-License-Identifier: MPL-2.0
#
# Checks the configuration of CoCoGitto.
#
# The tool writes the changelog of every application of the repository, so
# every application has to be a package of the monorepo in `cog.toml`, with
# the path of its directory and the path of its changelog.
{
  pkgs,
  lib,

  # The configuration of CoCoGitto.
  config,

  # The applications of the repository.
  applications,
}:
let
  settings = builtins.fromTOML (builtins.readFile config);

  packages = settings.monorepo.packages or { };

  # The applications of the repository, and the packages that are not one of
  # them.
  expected = map (application: application.app) applications;

  missing = builtins.filter (app: !(builtins.hasAttr app packages)) expected;

  extra = builtins.filter (app: !(builtins.elem app expected)) (builtins.attrNames packages);
in
pkgs.runCommand "blueforest-cog-packages-check"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.coreutils
    ];
  }
  ''
    # Every application of the repository is a package of the monorepo.
    if [ -n "${lib.concatStringsSep " " missing}" ]; then
      echo "the applications are missing in cog.toml: ${lib.concatStringsSep " " missing}" >&2
      exit 1
    fi

    # And the monorepo has no package that is not an application.
    if [ -n "${lib.concatStringsSep " " extra}" ]; then
      echo "cog.toml has packages that are not applications: ${lib.concatStringsSep " " extra}" >&2
      exit 1
    fi

    # Every package has the path of the directory of its application, and the
    # path of its changelog.
    ${lib.concatMapStringsSep "\n" (app: ''
      if [ "${packages.${app}.path}" != "modules/${app}" ]; then
        echo "the package ${app} has the path '${packages.${app}.path}', not 'modules/${app}'" >&2
        exit 1
      fi

      if [ "${packages.${app}.changelog_path}" != "modules/${app}/CHANGELOG.md" ]; then
        echo "the package ${app} has the changelog '${packages.${app}.changelog_path}', not 'modules/${app}/CHANGELOG.md'" >&2
        exit 1
      fi
    '') expected}

    touch $out
  ''
