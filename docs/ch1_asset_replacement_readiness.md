# Chapter 1 Asset Replacement Readiness

Date: 2026-04-28

## Replacement Manifests

- `assets/generated/prompts/image2_ch1_family_memory.jsonl`
- `assets/generated/prompts/audio_ch1_replacement_prompts.jsonl`

Each replacement record includes `asset_type`, `target_path`, `runtime_usage`, `prompt`, `negative_prompt`, `fallback_path`, and `acceptance_notes`.

## Ready-To-Replace Targets

- `assets/sprites/items/family_memory_clip.png`
- `assets/sprites/cg/cg_family_memory_clip.png`
- `assets/sprites/locations/mei_ling_apartment_family_memory_variant.png`
- `assets/audio/sfx/family_memory_fragment.ogg`
- `assets/audio/sfx/eagle_eye_glitch_sting.ogg`
- `assets/audio/sfx/broken_player_scan.ogg`
- `assets/audio/sfx/memory_signature_reveal.ogg`

## Runtime Fallbacks

- Missing family-memory icon falls back to the existing `memory_capsule` evidence icon.
- Missing family-memory CG keeps the dialogue-only story beat.
- Missing family-memory background variant keeps the normal Mei Ling apartment background.
- Missing or placeholder SFX is skipped by `AudioManager.play_optional_sfx()` unless the target file is a valid OggS stream.

## Validation

```powershell
python tests\test_data_integrity.py
python tests\test_story_progression.py --score
python tests\test_eagle_eye_presentation.py --score
& 'C:\Users\gary1\OneDrive\桌面\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path . --quit
```

Do not commit `.uid`, `.import`, `.godot/`, or the local `AGENTS.md` change when replacing these assets.
