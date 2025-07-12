#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "05-install-python.sh"

export XDG_RUNTIME_DIR=/tmp/runtime-abc
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Install Python in Wine if not present
if ! $wine_executable "C:\\Program Files\\Python39\\python.exe" --version > /dev/null 2>&1; then
    log_message "INFO" "Installing Python in Wine..."
    wget -O /tmp/python-installer.exe $python_url > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to download Python installer for Wine."
        exit 1
    fi
    winetricks -q vcrun2015 corefonts
    if [ $? -ne 0 ]; then
        log_message "ERROR" "winetricks failed during Python install."
        rm -f /tmp/python-installer.exe
        exit 1
    fi
    $wine_executable /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Python installation failed in Wine."
        rm -f /tmp/python-installer.exe
        exit 1
    fi
    rm -f /tmp/python-installer.exe
    log_message "INFO" "Python installed in Wine."
    log_message "INFO" "Installing pip manually under Wine..."
    $wine_executable "C:\\Program Files\\Python39\\python.exe" -m ensurepip
    if [ $? -ne 0 ]; then
        log_message "ERROR" "ensurepip failed in Wine Python."
        exit 1
    fi
    $wine_executable "C:\\Program Files\\Python39\\python.exe" -m pip install --upgrade pip
    if [ $? -ne 0 ]; then
        log_message "ERROR" "pip upgrade failed in Wine Python."
        exit 1
    fi
else
    log_message "INFO" "Python is already installed in Wine."
fi

log_message "INFO" "Linux Python version: $(python3 --version 2>&1)"
log_message "INFO" "Wine Python version: $($wine_executable "C:\\Program Files\\Python39\\python.exe" --version 2>&1)"

log_message "INFO" "Checking Wine Python environment..."
$wine_executable "C:\\Program Files\\Python39\\python.exe" -c "import sys; print(sys.prefix); print(sys.executable); print(sys.path)"

# Output Python and package information for Wine environment
log_message "INFO" "Wine Python installation details:"
$wine_executable "C:\\Program Files\\Python39\\python.exe" -c "import sys; print(f'Python version: {sys.version}')"
$wine_executable "C:\\Program Files\\Python39\\python.exe" -c "import sys; print(f'Python executable: {sys.executable}')"
$wine_executable "C:\\Program Files\\Python39\\python.exe" -c "import sys; print(f'Python path: {sys.path}')"
$wine_executable "C:\\Program Files\\Python39\\python.exe" -c "import site; print(f'Site packages: {site.getsitepackages()}')"

log_message "INFO" "Installed packages in Wine Python environment:"
$wine_executable "C:\\Program Files\\Python39\\python.exe" -m pip list || log_message "WARNING" "pip may not be available in Wine Python."

if ! $wine_executable "C:\\Program Files\\Python39\\python.exe" --version > /dev/null 2>&1; then
    log_message "ERROR" "Wine Python failed to install or run properly."
    exit 1
fi