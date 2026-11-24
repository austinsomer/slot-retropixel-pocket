"""Generate 720x720 GBA bezels for the RetroPixel Pocket (game hole at y 120..600)."""
import sys
from PIL import Image, ImageDraw, ImageFilter

W = H = 720
HOLE = (0, 120, 720, 600)
out = sys.argv[1]

# 1. Plain black.
img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
ImageDraw.Draw(img).rectangle((HOLE[0], HOLE[1], HOLE[2] - 1, HOLE[3] - 1), fill=(0, 0, 0, 0))
img.save(f"{out}/Black.png")

# 2. Indigo shell: vertical gradient plastic, dark lens border, power LED. No logos.
top, bot = (74, 66, 160), (46, 40, 112)
shell = Image.new("RGBA", (W, H))
px = shell.load()
for y in range(H):
    t = y / (H - 1)
    c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
    for x in range(W):
        px[x, y] = (*c, 255)
# subtle plastic grain
noise = Image.effect_noise((W, H), 6).convert("L")
shell = Image.composite(shell, Image.new("RGBA", (W, H), (60, 54, 140, 255)),
                        noise.point(lambda v: 200 + (v - 128) // 4))
d = ImageDraw.Draw(shell)
# lens: dark band hugging the game, rounded outer corners
d.rounded_rectangle((0, 84, W - 1, 636), radius=28, fill=(28, 28, 34, 255))
# thin highlight on the lens edge
d.rounded_rectangle((0, 84, W - 1, 636), radius=28, outline=(70, 70, 82, 255), width=2)
# power LED + label dots in the top lens band
d.ellipse((34, 98, 46, 110), fill=(40, 220, 90, 255))
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse((28, 92, 52, 116), fill=(40, 220, 90, 90))
shell = Image.alpha_composite(shell, glow.filter(ImageFilter.GaussianBlur(5)))
d = ImageDraw.Draw(shell)
# speaker grille dots, bottom right
for r in range(3):
    for c in range(6 - r):
        x = 600 + c * 16 + r * 8
        y = 660 + r * 16
        d.ellipse((x, y, x + 7, y + 7), fill=(30, 26, 80, 255))
d.rectangle((HOLE[0], HOLE[1], HOLE[2] - 1, HOLE[3] - 1), fill=(0, 0, 0, 0))
shell.save(f"{out}/Indigo.png")
print("ok")
