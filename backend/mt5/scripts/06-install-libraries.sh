#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "06-install-libraries.sh"

# Install MetaTrader5 library in Windows if not installed
log_message "INFO" "Installing MetaTrader5 library and dependencies in Windows"
if ! is_wine_python_package_installed "MetaTrader5"; then
    $wine_executable python -m pip install --no-cache-dir -r /app/requirements.txt
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to install Windows libraries from requirements.txt"
        exit 1
    else
        log_message "INFO" "Successfully installed Windows libraries."
    fi
else
    log_message "INFO" "MetaTrader5 is already installed in Wine Python."
fi