#!/bin/sh
# Restarts the firmware's retropixel-server (brightness rocker, battery LED, low-battery
# shutdown) with pocket/bin first on its PATH, so its idle `systemctl suspend` is ignored.
BIN=/storage/roms/slot/System/bin
pkill -f /usr/bin/retropixel-server
sleep 0.2
exec systemd-run --unit=retropixel-server --setenv=PATH="$BIN:/usr/bin:/usr/sbin:/bin:/sbin" /usr/bin/retropixel-server
