#!/bin/sh
# Full clocks while Slot runs. With the stock ondemand governors the RK3326 sits at its
# minimum (CPU 1008 MHz, GPU 400 MHz, DDR 528 MHz) under Slot's per-frame bursts, and games
# run short of time and stutter: Golden Sun went from 1.1M starved audio samples in 40 s to
# 79k with these. Sleep (power tap) still suspends the whole SoC.
for c in /sys/devices/system/cpu/cpufreq/policy*; do
	echo performance > "$c/scaling_governor" 2>/dev/null
done
echo performance > /sys/class/devfreq/ff400000.gpu/governor 2>/dev/null
echo performance > /sys/class/devfreq/dmc/governor 2>/dev/null
exit 0
