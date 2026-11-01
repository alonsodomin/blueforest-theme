# SPDX-License-Identifier: MPL-2.0
#
# The pin of the extension repository.
#
# The extension lives in a repository of its own, because that is how Zed
# ships extensions: the editor clones the repository and reads the theme from
# it. The repository is a submodule of this application, at `extension/`, so
# that the sources of the extension are part of this repository and every
# change of them is reviewed here.
#
# Nix cannot fetch the contents of a submodule of a git tree: a submodule is
# an empty directory in the tree of a repository. The sources are therefore
# fetched from the repository itself, at the revision the submodule points at.
# The two have to agree, and the check of the CI verifies it.
let
  # The revision of the extension repository.
  revision = "4e5d882eeeeb8fe270342c2a4ca87d3b980b45e3";

  # The hash of the tarball of the repository at that revision. It is computed
  # with:
  #
  #   nix store prefetch-file --unpack \
  #     https://github.com/alonsodomin/zed-blueforest-theme/archive/<revision>.tar.gz
  hash = "sha256-acTbF88gcfQDBUPeNuBb7nE6JMHunNEpbZurcNGiZ4A=";
in
{
  inherit revision hash;

  # The sources of the extension: the repository at the revision above.
  fetch =
    pkgs:
    pkgs.fetchFromGitHub {
      owner = "alonsodomin";
      repo = "zed-blueforest-theme";
      rev = revision;
      inherit hash;
    };
}
