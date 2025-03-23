#!/bin/bash

LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Clean up old logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive previous log
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

# Start UDP listener
echo "Starting UDP logger on port $PORT"
nc -kulw 0 $PORT >> "$LOG_FILE"
