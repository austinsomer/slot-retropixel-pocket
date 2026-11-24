#!/bin/sh
# Restore udev's hardware database from a cache instead of rebuilding it every boot.
# The firmware writes /run/hwdb.bin (12 MB, tmpfs) with `systemd-hwdb update` on every boot,
# which took 5.3 s and held up udev and everything after it. systemd-hwdb-update.service is
# masked; this rebuilds only when the firmware build or /etc/udev/hwdb.d changes.
CACHE=/storage/.cache/slot-hwdb
key="$(sed -n 's/^BUILD_ID=//p' /etc/os-release) $(cat /etc/udev/hwdb.d/*.hwdb 2>/dev/null | md5sum | cut -d' ' -f1)"
if [ -f "$CACHE/hwdb.bin" ] && [ "$(cat "$CACHE/key" 2>/dev/null)" = "$key" ]; then
	cp "$CACHE/hwdb.bin" /run/hwdb.bin.tmp && mv /run/hwdb.bin.tmp /run/hwdb.bin && exit 0
fi
systemd-hwdb update || exit 0
mkdir -p "$CACHE"
for f in /run/hwdb.bin /etc/udev/hwdb.bin; do
	[ -f "$f" ] && cp "$f" "$CACHE/hwdb.bin" && echo "$key" > "$CACHE/key" && break
done
exit 0
