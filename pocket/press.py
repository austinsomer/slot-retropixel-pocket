#!/usr/bin/env python3
"""Remote QA: inject gamepad presses into the Pocket's evdev node.

Usage: pocket-press.py BUTTON [BUTTON ...]   e.g.  right right a   or  hold:menu:800
Buttons: a b x y l1 r1 menu r2 up down left right select start power.
"""
import struct, sys, time

CODES = {"b": 0x130, "a": 0x131, "x": 0x133, "y": 0x134, "l1": 0x136, "r1": 0x137,
         "menu": 0x138, "r2": 0x139, "up": 0x220, "down": 0x221, "left": 0x222,
         "right": 0x223, "select": 0x2C0, "start": 0x2C1}
EV_SYN, EV_KEY = 0, 1

def emit(f, kind, code, value):
    t = time.time()
    f.write(struct.pack("llHHi", int(t), int((t % 1) * 1e6), kind, code, value))

def press(dev, code, hold):
    with open(dev, "wb", buffering=0) as f:
        emit(f, EV_KEY, code, 1); emit(f, EV_SYN, 0, 0)
        time.sleep(hold)
        emit(f, EV_KEY, code, 0); emit(f, EV_SYN, 0, 0)

for arg in sys.argv[1:]:
    hold, name = 0.08, arg
    if arg.startswith("hold:"):
        _, name, ms = arg.split(":")
        hold = int(ms) / 1000
    dev = "/dev/input/event1"
    code = CODES.get(name)
    if name == "power":
        dev, code = "/dev/input/event0", 116
    if code is None:
        sys.exit(f"unknown button {name}")
    press(dev, code, hold)
    time.sleep(0.25)
