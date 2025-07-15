#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "03-install-mono.sh"

# Set Mono version and installer path
mono_version="8.0.0"
mono_installer_url="https://dl.winehq.org/wine/wine-mono/${mono_version}/wine-mono-${mono_version}-x86.msi"
mono_installer_file="/tmp/mono-${mono_version}.msi"
mono_target_path="/config/.wine/drive_c/Program Files/Mono/bin/mono.exe"

# Check if Mono is already installed
if [ ! -f "$mono_target_path" ]; then
    log_message "INFO" "Mono not found — beginning download and installation..."

    wget -O "$mono_installer_file" "$mono_installer_url"
    if [ $? -eq 0 ]; then
        log_message "INFO" "Mono installer downloaded successfully."

        WINEDLLOVERRIDES=mscoree=d wine msiexec /i "$mono_installer_file" /qn
        install_status=$?

        rm -f "$mono_installer_file"

        if [ $install_status -eq 0 ]; then
            log_message "INFO" "Mono installed successfully."
        else
            log_message "ERROR" "Mono installation failed during execution."
            exit 1
        fi
    else
        log_message "ERROR" "Failed to download Mono installer from: $mono_installer_url"
        exit 1
    fi
else
    log_message "INFO" "Mono is already present at: $mono_target_path"
fi

# Optional: run winecfg silently to finish setup (can be skipped in CI)
log_message "INFO" "Running winecfg to finalize Mono/Wine setup..."
winecfg -v win10 || log_message "WARN" "winecfg failed but continuing anyway"