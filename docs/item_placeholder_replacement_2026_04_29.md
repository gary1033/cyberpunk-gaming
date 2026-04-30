# 2026-04-29 Item Placeholder Replacement

## Scope

The following simple line-art inventory icons were replaced with `image_gen` raster evidence icons:

| Runtime path | Generated source path |
|---|---|
| `assets/sprites/items/commission_letter.png` | `assets/generated/items/ch1_commission_letter.png` |
| `assets/sprites/items/work_id.png` | `assets/generated/items/ch1_work_id.png` |
| `assets/sprites/items/receipt.png` | `assets/generated/items/ch1_receipt.png` |
| `assets/sprites/items/data_chip.png` | `assets/generated/items/ch1_data_chip.png` |
| `assets/sprites/items/recording.png` | `assets/generated/items/ch1_recording.png` |
| `assets/sprites/items/photo.png` | `assets/generated/items/ch1_photo.png` |
| `assets/sprites/items/kai_eye_glitch_log.png` | `assets/generated/items/ch1_kai_eye_glitch_log.png` |
| `assets/sprites/items/family_memory_clip.png` | `assets/generated/items/ch1_family_memory_clip.png` |
| `assets/sprites/items/broken_memory_player.png` | `assets/generated/items/ch1_broken_memory_player.png` |

## Source

Built-in `image_gen` outputs were preserved under:

```text
C:\Users\gary1\.codex\generated_images\019dd9d0-2203-7111-bf16-de4b3b4cf98d
```

Prompt manifest:

```text
assets/generated/prompts/image_gen_placeholder_item_replacements_2026_04_29.jsonl
```

## Regression Guard

`tests/test_data_integrity.py` now verifies these icons as source/runtime pairs, checks `512x512` PNG dimensions, checks matching SHA-256, and rejects tiny placeholder-like files below `100_000` bytes.
