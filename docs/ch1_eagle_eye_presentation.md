# Chapter 1 Eagle Eye Presentation

Date: 2026-04-27

## Scope

This iteration wires Chapter 1 eagle-eye presentation as prompt-ready and runtime fallback-ready. PNG runtime targets are connected; OGG targets remain optional and are skipped safely until formal audio is generated.

## Prompt Manifest

Runtime prompt records live in:

```text
assets/generated/prompts/image2_ch1_eagle_eye.jsonl
```

The manifest includes runtime target paths for:

- `assets/sprites/ui/eagle_eye_scan_overlay_ch1.png`
- `assets/sprites/locations/variants/mei_ling_apartment_eye_scan_variant.png`
- `assets/sprites/items/broken_memory_player.png`
- `assets/sprites/items/kai_eye_glitch_log.png`
- `assets/audio/sfx/eagle_eye_glitch_sting.ogg`
- `assets/audio/sfx/broken_player_scan.ogg`
- `assets/audio/sfx/memory_signature_reveal.ogg`

The audio replacement prompts are also mirrored in:

```text
assets/generated/prompts/audio_ch1_replacement_prompts.jsonl
```

## Runtime Wiring

- `AugmentedVision` creates its overlay, energy bar, scan label, focus reticle, and mobile toggle at runtime.
- Missing `eagle_eye_scan_overlay_ch1.png` falls back to the scanline shader plus cyan tint.
- `LocationBase` mounts `AugmentedVision` automatically for location scenes.
- The toolbar eagle-eye button calls `AugmentedVision.toggle()`.
- Mei Ling apartment can use `mei_ling_apartment_eye_scan_variant.png` while eagle-eye mode is active. If that PNG is absent, the normal background stays active.
- `broken_memory_player` and `kai_eye_glitch_log` prefer dedicated item icons. If those PNGs are absent, they fall back to `memory_capsule.png` and `log.png`.

## Validation

```powershell
python tests\test_eagle_eye_presentation.py --score
python tests\test_story_progression.py --score
python tests\test_data_integrity.py
```

Acceptance for this round:

- Eagle-eye presentation score increases from the Round 1 baseline.
- Story progression score stays at `400` or higher.
- Data integrity passes.
- Godot headless project load exits normally.

## Next Asset Pass

Generate and copy the real assets into the runtime target paths above, then re-run the validation commands and capture screenshots of eagle-eye mode in `mei_ling_apartment`.
Audio files must be valid OGG Vorbis streams beginning with `OggS`; placeholder marker files are intentionally skipped by `AudioManager.play_optional_sfx()`.
