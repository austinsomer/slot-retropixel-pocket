#!/bin/sh
# Bind-mounted over /usr/bin/amixer on Slot boots (pocket/overrides.sh). The stock autostart,
# odroidgoa_utils and retropixel-server each set the codec playback level as Slot starts
# (178, 213, 178), which made the volume jump while a game loaded. Only pocket-volume.sh
# (SLOT_AMIXER_OK=1) may set that level; everything else (Playback Path routing, reads)
# passes through to the real amixer.
REAL=/storage/.config/slot-bin/amixer.real
if [ "$SLOT_AMIXER_OK" != 1 ]; then
	case " $* " in
	*" cset "*numid=3*) exit 0 ;;                      # amixer -c 0 cset numid=3 "178,178"
	*" cset "*"Playback Volume"*) exit 0 ;;
	*" set Playback "* | *" sset Playback "*) exit 0 ;;  # amixer set 'Playback' 90%
	esac
fi
exec "$REAL" "$@"
