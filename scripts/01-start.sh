#!/bin/bash

# Set display for Wine (different from KasmVNC)
export DISPLAY=:99
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export WINEARCH=win64
export WINEPREFIX="/config/.wine"
export WINEDEBUG=-all

# Source common variables and functions
source /scripts/02-common.sh

log_message "INFO" "Starting MT5 setup script..."

# Initialize Wine prefix if it doesn't exist
if [ ! -f "$WINEPREFIX/system.reg" ]; then
    log_message "INFO" "Initializing Wine prefix..."
    wineboot --init
    sleep 10
fi

# Verify Wine is working
log_message "INFO" "Testing Wine installation..."
wine cmd /c echo "Wine is working" || {
    log_message "ERROR" "Wine initialization failed"
    exit 1
}

# Create Terminal.ico to prevent errors
mkdir -p "$WINEPREFIX/drive_c/Program Files/MetaTrader 5"
touch "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/Terminal.ico"

# Run installation scripts
/scripts/03-install-mono.sh
/scripts/04-install-mt5.sh

# Keep the script running
tail -f /dev/null