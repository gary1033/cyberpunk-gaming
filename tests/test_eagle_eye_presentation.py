#!/usr/bin/env python3
"""
NEON MEMORIES - Eagle Eye Presentation Score

Autoresearch metric for Chapter 1 eagle-eye presentation wiring.
The score is intentionally mechanical and higher is better.
"""

import argparse
import json
import os
import re
import sys


PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROMPT_PATH = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image2_ch1_eagle_eye.jsonl")


def read_file(rel_path):
    path = os.path.join(PROJECT_ROOT, rel_path)
    if not os.path.exists(path):
        return ""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def load_prompt_records():
    if not os.path.exists(PROMPT_PATH):
        return [], ["missing prompt manifest"]

    records = []
    errors = []
    with open(PROMPT_PATH, "r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, 1):
            if not line.strip():
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as exc:
                errors.append(f"line {line_no}: {exc}")
    return records, errors


def score_manifest(records, errors, details):
    score = 0
    expected_ids = {
        "broken_memory_player",
        "kai_eye_glitch_log",
        "cg_kai_eye_glitch",
        "eagle_eye_activation_cutin_ch1",
        "eagle_eye_scan_overlay_ch1",
        "mei_ling_apartment_eye_scan_variant",
        "eagle_eye_focus_reticle_ch1",
        "eagle_eye_glitch_noise_ch1",
        "eagle_eye_glitch_sting",
        "broken_player_scan",
        "memory_signature_reveal",
    }

    if not errors:
        score += 10
        details.append("prompt manifest parses: +10")
    else:
        details.append("prompt manifest parse errors: +0")

    ids = {record.get("id") for record in records}
    covered = len(expected_ids & ids)
    score += covered * 4
    details.append(f"expected prompt ids covered {covered}/{len(expected_ids)}: +{covered * 4}")

    complete = 0
    for record in records:
        if all(record.get(key) for key in ("id", "category", "out", "generated_output_path", "runtime_target_path", "runtime_fallback")):
            complete += 1
    score += complete * 3
    details.append(f"runtime-ready prompt records {complete}/{len(records)}: +{complete * 3}")

    overlay_records = [
        record for record in records
        if record.get("category") in {"ui_overlay", "background_variant"}
    ]
    safe_overlay = 0
    for record in overlay_records:
        prompt = (record.get("prompt", "") + " " + record.get("negative_prompt", "")).lower()
        if ("dialogue" in prompt or "ui" in prompt) and ("no readable text" in prompt or "no text" in prompt):
            safe_overlay += 1
    score += safe_overlay * 4
    details.append(f"gameplay-safe overlay prompts {safe_overlay}/{len(overlay_records)}: +{safe_overlay * 4}")

    audio_records = [record for record in records if record.get("category") == "audio_prompt"]
    score += len(audio_records) * 2
    details.append(f"audio prompt records {len(audio_records)}: +{len(audio_records) * 2}")

    return score


def score_runtime(details):
    score = 0
    augmented = read_file("scripts/gameplay/augmented_vision.gd")
    location_base = read_file("scripts/ui/location_base.gd")
    evidence_data = read_file("scripts/data/evidence_data.gd")
    evidence_board = read_file("scripts/gameplay/evidence_board.gd")
    energy_state_files = [
        os.path.join(PROJECT_ROOT, "assets/sprites/ui", f"energy_bar_{i:02d}.png")
        for i in range(1, 11)
    ]
    energy_geometry_path = os.path.join(PROJECT_ROOT, "assets/generated/ui/energy_bar_10_equal_slots_geometry.json")
    energy_assets_ready = all(os.path.exists(path) for path in energy_state_files)
    equal_slot_geometry_ready = False
    if os.path.exists(energy_geometry_path):
        with open(energy_geometry_path, "r", encoding="utf-8") as f:
            energy_geometry = json.load(f)
        equal_slot_geometry_ready = (
            energy_geometry.get("slot_count") == 10
            and energy_geometry.get("slot_width") == 25
            and energy_geometry.get("slot_gap") == 3
            and energy_geometry.get("output_size") == [512, 96]
        )

    runtime_checks = [
        ("AugmentedVision creates runtime nodes", "_ensure_runtime_nodes" in augmented, 12),
        ("AugmentedVision loads PNG overlay", "eagle_eye_scan_overlay_ch1.png" in augmented and "_load_runtime_texture" in augmented, 10),
        ("AugmentedVision loads generated reticle", "eagle_eye_focus_reticle_ch1.png" in augmented and "GeneratedFocusReticle" in augmented, 8),
        ("AugmentedVision loads glitch noise", "eagle_eye_glitch_noise_ch1.png" in augmented and "GlitchNoise" in augmented, 8),
        ("AugmentedVision loads activation cut-in", "eagle_eye_activation_cutin_ch1.png" in augmented and "ActivationCutin" in augmented, 8),
        ("AugmentedVision exposes key-clue glitch pulse", "func trigger_glitch_pulse" in augmented and "ECHO SIGNATURE DESYNC" in augmented, 10),
        ("AugmentedVision renders texture-swapped 10-state tech energy", "ENERGY_BAR_STATE_DIR" in augmented and "EAGLE_EYE_SEGMENT_COUNT := 10" in augmented and "TechEnergyTexture" in augmented and "_set_energy_state_texture" in augmented and "_create_energy_bar_material" not in augmented, 8),
        ("AugmentedVision drains one 10-state energy segment per tick", "EAGLE_EYE_DRAIN_INTERVAL := 1.0" in augmented and "consume_eagle_eye_energy_amount(GameManager.eagle_eye_max_energy / float(EAGLE_EYE_SEGMENT_COUNT))" in augmented, 6),
        ("AugmentedVision uses yellow-to-red equal-slot energy images", energy_assets_ready and equal_slot_geometry_ready and "_get_energy_state_index" in augmented and "floori(ratio * EAGLE_EYE_SEGMENT_COUNT)" in augmented, 6),
        ("AugmentedVision moves scanner reticle", "_set_reticle_target(event.position)" in augmented and "_apply_reticle_position" in augmented, 8),
        ("AugmentedVision scans hotspots under reticle", "_scan_hotspots_under_reticle" in augmented and "get_nodes_in_group(\"hotspots\")" in augmented, 8),
        ("AugmentedVision has shader fallback", "scanline.gdshader" in augmented and "_setup_shader_fallback" in augmented, 8),
        ("LocationBase installs AugmentedVision", "_setup_augmented_vision" in location_base and "augmented_vision.gd" in location_base, 12),
        ("LocationBase swaps AP status-bar textures", "HUD_ENERGY_SEGMENT_COUNT := 10" in location_base and "HUD_ENERGY_BAR_RECT := Rect2(-536.0, 20.0, 512.0, 96.0)" in location_base and "_update_ap_status_bar" in location_base and "APStatusBar" in location_base, 8),
        ("Toolbar calls AugmentedVision toggle", "_augmented_vision" in location_base and ".toggle()" in location_base, 10),
        ("LocationBase supports eagle-eye background variant", "mei_ling_apartment_eye_scan_variant.png" in location_base and "_set_eagle_eye_background_active" in location_base, 10),
        ("LocationBase triggers anomaly only from key actions", "EAGLE_EYE_ANOMALY_ACTIONS" in location_base and "trigger_glitch_pulse" in location_base, 10),
        ("Evidence data names preferred eagle-eye icons", '"preferred_icon": "broken_memory_player"' in evidence_data and '"preferred_icon": "kai_eye_glitch_log"' in evidence_data, 8),
        ("EvidenceBoard falls back when preferred icon is missing", "preferred_icon" in evidence_board and "fallback_icon_id" in evidence_board, 10),
    ]

    for label, passed, points in runtime_checks:
        if passed:
            score += points
            details.append(f"{label}: +{points}")
        else:
            details.append(f"{label}: +0")

    return score


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--score", action="store_true", help="print parseable score line")
    parser.add_argument("--details", action="store_true", help="print scoring detail")
    args = parser.parse_args()

    records, errors = load_prompt_records()
    details = []
    score = score_manifest(records, errors, details)
    score += score_runtime(details)

    print("NEON MEMORIES Eagle Eye Presentation")
    print(f"EAGLE_EYE_PRESENTATION_SCORE={score}")

    if args.details:
        for detail in details:
            print(f"  - {detail}")
        for error in errors:
            print(f"[WARN] {error}")

    # Parse errors make the metric invalid; missing runtime wiring only lowers score.
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
