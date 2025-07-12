
#!/bin/bash

# Fix config permissions if running as root (ensures abc can read/write /config)
if [ "$(id -u)" = "0" ]; then
  chown -R abc:abc /config
fi

# Source common variables and functions
source /scripts/02-common.sh

# Setup environment
export WINEPREFIX=/config/.wine
export WINEARCH=win32
export DISPLAY=:0
export XDG_RUNTIME_DIR=/tmp/runtime-abc
mkdir -p $XDG_RUNTIME_DIR
chown abc:abc $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
export WINEDEBUG=-all

# Remove wine prefix and cache as abc (not root)
rm -rf /config/.wine /config/.cache/winetricks/vcrun2015

# Recreate prefix as abc
export WINEPREFIX=/config/.wine WINEARCH=win32 DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEDEBUG=-all && wineboot

# Let winetricks install vcrun2015 as abc with logs
export WINEPREFIX=/config/.wine WINEARCH=win32 DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEDEBUG=-all && winetricks --force -q vcrun2015 | tee /config/winetricks.log

# Show file/dir permissions for debug
ls -lh /config/.wine
ls -lh /config/.cache/winetricks/vcrun2015 || echo "Cache dir missing/inaccessible"
ls -lh /config/.wine/drive_c/windows/system32/kernel32.dll || echo "kernel32.dll missing"

# Start servers
for s in 03-install-mono.sh 04-install-mt5.sh 05-install-python.sh 06-install-libraries.sh 07-start-wine-flask.sh; do
  /scripts/$s
done

tail -f /dev/null
