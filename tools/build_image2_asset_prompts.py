#!/usr/bin/env python3
"""
Build image2.0-ready prompts for NEON MEMORIES environment assets.

Outputs JSONL manifests for location backgrounds, evidence item icons, and UI
reference assets. The manifests are source-controlled so image generation can be
re-run without rediscovering the game's visual direction.
"""

import json
import os
import re
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PROMPT_DIR = PROJECT_ROOT / "assets" / "generated" / "prompts"
DOC_PATH = PROJECT_ROOT / "docs" / "asset_generation_prompts.md"

STYLE_CORE = (
    "NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired "
    "Kowloon extension district, rain-soaked neon, cinematic 2D game asset, "
    "readable silhouettes, strong cyan and magenta accents, dark concrete and "
    "glass, high detail but not photorealistic, no text, no logos"
)

NEGATIVE = (
    "no characters, no readable text, no watermark, no real brand logos, no UI "
    "mockup labels, no blurry details, no low resolution, no extra frames"
)

UI_NEGATIVE = (
    "no readable text, no watermark, no real brand logos, no rounded marketing "
    "cards, no fantasy ornament, no low contrast"
)

UI_ASSETS = [
    {
        "id": "dialogue_panel",
        "name": "Dialogue panel frame",
        "size": "1536x1024",
        "target_size": "1280x240",
        "output_path": "assets/sprites/ui/dialogue_panel.png",
        "description": "bottom dialogue box frame with portrait-safe side margins",
    },
    {
        "id": "evidence_card",
        "name": "Evidence board card",
        "size": "1024x1024",
        "target_size": "512x384",
        "output_path": "assets/sprites/ui/evidence_card.png",
        "description": "draggable clue card frame with cyan border and dark glass surface",
    },
    {
        "id": "popup_panel",
        "name": "Map and investigation popup panel",
        "size": "1024x1024",
        "target_size": "768x768",
        "output_path": "assets/sprites/ui/popup_panel.png",
        "description": "modal panel background for map and investigation choices",
    },
    {
        "id": "toolbar_buttons",
        "name": "Toolbar button kit",
        "size": "1536x1024",
        "target_size": "1024x256",
        "output_path": "assets/sprites/ui/toolbar_buttons.png",
        "description": "six reusable cyberpunk button states for map, eye, evidence, investigate, hint, menu",
    },
    {
        "id": "memory_preview_overlay",
        "name": "Memory preview overlay",
        "size": "1280x720",
        "target_size": "1280x720",
        "output_path": "assets/sprites/ui/memory_preview_overlay.png",
        "description": "glitchy translucent overlay for fragmented memory playback",
    },
]


def read_text(rel_path: str) -> str:
    return (PROJECT_ROOT / rel_path).read_text(encoding="utf-8")


def find_matching(text: str, start: int, opener: str, closer: str) -> int:
    depth = 0
    in_string = False
    escaped = False
    for index in range(start, len(text)):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char == opener:
            depth += 1
        elif char == closer:
            depth -= 1
            if depth == 0:
                return index
    return -1


