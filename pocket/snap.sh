#!/bin/sh
# Remote QA: ask the running Slot for a full-screen PNG; prints its path.
RUN=${SLOT_RUN:-/run/slot}
rm -f "$RUN/snap.png"; touch "$RUN/snap"
i=0; while [ ! -f "$RUN/snap.png" ] && [ $i -lt 50 ]; do usleep 100000; i=$((i+1)); done
[ -f "$RUN/snap.png" ] && echo "$RUN/snap.png" || { echo "no snapshot (is Slot running?)" >&2; exit 1; }
