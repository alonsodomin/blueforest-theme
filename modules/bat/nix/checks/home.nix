# SPDX-License-Identifier: MPL-2.0
#
# Checks that the setup hook installs the theme in the configuration
# directory of bat, which is where bat reads the themes from, and that it
# rebuilds the cache of bat, without which the theme is not picked up.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-bat-theme-home-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    log="$TMPDIR/install.log"

    config_dir="$TMPDIR/config"

    mkdir -p "$TMPDIR/bin"

    # A stub of bat, so that the hook finds it. The hook asks it for the
    # configuration directory and rebuilds the cache.
    cat > "$TMPDIR/bin/bat" <<'STUB'
    #!/bin/sh
    if [ "$1" = "cache" ]; then
      echo "cache $*" >> "$BAT_INSTALL_LOG"
      exit 0
    fi
    echo "$BAT_CONFIG_DIR"
    STUB

    chmod +x "$TMPDIR/bin"/*

    PATH="$TMPDIR/bin:$PATH" \
      BAT_CONFIG_DIR="$config_dir" \
      BAT_INSTALL_LOG="$log" \
      out=${theme} \
      bash ${theme}/setup-hook

    # The theme is in the directory bat reads the themes from.
    test -f "$config_dir/themes/BlueForest.tmTheme"
    cmp "$config_dir/themes/BlueForest.tmTheme" ${source}

    # And the cache of bat has been rebuilt, without which the theme is
    # not picked up.
    grep -q "cache --build" "$log"

    touch $out
  ''
