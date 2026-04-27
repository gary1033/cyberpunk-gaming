#!/usr/bin/env python3
"""
Render deterministic PNG assets from the image2 prompt manifests.

This is a local fallback renderer for development builds. The JSONL manifests
remain the source of truth for later image2 generation, while this script gives
the game real raster backgrounds, evidence icons, and UI plates immediately.
"""

from __future__ import annotations

import hashlib
import json
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
PROMPT_DIR = ROOT / "assets" / "generated" / "prompts"

BACKGROUND_MANIFEST = PROMPT_DIR / "image2_backgrounds.jsonl"
ITEM_MANIFEST = PROMPT_DIR / "image2_items.jsonl"
UI_MANIFEST = PROMPT_DIR / "image2_ui.jsonl"

CYAN = (0, 225, 235)
MAGENTA = (255, 42, 170)
AMBER = (255, 180, 72)
GREEN = (84, 255, 145)
INK = (5, 8, 18)


def parse_size(value: str) -> tuple[int, int]:
    width, height = value.lower().split("x", 1)
    return int(width), int(height)


def seed_for(key: str) -> int:
    return int(hashlib.sha256(key.encode("utf-8")).hexdigest()[:16], 16)


def load_jsonl(path: Path) -> list[dict]:
    records = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def output_path(record: dict) -> Path:
    return ROOT / record["output_path"]


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    width, height = size
    img = Image.new("RGB", size, top)
    draw = ImageDraw.Draw(img)
    for y in range(height):
        t = y / max(1, height - 1)
        color = tuple(lerp(top[i], bottom[i], t) for i in range(3))
        draw.line([(0, y), (width, y)], fill=color)
    return img


def overlay(base: Image.Image, layer: Image.Image, blur: float = 0.0) -> None:
    if blur:
        layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def glow_line(base: Image.Image, points, color, width: int = 3, glow: int = 16) -> None:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.line(points, fill=(*color, 90), width=max(width * 5, glow), joint="curve")
    overlay(base, layer, blur=glow / 3)

    sharp = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(sharp)
    draw.line(points, fill=(*color, 230), width=width, joint="curve")
    overlay(base, sharp)


def glow_rect(base: Image.Image, rect, color, radius: int = 4, width: int = 2, glow: int = 14, fill_alpha: int = 20) -> None:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.rounded_rectangle(rect, radius=radius, outline=(*color, 120), width=width + 3, fill=(*color, fill_alpha))
    overlay(base, layer, blur=glow / 3)

    sharp = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(sharp)
    draw.rounded_rectangle(rect, radius=radius, outline=(*color, 230), width=width, fill=(5, 10, 22, 170))
    overlay(base, sharp)


def draw_scanlines(base: Image.Image, alpha: int = 30, step: int = 4) -> None:
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    width, height = base.size
    for y in range(0, height, step):
        draw.line([(0, y), (width, y)], fill=(255, 255, 255, alpha), width=1)
    overlay(base, layer)


def draw_rain(base: Image.Image, rng: random.Random, count: int) -> None:
    width, height = base.size
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for _ in range(count):
        x = rng.randrange(-80, width + 80)
        y = rng.randrange(-20, height)
        length = rng.randrange(12, 36)
        draw.line([(x, y), (x + 8, y + length)], fill=(160, 230, 255, rng.randrange(20, 75)), width=1)
    overlay(base, layer, blur=0.2)


