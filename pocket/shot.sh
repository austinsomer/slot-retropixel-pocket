#!/bin/sh
# Snapshot the Pocket's screen to the given local path (default /tmp/pocket.png).
out=${1:-/tmp/pocket.png}
ssh rpp /storage/roms/slot/System/pocket-snap.sh >/dev/null 2>&1 && scp -q rpp:/run/slot/snap.png "$out" && echo "$out"
