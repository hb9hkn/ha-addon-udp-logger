# syslog Logger Add-on for Home Assistant

This is a simple custom add-on that listens for syslog log messages on port udp/514
and writes them to `/share/syslog/syslog.log`. It also performs log rotation, and clean up
keeping logs for 7 days.

# Installation
This add-on can be added via my [Home Assistant Add-on repository](https://github.com/hb9hkn/ha-addon-udp-logger):

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fhb9hkn%2Fha-addon-udp-logger)

# [Documentation](https://github.com/hb9hkn/ha-addon-udp-logger)
Homeassistant does not have a syslog receiver for sending logs from different devices directly via udp/514. 

The syslog add-on creates its own container and uses socat to listen for incoming messages. The messages are not processed - they are directly written to a file on /share/syslog/ in the file syslog.log. 

### ⚠️ **Warning**
> This add-on does not monitor nor manage your availalbe disk space.  
> Syslog messages can be very chatty. Make sure you restart the plugin daily 
> to rotate and compress the logs as well as clean up old logs 
> (see the proposed automation below). If you decide not to run the restart,
> the logs can fill up your available disk space. HA will have major problems 
> running if the disk is full, or it may simply crash.
> I take no responsibility for consequences of using this add-on. 

# Log rotation, compression and clean up
Implement a simple automation to rotate, compress and remove old logs (logs older than 7 days will be removed)
<pre> ```alias: Restart UDP Logger Add-on Daily
trigger:
  - platform: time
    at: "03:02:00"
action:
  - service: hassio.addon_restart
    data:
      addon: local_udp_logger
mode: single``` </pre>
