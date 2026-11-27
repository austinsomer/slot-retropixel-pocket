# slot. for the RetroPixel Pocket

This is a fork of [slot.](https://github.com/slot-cfw/slot) by slot-cfw, ported to the FunnyPlaying
RetroPixel Pocket (2025 revision: RK3326, Mali-G31, 720x720 screen, 1 GB RAM).

The original slot. was built for the Anbernic RG SP and other Anbernic handhelds. This fork runs it
on the Pocket's stock firmware (RetroPixel, an AmberELEC fork) in place of EmulationStation. Wi-Fi
and SSH keep working, and you can boot back to the stock menu at any time.

It's a Game Boy-centric frontend and plays GBA, GBC and GB games only.

For setup, the files it puts on the device, how to get back to the stock menu and the build/deploy
scripts, see [pocket/README.md](pocket/README.md). For everything else about slot. itself, see the
[upstream repo](https://github.com/slot-cfw/slot) and [slot-cfw.fyi](https://slot-cfw.fyi).

---

# What does it look like?

These screenshots come from upstream, taken on an RG SP. The Pocket uses the same interface on a square 720x720 screen.

<p align="center">
<img src=".github/resources/screenshots/carousel.gif" width="48%" alt="Scrolling the cart carousel across the Game Boy Advance, Game Boy and Game Boy Color shelves">
<img src=".github/resources/screenshots/core-picker.gif" width="48%" alt="Flipping a cart to its circuit board to choose mGBA or gpSP">
</p>

---

# Supported Devices

| Device                                   | Notes                                    |
|------------------------------------------|------------------------------------------|
| FunnyPlaying RetroPixel Pocket (2025)    | Runs on the stock RetroPixel firmware    |

The Anbernic devices upstream supports are still in the code, but this fork doesn't test or build
for them. Use [upstream slot.](https://github.com/slot-cfw/slot/releases/latest) on those.

---

# Credits

All credit for slot. goes to its original author and to [Markus](https://github.com/MarkusMaribu) for
the art. mGBA, gpSP and Gambatte do the emulation. Upstream's notes follow.

## AI Disclosure (upstream)

The Rust frontend, and the SVGs on [slot-cfw.fyi](https://slot-cfw.fyi), were put together by Claude.
I reviewed everything that was produced. All documentation is 100% free-range, meatbag prose.

My goal with this project was to recreate the feeling of playing my GBA SP in the back seat as a kid,
but with a few modern creature comforts.

Nothing about this project is exciting or groundbreaking from a technological perspective, and as a
result, I delegated the glue code. mGBA, gpSP and Gambatte have been around forever and are the true stars of
this show. The incredible skeuomorphic art is the work of [Markus](https://github.com/MarkusMaribu), an
artist who saw the bare-bones version and offered to dress it up.

I understand if my use of AI is a dealbreaker for you. Just know it's the least interesting part of
what's here.

Figured I should share the end result of all the wasted water. ✌🏻

---

## Spread Joy! (upstream)

I've spent a lot of time building slot.

If you enjoy using it and feel inclined to pay it forward, go do something nice for someone! ❤️
