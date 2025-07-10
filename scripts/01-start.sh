#!/bin/bash

# Source common variables and functions
source /scripts/02-common.sh

# Run installation scripts
/scripts/03-install-mono.sh
/scripts/04-install-mt5.sh

#wine /mt5setup.exe
wine "C:\\Program Files\\MetaTrader 5\\terminal64.exe"

# Keep the script running
tail -f /dev/null