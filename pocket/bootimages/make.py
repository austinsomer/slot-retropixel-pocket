"""Boot logo and charging frames for the RetroPixel Pocket's /flash, in Slot's style.
720x720 24-bit BMPs, same format as the stock ones. Usage: python make.py OUT_DIR"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

out = Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
FONT = Path(__file__).resolve().parents[2] / "crates/slot-ui/assets/label.ttf"
W = H = 720
BG = (12, 11, 13)
INK = (244, 240, 230)
DIM = (120, 116, 112)
GREEN = (126, 206, 94)
RED = (224, 83, 61)

# Boot logo
img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)
d.text((W / 2, H / 2 - 20), "slot.", font=ImageFont.truetype(str(FONT), 150), fill=INK, anchor="mm")
small = ImageFont.truetype(str(FONT), 24)
d.text((W / 2, H / 2 + 80), "R E T R O P I X E L   P O C K E T", font=small, fill=DIM, anchor="mm")
img.save(out / "logo.bmp")

# Charging frames: battery outline, 4 segments.
def battery(segments, colour, outline, name):
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    bw, bh = 200, 340
    x0, y0 = (W - bw) // 2, (H - bh) // 2 + 20
    d.rounded_rectangle((x0 + 62, y0 - 30, x0 + bw - 62, y0 + 6), radius=8, fill=outline)  # cap
    d.rounded_rectangle((x0, y0, x0 + bw, y0 + bh), radius=26, outline=outline, width=12)
    pad, gap = 26, 12
    inner_h = bh - 2 * pad
    seg_h = (inner_h - 3 * gap) / 4
    for i in range(segments):
        sy1 = y0 + bh - pad - i * (seg_h + gap)
        d.rounded_rectangle((x0 + pad, sy1 - seg_h, x0 + bw - pad, sy1), radius=8, fill=colour)
    img.save(out / name)

for i in range(4):
    battery(i + 1, GREEN, INK, f"battery_{i}.bmp")
battery(1, RED, RED, "battery_fail.bmp")
print("ok")
