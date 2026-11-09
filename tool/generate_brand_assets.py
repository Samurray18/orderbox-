"""Generate OrderBox DZ brand assets (app icon + splash mark).

Pure Pillow, no external assets. Run from the project root:
    python tool/generate_brand_assets.py
"""

from __future__ import annotations

import os
from PIL import Image, ImageDraw, ImageFilter

S = 4  # supersampling factor
CANVAS = 1024
W = CANVAS * S

PURPLE_TOP = (112, 62, 246, 255)
PURPLE_BOTTOM = (74, 33, 196, 255)
MINT = (18, 194, 164, 255)
MINT_DARK = (10, 168, 141, 255)
LAVENDER_LEFT = (227, 218, 255, 255)
LAVENDER_RIGHT = (247, 243, 255, 255)
WHITE = (255, 255, 255, 255)


def sc(v: float) -> int:
    return int(round(v * S))


def pts(values):
    return [(sc(x), sc(y)) for x, y in values]


def make_gradient(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / max(1, size - 1)
        # ease-in-out blend
        t = t * t * (3 - 2 * t)
        color = tuple(
            int(PURPLE_TOP[i] + (PURPLE_BOTTOM[i] - PURPLE_TOP[i]) * t)
            for i in range(4)
        )
        draw.line([(0, y), (size, y)], fill=color)
    return img


def rounded_mask(size: int, radius: float) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=sc(radius), fill=255)
    return mask


def draw_parcel(base: Image.Image, scale: float, center_shift=(0.0, 0.0)) -> None:
    """Draw the parcel + check badge onto an RGBA image.

    Coordinates are designed on a 1024 canvas, then scaled around the canvas
    centre by ``scale`` and shifted by ``center_shift`` (1024-space units).
    """
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    def tx(x, y):
        cx = cy = CANVAS / 2
        return (
            sc(cx + (x - cx) * scale + center_shift[0]),
            sc(cy + (y - cy) * scale + center_shift[1]),
        )

    def poly(points, fill):
        d.polygon([tx(x, y) for x, y in points], fill=fill)

    # Ground shadow
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sx1, sy1 = tx(180, 815)
    sx2, sy2 = tx(880, 915)
    sd.ellipse([sx1, sy1, sx2, sy2], fill=(38, 14, 96, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(sc(26)))
    layer = Image.alpha_composite(layer, shadow)
    d = ImageDraw.Draw(layer)

    # Box faces (isometric parcel)
    poly([(230, 440), (500, 320), (770, 440), (500, 560)], WHITE)
    poly([(230, 440), (500, 560), (500, 860), (230, 740)], LAVENDER_LEFT)
    poly([(770, 440), (500, 560), (500, 860), (770, 740)], LAVENDER_RIGHT)

    # Mint ribbon over the top and down the front seam
    poly([(478, 331), (522, 348), (522, 552), (478, 535)], MINT)
    poly([(478, 535), (522, 552), (522, 861), (478, 844)], MINT_DARK)
    d.line([tx(481, 534), tx(481, 843)], fill=(255, 255, 255, 45), width=sc(3))

    # Soft face crease highlights
    d.line(
        [tx(500, 560), tx(500, 860)],
        fill=(255, 255, 255, 70),
        width=sc(3),
    )
    d.line([tx(232, 444), tx(498, 562)], fill=(255, 255, 255, 90), width=sc(2.5))

    # Check badge
    bx, by = tx(785, 748)
    r = sc(140 * scale)
    ring = sc(16 * scale)
    d.ellipse([bx - r - ring, by - r - ring, bx + r + ring, by + r + ring], fill=WHITE)
    d.ellipse([bx - r, by - r, bx + r, by + r], fill=MINT)
    check = [
        (bx - sc(60 * scale), by + sc(4 * scale)),
        (bx - sc(14 * scale), by + sc(50 * scale)),
        (bx + sc(66 * scale), by - sc(34 * scale)),
    ]
    d.line(check, fill=WHITE, width=sc(30 * scale), joint="curve")
    for px, py in (check[0], check[-1]):
        rr = sc(15 * scale)
        d.ellipse([px - rr, py - rr, px + rr, py + rr], fill=WHITE)

    base.alpha_composite(layer)


def build_icon() -> Image.Image:
    img = make_gradient(W)

    # Soft top-left glow
    glow = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([sc(-180), sc(-220), sc(560), sc(520)], fill=(255, 255, 255, 36))
    glow = glow.filter(ImageFilter.GaussianBlur(sc(90)))
    img = Image.alpha_composite(img, glow)

    draw_parcel(img, scale=1.0)
    mask = rounded_mask(W, 232)
    img.putalpha(mask)
    return img.resize((CANVAS, CANVAS), Image.LANCZOS)


def build_foreground() -> Image.Image:
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    draw_parcel(img, scale=0.72)
    return img.resize((CANVAS, CANVAS), Image.LANCZOS)


def build_splash_mark() -> Image.Image:
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    draw_parcel(img, scale=1.0)
    return img.resize((CANVAS, CANVAS), Image.LANCZOS)


def main() -> None:
    out = os.path.join("assets", "images")
    os.makedirs(out, exist_ok=True)

    build_icon().save(os.path.join(out, "app_icon.png"))
    build_foreground().save(os.path.join(out, "app_icon_foreground.png"))
    build_splash_mark().save(os.path.join(out, "logo_mark.png"))
    print("Brand assets generated in", out)


if __name__ == "__main__":
    main()