def extract_block(text: str, key: str) -> str:
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\{{', text)
    if not match:
        return ""
    start = text.find("{", match.start())
    end = find_matching(text, start, "{", "}")
    return text[start : end + 1] if end != -1 else ""


def extract_value(block: str, key: str) -> str:
    match = re.search(rf'"{re.escape(key)}"\s*:\s*"([^"]*)"', block)
    return match.group(1) if match else ""


def extract_locations(case_content: str):
    location_ids = [
        "detective_office",
        "mei_ling_apartment",
        "abyss_bar",
        "hao_ran_workshop",
        "east_district_street",
        "bitstorm_cafe",
        "memory_black_market",
        "abandoned_warehouse",
        "zhengtek_exterior",
        "sewer_passage",
        "echo_network_hq",
        "secret_lab",
        "memory_space",
        "rooftop",
        "office_epilogue",
    ]
    for location_id in location_ids:
        block = extract_block(case_content, location_id)
        yield {
            "id": location_id,
            "name": extract_value(block, "name"),
            "description": extract_value(block, "description"),
            "output_path": f"assets/sprites/locations/{location_id}.png",
            "size": "1280x720",
            "target_size": "1280x720",
        }


def extract_evidence(evidence_content: str):
    for match in re.finditer(r'^\s*"(\w+)"\s*:\s*\{', evidence_content, re.MULTILINE):
        evidence_id = match.group(1)
        block = extract_block(evidence_content, evidence_id)
        icon = extract_value(block, "icon") or evidence_id
        yield {
            "id": evidence_id,
            "icon": icon,
            "name": extract_value(block, "name"),
            "description": extract_value(block, "description"),
            "output_path": f"assets/sprites/items/{icon}.png",
            "size": "1024x1024",
            "target_size": "512x512",
        }


def location_prompt(asset):
    return (
        f"{STYLE_CORE}. Full-screen parallax-ready background for location "
        f"'{asset['name']}' ({asset['id']}): {asset['description']}. "
        "Wide establishing shot, empty playable scene, clear foreground/midground/background layers, "
        "soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI."
    )


def item_prompt(asset):
    return (
        f"{STYLE_CORE}. Opaque-background evidence item icon for '{asset['name']}' "
        f"({asset['id']}): {asset['description']}. Centered object, 3/4 view, crisp silhouette, "
        "cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, "
        "isolated on a clean dark gunmetal studio background with a soft contact shadow."
    )


def ui_prompt(asset):
    return (
        f"{STYLE_CORE}. UI reference asset: {asset['name']} ({asset['id']}), {asset['description']}. "
        "Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, "
        "mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset."
    )


def write_jsonl(path: Path, records):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as f:
        for record in records:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")


def build_records():
    case_content = read_text("scripts/data/case_data.gd")
    evidence_content = read_text("scripts/data/evidence_data.gd")

    backgrounds = []
    for asset in extract_locations(case_content):
        backgrounds.append({
            **asset,
            "model": "gpt-image-2",
            "category": "background",
            "out": Path(asset["output_path"]).name,
            "output_format": "png",
            "background": "opaque",
            "quality": "medium",
            "prompt": location_prompt(asset),
            "negative_prompt": NEGATIVE,
        })

    items = []
    seen_outputs = set()
    for asset in extract_evidence(evidence_content):
        if asset["output_path"] in seen_outputs:
            continue
        seen_outputs.add(asset["output_path"])
        items.append({
            **asset,
            "model": "gpt-image-2",
            "category": "item",
            "out": Path(asset["output_path"]).name,
            "output_format": "png",
            "background": "opaque",
            "quality": "medium",
            "prompt": item_prompt(asset),
            "negative_prompt": NEGATIVE,
        })

    ui = []
    for asset in UI_ASSETS:
        ui.append({
            **asset,
            "model": "gpt-image-2",
            "category": "ui",
            "out": Path(asset["output_path"]).name,
            "output_format": "png",
            "background": "opaque",
            "quality": "medium",
            "prompt": ui_prompt(asset),
            "negative_prompt": UI_NEGATIVE,
        })

    return backgrounds, items, ui


def write_markdown(backgrounds, items, ui):
    lines = [
        "# NEON MEMORIES image2.0 Asset Prompts",
        "",
        "These prompts are generated from game data and are intended for image2.0-style batch generation.",
        "",
        "## Generation Defaults",
        "",
        "- Backgrounds: generate at `1280x720`, output to `assets/sprites/locations/*.png`.",
        "- Evidence items: generate at `1024x1024` on opaque image2-compatible backgrounds, then downscale/crop to `512x512` if needed.",
        "- UI references: generate on opaque image2-compatible canvases, output to `assets/sprites/ui/*.png`.",
        "- Runtime loaders prefer PNG and keep existing SVG as fallback.",
        "",
        "## Backgrounds",
        "",
    ]
    for asset in backgrounds:
        lines.extend([
            f"### {asset['id']} - {asset['name']}",
            "",
            f"- Output: `{asset['output_path']}`",
            f"- Canvas: `{asset['size']}`; target: `{asset['target_size']}`",
            f"- Prompt: {asset['prompt']}",
            f"- Negative: {asset['negative_prompt']}",
            "",
        ])

    lines.append("## Evidence Items")
    lines.append("")
    for asset in items:
        lines.extend([
            f"### {asset['icon']} - {asset['name']}",
            "",
            f"- Output: `{asset['output_path']}`",
            f"- Canvas: `{asset['size']}`; target: `{asset['target_size']}`",
            f"- Prompt: {asset['prompt']}",
            f"- Negative: {asset['negative_prompt']}",
            "",
        ])

    lines.append("## UI")
    lines.append("")
    for asset in ui:
        lines.extend([
            f"### {asset['id']} - {asset['name']}",
            "",
            f"- Output: `{asset['output_path']}`",
            f"- Canvas: `{asset['size']}`; target: `{asset['target_size']}`",
            f"- Prompt: {asset['prompt']}",
            f"- Negative: {asset['negative_prompt']}",
            "",
        ])

    DOC_PATH.parent.mkdir(parents=True, exist_ok=True)
    DOC_PATH.write_text("\n".join(lines), encoding="utf-8", newline="\n")


def main():
    backgrounds, items, ui = build_records()
    write_jsonl(PROMPT_DIR / "image2_backgrounds.jsonl", backgrounds)
    write_jsonl(PROMPT_DIR / "image2_items.jsonl", items)
    write_jsonl(PROMPT_DIR / "image2_ui.jsonl", ui)
    write_markdown(backgrounds, items, ui)
    print(f"backgrounds={len(backgrounds)} items={len(items)} ui={len(ui)}")


if __name__ == "__main__":
    main()
