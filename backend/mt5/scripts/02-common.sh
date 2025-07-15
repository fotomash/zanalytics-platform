#!/bin/bash

# Set variables
mt5setup_url="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
mt5file="/config/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
python_url="https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe"

# Use Wine as non-root user (assumes running as abc)
wine_executable="wine"
metatrader_version="5.0.36"
mt5server_port=18812

# Setup log path
log_dir="/config/logs"
log_file="${log_dir}/mt5_setup.log"
mkdir -p "$log_dir"

# Function to show log messages
log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] $message" | tee -a "$log_file"
}

# Function to check if a Wine Python package is installed
is_wine_python_package_installed() {
    $wine_executable python -c "import pkg_resources; pkg_resources.require('$1')" 2>/dev/null
    return $?
}

# Function to check if a Linux Python package is installed
is_python_package_installed() {
    python3 -c "import pkg_resources; pkg_resources.require('$1')" 2>/dev/null
    return $?
}

# Mute noisy Wine logs but keep critical info
export WINEDEBUG=-all,err-toolbar,fixme-all

# Set Wine architecture and prefix
export WINEARCH=win32
export WINEPREFIX="/config/.wine"

# Ensure Wine prefix is owned by abc and cleaned up first (if run from a privileged container)
if [ "$(id -u)" -eq 0 ]; then
    log_message "INFO" "Fixing Wine folder ownership to abc (UID 1000)..."
    mkdir -p /config/.wine
    chown -R 1000:1000 /config
fi

# If run as abc, do the full Wine init
if [ "$(id -u)" -eq 1000 ]; then
    log_message "INFO" "Resetting Wine prefix to ensure clean setup."
    rm -rf "$WINEPREFIX"

    log_message "INFO" "Initializing Wine prefix..."
    wineboot --init

    log_message "INFO" "Installing required DLLs via winetricks..."
    winetricks -q vcrun2015 corefonts
    if [ $? -ne 0 ]; then
        log_message "ERROR" "winetricks failed"
        exit 1
    fi

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

    if wine python --version &>/dev/null; then
        log_message "INFO" "Python installed successfully under Wine."
    else
        log_message "ERROR" "Python installation failed under Wine."
        exit 1
    fi
else
    log_message "WARN" "Not running as user abc (UID 1000); skipping Wine environment setup."
fi