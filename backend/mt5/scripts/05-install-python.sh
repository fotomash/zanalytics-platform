#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "05-install-python.sh"

# Check if Python is already installed in Wine
if ! $wine_executable python --version > /dev/null 2>&1; then
    log_message "INFO" "Python not found in Wine. Installing..."

    log_message "INFO" "Downloading Python installer..."
    if wget -O /tmp/python-installer.exe "$python_url"; then
        log_message "INFO" "Running Python installer via Wine..."
        $wine_executable /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

        if [ $? -ne 0 ]; then
            log_message "ERROR" "Wine Python installer failed."
            exit 1
        fi

        rm -f /tmp/python-installer.exe
        log_message "INFO" "Python successfully installed in Wine."
    else
        log_message "ERROR" "Failed to download Python from $python_url"
        exit 1
    fi
else
    log_message "INFO" "Python is already installed in Wine."
fi

# Confirm Python versions
log_message "INFO" "Linux Python version: $(python3 --version 2>&1)"
log_message "INFO" "Wine Python version: $($wine_executable python --version 2>&1)"

# Show detailed Wine Python environment info
log_message "INFO" "Verifying Wine Python environment:"
$wine_executable python -c "import sys; print('prefix:', sys.prefix); print('exec:', sys.executable); print('path:', sys.path)"
$wine_executable python -c "import site; print('site-packages:', site.getsitepackages())"

# List installed packages
log_message "INFO" "Installed packages in Wine Python environment:"
$wine_executable python -m pip list || log_message "WARN" "pip list failed – pip may not be installed yet"