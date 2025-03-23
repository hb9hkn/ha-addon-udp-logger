#!/bin/sh

VERSION="1.0.2"
LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=55514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Clean up old logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive old log if exists
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

touch "$LOG_FILE"
echo "UDP Logger started — version $VERSION" >> "$LOG_FILE"
echo "Starting socat on port $PORT..." | tee -a "$LOG_FILE"

/usr/bin/socat -T10 -u UDP-RECV:$PORT,reuseaddr STDOUT >> "$LOG_FILE" 2>> "$LOG_FILE"

# If socat fails, log it
echo "❌ Socat exited unexpectedly (exit code: $?)" | tee -a "$LOG_FILE"
