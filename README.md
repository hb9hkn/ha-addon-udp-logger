# syslog Logger Add-on for Home Assistant

This is a simple custom add-on that listens for syslog messages on port udp/514
and writes them to `/share/syslog/syslog.log`. It also performs log rotation, compression and clean up at startup (an automation is required to regularly perform log clean up).

### ⚠️ **Warning**
> **This add-on does not monitor nor manage your availalbe disk space.  
> Syslog messages can be very chatty. Make sure you restart the plugin daily 
> to rotate and compress the logs as well as clean up old logs 
> (see the proposed automation below). If you decide not to run the restart,
> the logs can fill up your available disk space. HA will have major problems 
> running if the disk is full, or it may simply crash.
> I take no responsibility for consequences of using this add-on.** 

# Installation
This add-on can be added via my [Home Assistant Add-on repository](https://github.com/hb9hkn/ha-addon-udp-logger):

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fhb9hkn%2Fha-addon-udp-logger)

# [Documentation](https://github.com/hb9hkn/ha-addon-udp-logger)
Homeassistant does not have a syslog receiver for sending logs from different devices directly via udp/514. 

The syslog add-on creates its own container and uses socat to listen for incoming messages. The messages are not processed - they are directly written to a file on /share/syslog/ in the file syslog.log. 

 It starts listening on port udp/514 when the add-on starts, generates the log file if it doesn't exist and cleans up the old log files if they exist. 

# IMPORTANT: Log rotation, compression and clean up
Log file rotation, compression and clean up requires a restart of the add-on. Logs can be retains for a period defined in the add-on's Configuration page. The value can be between 1 and 30 days. 
```
alias: Restart UDP Logger Add-on Daily
trigger:
  - platform: time
    at: "03:02:00"
action:
  - service: hassio.addon_restart
    data:
      addon: local_udp_logger
mode: single
```

# 🔧 Configuration

##Trigger Patterns:
Enter keywords or phrases that, when matched in incoming UDP messages, will trigger a Home Assistant event.  
Example patterns:
- `ALERT`
- `door opened`
- `unauthorized access`

These are not case-sensitive. Each pattern will be matched against every incoming line.
## 🔐 How to Create a Home Assistant Long-Lived Access Token (`ha_token`)

To allow the UDP Logger add-on to communicate with Home Assistant (e.g., fire events), you need to provide a **long-lived access token**.

### ✅ Step-by-Step Instructions

1. Log in to your Home Assistant web interface.
2. Click your **profile picture or initials** in the bottom-left corner to open your **User Profile**.
3. Select the "Security" tab at the top
4. Scroll down to the section called **Long-Lived Access Tokens**.
5. Click **“Create Token”**.
6. Enter a name like `UDP Logger` and click **OK**.
7. **Copy the token** — you won’t be able to view it again!
8. In Home Assistant, go to:
   **Settings → Add-ons → UDP Logger → Configuration**
9. Paste the token into the `ha_token` field.
10. Save and **restart the add-on**.

---

### ⚠️ Important Notes

- Keep this token **private** — it grants access to your HA instance.
- You can revoke the token anytime via your profile.

## Log Retention Period
Define the number of days you want the logs stored. One day will be in clear ASCII file at /share/syslog/syslog.log. All older files will be compressed (using zip) and retained for the number of days you define. The limit of days can be between 1 and 30 days. Carefully calculate the available disk space (see the Warning above). The old logs will be removed after the number of days you define.

# How to Test
If you need to test if your implementation works, simply go to the Terminal and send the message:
```
echo "Hello HA syslog" | nc -u <YOUR_HA_IP> 514
```
This command should generate a message (together with a timestamp) in the Log tab of the add-on and in the log file at /share/syslog/syslog.log