#!/bin/sh

LOG_DIR="/share/udp_logs"
LOG_FILE="$LOG_DIR/udp_logs.log"
PORT=55514
MAX_DAYS=7
VERSION="1.0.1"

mkdir -p "$LOG_DIR"

# Rotate old logs
find "$LOG_DIR" -name "udp_logs-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive existing log
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$LOG_FILE" "$LOG_DIR/udp_logs-$TIMESTAMP.log"
fi

# Ensure log file exists before starting
touch "$LOG_FILE"
echo "UDP Logger started — version $VERSION" >> "$LOG_FILE"

# Start the UDP listener without 'fork'
echo "Starting UDP logger on port $PORT using socat... version $VERSION"
#socat -T10 -u UDP-RECV:$PORT,reuseaddr STDOUT >> "$LOG_FILE"
socat -T10 -u UDP-RECV:$PORT,reuseaddr STDOUT | tee -a "$LOG_FILE"

echo "Writing to log file: $LOG_FILE"
ls -l "$LOG_FILE" || echo "Log file not found"



