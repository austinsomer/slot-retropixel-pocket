#!/bin/sh
# Slot's sleep hook (DSOS_SLEEP) on the RetroPixel Pocket: Slot has already saved a resume
# state, flushed saves and turned the backlight off. Deep-sleep the SoC; POWER wakes it.
echo "$(date '+%F %T') sleep: suspend" >> /storage/roms/slot/Logs/boot.log
exec /usr/bin/systemctl suspend
