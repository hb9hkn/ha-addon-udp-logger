#!/bin/sh

VERSION="1.0.7"
LOG_DIR="/share/syslog"
LOG_FILE="$LOG_DIR/syslog.log"
PORT=514
MAX_DAYS=7

mkdir -p "$LOG_DIR"

# Clean up old logs
find "$LOG_DIR" -name "syslog-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive old log if exists
# Archive previous log (if it exists)
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    ROTATED="$LOG_DIR/syslog-$TIMESTAMP.log"
    mv "$LOG_FILE" "$ROTATED"
    echo "Archived log: $ROTATED"

    # Compress the rotated log
    gzip "$ROTATED"
    echo "Compressed log: $ROTATED.gz"
fi

# Clean up old compressed logs
find "$LOG_DIR" -name "syslog-*.log.gz" -type f -mtime +$MAX_DAYS -exec rm {} \;


touch "$LOG_FILE"
echo "UDP Logger started — version $VERSION" >> "$LOG_FILE"
echo "Starting socat v$VERSION on port $PORT..." | tee -a "$LOG_FILE"

while true; do
  socat -T10 -u UDP-LISTEN:$PORT,reuseaddr STDOUT
done | while read line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done | tee -a "$LOG_FILE"


# If socat fails, log it
echo "❌ Socat exited unexpectedly (exit code: $?)" | tee -a "$LOG_FILE"
