#!/bin/sh

VERSION="1.0.0"
LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=55514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Rotate logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive previous log
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

# Create fresh log file
touch "$LOG_FILE"
echo "UDP Logger started — version $VERSION" >> "$LOG_FILE"
echo "Starting socat on port $PORT..." | tee -a "$LOG_FILE"

# Run socat with real-time logging
socat -T10 -u UDP-RECV:$PORT,bind=0.0.0.0,reuseaddr STDOUT | tee -a "$LOG_FILE"

# This should never run unless socat exits
echo "❌ Socat exited unexpectedly" | tee -a "$LOG_FILE"




