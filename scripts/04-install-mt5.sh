#!/bin/bash
#
# Installs MetaTrader 5 into the Wine prefix under /config/.wine.
# This script now runs **inside** the container—no docker‑exec calls.

source /scripts/02-common.sh

# Environment for Wine
export DISPLAY=:0
export WINEPREFIX="/config/.wine"
export WINEARCH=win64
export USER=abc
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p "$XDG_RUNTIME_DIR"
chown abc:abc "$XDG_RUNTIME_DIR"

log_message "RUNNING" "04-install-mt5.sh"

# Ensure abc owns the Wine prefix
chown -R abc:abc /config/.wine

# $mt5file and $mt5setup_url are defined in 02-common.sh
if [ -e "$mt5file" ]; then
    log_message "INFO" "File $mt5file already exists."
else
    log_message "INFO" "File $mt5file is not installed. Installing..."

    # Download MT5 installer if not already present
    if [ ! -f /tmp/mt5setup.exe ]; then
        log_message "INFO" "Downloading MT5 installer..."
        wget -O /tmp/mt5setup.exe "$mt5setup_url"
    fi

    # Force Wine to Windows 10 mode
    sudo -E -u abc bash -c "export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEPREFIX=/config/.wine && \
                 wine reg add 'HKEY_CURRENT_USER\\Software\\Wine' /v Version /t REG_SZ /d win10 /f"

    log_message "INFO" "Installing MetaTrader 5..."
    sudo -E -u abc bash -c "export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEPREFIX=/config/.wine && \
                 wine /tmp/mt5setup.exe /auto"

    # Give the installer a moment to finish
    sleep 30
fi

# Verify installation and launch MT5
if [ -e "$mt5file" ]; then
    log_message "INFO" "MT5 installed successfully. Starting MT5..."
    sudo -E -u abc bash -c "export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEPREFIX=/config/.wine && \
                 wine '$mt5file' /portable &"
else
    log_message "ERROR" "MT5 installation failed. Checking Wine..."
    sudo -E -u abc bash -c "export DISPLAY=:0 XDG_RUNTIME_DIR=/tmp/runtime-abc WINEPREFIX=/config/.wine && wine --version"
fi