def draw_city_background(record: dict) -> Image.Image:
    size = parse_size(record.get("target_size", record["size"]))
    rng = random.Random(seed_for(record["id"]))
    if record["id"] == "detective_office":
        return draw_detective_office_background(size, rng)

    top = (rng.randrange(5, 15), rng.randrange(8, 18), rng.randrange(28, 48))
    bottom = (rng.randrange(9, 18), rng.randrange(5, 14), rng.randrange(20, 35))
    img = vertical_gradient(size, top, bottom).convert("RGBA")
    draw = ImageDraw.Draw(img, "RGBA")
    width, height = size
    horizon = int(height * rng.uniform(0.48, 0.64))

    # Far skyline.
    x = -40
    while x < width:
        b_width = rng.randrange(42, 120)
        b_height = rng.randrange(int(height * 0.18), int(height * 0.58))
        y0 = horizon - b_height
        color = (5 + rng.randrange(12), 9 + rng.randrange(18), 24 + rng.randrange(24), 210)
        draw.rectangle([x, y0, x + b_width, horizon + 18], fill=color)
        if rng.random() < 0.35:
            accent = CYAN if rng.random() < 0.55 else MAGENTA
            glow_line(img, [(x + b_width // 2, y0 + 8), (x + b_width // 2, horizon)], accent, width=2, glow=12)
        for wx in range(x + 8, x + b_width - 8, rng.randrange(14, 26)):
            for wy in range(y0 + 12, horizon - 8, rng.randrange(18, 32)):
                if rng.random() < 0.38:
                    fill = (*rng.choice([CYAN, MAGENTA, AMBER, GREEN]), rng.randrange(70, 150))
                    draw.rectangle([wx, wy, wx + 4, wy + 8], fill=fill)
        x += b_width + rng.randrange(2, 12)

    # Wet playable plane and reflections.
    draw.rectangle([0, horizon, width, height], fill=(3, 5, 12, 150))
    for _ in range(95):
        y = rng.randrange(horizon + 18, height)
        length = rng.randrange(40, 220)
        x0 = rng.randrange(-40, width)
        color = rng.choice([CYAN, MAGENTA, AMBER])
        draw.line([(x0, y), (x0 + length, y + rng.randrange(-2, 3))], fill=(*color, rng.randrange(18, 70)), width=rng.randrange(1, 3))

    draw_location_detail(img, draw, rng, record["id"], horizon)
    draw_rain(img, rng, count=max(260, width * height // 3600))
    draw_scanlines(img, alpha=16, step=5)
    return img.convert("RGB")


def draw_detective_office_background(size: tuple[int, int], rng: random.Random) -> Image.Image:
    width, height = size
    img = vertical_gradient(size, (8, 10, 20), (18, 9, 18)).convert("RGBA")
    draw = ImageDraw.Draw(img, "RGBA")

    # Back wall and window blinds.
    draw.rectangle([0, 0, width, int(height * 0.64)], fill=(9, 11, 22, 235))
    window = [int(width * 0.58), 42, width - 80, int(height * 0.56)]
    draw.rectangle(window, fill=(5, 8, 18, 245), outline=(*CYAN, 180), width=3)
    for y in range(window[1] + 22, window[3] - 12, 18):
        draw.line([(window[0] + 8, y), (window[2] - 8, y)], fill=(150, 230, 255, 55), width=2)
    for _ in range(45):
        x = rng.randrange(window[0] + 10, window[2] - 10)
        y = rng.randrange(window[1] + 10, window[3] - 10)
        color = rng.choice([CYAN, MAGENTA, AMBER, GREEN])
        draw.rectangle([x, y, x + rng.randrange(3, 8), y + rng.randrange(12, 28)], fill=(*color, rng.randrange(80, 180)))

    # Neon spill through the blinds.
    glow_line(img, [(window[0] + 42, window[1] + 20), (window[0] + 42, window[3] + 70)], CYAN, width=3, glow=18)
    glow_line(img, [(window[2] - 70, window[1] + 80), (window[2] - 70, window[3] + 40)], MAGENTA, width=2, glow=15)

    # Floor.
    floor_y = int(height * 0.64)
    draw.rectangle([0, floor_y, width, height], fill=(6, 7, 12, 245))
    for y in range(floor_y + 20, height, 38):
        draw.line([(0, y), (width, y + rng.randrange(-5, 6))], fill=(60, 90, 110, 35), width=2)
    for x in range(0, width, 140):
        draw.line([(x, floor_y), (x - 210, height)], fill=(120, 210, 235, 22), width=2)

    # Desk, terminal and case board.
    desk = [int(width * 0.10), int(height * 0.56), int(width * 0.55), int(height * 0.80)]
    draw.rounded_rectangle(desk, radius=10, fill=(14, 13, 19, 245), outline=(*CYAN, 130), width=3)
    draw.rectangle([desk[0] + 24, desk[1] - 78, desk[0] + 210, desk[1] + 10], fill=(5, 10, 18, 230), outline=(*CYAN, 210), width=3)
    glow_line(img, [(desk[0] + 42, desk[1] - 22), (desk[0] + 190, desk[1] - 22)], CYAN, width=2, glow=10)
    draw.rectangle([desk[0] + 260, desk[1] - 110, desk[0] + 380, desk[1] - 20], fill=(25, 22, 18, 230), outline=(*AMBER, 140), width=2)
    for i in range(5):
        y = desk[1] - 94 + i * 15
        draw.line([(desk[0] + 276, y), (desk[0] + 360, y)], fill=(230, 210, 150, 80), width=2)

    board = [70, 86, int(width * 0.42), int(height * 0.43)]
    draw.rounded_rectangle(board, radius=8, fill=(12, 16, 22, 225), outline=(*MAGENTA, 170), width=3)
    for _ in range(11):
        px = rng.randrange(board[0] + 24, board[2] - 70)
        py = rng.randrange(board[1] + 20, board[3] - 44)
        note_color = rng.choice([(210, 225, 210), (220, 210, 160), (190, 220, 235)])
        draw.rectangle([px, py, px + 48, py + 34], fill=(*note_color, 165), outline=(0, 0, 0, 70), width=1)
    for _ in range(8):
        x0 = rng.randrange(board[0] + 30, board[2] - 50)
        y0 = rng.randrange(board[1] + 30, board[3] - 40)
        x1 = rng.randrange(board[0] + 30, board[2] - 50)
        y1 = rng.randrange(board[1] + 30, board[3] - 40)
        draw.line([(x0, y0), (x1, y1)], fill=(*MAGENTA, 95), width=2)

    # Foreground silhouettes and rain reflections.
    draw.rectangle([int(width * 0.64), int(height * 0.67), int(width * 0.92), int(height * 0.72)], fill=(14, 10, 14, 230))
    draw.ellipse([int(width * 0.72), int(height * 0.61), int(width * 0.82), int(height * 0.77)], fill=(5, 6, 10, 220))
    for _ in range(42):
        y = rng.randrange(floor_y + 14, height - 8)
        x = rng.randrange(0, width)
        color = rng.choice([CYAN, MAGENTA, AMBER])
        draw.line([(x, y), (x + rng.randrange(35, 180), y + rng.randrange(-2, 3))], fill=(*color, rng.randrange(24, 70)), width=2)

    draw_scanlines(img, alpha=14, step=5)
    return img.convert("RGB")


def draw_location_detail(img: Image.Image, draw: ImageDraw.ImageDraw, rng: random.Random, loc_id: str, horizon: int) -> None:
    width, height = img.size
    accent = CYAN if seed_for(loc_id) % 2 == 0 else MAGENTA

    if "office" in loc_id:
        draw.rectangle([80, horizon - 70, width - 80, horizon + 24], fill=(4, 8, 18, 170))
        glow_rect(img, [130, horizon - 150, 360, horizon - 30], CYAN, radius=3, fill_alpha=12)
        glow_rect(img, [width - 360, horizon - 145, width - 120, horizon - 28], MAGENTA, radius=3, fill_alpha=12)
        draw.rectangle([width * 0.36, horizon - 15, width * 0.64, horizon + 68], fill=(6, 8, 14, 230))
    elif "apartment" in loc_id:
        for i in range(4):
            x0 = 120 + i * 220
            glow_rect(img, [x0, horizon - 220, x0 + 130, horizon - 60], CYAN if i % 2 else MAGENTA, radius=2, fill_alpha=10)
        draw.rectangle([width - 260, horizon - 45, width - 40, horizon + 45], fill=(9, 7, 13, 220))
    elif "bar" in loc_id or "cafe" in loc_id:
        draw.rectangle([60, horizon - 30, width - 60, horizon + 64], fill=(8, 5, 12, 230))
        for i in range(8):
            x = 90 + i * (width - 180) // 8
            glow_rect(img, [x, horizon - 210, x + 70, horizon - 120], rng.choice([CYAN, MAGENTA, AMBER]), radius=10, fill_alpha=18)
    elif "warehouse" in loc_id or "sewer" in loc_id:
        for i in range(5):
            x = 70 + i * 250
            draw.rectangle([x, horizon - 130, x + 110, horizon + 12], fill=(9, 13, 16, 210))
            glow_line(img, [(x + 12, horizon - 125), (x + 100, horizon - 125)], CYAN, width=2, glow=9)
        for y in range(horizon - 190, horizon - 50, 38):
            glow_line(img, [(0, y), (width, y + rng.randrange(-20, 20))], accent, width=1, glow=7)
    elif "lab" in loc_id or "echo" in loc_id or "memory" in loc_id:
        cx, cy = width // 2, horizon - 70
        for radius in range(70, 300, 55):
            draw.arc([cx - radius, cy - radius, cx + radius, cy + radius], start=rng.randrange(180), end=360, fill=(*accent, 150), width=3)
        for i in range(10):
            angle = i * math.tau / 10
            x = cx + int(math.cos(angle) * rng.randrange(90, 280))
            y = cy + int(math.sin(angle) * rng.randrange(40, 150))
            glow_line(img, [(cx, cy), (x, y)], rng.choice([CYAN, MAGENTA, GREEN]), width=2, glow=10)
    elif "rooftop" in loc_id or "street" in loc_id or "exterior" in loc_id:
        for i in range(7):
            x = rng.randrange(0, width)
            glow_line(img, [(x, horizon - rng.randrange(190, 330)), (x + rng.randrange(-40, 40), height)], rng.choice([CYAN, MAGENTA]), width=2, glow=14)
        draw.rectangle([0, horizon + 35, width, horizon + 55], fill=(4, 6, 12, 240))
    else:
        glow_rect(img, [width // 2 - 180, horizon - 170, width // 2 + 180, horizon - 30], accent, radius=6, fill_alpha=10)


def draw_item_background(size: tuple[int, int], rng: random.Random) -> Image.Image:
    img = vertical_gradient(size, (7, 10, 22), (16, 8, 24)).convert("RGBA")
    width, height = size
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for radius, alpha in [(210, 22), (150, 28), (88, 35)]:
        color = rng.choice([CYAN, MAGENTA, GREEN])
        draw.ellipse([width // 2 - radius, height // 2 - radius, width // 2 + radius, height // 2 + radius], outline=(*color, alpha), width=3)
    overlay(img, layer, blur=4)
    return img


def draw_chip(draw, box, color):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=18, fill=(18, 24, 38, 235), outline=(*color, 235), width=5)
    for i in range(7):
        x = x0 + 36 + i * ((x1 - x0 - 72) // 6)
        draw.line([(x, y0 - 16), (x, y0 + 16)], fill=(*color, 180), width=4)
        draw.line([(x, y1 - 16), (x, y1 + 16)], fill=(*color, 180), width=4)
    for i in range(5):
        y = y0 + 35 + i * ((y1 - y0 - 70) // 4)
        draw.line([(x0 + 36, y), (x1 - 36, y)], fill=(*color, 95), width=3)
    draw.rectangle([x0 + 82, y0 + 76, x1 - 82, y1 - 76], outline=(*color, 210), width=4)


def draw_document(draw, box, color, folded: bool = True):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=12, fill=(215, 232, 236, 235), outline=(*color, 230), width=5)
    if folded:
        draw.polygon([(x1 - 70, y0), (x1, y0 + 70), (x1 - 70, y0 + 70)], fill=(140, 170, 184, 240), outline=(*color, 220))
    for i in range(7):
        y = y0 + 70 + i * 31
        draw.line([(x0 + 42, y), (x1 - 54 - (i % 3) * 26, y)], fill=(14, 30, 42, 145), width=6)
    draw.rectangle([x0 + 42, y1 - 86, x0 + 146, y1 - 42], outline=(*MAGENTA, 190), width=4)


def draw_book(draw, box, color):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=18, fill=(16, 18, 30, 245), outline=(*color, 235), width=5)
    draw.line([(x0 + 34, y0 + 24), (x0 + 34, y1 - 24)], fill=(*MAGENTA, 210), width=6)
    for i in range(4):
        draw.line([(x0 + 72, y0 + 70 + i * 44), (x1 - 54, y0 + 70 + i * 44)], fill=(*color, 110), width=5)
    draw.polygon([(x1 - 92, y0 + 40), (x1 - 42, y0 + 90), (x1 - 92, y0 + 140)], outline=(*GREEN, 180), fill=(0, 0, 0, 0))


def draw_key(draw, box, color):
    x0, y0, x1, y1 = box
    cy = (y0 + y1) // 2
    draw.ellipse([x0, cy - 58, x0 + 116, cy + 58], outline=(*color, 240), width=13, fill=(28, 31, 34, 230))
    draw.line([(x0 + 108, cy), (x1 - 38, cy)], fill=(*color, 235), width=22)
    draw.rectangle([x1 - 102, cy, x1 - 82, cy + 58], fill=(*color, 230))
    draw.rectangle([x1 - 62, cy, x1 - 42, cy + 40], fill=(*color, 230))


def draw_waveform(draw, box, color):
    x0, y0, x1, y1 = box
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    draw.ellipse([cx - 58, cy - 58, cx + 58, cy + 58], fill=(16, 22, 34, 240), outline=(*color, 240), width=6)
    for r in [95, 135, 175]:
        draw.arc([cx - r, cy - r, cx + r, cy + r], start=215, end=325, fill=(*color, 190), width=8)
        draw.arc([cx - r, cy - r, cx + r, cy + r], start=35, end=145, fill=(*MAGENTA, 150), width=5)
    points = []
    for i in range(18):
        x = x0 + 32 + i * ((x1 - x0 - 64) // 17)
        y = cy + int(math.sin(i * 0.85) * 42)
        points.append((x, y))
    draw.line(points, fill=(*GREEN, 230), width=5)


def draw_map(draw, box, color):
    x0, y0, x1, y1 = box
    third = (x1 - x0) // 3
    folds = [(x0, y0, x0 + third, y1), (x0 + third, y0 + 26, x0 + 2 * third, y1 - 20), (x0 + 2 * third, y0, x1, y1)]
    for i, rect in enumerate(folds):
        draw.polygon([(rect[0], rect[1] + 25), (rect[2], rect[1]), (rect[2], rect[3] - 25), (rect[0], rect[3])], fill=(21 + i * 12, 34 + i * 9, 42 + i * 10, 235), outline=(*color, 200))
    for i in range(6):
        y = y0 + 55 + i * 32
        draw.line([(x0 + 32, y), (x1 - 34, y + (i % 2) * 28 - 14)], fill=(*MAGENTA, 160), width=5)
    draw.ellipse([x0 + 170, y0 + 110, x0 + 214, y0 + 154], fill=(*GREEN, 220))


def draw_capsule(draw, box, color):
    x0, y0, x1, y1 = box
    cx = (x0 + x1) // 2
    draw.rounded_rectangle([cx - 58, y0 + 8, cx + 58, y1 - 8], radius=58, fill=(16, 35, 44, 150), outline=(*color, 235), width=6)
    draw.rectangle([cx - 56, (y0 + y1) // 2, cx + 56, y1 - 64], fill=(*MAGENTA, 75))
    for i in range(5):
        y = y0 + 70 + i * 45
        draw.line([(cx - 92, y), (cx + 92, y + 10)], fill=(*GREEN, 130), width=3)
    draw.ellipse([cx - 23, (y0 + y1) // 2 - 23, cx + 23, (y0 + y1) // 2 + 23], fill=(*color, 230))


def draw_photo(draw, box, color):
    x0, y0, x1, y1 = box
    draw.rectangle(box, fill=(226, 232, 226, 235), outline=(*color, 230), width=6)
    inner = [x0 + 34, y0 + 34, x1 - 34, y1 - 74]
    draw.rectangle(inner, fill=(12, 21, 36, 240))
    draw.ellipse([inner[0] + 80, inner[1] + 42, inner[0] + 155, inner[1] + 117], fill=(*MAGENTA, 110))
    draw.polygon([(inner[0] + 30, inner[3]), (inner[0] + 150, inner[2] - 30), (inner[0] + 300, inner[3])], fill=(*CYAN, 90))
    draw.line([(x0 + 44, y1 - 42), (x1 - 44, y1 - 42)], fill=(20, 32, 42, 160), width=6)


def draw_default_artifact(draw, box, color):
    x0, y0, x1, y1 = box
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    points = []
    for i in range(6):
        angle = math.tau * i / 6 + math.pi / 6
        points.append((cx + int(math.cos(angle) * 130), cy + int(math.sin(angle) * 130)))
    draw.polygon(points, fill=(16, 22, 36, 235), outline=(*color, 235))
    for p in points:
        draw.line([(cx, cy), p], fill=(*MAGENTA, 120), width=4)
    draw.ellipse([cx - 42, cy - 42, cx + 42, cy + 42], fill=(*color, 210))


def draw_item_icon(record: dict) -> Image.Image:
    size = parse_size(record.get("target_size", "512x512"))
    rng = random.Random(seed_for(record["output_path"]))
    img = draw_item_background(size, rng)
    draw = ImageDraw.Draw(img, "RGBA")
    width, height = size
    key = f"{record.get('id', '')} {record.get('icon', '')}".lower()
    accent = rng.choice([CYAN, MAGENTA, AMBER, GREEN])

    # Soft shadow.
    draw.ellipse([width * 0.24, height * 0.75, width * 0.76, height * 0.87], fill=(0, 0, 0, 110))
    box = [int(width * 0.22), int(height * 0.17), int(width * 0.78), int(height * 0.75)]

    if any(token in key for token in ["chip", "data", "id", "keycard", "ai"]):
        draw_chip(draw, box, accent)
    elif any(token in key for token in ["letter", "receipt", "report", "memo", "list", "order", "funding"]):
        draw_document(draw, box, accent)
    elif any(token in key for token in ["diary", "journal", "log", "ledger"]):
        draw_book(draw, box, accent)
    elif "key" in key:
        draw_key(draw, [int(width * 0.17), int(height * 0.3), int(width * 0.83), int(height * 0.68)], accent)
    elif any(token in key for token in ["recording", "comms", "frequency", "sos"]):
        draw_waveform(draw, box, accent)
    elif "map" in key:
        draw_map(draw, box, accent)
    elif any(token in key for token in ["photo", "profiles"]):
        draw_photo(draw, box, accent)
    elif any(token in key for token in ["memory", "sample", "fragment", "capsule", "authorization"]):
        draw_capsule(draw, box, accent)
    else:
        draw_default_artifact(draw, box, accent)

    glow_line(img, [(width * 0.18, height * 0.86), (width * 0.82, height * 0.86)], accent, width=2, glow=18)
    draw_scanlines(img, alpha=14, step=5)
    return img.convert("RGB")


def draw_ui_asset(record: dict) -> Image.Image:
    size = parse_size(record.get("target_size", record["size"]))
    rng = random.Random(seed_for(record["id"]))
    img = vertical_gradient(size, (5, 7, 17), (13, 8, 20)).convert("RGBA")
    draw = ImageDraw.Draw(img, "RGBA")
    width, height = size
    asset_id = record["id"]

    if asset_id == "dialogue_panel":
        glow_rect(img, [18, 18, width - 18, height - 18], CYAN, radius=16, width=3, glow=18, fill_alpha=18)
        glow_rect(img, [36, 34, 180, height - 34], MAGENTA, radius=10, width=2, glow=12, fill_alpha=10)
        for y in range(62, height - 38, 34):
            draw.line([(220, y), (width - 54, y)], fill=(150, 245, 255, 55), width=2)
    elif asset_id == "evidence_card":
        glow_rect(img, [22, 22, width - 22, height - 22], CYAN, radius=12, width=4, glow=18, fill_alpha=20)
        glow_rect(img, [50, 52, width - 50, 142], MAGENTA, radius=8, width=2, glow=10, fill_alpha=12)
        for i in range(5):
            y = 180 + i * 34
            draw.line([(58, y), (width - 64 - i * 24, y)], fill=(170, 235, 245, 55), width=3)
    elif asset_id == "popup_panel":
        glow_rect(img, [36, 36, width - 36, height - 36], MAGENTA, radius=18, width=4, glow=22, fill_alpha=18)
        for i in range(4):
            y0 = 150 + i * 115
            glow_rect(img, [92, y0, width - 92, y0 + 72], CYAN if i % 2 else MAGENTA, radius=8, width=2, glow=10, fill_alpha=8)
    elif asset_id == "toolbar_buttons":
        cols = 6
        pad = 22
        slot_w = (width - pad * (cols + 1)) // cols
        for i in range(cols):
            x0 = pad + i * (slot_w + pad)
            y0 = 46
            color = [CYAN, MAGENTA, GREEN, AMBER, CYAN, MAGENTA][i]
            glow_rect(img, [x0, y0, x0 + slot_w, height - 46], color, radius=12, width=3, glow=12, fill_alpha=16)
            cx = x0 + slot_w // 2
            cy = height // 2
            draw.ellipse([cx - 22, cy - 22, cx + 22, cy + 22], outline=(*color, 210), width=5)
            draw.line([(cx - 42, cy), (cx + 42, cy)], fill=(*color, 120), width=3)
    elif asset_id == "memory_preview_overlay":
        for _ in range(46):
            x0 = rng.randrange(0, width)
            y0 = rng.randrange(0, height)
            w = rng.randrange(80, 320)
            h = rng.randrange(4, 22)
            color = rng.choice([CYAN, MAGENTA, GREEN])
            draw.rectangle([x0, y0, min(width, x0 + w), min(height, y0 + h)], fill=(*color, rng.randrange(20, 65)))
        for i in range(11):
            y = int(height * (i + 1) / 12)
            glow_line(img, [(0, y), (width, y + rng.randrange(-18, 18))], rng.choice([CYAN, MAGENTA]), width=1, glow=9)
    else:
        glow_rect(img, [24, 24, width - 24, height - 24], rng.choice([CYAN, MAGENTA]), radius=12, width=3, glow=16, fill_alpha=16)

    draw_scanlines(img, alpha=20, step=4)
    return img.convert("RGB")


def save_asset(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


def render_all() -> dict[str, int]:
    counts = {"backgrounds": 0, "items": 0, "ui": 0}
    for record in load_jsonl(BACKGROUND_MANIFEST):
        save_asset(draw_city_background(record), output_path(record))
        counts["backgrounds"] += 1

    for record in load_jsonl(ITEM_MANIFEST):
        save_asset(draw_item_icon(record), output_path(record))
        counts["items"] += 1

    for record in load_jsonl(UI_MANIFEST):
        save_asset(draw_ui_asset(record), output_path(record))
        counts["ui"] += 1

    return counts


def main() -> None:
    counts = render_all()
    print(" ".join(f"{key}={value}" for key, value in counts.items()))


if __name__ == "__main__":
    main()
