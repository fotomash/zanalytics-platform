#!/bin/bash

# Set variables
mt5setup_url="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
mt5file="/config/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
python_url="https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe"
wine_executable="wine"
metatrader_version="5.0.36"
mt5server_port=18812

# Function to show messages
log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] $message" | tee -a /var/log/mt5_setup.log
}

# Function to check if a Python package is installed in Wine
is_wine_python_package_installed() {
    $wine_executable python -c "import pkg_resources; pkg_resources.require('$1')" 2>/dev/null
    return $?
}

# Function to check if a Python package is installed in Linux
is_python_package_installed() {
    python3 -c "import pkg_resources; pkg_resources.require('$1')" 2>/dev/null
    return $?
}

# Mute Unnecessary Wine Errors
export WINEDEBUG=-all,err-toolbar,fixme-all

# Reset Wine prefix to ensure clean environment
if [ -d "/config/.wine" ]; then
    log_message "INFO" "Removing existing Wine prefix for clean setup."
    rm -rf /config/.wine
fi

# Set up 32-bit Wine environment
export WINEARCH=win32
export WINEPREFIX=/config/.wine

log_message "INFO" "Initializing Wine prefix..."
wineboot --init

# Install base libraries via winetricks
log_message "INFO" "Installing required DLLs via winetricks..."
winetricks -q vcrun2015 corefonts
if [ $? -ne 0 ]; then
    log_message "ERROR" "winetricks failed"
    exit 1
fi

# Download and install Python in Wine
log_message "INFO" "Downloading Python installer..."
wget -O /tmp/python.exe "$python_url"
if [ $? -ne 0 ]; then
    log_message "ERROR" "Failed to download Python installer"
    exit 1
fi

log_message "INFO" "Installing Python in Wine..."
wine /tmp/python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
if [ $? -ne 0 ]; then
    log_message "ERROR" "Python install failed in Wine"
    exit 1
fi

# Verify Python install
if wine python --version &>/dev/null; then
    log_message "INFO" "Python installed successfully under Wine."
else
    log_message "ERROR" "Python installation failed under Wine."
    exit 1
fi