#!/bin/sh
# Sets the codec playback level the speaker amp is fed with. The volume rocker works the amp in
# hardware and the amp comes up loud on every boot, so this level is set lower to compensate.
# Edit /storage/roms/slot/Config/pocket-volume (0-237, default 130) to change it.
FILE=/storage/roms/slot/Config/pocket-volume
level=$(tr -cd '0-9' < "$FILE" 2>/dev/null)
[ -n "$level" ] && [ "$level" -le 237 ] || level=130
SLOT_AMIXER_OK=1 amixer -q -c 0 cset numid=3 "$level,$level"
