#!/bin/sh

VERSION="1.1.5"
LOG_DIR="/share/syslog"
LOG_FILE="$LOG_DIR/syslog.log"
MAX_DAYS=$(jq -r '.max_days // 7' /data/options.json)
PORT=$(jq -r '.port // 514' /data/options.json)

mkdir -p "$LOG_DIR"

# Clean up old logs
find "$LOG_DIR" -name "syslog-*.log" -type f -mtime +$MAX_DAYS -exec rm {} \;

# Archive previous log (if it exists)
if [ -f "$LOG_FILE" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    ROTATED="$LOG_DIR/syslog-$TIMESTAMP.log"
    mv "$LOG_FILE" "$ROTATED"
    echo "Archived log: $ROTATED"
    gzip "$ROTATED"
    echo "Compressed log: $ROTATED.gz"
fi

# Clean up old compressed logs
find "$LOG_DIR" -name "syslog-*.log.gz" -type f -mtime +$MAX_DAYS -exec rm {} \;

touch "$LOG_FILE"
echo "syslog Logger started — version $VERSION" >> "$LOG_FILE"
echo "Starting socat with syslog Logger add-on v$VERSION on port $PORT..." | tee -a "$LOG_FILE"

# Load configuration from /data/options.json
PATTERNS=$(jq -r '.trigger_patterns[]?' /data/options.json)
HA_TOKEN=$(jq -r '.ha_token' /data/options.json)

# Validate token
if [ -z "$HA_TOKEN" ] || [ "$HA_TOKEN" = "null" ]; then
  echo "❌ ERROR: ha_token is not set. Please configure it in the add-on settings." | tee -a "$LOG_FILE"
  exit 1
fi

# Start UDP listener and process incoming lines
while true; do
(
  socat -T10 -u UDP-LISTEN:$PORT,reuseaddr,fork STDOUT &
  socat -T10 -u TCP-LISTEN:$PORT,reuseaddr,fork STDOUT &
  wait
)
done | while read line; do
  TIMESTAMPED="$(date '+%Y-%m-%d %H:%M:%S') $line"
  echo "$TIMESTAMPED" | tee -a "$LOG_FILE"

  for pattern in $PATTERNS; do
    if echo "$line" | grep -qi "$pattern"; then
      echo "Matched pattern: $pattern" | tee -a "$LOG_FILE"

      # Send event to Home Assistant
      curl -s -X POST -H "Authorization: Bearer $HA_TOKEN" \
           -H "Content-Type: application/json" \
           -d "{\"event_type\": \"udp_logger_match\", \"data\": {\"message\": \"$line\", \"pattern\": \"$pattern\"}}" \
           "http://homeassistant.local:8123/api/events/udp_logger_match" \
           >> "$LOG_FILE"
    fi
  done
done
