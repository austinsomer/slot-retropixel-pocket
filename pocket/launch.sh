#!/bin/sh
# Slot. on the FunnyPlaying RetroPixel Pocket (stock RetroPixel/AmberELEC firmware).
# Runs in place of EmulationStation; see pocket/README.md.
ROOT="${SLOT_ROOT:-/storage/roms/slot}"
export SLOT_ROOT="$ROOT"
export SLOT_RUN=/run/slot
export SLOT_DEVICE=rppocket
# The Pocket's Mali blob has GBM/KMS EGL only; rk3568 selects Slot's KMS surface.
export BASEOS_PLATFORM=rk3568
# gpSP holds full speed on the RK3326 where mGBA does not; dmix never recovers from underruns.
export SLOT_GBA_CORE=gpsp
export SLOT_ALSA_DEVICE=plughw:0,0
export HOME=/storage
# The Mali GPU driver (40 MB) loads ~0.9 s faster from an uncompressed copy on /storage than
# from the squashfs system image. Re-copied whenever the firmware's copy changes.
GL=/storage/.config/slot-bin/lib
stamp=$(ls -l --full-time /usr/lib/libmali.so.1 2>/dev/null | awk "{print \$5, \$6, \$7}")
if [ -n "$stamp" ] && [ "$(cat $GL/.stamp 2>/dev/null)" != "$stamp" ]; then
	mkdir -p $GL && cp /usr/lib/libmali.so.1 $GL/libmali.so.1.tmp && mv $GL/libmali.so.1.tmp $GL/libmali.so.1
	for n in libEGL.so libEGL.so.1 libGLESv2.so libGLESv2.so.2 libgbm.so libgbm.so.1 libmali.so; do ln -sf libmali.so.1 $GL/$n; done
	echo "$stamp" > $GL/.stamp
fi
export LD_LIBRARY_PATH=$GL:/usr/lib
mkdir -p "$SLOT_RUN" "$ROOT/Logs"
cd "$ROOT" || exit 1
"$ROOT/System/pocket-perf.sh"
# Slot keeps its own time zone (default Etc/UTC); start it on the firmware's, which the stock
# settings set and connman's network time follows. Slot ignores zones it doesn't list.
STATE="$ROOT/Config/slot.state"
SYSZONE=$(sed -n 's/^TIMEZONE=//p' /storage/.cache/timezone 2>/dev/null)
if [ -n "$SYSZONE" ] && grep -q '^zone=Etc/UTC$' "$STATE" 2>/dev/null; then
	sed -i "s|^zone=Etc/UTC$|zone=$SYSZONE|" "$STATE"
fi
# Slot owns the power key (tap: save, then deep sleep via DSOS_SLEEP; hold: save, power off),
# so logind must not suspend on it too.
export DSOS_SLEEP="$ROOT/System/pocket-sleep.sh"
exec systemd-inhibit --what=handle-power-key --who=slot --why="Slot handles the power key" \
	--mode=block "$ROOT/System/slot" >> "$ROOT/Logs/slot.log" 2>&1
