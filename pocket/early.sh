#!/bin/sh
# Starts Slot as soon as the games partition is mounted, without waiting for the stock
# autostart (which sits behind time sync and graphical.target). Run by slot-early.service.
SYS=/storage/roms/slot/System
# Audio routing autostart.sh would set: speaker + headphones, one silent play so the
# softvol control exists, then Slot's boot level (see volume.sh).
amixer -q -c 0 cset iface=MIXER,name='Playback Path' SPK_HP
aplay -q /usr/bin/emustation-config-init.wav 2>/dev/null
"$SYS/pocket-volume.sh"
# emustation.service only runs once this lock exists; autostart recreates it later, harmlessly.
touch /var/lock/start.games
systemctl start --no-block emustation
