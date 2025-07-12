# ==============================================================================
# WARNING: Dev/test script only! Do NOT run in production or automation.
# This script nukes all Wine data in /config/.wine and is only for manual
# troubleshooting/validation of the Wine+winetricks environment.
# ==============================================================================
#!/bin/bash
set -e

# Set variables
export WINEPREFIX=/config/.wine
export WINEARCH=win32
export DISPLAY=:0
export XDG_RUNTIME_DIR=/tmp/runtime-abc

# Prep runtime dir
mkdir -p $XDG_RUNTIME_DIR
chown abc:abc $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Nuke all previous wine data
su - abc -c "rm -rf /config/.wine /config/.cache/winetricks"

# Recreate the wine prefix
su - abc -c "export WINEPREFIX=/config/.wine WINEARCH=win32 DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc && wineboot"

# Try to install vcrun2015 with winetricks
su - abc -c "export WINEPREFIX=/config/.wine WINEARCH=win32 DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc && winetricks -v --force -q vcrun2015" | tee /config/winetricks-test.log

# List results
ls -lh /config/.wine/drive_c/windows/system32/kernel32.dll || echo "kernel32.dll missing"
ls -lh /config/.cache/winetricks/vcrun2015 || echo "Cache dir missing/inaccessible"

echo "Done."