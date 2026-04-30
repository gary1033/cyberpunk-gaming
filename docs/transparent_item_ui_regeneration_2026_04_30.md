# 2026-04-30 Transparent Item and UI Regeneration

## Completed Scope

- Regenerated all 42 runtime item PNGs under `assets/sprites/items/` as transparent `512x512` RGBA assets.
- Regenerated overlay UI assets under `assets/sprites/ui/`, excluding `main_menu_background.png`.
- Preserved source copies under `assets/generated/items/ch1_` and `assets/generated/ui/`.

## Manifests

```text
assets/generated/prompts/image_gen_items_transparent_2026_04_30.jsonl
assets/generated/prompts/image_gen_ui_transparent_2026_04_30.jsonl
```

## Validation

`tests/test_data_integrity.py` now checks:

- generated-source and runtime PNGs match by SHA-256
- item icons are `512x512` RGBA
- overlay UI assets keep their expected runtime dimensions
- transparent assets have transparent corners and real transparent pixels

`main_menu_background.png` remains a full-screen background and is intentionally excluded from the transparent overlay UI set.
