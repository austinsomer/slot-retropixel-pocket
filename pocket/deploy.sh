#!/bin/sh
# Push the latest Pocket build and restart Slot.
set -e
cd "$(dirname "$0")/.."
S=/storage/roms/slot
scp -q target-pocket/aarch64-unknown-linux-gnu/device/slot rpp:$S/System/slot.new
ssh rpp "systemctl stop emustation; mv -f $S/System/slot.new $S/System/slot; chmod +x $S/System/slot; systemctl start emustation" 2>&1 | grep -v -iE 'quantum|store now|openssh.com' || true
