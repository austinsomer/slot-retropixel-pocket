#!/bin/sh
# Boots every game in Slot/Games for SECS seconds each and records how it went.
# Usage: pocket-compat.sh [SECS]   Output: Logs/compat.txt (and Logs/compat/<game>.log)
ROOT=/storage/roms/slot
SECS=${1:-25}
STATE=$ROOT/Config/slot.state
OUT=$ROOT/Logs/compat.txt
mkdir -p "$ROOT/Logs/compat"
systemctl stop emustation
: > "$OUT"
for dir in GB GBC GBA; do
	plat=$(echo $dir | tr A-Z a-z)
	for rom in "$ROOT/Games/$dir"/*; do
		[ -f "$rom" ] || continue
		name=$(basename "$rom"); stem=${name%.*}
		log="$ROOT/Logs/compat/$plat-$stem.log"
		sed -i "s/^cart=.*/cart=$(printf '%s' "$stem" | sed 's/[&/\]/\\&/g')/; s/^cart_platform=.*/cart_platform=$plat/" "$STATE"
		SLOT_ROOT=$ROOT SLOT_RUN=/run/slot SLOT_DEVICE=rppocket BASEOS_PLATFORM=rk3568 SLOT_GBA_CORE=gpsp SLOT_ALSA_DEVICE=plughw:0,0 HOME=/storage \
			timeout "$SECS" sh -c "cd $ROOT && exec ./System/slot" > "$log" 2>&1
		core=$(grep -o 'on [a-z0-9_]* at' "$log" | head -1 | cut -d' ' -f2)
		ready=$(grep -c 'emu: ready' "$log")
		shown=$(grep -o 'first frame shown at [0-9.]*' "$log" | head -1 | awk '{print $5}')
		audio=$(grep -o 'audio: [0-9]* samples dropped, [0-9]* starved, [0-9]* xruns' "$log" | tail -1)
		err=$(grep -iE 'panic|error|fail|cannot' "$log" | grep -vE 'ntp|timedatectl|ble:|Bluetooth' | head -1)
		echo "$plat | $stem | core=$core ready=$ready shown=${shown}ms | $audio | $err" >> "$OUT"
	done
done
sed -i "s/^cart=.*/cart=spire/; s/^cart_platform=.*/cart_platform=gba/" "$STATE"
echo DONE >> "$OUT"
systemctl start emustation
