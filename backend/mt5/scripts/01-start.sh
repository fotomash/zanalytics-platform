#!/bin/bash

# Set environment
export DISPLAY=:0
export WINEARCH=win64
export WINEPREFIX="/config/.wine"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Source common functions if exists
if [ -f "/scripts/02-common.sh" ]; then
    source /scripts/02-common.sh
else
    # Define simple log function
    log_message() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2" | tee -a /var/log/mt5_setup.log
    }
fi

log_message "INFO" "Starting MT5 setup..."

# Create Wine directory if it doesn't exist
if [ ! -d "$WINEPREFIX" ]; then
    log_message "INFO" "Creating Wine prefix directory..."
    mkdir -p "$WINEPREFIX"
fi

# Initialize Wine if needed
if [ ! -f "$WINEPREFIX/system.reg" ]; then
    log_message "INFO" "Initializing Wine prefix..."
    wineboot --init
    sleep 5
fi

# Test Wine
log_message "INFO" "Testing Wine installation..."
wine --version || {
    log_message "ERROR" "Wine test failed"
    exit 1
}

# Install VC++ runtime using winetricks with proper environment
if ! wine winepath -u 'C:\windows\system32\ucrtbase.dll' >/dev/null 2>&1; then
    log_message "INFO" "Installing Visual C++ runtime..."

    # Set winetricks to use our cached file
    export W_CACHE="/config/.cache/winetricks"

    # Run winetricks with proper display
    DISPLAY=:0 winetricks -q vcrun2015 || {
        log_message "WARNING" "vcrun2015 installation failed, trying alternative method..."

        # Alternative: Install directly with Wine
        if [ -f "/config/.cache/winetricks/vcrun2015/vc_redist.x86.exe" ]; then
            log_message "INFO" "Installing VC++ directly..."
            cd /config/.cache/winetricks/vcrun2015
            wine vc_redist.x86.exe /quiet /norestart || log_message "WARNING" "Direct installation had issues"
        fi
    }
fi

# Create MT5 directory
mkdir -p "$WINEPREFIX/drive_c/Program Files/MetaTrader 5"

# Download and install MT5
if [ ! -f "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe" ]; then
    log_message "INFO" "Downloading MT5 installer..."
    wget -O /tmp/mt5setup.exe https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe || {
        log_message "ERROR" "Failed to download MT5"
        exit 1
    }

    log_message "INFO" "Installing MT5..."
    wine /tmp/mt5setup.exe /auto

    # Wait for installation
    sleep 30

    # Clean up
    rm -f /tmp/mt5setup.exe
fi

# Check if MT5 is installed
if [ -f "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe" ]; then
    log_message "INFO" "MT5 installed successfully!"
    log_message "INFO" "Starting MetaTrader 5..."
    cd "$WINEPREFIX/drive_c/Program Files/MetaTrader 5"
    wine terminal64.exe /portable &
else
    log_message "ERROR" "MT5 installation failed"
fi

# Keep script running
log_message "INFO" "MT5 setup script running..."
tail -f /dev/null
