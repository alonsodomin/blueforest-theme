# SPDX-License-Identifier: MPL-2.0
#
# Checks that the asset of the release of the theme of Yazi carries the
# colours of the code preview.
#
# The asset is built by the release workflow, out of the sources of the
# repository, and it is unpacked by hand: it cannot carry a link to the
# store, so it has to carry the theme of bat itself.
#
# The check packages the theme the way the release workflow does, with the
# packaging of the workflow itself, so that the two of them cannot drift
# apart.
{
  pkgs,

  # The packaging of the applications of the repository.
  applications,

  # The modules of the repository, which the packaging reads the themes from.
  modules,
}:
let
  # The packaging of the theme of Yazi.
  yazi = builtins.head (builtins.filter (definition: definition.app == "yazi") applications);

  # The asset of the packaging.
  asset = builtins.head yazi.assets;

  # The version the check packages with. The version of a release is the one
  # of its tag, and the packaging does not care about it.
  version = "0.0.0";
in
pkgs.runCommand "blueforest-yazi-asset-check" { } ''
  # The packaging reads the themes of the repository, so the modules of the
  # repository are copied where the packaging looks for them. They are made
  # writable, because the release workflow packages them out of a checkout,
  # where they are writable.
  cp -r ${modules} modules
  chmod -R u+w modules

  export VERSION=${version}

  ${yazi.package}

  # The asset carries the flavour.
  tar -tzf "${asset}" | grep -q 'blueforest.yazi/flavor.toml'

  # And the colours of the code preview, as a regular file: the asset is
  # unpacked by hand, and a link to the store would be of no use there.
  tar -tvzf "${asset}" \
    | grep 'blueforest.yazi/tmtheme.xml' \
    | grep -q '^-'

  # And the theme it carries is the theme of bat.
  tar -xzOf "${asset}" './blueforest.yazi/tmtheme.xml' \
    | cmp - ${modules}/bat/themes/BlueForest.tmTheme

  touch $out
''
