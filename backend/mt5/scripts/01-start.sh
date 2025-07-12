#!/bin/bash

export DISPLAY=:99
export WINEARCH=win64
export WINEPREFIX="/config/.wine"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

source /scripts/02-common.sh

log_message "INFO" "Starting MT5 setup..."

if [ ! -f "$WINEPREFIX/system.reg" ]; then
    log_message "INFO" "Initializing Wine prefix..."
    wineboot --init
    sleep 5
fi

if ! wine winepath -u 'C:\windows\system32\ucrtbase.dll' >/dev/null 2>&1; then
    log_message "INFO" "Installing Visual C++ runtime..."
    winetricks -q vcrun2015
fi

mkdir -p "$WINEPREFIX/drive_c/Program Files/MetaTrader 5"

if [ ! -f "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe" ]; then
    log_message "INFO" "Downloading MT5..."
    wget -O /tmp/mt5setup.exe https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe
    
    log_message "INFO" "Installing MT5..."
    wine /tmp/mt5setup.exe /auto
    sleep 30
fi

if [ -f "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe" ]; then
    log_message "INFO" "MT5 installed successfully!"
    wine "$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe" /portable &
else
    log_message "ERROR" "MT5 installation failed"
fi

tail -f /dev/null