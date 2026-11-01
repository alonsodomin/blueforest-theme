# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for bat.
#
# The theme is a TextMate file, the format bat reads, and the name of the
# theme is the name of the file: BlueForest.
#
# The setup hook puts the theme where bat looks for it: the system-wide
# configuration directory when it runs as root, which is what the activation
# of a NixOS system does, and the configuration directory of the user
# otherwise, which is what Home Manager does in the session of the user.
{
  lib,
  pkgs,
  version,
}:
pkgs.runCommand "blueforest-bat-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for bat";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0, the theme it carries is CC BY 4.0.
      license = [
        lib.licenses.mpl20
        lib.licenses.cc-by-40
      ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/bat/themes
    cp ${../themes/BlueForest.tmTheme} $out/share/bat/themes/BlueForest.tmTheme

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE

    cat > $out/setup-hook <<'HOOK'
      # The theme goes where bat looks for it, and bat has to be there to say
      # where that is.
      if ! command -v bat >/dev/null 2>&1; then
        echo "bat is not installed, so the BlueForest theme is not installed either." >&2
        exit 0
      fi

      # bat reads the themes from its own configuration directory, and the
      # configuration directory belongs to the user that runs bat. The system
      # only has a configuration file of its own, at /etc/bat/config, which
      # carries no themes.
      config_dir="$(bat --config-dir)"

      mkdir -p "$config_dir/themes"
      cp -f "$out/share/bat/themes/BlueForest.tmTheme" "$config_dir/themes/BlueForest.tmTheme"

      # bat keeps the list of the themes it knows in a cache, and it only
      # picks the theme up once the cache has been rebuilt. The rebuild is
      # done here, so that the theme is there without further work.
      if ! bat cache --build >/dev/null 2>&1; then
        echo "the cache of bat could not be rebuilt, so the BlueForest theme is not available yet. Run 'bat cache --build' to fix it." >&2
      fi
    HOOK
  ''
