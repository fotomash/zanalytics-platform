#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "06-install-libraries.sh"

log_message "INFO" "Installing MetaTrader5 library and dependencies in Wine Python environment"

if ! is_wine_python_package_installed "MetaTrader5"; then
    log_message "INFO" "MetaTrader5 not found in Wine — installing all requirements"

    # Ensure pip is present and up-to-date
    $wine_executable python -m ensurepip
    $wine_executable python -m pip install --upgrade pip setuptools wheel

    # Install dependencies
    $wine_executable python -m pip install --no-cache-dir -r /app/requirements.txt
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to install Wine Python libraries from requirements.txt"
        exit 1
    else
        log_message "INFO" "Successfully installed Wine Python libraries."
    fi

    # Optional: log what's actually installed
    $wine_executable python -m pip freeze | tee /config/wine-installed-packages.txt
else
    log_message "INFO" "MetaTrader5 is already installed in Wine Python."
fi