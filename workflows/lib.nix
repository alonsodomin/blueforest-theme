# SPDX-License-Identifier: MPL-2.0
#
# The pieces that the workflows of the repository share.
rec {
  # The applications of the repository. Every one of them is a flake of its
  # own, and every one of them is checked on its own, because a consumer can
  # install just one of them.
  applications = [
    "vscode"
    "bat"
    "starship"
    "opencode"
    "sbt"
    "neovim"
    "eza"
    "zed"
    "yazi"
  ];

  # The actions that the workflows use. Their versions live here, so that they
  # are updated in one place, and Renovate keeps them up to date.
  actions = {
    checkout = "actions/checkout@v7";
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

    # The extension of Zed lives in a submodule of the repository, and the
    # release packages it.
    "with".submodules = true;
  };

  # Installs Nix, with the features the flakes need.
  installNix = {
    uses = actions.installNix;
    "with".extra_nix_config = "experimental-features = nix-command flakes";
  };

  # The job that checks the flake of an application.
  checkFlake = flake: {
    name = "Check";
    runs-on = "ubuntu-latest";
    steps = [
      checkout
      installNix
      {
        name = "Run flake checks";
        run = "nix flake check ${flake}";
      }
    ];
  };
}
