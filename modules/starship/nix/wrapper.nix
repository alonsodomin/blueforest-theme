# SPDX-License-Identifier: MPL-2.0
#
# Starship with the BlueForest preset bundled.
#
# The preset is added to the directory where Starship looks for the presets
# that `programs.starship.presets` reads, so that a consumer can select
# `blueforest` like any shipped preset.
{
  pkgs,
  starship,
  preset,
}:
pkgs.runCommand "blueforest-starship-${starship.version}"
  {
    meta = starship.meta // {
      description = "Starship with the BlueForest preset bundled";
      mainProgram = "starship";
      # The wrapper carries the upstream Starship, which is ISC, and the
      # BlueForest preset, which is CC BY 4.0. The packaging of the wrapper
      # is MPL-2.0, like the packaging of every other package of the
      # repository.
      license = with pkgs.lib.licenses; [
        isc
        cc-by-40
        mpl20
      ];
    };
    # The schema of the configuration travels with the wrapper, so that the
    # validation of the configuration keeps working.
    passthru = starship.passthru;
  }
  ''
    mkdir -p $out

    # The package is the upstream Starship.
    cp -r ${starship}/. $out/

    # The store is read-only, and the copy carries the mode of the original.
    # The preset needs a directory it can write into.
    chmod -R u+w $out

    # The preset joins the presets the upstream Starship ships.
    install -Dm644 ${preset}/share/starship/presets/blueforest.toml \
      $out/share/starship/presets/blueforest.toml

    # The attribution of the theme travels with the wrapper, because the
    # wrapper ships the theme.
    mkdir -p $out/share/doc/blueforest
    install -Dm644 ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    install -Dm644 ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
