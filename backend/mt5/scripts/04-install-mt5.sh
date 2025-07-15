#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "04-install-mt5.sh"

# Check if MetaTrader 5 is already installed
if [ -e "$mt5file" ]; then
    log_message "INFO" "MetaTrader 5 already installed at: $mt5file"
else
    log_message "INFO" "MetaTrader 5 not found. Proceeding with installation..."

    # Set Wine to Windows 10 mode
    $wine_executable reg add "HKCU\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to set Wine to Windows 10 mode"
        exit 1
    fi

    # Download MT5 installer
    log_message "INFO" "Downloading MetaTrader 5 installer from $mt5setup_url"
    wget -q -O /tmp/mt5setup.exe "$mt5setup_url"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to download MT5 installer"
        exit 1
    fi

    # Run MT5 installer
    log_message "INFO" "Installing MetaTrader 5..."
    $wine_executable /tmp/mt5setup.exe /auto
    install_status=$?

    rm -f /tmp/mt5setup.exe

    if [ $install_status -ne 0 ]; then
        log_message "ERROR" "MT5 installation failed with exit code $install_status"
        exit 1
    fi
fi

# Verify installation
if [ -e "$mt5file" ]; then
    log_message "SUCCESS" "MetaTrader 5 successfully installed at: $mt5file"
    log_message "INFO" "Launching MetaTrader 5..."
    $wine_executable "$mt5file" &
else
    log_message "ERROR" "MT5 file not found after install. Something went wrong."
    exit 1
fi