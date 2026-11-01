# SPDX-License-Identifier: MPL-2.0
#
# Checks that the setup hook installs the theme in the configuration
# directory of bat even when it runs as root, which is what the activation
# of a NixOS system does.
#
# bat reads the themes from the configuration directory of the user, and it
# has no system-wide directory for them. The check therefore verifies that
# the theme does not end up in a directory that bat never reads.
#
# The check cannot write to /etc, so the directories and the copy are
# recorded instead of being made.
{
  pkgs,
  theme,
}:
pkgs.runCommand "blueforest-bat-theme-nixos-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    log="$TMPDIR/install.log"

    config_dir="$TMPDIR/config"

    mkdir -p "$TMPDIR/bin"

    # A stub of id, so that the hook believes it runs as root.
    cat > "$TMPDIR/bin/id" <<'STUB'
    #!/bin/sh
    echo 0
    STUB

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

    # Stubs of mkdir and cp, so that the check sees where the theme would
    # be installed without installing it.
    cat > "$TMPDIR/bin/mkdir" <<'STUB'
    #!/bin/sh
    echo "mkdir $*" >> "$BAT_INSTALL_LOG"
    STUB
    cat > "$TMPDIR/bin/cp" <<'STUB'
    #!/bin/sh
    echo "cp $*" >> "$BAT_INSTALL_LOG"
    STUB

    chmod +x "$TMPDIR/bin"/*

    PATH="$TMPDIR/bin:$PATH" \
      BAT_CONFIG_DIR="$config_dir" \
      BAT_INSTALL_LOG="$log" \
      out=${theme} \
      bash ${theme}/setup-hook

    # The theme is in the directory bat reads the themes from, even when
    # the hook runs as root.
    grep -q "cp -f ${theme}/share/bat/themes/BlueForest.tmTheme $config_dir/themes/BlueForest.tmTheme" "$log"

    # And it is not in a directory that bat never reads.
    if grep -q "/etc/bat" "$log"; then
      echo "the theme was installed in /etc/bat, which bat does not read" >&2
      exit 1
    fi

    # The cache of bat has been rebuilt, without which the theme is not
    # picked up.
    grep -q "cache --build" "$log"

    touch $out
  ''
