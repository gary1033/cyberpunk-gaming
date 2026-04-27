#!/usr/bin/env python3
"""Slice generated character reference sheets into runtime portrait PNGs."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = PROJECT_ROOT / "assets" / "generated" / "characters" / "reference_sheets"
OUTPUT_DIR = PROJECT_ROOT / "assets" / "sprites" / "characters"
TARGET_SIZE = (256, 384)
BACKGROUND_MIN_CHANNEL = 225
BACKGROUND_MAX_SPREAD = 35


SHEETS = {
    "kai": {
        "source": "01_kai_kawasaki_reference_sheet.png",
        "boxes": [
            (897, 39, 1108, 324),
            (1106, 35, 1302, 323),
            (1297, 35, 1493, 323),
            (1474, 43, 1662, 323),
        ],
        "moods": {
            "default": 0,
            "serious": 1,
            "surprised": 2,
            "thoughtful": 3,
        },
    },
    "mei_ling": {
        "source": "02_mei_ling_lin_reference_sheet.png",
        "boxes": [
            (1080, 48, 1265, 282),
            (1268, 48, 1454, 282),
            (1458, 48, 1644, 282),
            (1080, 312, 1270, 528),
            (1272, 312, 1454, 528),
        ],
        "moods": {
            "default": 0,
            "worried": 1,
            "nervous": 2,
            "relieved": 3,
            "frightened": 4,
        },
    },
    "ajie": {
        "source": "03_ajie_reference_sheet.png",
        "boxes": [
            (21, 614, 203, 817),
            (208, 614, 390, 817),
            (399, 614, 589, 817),
            (599, 614, 778, 817),
            (786, 614, 979, 817),
        ],
        "moods": {
            "default": 0,
            "suspicious": 1,
            "nervous": 2,
            "angry": 3,
            "cooperative": 4,
        },
    },
    "snake": {
        "source": "04_snake_reference_sheet.png",
        "boxes": [
            (288, 713, 390, 909),
            (394, 713, 497, 909),
            (501, 713, 603, 909),
            (607, 713, 708, 909),
        ],
        "moods": {
            "default": 0,
            "amused": 1,
            "serious": 2,
            "threatening": 3,
        },
    },
    "dr_chen": {
        "source": "05_dr_chen_reference_sheet.png",
        "boxes": [
            (990, 58, 1168, 292),
            (1174, 58, 1336, 292),
            (1340, 58, 1492, 292),
            (1500, 58, 1658, 292),
        ],
        "moods": {
            "default": 0,
            "nervous": 1,
            "frightened": 2,
            "relieved": 3,
        },
    },
    "ghost": {
        "source": "06_ghost_reference_sheet.png",
        "boxes": [
            (914, 90, 1069, 486),
            (1086, 90, 1246, 486),
            (1300, 94, 1447, 486),
            (1500, 92, 1627, 486),
        ],
        "moods": {
            "default": 0,
            "hostile": 1,
            "cautious": 2,
            "revealed": 3,
        },
    },
    "zhao_ming": {
        "source": "07_zhao_ming_reference_sheet.png",
        "boxes": [
            (1122, 56, 1286, 230),
            (1294, 56, 1470, 230),
            (1478, 56, 1644, 230),
            (1122, 278, 1286, 455),
            (1294, 278, 1470, 455),
            (1478, 278, 1644, 455),
        ],
        "moods": {
            "default": 0,
            "conflicted": 1,
            "nervous": 2,
            "determined": 3,
            "sincere": 4,
            "sad": 5,
        },
    },
    "kid": {
        "source": "08_kid_reference_sheet.png",
        "boxes": [
            (1190, 48, 1356, 252),
            (1490, 48, 1660, 252),
            (1190, 294, 1356, 497),
            (1490, 294, 1660, 497),
        ],
        "moods": {
            "default": 0,
            "excited": 1,
            "serious": 2,
            "angry": 3,
        },
    },
    "mask_merchant": {
        "source": "09_mask_merchant_reference_sheet.png",
        "boxes": [
            (1108, 50, 1269, 267),
            (1282, 50, 1445, 267),
            (1457, 50, 1622, 267),
        ],
        "moods": {
            "default": 0,
            "interested": 1,
            "suspicious": 2,
        },
    },
    "dr_xiao": {
        "source": "10_dr_xiao_reference_sheet.png",
        "boxes": [
            (1108, 36, 1288, 289),
            (1289, 36, 1473, 289),
            (1475, 36, 1657, 289),
            (1108, 323, 1288, 581),
            (1289, 323, 1473, 581),
            (1475, 323, 1657, 581),
        ],
        "moods": {
            "default": 0,
            "calm": 1,
            "intense": 2,
            "philosophical": 3,
            "amused": 4,
            "cracking": 5,
        },
    },
    "hao_ran": {
        "source": "11_hao_ran_lin_reference_sheet.png",
        "boxes": [
            (982, 50, 1148, 285),
            (1149, 50, 1314, 285),
            (1315, 50, 1479, 285),
            (1480, 50, 1645, 285),
        ],
        "moods": {
            "default": 0,
            "dazed": 1,
            "confused": 2,
            "hopeful": 3,
        },
    },
    "echo_ai": {
        "source": "12_echo_ai_reference_sheet.png",
        "boxes": [
            (1088, 54, 1232, 308),
        ],
        "moods": {
            "default": 0,
        },
    },
}


def is_edge_background(red: int, green: int, blue: int) -> bool:
    return (
        min(red, green, blue) >= BACKGROUND_MIN_CHANNEL
        and max(red, green, blue) - min(red, green, blue) <= BACKGROUND_MAX_SPREAD
    )


def make_edge_background_transparent(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    seen = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in seen:
            continue
        seen.add((x, y))

        red, green, blue, _alpha = pixels[x, y]
        if not is_edge_background(red, green, blue):
            continue

        pixels[x, y] = (red, green, blue, 0)
        if x > 0:
            queue.append((x - 1, y))
        if x < width - 1:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y < height - 1:
            queue.append((x, y + 1))

    return rgba


def normalize_portrait(image: Image.Image) -> Image.Image:
    rgba = make_edge_background_transparent(image)
    alpha_bbox = rgba.getchannel("A").getbbox()
    if alpha_bbox:
        left, top, right, bottom = alpha_bbox
        margin = 8
        left = max(0, left - margin)
        top = max(0, top - margin)
        right = min(rgba.width, right + margin)
        bottom = min(rgba.height, bottom + margin)
        rgba = rgba.crop((left, top, right, bottom))

    scale = min(TARGET_SIZE[0] / rgba.width, TARGET_SIZE[1] / rgba.height)
    resized = rgba.resize(
        (max(1, int(rgba.width * scale)), max(1, int(rgba.height * scale))),
        Image.Resampling.LANCZOS,
    )

    canvas = Image.new("RGBA", TARGET_SIZE, (0, 0, 0, 0))
    paste_x = (TARGET_SIZE[0] - resized.width) // 2
    paste_y = TARGET_SIZE[1] - resized.height
    canvas.alpha_composite(resized, (paste_x, paste_y))
    return canvas


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    written = []

    for character_id, config in SHEETS.items():
        source_path = SOURCE_DIR / config["source"]
        if not source_path.exists():
            raise FileNotFoundError(f"Missing reference sheet: {source_path}")

        sheet = Image.open(source_path)
        boxes = config["boxes"]
        for mood, box_index in config["moods"].items():
            crop_box = boxes[box_index]
            portrait = normalize_portrait(sheet.crop(crop_box))
            output_path = OUTPUT_DIR / f"{character_id}_{mood}.png"
            portrait.save(output_path)
            written.append(output_path.relative_to(PROJECT_ROOT).as_posix())

    print(f"Wrote {len(written)} portrait PNGs")
    for rel_path in written:
        print(rel_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
