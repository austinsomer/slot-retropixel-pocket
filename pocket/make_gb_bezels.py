"""720x720 GB/GBC bezels for the RetroPixel Pocket.
Fit: game at 0,36 720x648. Integer: 40,72 640x576. Suffix tells Slot which Scale each is for."""
import sys
from PIL import Image, ImageDraw

out = sys.argv[1]
HOLES = {"fit": (0, 36, 720, 684), "integer": (40, 72, 680, 648)}
THEMES = {
    "GB": {"Black": None, "Grey": ((196, 194, 188), (172, 170, 164), (110, 30, 70))},
    "GBC": {"Black": None, "Berry": ((120, 40, 110), (86, 26, 80), (60, 200, 255))},
}

for plat, themes in THEMES.items():
    for name, colours in themes.items():
        for scale, (x0, y0, x1, y1) in HOLES.items():
            if colours is None:
                img = Image.new("RGBA", (720, 720), (0, 0, 0, 255))
            else:
                top, bot, accent = colours
                img = Image.new("RGBA", (720, 720))
                px = img.load()
                for y in range(720):
                    t = y / 719
                    c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
                    for x in range(720):
                        px[x, y] = (*c, 255)
                d = ImageDraw.Draw(img)
                # dark lens hugging the game, thin accent line under it
                d.rounded_rectangle((x0 - 12 if x0 else 0, y0 - 14, (x1 + 12 if x0 else 719), y1 + 14),
                                    radius=18, fill=(34, 34, 40, 255))
                d.line((24, y1 + 22, 696, y1 + 22), fill=(*accent, 255), width=3)
                ly = max(4, y0 - 30); d.ellipse((10, ly, 18, ly + 8), fill=(220, 40, 40, 255))  # power LED
            ImageDraw.Draw(img).rectangle((x0, y0, x1 - 1, y1 - 1), fill=(0, 0, 0, 0))
            img.save(f"{out}/{plat}/{name}_{scale}.png")
print("ok")
