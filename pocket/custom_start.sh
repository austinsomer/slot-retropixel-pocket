#!/bin/bash
# /storage/.config/custom_start.sh: the stock autostart.sh runs this with "before" midway and
# with "after" as its last step.
. /etc/profile
case "${1}" in
"before")
	exit 0
	;;
*)
	# Slot on the RetroPixel Pocket (see pocket/README.md):
	# keep Wi-Fi awake so SSH stays reachable,
	iw dev wlan0 set power_save off 2>/dev/null
	# restart retropixel-server without its idle auto-suspend (it sets the codec to 178
	# as it starts, so this goes first),
	/storage/roms/slot/System/pocket-vendor.sh >/dev/null 2>&1
	sleep 1
	# then put Slot's audio level back (the amp itself starts loud on every boot).
	/storage/roms/slot/System/pocket-volume.sh
	# autostart sets the ondemand governors right after this hook returns; put full clocks back.
	(sleep 5; /storage/roms/slot/System/pocket-perf.sh) >/dev/null 2>&1 &
	exit 0
	;;
esac
exit 0
