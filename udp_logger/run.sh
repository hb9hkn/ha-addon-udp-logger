#!/bin/sh

LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Clean old logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive current log
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

# Use socat instead of netcat
echo "Starting UDP listener on port $PORT"
socat -T10 -u UDP-RECV:$PORT,reuseaddr STDOUT >> "$LOG_FILE"

