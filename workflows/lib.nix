# SPDX-License-Identifier: MPL-2.0
#
# The pieces that the workflows of the repository share.
rec {
  # The actions that the workflows use. Their versions live here, so that they
  # are updated in one place, and Renovate keeps them up to date.
  actions = {
    checkout = "actions/checkout@v7";
    cocogitto = "cocogitto/cocogitto-action@v4";
    configurePages = "actions/configure-pages@v6";
    deployPages = "actions/deploy-pages@v5";
    downloadArtifact = "actions/download-artifact@v8";
    installNix = "cachix/install-nix-action@v31";
    setupNode = "actions/setup-node@v7";
    uploadArtifact = "actions/upload-artifact@v7";
    uploadPagesArtifact = "actions/upload-pages-artifact@v5";
  };

  # Checks the repository out.
  checkout = {
    uses = actions.checkout;
  };

  # Checks the repository out with the whole history of it, and every tag.
  #
  # The changelog of a release is generated out of the commits of the
  # repository, and the version of a release is checked against the tags of
  # it.
  checkoutFull = {
    uses = actions.checkout;

    "with" = {
      fetch-depth = 0;
    };
  };

  # Installs Nix, with the features the flakes need.
  installNix = {
    uses = actions.installNix;
    "with".extra_nix_config = "experimental-features = nix-command flakes";
  };
}
