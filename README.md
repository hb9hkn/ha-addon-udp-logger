# syslog Logger Add-on for Home Assistant

This is a simple custom add-on that listens for syslog (udp/514) log messages on port 514
and writes them to `/share/syslog/syslog.log`. It also performs log rotation,
keeping logs for 7 days.

# Installation
This add-on can be added via my [Home Assistant Add-on repository](https://github.com/hb9hkn/ha-addon-udp-logger):

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fhb9hkn%2Fha-addon-udp-logger)

# [Documentation](https://github.com/hb9hkn/ha-addon-udp-logger)