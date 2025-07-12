#!/bin/bash

source /scripts/02-common.sh

log_message "RUNNING" "07-start-wine-flask.sh"

log_message "INFO" "Starting Flask server in Wine environment..."

wine python /app/app.py > /var/log/flask_wine.log 2>&1 &

FLASK_PID=$!

# Give the server some time to start
sleep 5

# Check if the Flask server is running and responding
if curl -s http://localhost:5000/ > /dev/null; then
    log_message "INFO" "Flask server in Wine started and is responding on port 5000 (PID $FLASK_PID)."
else
    log_message "ERROR" "Flask server process ($FLASK_PID) not responding on port 5000. See /var/log/flask_wine.log for details."
    kill $FLASK_PID
    exit 1
fi