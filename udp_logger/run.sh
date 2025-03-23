#!/bin/sh

LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Rotate old logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive existing log
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

# Start the UDP listener without 'fork'
echo "Starting UDP logger on port $PORT using socat..."
socat -T10 -u UDP-RECV:$PORT,reuseaddr STDOUT | tee -a "$LOG_FILE"



