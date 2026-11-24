#!/bin/sh
# Make Slot resume straight into a game: play.sh gbc "Pokemon - Crystal Version (UE) (V1.1) [C][!]"
# The name travels on stdin, so any characters (quotes, brackets) are safe.
plat=$1
printf '%s\n' "$2" | ssh rpp "plat=$plat"'; read -r stem; esc=$(printf "%s" "$stem" | sed "s/[&/\\]/\\\\&/g"); systemctl stop emustation; sed -i "s/^cart=.*/cart=$esc/; s/^cart_platform=.*/cart_platform=$plat/" /storage/roms/slot/Config/slot.state; grep -E "^cart" /storage/roms/slot/Config/slot.state; systemctl start emustation' 2>&1 | grep -v -iE 'quantum|store now|openssh.com' || true
