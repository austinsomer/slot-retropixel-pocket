# Slot. on the FunnyPlaying RetroPixel Pocket

Slot runs on the RetroPixel Pocket (2025 revision: Rockchip RK3326, Mali-G31, 720x720 DSI panel,
1 GB) on top of its stock firmware, a fork of AmberELEC. It replaces EmulationStation as the
frontend; the stock OS, Wi-Fi and SSH stay as they are.

## Layout on the device

| Path | What |
|---|---|
| `/storage/roms/slot/` | Slot's card root (Games, Saves, States, Bezels, Config, Logs). Shared over SMB as `roms/slot`. |
| `/storage/roms/slot/System/slot` | The Pocket build (`pocket/build.sh`). |
| `System/pocket-boot.sh` | `emustation.service` runs this: Slot, or the stock menu on fallback. |
| `System/launch-pocket.sh` | Environment for Slot on the Pocket, then exec Slot. |
| `System/pocket-early.sh` | `slot-early.service`: audio routing and starts Slot without waiting for autostart. |
| `System/pocket-volume.sh` | Codec level from `Config/pocket-volume` (0-237, default 150). |
| `System/pocket-vendor.sh`, `System/bin/systemctl` | Restart `retropixel-server` with a `systemctl` that ignores its idle `suspend`. |
| `/storage/.config/system.d/emustation.service.d/slot.conf` | Swaps EmulationStation for `pocket-boot.sh`; `KillMode=control-group`. |
| `/storage/.config/system.d/slot-early.service` | Wanted by `multi-user.target`. |
| `/storage/.config/custom_start.sh` | Stock hook, end of autostart: Wi-Fi power save off, vendor restart, volume. |
| `/storage/.config/slot-overrides.sh` + `system.d/slot-overrides.service` | Early boot (sysinit), Slot boots only: bind-mounts `slot-splash.png` over the firmware splash and `slot-bin/amixer` (`pocket/amixer-wrapper.sh`) over `/usr/bin/amixer`, so only `pocket-volume.sh` sets the codec level (no jumps while a game loads). |
| `/flash/logo.bmp`, `/flash/battery_*.bmp` | Slot-style boot logo and charging frames (`pocket/bootimages/make.py`); originals kept in `/storage/flash-backup`. |
| `/storage/.config/slot-hwdb.sh` + `system.d/slot-hwdb.service` | Restores udev's 12 MB `hwdb.bin` from `/storage/.cache/slot-hwdb` (rebuilt only when the firmware build or `hwdb.d` changes); `systemd-hwdb-update` is masked. Saved 5.3 s per boot. |
| `system.d/<svc>.service.d/slot-skip.conf` | Samba (smbd, nmbd, wsdd2), PulseAudio, volume, joyled, connman-vpn skip on Slot boots (`/run/slot-boot`); the stock-menu boot still starts them. No `\\RP-POCKET` share in Slot mode. |
| `system.d/amberelec-autostart.service.d/slot.conf` | Stock autostart at Nice 10, idle I/O, so Slot loads first. |
| `/flash/rk3326-rppocket_v6_0-linux.dtb` | One byte changed: `bootargs` `loglevel=7` to `loglevel=3` (the DTB overrides extlinux `APPEND`). Stops ~500 lines of kernel log at 115200 baud: kernel 5.9 s to 3.9 s. Original: `/storage/flash-backup/` and `~/Projects/slot-pocket/flash-backup/*.orig`. |
| `/flash/KERNEL` | The initramfs inside it draws `/splash/splash-640.png` early in boot (before /storage or the system image are up). That one file was swapped for Slot's splash in place (`pocket/kernel-splash.py`: same entries, recompressed to fit the original gzip slot, zero-padded; everything outside the initramfs byte-identical). Original: `/storage/flash-backup/KERNEL`, `~/Projects/slot-pocket/flash-backup/KERNEL.orig`. |
| `/storage/.config/slot-bin/lib/` | Uncompressed copy of `libmali.so.1` (the launcher re-copies it when the firmware's changes); Slot gets its display ~0.9 s sooner than from squashfs. |
| `System/pocket-perf.sh` | Full CPU/GPU/DDR clocks while Slot runs (fixes audio stutter); run by the launcher and after autostart. |
| `/storage/.config/modprobe.d/8188eu-awake.conf` | RTL8188EU power management off. |

Files the firmware owned before are backed up next to them as `*.bak-slot`.

## Getting back to the stock menu

- Hold **Select** while powering on, or
- `touch /storage/.slot-off` (remove it to go back to Slot), or
- Slot crashing 3 times within 30 s falls back on its own.

## Hardware notes

- Display: KMS/GBM only (`libmali` has no fbdev EGL). One connector, DSI-1; Slot's KMS surface
  handles single-panel devices. `BASEOS_PLATFORM=rk3568` selects it.
- Input: `GO-Super Gamepad` on `event1`; keymap `Keymap::Pocket` (`SLOT_DEVICE=rppocket`).
  No L2/R2 triggers: brightness rocker push = TL2 (Slot's Menu), volume rocker push = TR2.
  Brightness rocker up/down (HAPPY5/6) is handled by `retropixel-server`. Volume rocker up/down
  drives the speaker amp in hardware (GPIO 123 up / 116 down only mirror it); the amp resets
  loud on every power-on, hence the lower codec level.
- Audio: RK817. `snd_pcm_recover` fails with EPIPE after an underrun; Slot now reopens the
  device instead of going silent. `SLOT_ALSA_DEVICE=plughw:0,0` skips the stock dmix.
- GBA: gpSP by default (`SLOT_GBA_CORE=gpsp`); mGBA can't hold full speed on the RK3326.
- Wi-Fi: connman owns it. Slot's own Wi-Fi manager is replaced on the Pocket by a read-only
  backend (`wifi/system.rs`) that only reports status.
- Kernel 4.4: never run recursive grep/find over `/usr` on the device; it trips a `__brelse`
  soft lockup and the `panic=20` reboot.

## Feature parity with upstream (checked 2026-11-23)

| Feature | On the Pocket |
|---|---|
| Shelf, collections, favorites, recents, kid mode, Cart Studio, guides | Same (software) |
| Saves, save states, resume on insert / power on, undo | Same |
| Screenshots and gallery | Same (Select + X) |
| Shaders, colour correction, palettes, frame blending, overlays | Same |
| Scale / bezels | Square-panel bezels with hole auto-fit (upstream had none at 720x720) |
| Fast forward / turbo | Same; fast forward is R2 = volume-rocker push |
| Rewind, Palette Back, shelf L2 | No L2 on the Pocket; rebind in Settings > Controls |
| Gamebit (web file manager), slot.local | Works over connman Wi-Fi (`wifi/system.rs`) |
| Fetch Missing Art | Works |
| Wi-Fi menu | Shows the joined network; joining others is done in the stock settings |
| Check for Updates | Off: "No updates on this device" (upstream builds would replace the port) |
| Link play, Bluetooth invites | Off: "No link support" (slotlink needs a 5 GHz AP; RTL8188EU is 2.4 GHz) |
| Power tap / hold | Slot owns the key (logind inhibited): tap = save then deep sleep (`DSOS_SLEEP`), hold = save and power off |
| Lid Power Off timer | Applies to power-tap sleep as on lidless upstream devices |
| Clock / city | Slot starts on the firmware's time zone (launcher copies it once) |
| Low-battery save and power off | Same (reads `/sys/class/power_supply/battery`) |
| Brightness | Slot's steps plus the hardware rocker (`retropixel-server`) |
| Volume | Slot's software volume; rocker is the hardware amp |
| Headphone volume | Not separate: no headphone-detect line Slot can read |
| Rumble | Motor found (`event1` FF); untested, no rumble carts on the card |
| Card repair | Would run on `/dev/mmcblk0p3`; its result note goes to `/data`, absent here. Untested |
| Boot logo | Not available (H700 boot-resource partition only) |
| LEDs | Battery LED stays with `retropixel-server` |

## Bezels on the square panel

Any 720x720 PNG with a transparent hole works: Slot finds the hole and fits the game in it,
snapping to a whole-number scale when the hole is within 4% of one. Put them in
`Bezels/GB`, `Bezels/GBC` or `Bezels/GBA` and pick them under Settings > Screen.
Community packs that fit as-is: BB64's 720x720 Handheld Bezel Pack and acatone's
Game Boy Player overlays for the RG CubeXX (both personal use, no licence; not shipped here).
`make_bezels.py` and `make_gb_bezels.py` generate simple original ones.

## Developer loop

The scripts reach the Pocket as `rpp`, an SSH host alias (root on the Pocket, key auth). Add one to
`~/.ssh/config` with your Pocket's address; the stock root password is `retropixel`.

```
sh pocket/build.sh                 # cross-compile in an x86 container, ~3 min
sh pocket/deploy.sh                # push the binary and restart Slot
sh pocket/play.sh gba "Golden Sun (USA, Europe)"   # resume straight into a game
sh pocket/shot.sh /tmp/pocket.png  # full-screen PNG (touch $SLOT_RUN/snap hook)
ssh rpp /storage/roms/slot/System/pocket-press.py right right a   # inject buttons
ssh rpp /storage/roms/slot/System/pocket-compat.sh 25  # boot every game, Logs/compat.txt
```
