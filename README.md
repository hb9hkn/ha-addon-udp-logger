# UDP Logger Add-on for Home Assistant

This is a simple custom add-on that listens for UDP log messages on port 514
and writes them to `/share/udp_logs/udp_logs.log`. It also performs log rotation,
keeping logs for 7 days.
