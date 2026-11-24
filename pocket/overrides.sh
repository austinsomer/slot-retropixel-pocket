#!/bin/sh
# Early-boot overrides for Slot boots, as bind mounts so the read-only firmware stays as it is.
# Skipped when booting to the stock menu (Select held, or /storage/.slot-off).
C=/storage/.config
[ -e /storage/.slot-off ] && exit 0
evtest --query /dev/input/event1 EV_KEY BTN_TRIGGER_HAPPY1 >/dev/null 2>&1
[ $? = 10 ] && exit 0
# Services with a slot-skip drop-in (Samba, PulseAudio, ...) see this and stay off.
touch /run/slot-boot
# Slot's splash instead of the firmware's RetroPixel one (show_splash.sh draws it).
[ -f $C/slot-splash.png ] && mount --bind $C/slot-splash.png /usr/config/splash/splash-640.png
# One audio level: only pocket-volume.sh may change the playback level.
mkdir -p $C/slot-bin
[ -x $C/slot-bin/amixer.real ] || cp /usr/bin/amixer $C/slot-bin/amixer.real
mount --bind $C/slot-bin/amixer /usr/bin/amixer
/storage/roms/slot/System/pocket-volume.sh
exit 0
