# SPDX-License-Identifier: MPL-2.0
#
# Checks the assets of the release.
#
# The check packages every application the way the release workflow does,
# and it looks at what the archive of each one carries: the files of the
# theme, and the changelog of the application.
{
  pkgs,
  lib,
  applications,
  modules,
}:
let
  # The applications that are packed into an archive. The extension of VS
  # Code is the exception: it is built with vsce, and the check of the
  # extension of the repository covers it.
  packaged = builtins.filter (
    definition: (definition ? files) && definition.files != [ ]
  ) applications;
in
pkgs.runCommand "blueforest-release-assets-check" { } ''
  # The packaging reads the themes of the repository, so the modules of the
  # repository are copied where the packaging looks for them. They are made
  # writable, because the release workflow packages them out of a checkout,
  # where they are writable.
  cp -r ${modules} modules
  chmod -R u+w modules

  export VERSION=0.0.0

  ${lib.concatMapStringsSep "\n" (definition: ''
    ${definition.package}

    archive="dist/blueforest-${definition.app}-theme-$VERSION.tar.gz"

    # The archive carries the changelog of the application.
    tar -tzf "$archive" | grep -c 'CHANGELOG.txt' >/dev/null

    # And every file of the theme.
    ${lib.concatMapStringsSep "\n" (file: ''
      tar -tzf "$archive" | grep -c '${file.dst}' >/dev/null
    '') definition.files}
  '') packaged}

  touch $out
''
