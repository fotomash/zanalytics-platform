#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "07-start-wine-flask.sh"

log_message "INFO" "Starting Flask server inside Wine environment..."

export FLASK_LOG=/var/log/flask_wine.log
export WINEPREFIX="/config/.wine"

# Run Flask via Wine (in background, suppress noisy logs)
$wine_executable python /app/app.py > "$FLASK_LOG" 2>&1 &

FLASK_PID=$!

# Wait a few seconds to allow server startup
sleep 5

# Check Flask availability on expected port
if curl -s http://localhost:5000/ > /dev/null; then
    log_message "INFO" "Flask server started successfully on port 5000 (PID $FLASK_PID)"
else
    log_message "ERROR" "Flask server failed to respond on port 5000 (PID $FLASK_PID). See $FLASK_LOG for details."
    kill $FLASK_PID
    exit 1
fi