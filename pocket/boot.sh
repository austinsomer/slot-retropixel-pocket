#!/bin/sh
# Boot entry for Slot on the RetroPixel Pocket, run by emustation.service (see pocket/README.md).
# Falls back to the stock EmulationStation when:
#   - Select is held while booting,
#   - /storage/.slot-off exists, or
#   - Slot has crashed 3 times within 30 seconds.
ROOT=/storage/roms/slot
RUN=/run/slot
STOCK=/usr/bin/emulationstation
mkdir -p "$RUN" "$ROOT/Logs"
log() { echo "$(date '+%F %T') boot: $*" >> "$ROOT/Logs/boot.log"; }

stock() {
	log "stock menu ($1)"
	exec "$STOCK"
}

[ -e /storage/.slot-off ] && stock "/storage/.slot-off present"
[ -x "$ROOT/System/slot" ] || stock "no Slot binary"
evtest --query /dev/input/event1 EV_KEY BTN_TRIGGER_HAPPY1 >/dev/null 2>&1
[ $? = 10 ] && stock "Select held"

# Crash-loop guard: timestamps of recent failed starts.
now=$(cut -d. -f1 /proc/uptime)
recent=$(awk -v n="$now" '$1 > n - 30' "$RUN/fails" 2>/dev/null | wc -l)
[ "$recent" -ge 3 ] && stock "Slot failed $recent times in 30 s"

log "slot"
"$ROOT/System/launch-pocket.sh"
code=$?
log "slot exited $code"
[ "$code" = 0 ] || echo "$now" >> "$RUN/fails"
exit "$code"
