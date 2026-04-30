#!/usr/bin/env python3
"""
NEON MEMORIES - Data Integrity Tests
Validates game data cross-references without requiring Godot engine.
Parses .gd and .tscn files to check scene paths, dialogue IDs,
evidence connections, asset files, and more.
"""

import os
import json
import hashlib
import re
import struct
import sys
import zlib

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

passed = 0
failed = 0
warnings = 0


# Bug regression: Keep test status prefixes ASCII-only so Windows cp950
# terminals do not crash before the actual integrity checks run.
def ok(msg):
    global passed
    passed += 1
    print(f"  [OK] {msg}")


def fail(msg):
    global failed
    failed += 1
    print(f"  [FAIL] {msg}")


def warn(msg):
    global warnings
    warnings += 1
    print(f"  [WARN] {msg}")


def read_file(rel_path):
    path = os.path.join(PROJECT_ROOT, rel_path)
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def res_to_real(res_path):
    """Convert res:// path to filesystem path."""
    return os.path.join(PROJECT_ROOT, res_path.replace("res://", ""))


def get_png_size(path):
    with open(path, "rb") as f:
        header = f.read(24)
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", header[16:24])


def png_has_alpha(path):
    with open(path, "rb") as f:
        header = f.read(26)
    if len(header) < 26 or header[:8] != b"\x89PNG\r\n\x1a\n":
        return False
    color_type = header[25]
    return color_type in (4, 6)


def png_alpha_stats(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    pos = 8
    width = height = bit_depth = color_type = interlace = None
    idat = bytearray()
    while pos + 8 <= len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        chunk_type = data[pos + 4:pos + 8]
        chunk_data = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if chunk_type == b"IHDR":
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", chunk_data)
        elif chunk_type == b"IDAT":
            idat.extend(chunk_data)
        elif chunk_type == b"IEND":
            break
    if bit_depth != 8 or color_type != 6 or interlace != 0:
        return None

    raw = zlib.decompress(bytes(idat))
    stride = width * 4
    rows = []
    cursor = 0
    prev = [0] * stride
    for _ in range(height):
        filter_type = raw[cursor]
        cursor += 1
        scan = list(raw[cursor:cursor + stride])
        cursor += stride
        recon = [0] * stride
        for i, value in enumerate(scan):
            left = recon[i - 4] if i >= 4 else 0
            up = prev[i]
            up_left = prev[i - 4] if i >= 4 else 0
            if filter_type == 0:
                recon[i] = value
            elif filter_type == 1:
                recon[i] = (value + left) & 0xFF
            elif filter_type == 2:
                recon[i] = (value + up) & 0xFF
            elif filter_type == 3:
                recon[i] = (value + ((left + up) // 2)) & 0xFF
            elif filter_type == 4:
                p = left + up - up_left
                pa = abs(p - left)
                pb = abs(p - up)
                pc = abs(p - up_left)
                predictor = left if pa <= pb and pa <= pc else (up if pb <= pc else up_left)
                recon[i] = (value + predictor) & 0xFF
            else:
                return None
        rows.append(recon)
        prev = recon

    alpha_values = [row[i] for row in rows for i in range(3, stride, 4)]
    corners = [
        rows[0][3],
        rows[0][stride - 1],
        rows[height - 1][3],
        rows[height - 1][stride - 1],
    ]
    return {
        "size": (width, height),
        "corners": corners,
        "transparent_pixels": sum(1 for value in alpha_values if value < 8),
    }


def file_sha256(path):
    hasher = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


# ---------------------------------------------------------------------------
# 1. Scene paths in SceneManager
# ---------------------------------------------------------------------------
def test_scene_paths():
    print("\n[1] SceneManager scene paths")
    content = read_file("scripts/core/scene_manager.gd")
    if not content:
        fail("scene_manager.gd not found")
        return

    # Extract all res:// paths from scene_paths dictionary
    matches = re.findall(r'"(res://scenes/[^"]+\.tscn)"', content)
    if not matches:
        fail("No scene paths found in scene_manager.gd")
        return

    for res_path in matches:
        real = res_to_real(res_path)
        if os.path.exists(real):
            ok(f"Scene exists: {res_path}")
        else:
            fail(f"Scene missing: {res_path}")


# ---------------------------------------------------------------------------
# 2. CaseData location connections
# ---------------------------------------------------------------------------
def test_case_data_connections():
    print("\n[2] CaseData location connections")
    case_content = read_file("scripts/data/case_data.gd")
    scene_content = read_file("scripts/core/scene_manager.gd")
    if not case_content or not scene_content:
        fail("Required files not found")
        return

    # Extract scene_paths keys
    scene_keys = set(re.findall(r'"(\w+)":\s*"res://scenes/', scene_content))

    # Extract all location IDs from case_data (keys in "locations" dicts)
    # Pattern: "location_id": { ... }
    location_ids = set(re.findall(r'"(\w+)":\s*\{[^}]*"name":', case_content))

    # Extract all connection references
    conn_matches = re.findall(r'"connections":\s*\[([^\]]*)\]', case_content)
    all_connections = set()
    for match in conn_matches:
        ids = re.findall(r'"(\w+)"', match)
        all_connections.update(ids)

    for conn_id in sorted(all_connections):
        if conn_id in location_ids or conn_id in scene_keys:
            ok(f"Connection target valid: {conn_id}")
        else:
            fail(f"Connection target not a known location: {conn_id}")


# ---------------------------------------------------------------------------
# 3. CaseData initial_dialogue references DialogueData
# ---------------------------------------------------------------------------
def test_initial_dialogues():
    print("\n[3] CaseData initial_dialogue → DialogueData")
    case_content = read_file("scripts/data/case_data.gd")
    dialogue_content = read_file("scripts/data/dialogue_data.gd")
    if not case_content or not dialogue_content:
        fail("Required files not found")
        return

    # Extract dialogue function names from DialogueData
    dialogue_funcs = set(re.findall(r'func\s+(get_\w+)\s*\(', dialogue_content))
    # Also extract string-based dialogue IDs (the keys used in get_dialogue)
    dialogue_ids = set(re.findall(r'"(ch\d+_\w+|ending_\w+)"', dialogue_content))

    # Extract initial_dialogue values from case_data
    init_dialogues = re.findall(r'"initial_dialogue":\s*"(\w+)"', case_content)

    for dlg_id in init_dialogues:
        if dlg_id in dialogue_ids or f"get_{dlg_id}" in dialogue_funcs:
            ok(f"Dialogue exists: {dlg_id}")
        else:
            fail(f"Dialogue not found in DialogueData: {dlg_id}")


# ---------------------------------------------------------------------------
# 4. DialogueData label jump targets
# ---------------------------------------------------------------------------
def test_dialogue_labels():
    print("\n[4] DialogueData label jump targets")
    content = read_file("scripts/data/dialogue_data.gd")
    if not content:
        fail("dialogue_data.gd not found")
        return

    # Find all "label": "xxx" definitions
    labels_defined = set(re.findall(r'"label":\s*"(\w+)"', content))
    # Find all "next": "xxx" references (excluding "end")
    next_refs = set(re.findall(r'"next":\s*"(\w+)"', content))
    next_refs.discard("end")

    missing = next_refs - labels_defined
    if missing:
        for m in sorted(missing):
            fail(f"Label jump target not defined: {m}")
    else:
        ok(f"All {len(next_refs)} label jump targets are valid")


# ---------------------------------------------------------------------------
# 5. Evidence IDs in EvidenceData
# ---------------------------------------------------------------------------
def test_evidence_ids():
    print("\n[5] Evidence IDs consistency")
    evidence_content = read_file("scripts/data/evidence_data.gd")
    board_content = read_file("scripts/gameplay/evidence_board.gd")
    case_content = read_file("scripts/data/case_data.gd")
    if not evidence_content:
        fail("evidence_data.gd not found")
        return

    # Extract all evidence IDs from evidence_data.gd
    # Evidence is stored as dictionary keys: "commission_letter": { ... }
    # Match keys that are followed by a dict with "name": and "icon":
    evidence_ids = set()
    # Find keys in the top-level dictionary of get_all_evidence()
    in_func = False
    for line in evidence_content.split('\n'):
        if 'get_all_evidence' in line:
            in_func = True
        if in_func:
            m = re.match(r'\s*"(\w+)":\s*\{', line)
            if m:
                evidence_ids.add(m.group(1))
    ok(f"Found {len(evidence_ids)} evidence IDs")

    # Check for duplicates
    id_list = []
    in_func = False
    for line in evidence_content.split('\n'):
        if 'get_all_evidence' in line:
            in_func = True
        if in_func:
            m = re.match(r'\s*"(\w+)":\s*\{', line)
            if m:
                id_list.append(m.group(1))
    seen = set()
    for eid in id_list:
        if eid in seen:
            fail(f"Duplicate evidence ID: {eid}")
        seen.add(eid)

    if len(seen) == len(id_list):
        ok("No duplicate evidence IDs")

    # Check evidence_board valid_connections reference valid evidence
    if board_content:
        conn_refs = set(re.findall(r'"(\w+)":\s*"(\w+)"', board_content))
        board_ids = set()
        for k, v in conn_refs:
            board_ids.add(k)
            board_ids.add(v)

        # Filter to only IDs that look like evidence (not UI strings)
        # valid_connections keys/values are evidence IDs
        vc_section = re.search(
            r'valid_connections\s*:=\s*\{(.*?)\}',
            board_content,
            re.DOTALL
        )
        if vc_section:
            vc_ids = set(re.findall(r'"(\w+)"', vc_section.group(1)))
            for eid in sorted(vc_ids):
                if eid in evidence_ids:
                    ok(f"Board connection valid: {eid}")
                else:
                    fail(f"Board references unknown evidence: {eid}")

    # Check case_data evidence references
    if case_content:
        case_evidence = set(re.findall(r'"evidence_id":\s*"(\w+)"', case_content))
        for eid in sorted(case_evidence):
            if eid in evidence_ids:
                ok(f"Case evidence valid: {eid}")
            else:
                fail(f"Case references unknown evidence: {eid}")


# ---------------------------------------------------------------------------
# 6. Character portrait files
# ---------------------------------------------------------------------------
def test_character_portraits():
    print("\n[6] Character portrait files")
    char_content = read_file("scripts/data/character_data.gd")
    if not char_content:
        fail("character_data.gd not found")
        return

    # Extract character IDs and moods
    # Characters stored as dict keys: "kai": { ... "moods": [...] }
    chars = []
    mood_blocks = []
    in_func = False
    for line in char_content.split('\n'):
        if 'get_all_characters' in line:
            in_func = True
        if in_func:
            m = re.match(r'\s*"(\w+)":\s*\{', line)
            if m:
                chars.append(m.group(1))
    mood_blocks = re.findall(r'"moods":\s*\[([^\]]+)\]', char_content)

    sprites_dir = os.path.join(PROJECT_ROOT, "assets/sprites/characters")
    if not os.path.isdir(sprites_dir):
        fail("assets/sprites/characters/ directory not found")
        return

    for i, char_id in enumerate(chars):
        if i < len(mood_blocks):
            moods = re.findall(r'"(\w+)"', mood_blocks[i])
            for mood in moods:
                png_path = os.path.join(sprites_dir, f"{char_id}_{mood}.png")
                if os.path.exists(png_path):
                    ok(f"Portrait PNG: {char_id}_{mood}.png")
                else:
                    fail(f"Missing portrait PNG: {char_id}_{mood}.png")


# ---------------------------------------------------------------------------
# 6b. Bug regression: Generated PNG portraits cover CharacterData moods
# Reference-sheet slices must exist as PNG so runtime replaces old SVG art.
# ---------------------------------------------------------------------------
def test_generated_png_character_portraits():
    print("\n[6b] Generated PNG character portraits")
    char_content = read_file("scripts/data/character_data.gd")
    if not char_content:
        fail("character_data.gd not found")
        return

    chars = []
    in_func = False
    for line in char_content.split('\n'):
        if 'get_all_characters' in line:
            in_func = True
        if in_func:
            m = re.match(r'\s*"(\w+)":\s*\{', line)
            if m:
                chars.append(m.group(1))
    mood_blocks = re.findall(r'"moods":\s*\[([^\]]+)\]', char_content)

    generated_dir = os.path.join(PROJECT_ROOT, "assets/generated/characters")
    sprites_dir = os.path.join(PROJECT_ROOT, "assets/sprites/characters")
    missing_png = 0
    invalid_runtime_copy = 0
    for i, char_id in enumerate(chars):
        if i >= len(mood_blocks):
            continue
        moods = re.findall(r'"(\w+)"', mood_blocks[i])
        for mood in moods:
            generated_path = os.path.join(generated_dir, f"{char_id}_{mood}.png")
            png_path = os.path.join(sprites_dir, f"{char_id}_{mood}.png")
            if os.path.exists(generated_path) and os.path.exists(png_path):
                ok(f"Generated PNG: {char_id}_{mood}.png")
                generated_size = get_png_size(generated_path)
                runtime_size = get_png_size(png_path)
                if generated_size == runtime_size and file_sha256(generated_path) == file_sha256(png_path):
                    ok(f"Runtime portrait matches generated source: {char_id}_{mood}.png ({runtime_size[0]}x{runtime_size[1]})")
                else:
                    fail(f"Runtime portrait does not match generated source: {char_id}_{mood}.png generated={generated_size} runtime={runtime_size}")
                    invalid_runtime_copy += 1
            else:
                fail(f"Missing generated/runtime PNG portrait: {char_id}_{mood}.png")
                missing_png += 1

    if missing_png == 0:
        ok("Generated PNG portraits cover all CharacterData moods")
    if invalid_runtime_copy == 0:
        ok("Runtime character portraits mirror generated high-resolution sources")


# ---------------------------------------------------------------------------
# 6c. Bug regression: Runtime portrait loaders use generated PNG portraits.
# Legacy SVG portraits should not remain as a fallback path.
# ---------------------------------------------------------------------------
def test_runtime_portrait_loader_supports_png():
    print("\n[6c] Runtime portrait loader supports PNG")
    required_scripts = [
        "scripts/gameplay/dialogue_system.gd",
        "scripts/gameplay/interrogation.gd",
    ]

    for rel_path in required_scripts:
        content = read_file(rel_path)
        if not content:
            fail(f"{rel_path} not found")
            continue

        if "_load_character_portrait" in content and ".png" in content and '"svg"' not in content:
            ok(f"{rel_path}: loads PNG portraits without SVG fallback")
        else:
            fail(f"{rel_path}: still references SVG portrait fallback")

    dialogue_system = read_file("scripts/gameplay/dialogue_system.gd") or ""
    location_base = read_file("scripts/ui/location_base.gd") or ""
    if 'speaker == "narrator"' in dialogue_system and 'speaker = "kai"' in dialogue_system:
        ok("Narrator entries fall back to Kai portrait at startup")
    else:
        fail("Narrator entries do not show a fallback portrait")

    # Bug regression: portraits need explicit source-image bounds; otherwise
    # the TextureRect can have zero or negative width in the frame-root layout.
    if "DIALOGUE_PORTRAIT_RECT" in location_base and "_apply_source_rect(portrait_left, DIALOGUE_PORTRAIT_RECT" in location_base and "_apply_source_rect(portrait_right, DIALOGUE_PORTRAIT_RECT" in location_base:
        ok("Dialogue portraits have explicit source-frame bounds")
    else:
        fail("Dialogue portrait bounds are incomplete")


# ---------------------------------------------------------------------------
# 7. Location background PNG files
# ---------------------------------------------------------------------------
def test_location_backgrounds():
    print("\n[7] Location background PNG files")
    scene_content = read_file("scripts/core/scene_manager.gd")
    if not scene_content:
        fail("scene_manager.gd not found")
        return

    sprites_dir = os.path.join(PROJECT_ROOT, "assets/sprites/locations")
    if not os.path.isdir(sprites_dir):
        fail("assets/sprites/locations/ directory not found")
        return

    # Extract location IDs (scene_paths keys, excluding main_menu and game)
    location_ids = re.findall(r'"(\w+)":\s*"res://scenes/locations/', scene_content)
    for loc_id in location_ids:
        png_path = os.path.join(sprites_dir, f"{loc_id}.png")
        if os.path.exists(png_path):
            ok(f"Background PNG: {loc_id}.png")
        else:
            fail(f"Missing background PNG: {loc_id}.png")


# ---------------------------------------------------------------------------
# 8. Evidence icon PNG files
# ---------------------------------------------------------------------------
def test_evidence_icons():
    print("\n[8] Evidence icon PNG files")
    evidence_content = read_file("scripts/data/evidence_data.gd")
    if not evidence_content:
        fail("evidence_data.gd not found")
        return

    sprites_dir = os.path.join(PROJECT_ROOT, "assets/sprites/items")
    if not os.path.isdir(sprites_dir):
        fail("assets/sprites/items/ directory not found")
        return

    icons = re.findall(r'"icon":\s*"(\w+)"', evidence_content)
    for icon in icons:
        png_path = os.path.join(sprites_dir, f"{icon}.png")
        if os.path.exists(png_path):
            ok(f"Icon PNG: {icon}.png")
        else:
            fail(f"Missing icon PNG: {icon}.png")


# ---------------------------------------------------------------------------
# 8b. Bug regression: Legacy SVG assets were removed after generated PNGs
# replaced character, location, and item art.
# ---------------------------------------------------------------------------
def test_no_legacy_svg_assets():
    print("\n[8b] No legacy SVG assets")
    assets_dir = os.path.join(PROJECT_ROOT, "assets")
    svg_files = []
    for root, _, files in os.walk(assets_dir):
        for file_name in files:
            if file_name.lower().endswith(".svg"):
                svg_files.append(os.path.relpath(os.path.join(root, file_name), PROJECT_ROOT))

    if svg_files:
        for rel_path in sorted(svg_files):
            fail(f"Legacy SVG asset still present: {rel_path}")
    else:
        ok("No SVG files remain under assets/")


# ---------------------------------------------------------------------------
# 9. Project structure
# ---------------------------------------------------------------------------
def test_project_structure():
    print("\n[9] Project structure")
    required_files = [
        "project.godot",
        "CLAUDE.md",
        "scripts/core/game_manager.gd",
        "scripts/core/scene_manager.gd",
        "scripts/core/save_manager.gd",
        "scripts/core/audio_manager.gd",
        "scripts/core/input_manager.gd",
        "scripts/data/dialogue_data.gd",
        "scripts/data/evidence_data.gd",
        "scripts/data/case_data.gd",
        "scripts/data/character_data.gd",
        "scripts/gameplay/dialogue_system.gd",
        "scripts/gameplay/evidence_board.gd",
        "scripts/gameplay/interrogation.gd",
        "scripts/gameplay/augmented_vision.gd",
        "scripts/gameplay/hotspot.gd",
    ]

    for f in required_files:
        path = os.path.join(PROJECT_ROOT, f)
        if os.path.exists(path):
            ok(f"File exists: {f}")
        else:
            fail(f"Missing file: {f}")

    required_dirs = [
        "scenes",
        "assets/shaders",
        "assets/sprites/characters",
        "assets/sprites/locations",
        "assets/sprites/items",
    ]

    for d in required_dirs:
        path = os.path.join(PROJECT_ROOT, d)
        if os.path.isdir(path):
            ok(f"Directory exists: {d}")
        else:
            fail(f"Missing directory: {d}")


# ---------------------------------------------------------------------------
# 10. GDScript basic checks
# ---------------------------------------------------------------------------
def test_gdscript_quality():
    print("\n[10] GDScript quality checks")
    gd_files = []
    for root, dirs, files in os.walk(os.path.join(PROJECT_ROOT, "scripts")):
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))

    debug_prints = 0
    for gd_file in gd_files:
        with open(gd_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        rel = os.path.relpath(gd_file, PROJECT_ROOT)
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            # Check for debug prints (not in comments)
            if not stripped.startswith("#") and re.search(r'\bprint\s*\(', stripped):
                warn(f"Debug print in {rel}:{i}: {stripped[:60]}")
                debug_prints += 1

    if debug_prints == 0:
        ok("No debug print statements found")
    else:
        warn(f"Found {debug_prints} print statement(s) — review before release")

    ok(f"Scanned {len(gd_files)} GDScript files")


# ---------------------------------------------------------------------------
# 11. Bug regression: Invalid UIDs in .tscn files
# Godot 4 UIDs must be numeric (e.g. uid://abc123), not string-based.
# String UIDs like uid://main_menu cause scene parse errors.
# ---------------------------------------------------------------------------
def test_no_invalid_tscn_uids():
    print("\n[11] No invalid UIDs in .tscn files")
    tscn_dir = os.path.join(PROJECT_ROOT, "scenes")
    if not os.path.isdir(tscn_dir):
        fail("scenes/ directory not found")
        return

    invalid_count = 0
    for root, dirs, files in os.walk(tscn_dir):
        for f in files:
            if not f.endswith(".tscn"):
                continue
            fpath = os.path.join(root, f)
            rel = os.path.relpath(fpath, PROJECT_ROOT)
            with open(fpath, "r", encoding="utf-8") as fh:
                first_line = fh.readline()
            # Check for uid:// that contains non-hex/non-alnum characters
            # Valid Godot UIDs look like uid://d1abc2ef3 (short base62-like IDs)
            uid_match = re.search(r'uid="uid://([^"]+)"', first_line)
            if uid_match:
                uid_value = uid_match.group(1)
                # Valid UIDs are short alphanumeric strings generated by Godot
                # Invalid: human-readable names like "main_menu", "game_scene"
                if re.match(r'^[a-z_]+$', uid_value) and len(uid_value) > 8:
                    fail(f"Invalid string-based UID in {rel}: uid://{uid_value}")
                    invalid_count += 1
                elif '_' in uid_value:
                    fail(f"Invalid UID with underscore in {rel}: uid://{uid_value}")
                    invalid_count += 1

    if invalid_count == 0:
        ok("No invalid string-based UIDs in .tscn files")


# ---------------------------------------------------------------------------
# 12. Bug regression: class_name placement
# class_name should appear near the top of the file (within first 15 lines).
# Having it at the bottom can cause parser/dependency resolution issues.
# ---------------------------------------------------------------------------
def test_class_name_placement():
    print("\n[12] class_name placement (should be near top of file)")
    gd_files = []
    for root, dirs, files in os.walk(os.path.join(PROJECT_ROOT, "scripts")):
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))

    for gd_file in gd_files:
        with open(gd_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        rel = os.path.relpath(gd_file, PROJECT_ROOT)

        for i, line in enumerate(lines):
            if line.strip().startswith("class_name "):
                if i > 15:
                    fail(f"class_name at line {i+1} in {rel} (should be within first 15 lines)")
                else:
                    ok(f"class_name at line {i+1} in {rel}")
                first_signal_index = next(
                    (idx for idx, candidate in enumerate(lines) if candidate.strip().startswith("signal ")),
                    None
                )
                if first_signal_index is not None and i > first_signal_index:
                    fail(f"class_name appears after signal declarations in {rel}")
                elif first_signal_index is not None:
                    ok(f"class_name appears before signal declarations in {rel}")
                break


# ---------------------------------------------------------------------------
# 13. Bug regression: Scene transition await safety
# Calls to SceneManager.change_scene / change_scene_with_chapter_title
# should be awaited to prevent state conflicts and double-click crashes.
# ---------------------------------------------------------------------------
def test_scene_transition_await():
    print("\n[13] Scene transition calls are awaited")
    gd_files = []
    for root, dirs, files in os.walk(os.path.join(PROJECT_ROOT, "scripts")):
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))

    # scene_manager.gd itself is excluded (it defines the methods)
    for gd_file in gd_files:
        rel = os.path.relpath(gd_file, PROJECT_ROOT)
        if rel == os.path.join("scripts", "core", "scene_manager.gd"):
            continue

        with open(gd_file, "r", encoding="utf-8") as f:
            lines = f.readlines()

        for i, line in enumerate(lines):
            stripped = line.strip()
            # Skip comments
            if stripped.startswith("#"):
                continue
            # Check for direct calls without await
            for method in ["change_scene_with_chapter_title", "change_scene("]:
                if f"SceneManager.{method}" in stripped:
                    if "await " not in stripped:
                        fail(f"Missing await on SceneManager.{method.rstrip('(')} in {rel}:{i+1}")
                    else:
                        ok(f"Properly awaited SceneManager call in {rel}:{i+1}")


# ---------------------------------------------------------------------------
# 14. Bug regression: change_scene_to_file error handling
# All calls to get_tree().change_scene_to_file() should check the return
# value for errors to prevent silent failures and broken state.
# ---------------------------------------------------------------------------
def test_change_scene_error_handling():
    print("\n[14] change_scene_to_file() error handling")
    content = read_file("scripts/core/scene_manager.gd")
    if not content:
        fail("scene_manager.gd not found")
        return

    # Find all change_scene_to_file calls
    calls = [(i, line) for i, line in enumerate(content.split('\n'), 1)
             if 'change_scene_to_file' in line and not line.strip().startswith('#')]

    for lineno, line in calls:
        stripped = line.strip()
        # Should be assigned to a variable for error checking: var error :=
        if stripped.startswith("var ") or stripped.startswith("var\t"):
            ok(f"change_scene_to_file result checked at line {lineno}")
        elif 'error' in stripped:
            ok(f"change_scene_to_file result checked at line {lineno}")
        else:
            fail(f"change_scene_to_file result not checked at line {lineno}: {stripped[:60]}")


# ---------------------------------------------------------------------------
# 15. Bug regression: Lambda loop variable capture
# In GDScript 4, capturing a loop variable (for i in ...) inside a lambda
# captures by reference. The variable must be copied to a local first.
# Pattern: for i in X: ... func(): ...use i...  (BAD)
#          for i in X: var c := i ... func(): ...use c... (OK)
# ---------------------------------------------------------------------------
def test_lambda_loop_capture():
    print("\n[15] Lambda loop variable capture safety")
    gd_files = []
    for root, dirs, files in os.walk(os.path.join(PROJECT_ROOT, "scripts")):
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))

    issues = 0
    for gd_file in gd_files:
        with open(gd_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        rel = os.path.relpath(gd_file, PROJECT_ROOT)

        # Track active for-loop variables and their scope (indent level)
        loop_vars = []  # [(var_name, indent_level)]

        for i, line in enumerate(lines):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue

            indent = len(line) - len(line.lstrip('\t'))

            # Remove loop vars that are out of scope
            loop_vars = [(v, lvl) for v, lvl in loop_vars if lvl < indent]

            # Detect for-loop variable
            for_match = re.match(r'for\s+(\w+)\s+in\s+', stripped)
            if for_match:
                loop_vars.append((for_match.group(1), indent))

            # Detect lambda using a loop variable directly
            if 'func()' in stripped or 'func(' in stripped:
                # Check subsequent lines in the lambda body for loop var usage
                # Simple heuristic: check if the lambda line itself uses a loop var
                for var_name, _ in loop_vars:
                    # Check this line and next few lines for the variable
                    block = '\n'.join(l.strip() for l in lines[i:i+5])
                    if re.search(rf'func\s*\(.*?\).*?{re.escape(var_name)}(?!\w)', block):
                        # Check if there's a local copy before the lambda
                        pre_lines = '\n'.join(l.strip() for l in lines[max(0,i-3):i])
                        if re.search(rf'var\s+\w+\s*:?=\s*{re.escape(var_name)}\b', pre_lines):
                            continue  # Properly copied
                        # Check if the lambda line itself has a bind() instead
                        if f'.bind({var_name})' in block:
                            continue  # Using bind is safe
                        warn(f"Possible loop var '{var_name}' captured in lambda at {rel}:{i+1}")
                        issues += 1

    if issues == 0:
        ok("No unsafe lambda loop variable captures detected")


# ---------------------------------------------------------------------------
# 16. Bug regression: Button state during transitions
# Menu buttons should be disabled during scene transitions to prevent
# double-click crashes and state corruption.
# ---------------------------------------------------------------------------
def test_button_disable_on_transition():
    print("\n[16] Buttons disabled during scene transitions")
    content = read_file("scripts/ui/main_menu.gd")
    if not content:
        fail("main_menu.gd not found")
        return

    # Check that _on_new_game disables buttons
    new_game_section = re.search(
        r'func _on_new_game\(\).*?(?=\nfunc |\Z)',
        content,
        re.DOTALL
    )
    if new_game_section:
        body = new_game_section.group(0)
        if 'disabled = true' in body:
            ok("_on_new_game disables buttons before transition")
        else:
            fail("_on_new_game does not disable buttons — risk of double-click crash")
    else:
        fail("_on_new_game function not found")

    # Check that _on_continue disables buttons
    continue_section = re.search(
        r'func _on_continue\(\).*?(?=\nfunc |\Z)',
        content,
        re.DOTALL
    )
    if continue_section:
        body = continue_section.group(0)
        if 'disabled = true' in body:
            ok("_on_continue disables buttons before transition")
        else:
            fail("_on_continue does not disable buttons — risk of double-click crash")
    else:
        fail("_on_continue function not found")


# ---------------------------------------------------------------------------
# 16b. Bug regression: Popup panels should be centered by a full-screen
# CenterContainer, not by anchoring the panel itself to PRESET_CENTER.
# ---------------------------------------------------------------------------
def test_main_menu_popup_layout_bounds():
    print("\n[16b] Main menu popup layout bounds")
    content = read_file("scripts/ui/main_menu.gd")
    if not content:
        fail("main_menu.gd not found")
        return

    if "func _add_centered_popup_panel" in content and "CenterContainer.new()" in content:
        ok("Main menu popups use CenterContainer for viewport-safe centering")
    else:
        fail("Main menu popups do not use CenterContainer centering")

    if "panel.set_anchors_preset(Control.PRESET_CENTER)" not in content:
        ok("Main menu popup panels are not anchored to PRESET_CENTER")
    else:
        fail("Main menu popup panels still use PRESET_CENTER and can overflow")

    if "viewport_size.y - 120.0" in content and "ScrollContainer.new()" in content:
        ok("Main menu popups clamp scroll height to visible viewport")
    else:
        fail("Main menu popups do not clamp scroll height to viewport")

    # Bug regression: controls popup right-column text needs room between
    # the keyboard labels and the scrollbar.
    if "panel_width := minf(900.0, viewport_size.x * 0.94)" in content and 'margin_right", 96' in content:
        ok("Controls popup has a wider panel and scrollbar-safe right padding")
    else:
        fail("Controls popup can clip right-column text behind the scrollbar")

    if "key_lbl.custom_minimum_size = Vector2(360, 0)" in content and "key_lbl.autowrap_mode" in content and "compact := get_viewport().get_visible_rect().size.x < 560.0" in content:
        ok("Controls popup key labels have a stable desktop width and compact mobile layout")
    else:
        fail("Controls popup key labels can overflow the panel")

    # Bug regression: settings and controls popups should be dismissible with
    # Esc so players are not trapped when focus is inside a selector or slider.
    if "func _unhandled_input(event: InputEvent)" in content and 'event.is_action_pressed("ui_cancel")' in content and 'add_to_group("dismissible_popup")' in content:
        ok("Main menu popups can be dismissed with Esc")
    else:
        fail("Main menu popups do not handle Esc dismissal")

    if '"Esc 關閉"' in content and '"關閉說明 / 設定", "Esc"' in content:
        ok("Controls and settings popups show Esc dismissal hints")
    else:
        fail("Controls/settings popups do not show Esc dismissal hints")


    # Bug regression: title-screen choices need opaque cyberpunk button panels
    # so text remains readable over generated city backgrounds.
    if "func _style_main_menu_buttons" in content and "_create_menu_button_style" in content and "shadow_color" in content and "font_hover_color" in content:
        ok("Main menu options use deeper cyberpunk button frames")
    else:
        fail("Main menu options do not have styled cyberpunk button frames")


# ---------------------------------------------------------------------------
# 17. Bug regression: No @onready with bare $ in class_name scripts
# Scripts with class_name are registered globally. Using @onready with
# bare $NodePath can crash if nodes don't exist when parsed/instantiated
# dynamically. Use get_node_or_null() in _ready() instead.
# ---------------------------------------------------------------------------
def test_no_onready_in_classname_scripts():
    print("\n[17] No @onready with bare $ in class_name scripts")
    gd_files = []
    for root, dirs, files in os.walk(os.path.join(PROJECT_ROOT, "scripts")):
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))

    for gd_file in gd_files:
        with open(gd_file, "r", encoding="utf-8") as f:
            content = f.read()
        rel = os.path.relpath(gd_file, PROJECT_ROOT)

        has_class_name = bool(re.search(r'^class_name\s+\w+', content, re.MULTILINE))
        if not has_class_name:
            continue

        # Match @onready var x = $Path but NOT @onready var x = $Path if has_node(...)
        onready_lines = [
            line.strip() for line in content.split('\n')
            if re.match(r'\s*@onready\s+var\s+\w+.*=\s*\$', line)
            and 'if has_node' not in line
            and 'get_node_or_null' not in line
        ]
        if onready_lines:
            fail(f"{rel}: {len(onready_lines)} @onready with bare $ in class_name script (use get_node_or_null in _ready)")
        else:
            ok(f"{rel}: No unsafe @onready patterns")


# ---------------------------------------------------------------------------
# 18. Bug regression: Null safety in _ready() for dynamically created nodes
# EvidenceBoard, Interrogation, MemoryPreview are created via .new() with
# child nodes added externally. Their _ready() must use null checks.
# ---------------------------------------------------------------------------
def test_ready_null_safety():
    print("\n[18] Null safety in class_name script _ready() methods")
    critical_scripts = [
        "scripts/gameplay/evidence_board.gd",
        "scripts/gameplay/interrogation.gd",
        "scripts/gameplay/memory_preview.gd",
    ]

    for rel_path in critical_scripts:
        content = read_file(rel_path)
        if not content:
            fail(f"{rel_path} not found")
            continue

        # Check that _ready uses get_node_or_null instead of bare $ access
        if "get_node_or_null" in content:
            ok(f"{rel_path}: Uses safe node resolution")
        else:
            fail(f"{rel_path}: Missing get_node_or_null — risk of null crash")


# ---------------------------------------------------------------------------
# 19. Bug regression: DialogueSystem must be instantiated in location scenes
# LocationBase._setup_ui() must create a DialogueSystem node and add it to
# the "dialogue_system" group, otherwise no dialogue can play in-game.
# ---------------------------------------------------------------------------
def test_dialogue_system_instantiated():
    print("\n[19] DialogueSystem instantiated in LocationBase")
    content = read_file("scripts/ui/location_base.gd")
    if not content:
        fail("location_base.gd not found")
        return

    # Must load and set dialogue_system.gd script
    if 'dialogue_system.gd' in content:
        ok("LocationBase loads dialogue_system.gd script")
    else:
        fail("LocationBase does not load dialogue_system.gd — dialogue will never appear")

    # Must add to "dialogue_system" group
    if 'add_to_group("dialogue_system")' in content:
        ok("DialogueSystem added to 'dialogue_system' group")
    else:
        fail("DialogueSystem not added to 'dialogue_system' group — hotspots cannot find it")

    # _trigger_initial_dialogue must call start_dialogue, not be a stub
    trigger_section = re.search(
        r'func _trigger_initial_dialogue\(\).*?(?=\nfunc |\Z)',
        content,
        re.DOTALL
    )
    if trigger_section:
        body = trigger_section.group(0)
        if 'start_dialogue' in body:
            ok("_trigger_initial_dialogue calls start_dialogue")
            # Bug regression: start_dialogue must stay nested under the ds guard,
            # otherwise Godot treats the function as malformed or unguarded.
            body_lines = body.splitlines()
            guard_index = next(
                (i for i, line in enumerate(body_lines) if 'if ds and ds.has_method("start_dialogue")' in line),
                None
            )
            call_index = next(
                (i for i, line in enumerate(body_lines) if 'ds.start_dialogue(dialogue_entries)' in line),
                None
            )
            if guard_index is not None and call_index is not None and call_index > guard_index:
                guard_indent = len(re.match(r'^\s*', body_lines[guard_index]).group(0))
                call_indent = len(re.match(r'^\s*', body_lines[call_index]).group(0))
                if call_indent > guard_indent:
                    ok("Initial dialogue start call is nested under ds guard")
                else:
                    fail("Initial dialogue start call is not nested under ds guard")
            else:
                fail("Initial dialogue ds guard or start call not found")
        else:
            fail("_trigger_initial_dialogue is a stub – initial dialogue will never play")
    else:
        fail("_trigger_initial_dialogue function not found")


# ---------------------------------------------------------------------------
# 20. Bug regression: class_name references via load() in location_base
# Direct class_name identifiers (e.g. EvidenceBoard.new()) can fail with
# "identifier not declared in scope" due to Godot script loading order.
# Use load("res://...gd").new() instead.
# ---------------------------------------------------------------------------
def test_classname_load_safety():
    print("\n[20] class_name references use load() in location_base")
    content = read_file("scripts/ui/location_base.gd")
    if not content:
        fail("location_base.gd not found")
        return

    # Check that EvidenceBoard is not used as a direct identifier
    has_direct_eb = False
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped.startswith('#'):
            continue
        if 'EvidenceBoard.new()' in stripped:
            has_direct_eb = True
            break
    if has_direct_eb:
        fail("Direct EvidenceBoard.new() found — use load() to avoid scope errors")
    else:
        ok("EvidenceBoard loaded via load() (no direct class_name reference)")

    # Check that Hotspot static calls use load() too
    has_direct_hs = False
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped.startswith('#'):
            continue
        if 'Hotspot.pulse_all_hotspots' in stripped:
            has_direct_hs = True
            break
    if has_direct_hs:
        fail("Direct Hotspot.pulse_all_hotspots() found — use load() to avoid scope errors")
    else:
        ok("Hotspot accessed via load() (no direct class_name reference)")

    # Bug regression: directly loading a location scene can parse before
    # data class_names are registered, so LocationBase should use preloads.
    if "CaseData." not in content and "DialogueData." not in content and "CaseDataScript" in content and "DialogueDataScript" in content:
        ok("LocationBase data access uses preloaded scripts, not direct class_name identifiers")
    else:
        fail("LocationBase still uses direct CaseData/DialogueData identifiers")


# ---------------------------------------------------------------------------
# 21. Bug regression: Autoload singletons must set process_mode = ALWAYS
# Core autoloads (GameManager, SceneManager, InputManager) must set
# process_mode = Node.PROCESS_MODE_ALWAYS in _ready() so they keep
# functioning when the scene tree is paused.
# ---------------------------------------------------------------------------
def test_autoload_process_mode():
    print("\n[21] Autoload singletons set process_mode = ALWAYS")
    autoloads = [
        "scripts/core/game_manager.gd",
        "scripts/core/scene_manager.gd",
        "scripts/core/input_manager.gd",
    ]

    for rel_path in autoloads:
        content = read_file(rel_path)
        if not content:
            fail(f"{rel_path} not found")
            continue

        if "PROCESS_MODE_ALWAYS" in content:
            ok(f"{rel_path}: process_mode = ALWAYS set")
        else:
            fail(f"{rel_path}: missing process_mode = ALWAYS — will stop during pause")


# ---------------------------------------------------------------------------
# 22. Bug regression: Dialogue flags that are also ending decisions must
# update GameManager.decisions, otherwise choices cannot affect endings.
# ---------------------------------------------------------------------------
def test_dialogue_flags_update_decisions():
    print("\n[22] Dialogue flags update ending decisions")
    game_manager = read_file("scripts/core/game_manager.gd")
    dialogue_system = read_file("scripts/gameplay/dialogue_system.gd")
    dialogue_content = read_file("scripts/data/dialogue_data.gd")
    location_base = read_file("scripts/ui/location_base.gd")
    if not game_manager or not dialogue_system or not dialogue_content or not location_base:
        fail("Required files not found")
        return

    set_flag_section = re.search(
        r'func set_dialogue_flag\(.*?(?=\nfunc |\Z)',
        game_manager,
        re.DOTALL
    )
    if not set_flag_section:
        fail("GameManager.set_dialogue_flag not found")
    else:
        body = set_flag_section.group(0)
        if "flag in decisions" in body and "decisions[flag] = value" in body:
            ok("set_dialogue_flag mirrors matching boolean decisions")
        else:
            fail("set_dialogue_flag does not update matching ending decisions")

    if '"set_flag": "trusted_zhao"' in dialogue_content:
        fail("DialogueData still sets legacy trusted_zhao flag instead of trusted_zhao_ming")
    else:
        ok("DialogueData no longer uses legacy trusted_zhao flag")

    if '"set_flag": "trusted_zhao_ming"' in dialogue_content:
        ok("Zhao trust choice sets trusted_zhao_ming decision flag")
    else:
        fail("Zhao trust choice does not set trusted_zhao_ming")

    if '"set_flag": "has_fake_id"' in dialogue_content and '"give_evidence": "fake_id_chip"' in dialogue_content:
        ok("Kid deal unlocks market gate when fake ID evidence is granted")
    else:
        fail("Kid deal does not pair fake_id_chip with has_fake_id gate flag")

    if "func set_decision" in game_manager and "GameManager.set_decision" in dialogue_system:
        ok("Dialogue entries and choices can update non-boolean ending decisions")
    else:
        fail("Dialogue system cannot update non-boolean ending decisions such as memory_attitude")

    if '"memory_attitude": "accept"' in dialogue_content and '"memory_attitude": "deny"' in dialogue_content:
        ok("Echo AI memory choice records memory_attitude")
    else:
        fail("Echo AI memory choice does not record memory_attitude")

    if "use_calculated_ending" in location_base and "calculate_ending" in location_base:
        ok("LocationBase can trigger calculated ending story actions")
    else:
        fail("LocationBase cannot trigger calculated ending story actions")


# ---------------------------------------------------------------------------
# 23. Bug regression: Generated image2 prompt manifests must cover all
# backgrounds and evidence item icons before AI asset generation.
# ---------------------------------------------------------------------------
def test_image2_asset_prompt_manifests():
    print("\n[23] image2 asset prompt manifests")
    required_manifests = {
        "assets/generated/prompts/image2_backgrounds.jsonl": 15,
        "assets/generated/prompts/image2_items.jsonl": 28,
        "assets/generated/prompts/image2_ui.jsonl": 5,
    }

    for rel_path, min_count in required_manifests.items():
        path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.exists(path):
            fail(f"Missing image2 prompt manifest: {rel_path}")
            continue

        records = []
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    records.append(json.loads(line))

        if len(records) >= min_count:
            ok(f"{rel_path}: {len(records)} prompt records")
        else:
            fail(f"{rel_path}: expected at least {min_count} records, found {len(records)}")

        for record in records:
            if record.get("prompt", "") and record.get("output_path", ""):
                ok(f"Prompt ready: {record.get('id', record.get('icon', 'unknown'))}")
            else:
                fail(f"Incomplete prompt record in {rel_path}: {record}")

            # Bug regression: gpt-image-2 does not support transparent backgrounds.
            if record.get("model") == "gpt-image-2" and record.get("background") == "transparent":
                fail(f"{rel_path}: gpt-image-2 record uses unsupported transparent background")


# ---------------------------------------------------------------------------
# 24. Bug regression: Generated raster assets must exist after image2/local
# rendering so runtime PNG loaders do not silently fall back to SVG.
# ---------------------------------------------------------------------------
def test_generated_environment_item_ui_png_assets():
    print("\n[24] Generated environment, item, and UI PNG assets")
    manifests = [
        "assets/generated/prompts/image2_backgrounds.jsonl",
        "assets/generated/prompts/image2_items.jsonl",
        "assets/generated/prompts/image2_ui.jsonl",
    ]

    for rel_manifest in manifests:
        manifest_path = os.path.join(PROJECT_ROOT, rel_manifest)
        if not os.path.exists(manifest_path):
            fail(f"Missing manifest for generated assets: {rel_manifest}")
            continue

        with open(manifest_path, "r", encoding="utf-8") as f:
            records = [json.loads(line) for line in f if line.strip()]

        for record in records:
            rel_output = record.get("output_path", "")
            expected_size = tuple(map(int, record.get("target_size", record.get("size", "0x0")).split("x")))
            asset_path = os.path.join(PROJECT_ROOT, rel_output)
            if not os.path.exists(asset_path):
                fail(f"Generated PNG missing: {rel_output}")
                continue

            actual_size = get_png_size(asset_path)
            if actual_size == expected_size:
                ok(f"Generated PNG ready: {rel_output} ({actual_size[0]}x{actual_size[1]})")
            else:
                fail(f"Generated PNG size mismatch: {rel_output}; expected {expected_size}, got {actual_size}")


# ---------------------------------------------------------------------------
# 25. Bug regression: Runtime loaders use generated PNG backgrounds/items
# without falling back to legacy SVG assets.
# ---------------------------------------------------------------------------
def test_runtime_asset_loader_supports_generated_pngs():
    print("\n[25] Runtime loaders support generated PNG background/item/UI assets")
    location_base = read_file("scripts/ui/location_base.gd")
    evidence_board = read_file("scripts/gameplay/evidence_board.gd")
    memory_preview = read_file("scripts/gameplay/memory_preview.gd")
    if not location_base or not evidence_board or not memory_preview:
        fail("Required runtime loader files not found")
        return

    if "_load_location_background" in location_base and ".png" in location_base and '"svg"' not in location_base:
        ok("LocationBase loads generated PNG backgrounds without SVG fallback")
    else:
        fail("LocationBase still references SVG background fallback")

    if "_load_evidence_icon" in evidence_board and ".png" in evidence_board and '"svg"' not in evidence_board:
        ok("EvidenceBoard loads generated PNG item icons without SVG fallback")
    else:
        fail("EvidenceBoard still references SVG item icon fallback")

    if (
        "_create_generated_panel_style" in location_base
        and "dialogue_panel" in location_base
        and "popup_panel" in location_base
        and "toolbar_buttons" in location_base
    ):
        ok("LocationBase uses generated dialogue, popup, and toolbar UI PNGs")
    else:
        fail("LocationBase does not use generated UI panel/button PNGs")

    if "_create_card_style" in evidence_board and "evidence_card.png" in evidence_board:
        ok("EvidenceBoard uses generated evidence card UI PNG")
    else:
        fail("EvidenceBoard does not use generated evidence card UI PNG")

    if "memory_preview_overlay.png" in memory_preview and "_setup_generated_overlay" in memory_preview:
        ok("MemoryPreview uses generated memory overlay UI PNG")
    else:
        fail("MemoryPreview does not use generated memory overlay UI PNG")

    # Bug regression: generated PNGs are source-controlled without Godot .import
    # sidecars, so runtime loaders must be able to create ImageTexture directly.
    runtime_texture_scripts = {
        "LocationBase": location_base,
        "EvidenceBoard": evidence_board,
        "MemoryPreview": memory_preview,
        "DialogueSystem": read_file("scripts/gameplay/dialogue_system.gd") or "",
        "Interrogation": read_file("scripts/gameplay/interrogation.gd") or "",
    }
    for script_name, content in runtime_texture_scripts.items():
        if "_load_runtime_texture" in content and "ImageTexture.create_from_image" in content:
            ok(f"{script_name} can load PNG textures without .import sidecars")
        else:
            fail(f"{script_name} cannot load PNG textures without .import sidecars")


# ---------------------------------------------------------------------------
# 26. Bug regression: Image2 background/item/UI outputs must be copied into the runtime
# sprite directories. Generating files under assets/generated is not enough.
# ---------------------------------------------------------------------------
def test_image2_outputs_are_connected_to_runtime_sprites():
    print("\n[26] Image2 outputs are connected to runtime sprites")
    mappings = [
        ("backgrounds", "assets/generated/backgrounds", "assets/sprites/locations", ""),
        ("items", "assets/generated/items", "assets/sprites/items", "ch1_"),
        ("ui", "assets/generated/ui", "assets/sprites/ui", ""),
    ]
    source_only_images = {
        "ui": {"energy_bar_states_sheet.png"},
    }

    checked = 0
    for label, generated_rel, sprite_rel, runtime_prefix in mappings:
        generated_dir = os.path.join(PROJECT_ROOT, generated_rel)
        sprite_dir = os.path.join(PROJECT_ROOT, sprite_rel)
        if not os.path.isdir(generated_dir):
            warn(f"No generated {label} directory found: {generated_rel}")
            continue

        for file_name in sorted(os.listdir(generated_dir)):
            if not file_name.lower().endswith(".png"):
                continue
            if file_name in source_only_images.get(label, set()):
                continue
            if runtime_prefix and not file_name.startswith(runtime_prefix):
                continue
            generated_path = os.path.join(generated_dir, file_name)
            sprite_name = file_name[len(runtime_prefix):] if runtime_prefix else file_name
            sprite_path = os.path.join(sprite_dir, sprite_name)
            checked += 1
            if not os.path.exists(sprite_path):
                fail(f"Generated {label} image is not in runtime sprites: {file_name}")
                continue
            if file_sha256(generated_path) == file_sha256(sprite_path):
                ok(f"Generated {label} image connected: {file_name}")
            else:
                fail(f"Generated {label} image differs from runtime sprite: {file_name}")

    if checked > 0:
        ok(f"Checked {checked} generated background/item/UI image connections")
    else:
        fail("No generated background/item/UI PNG outputs were checked")


# ---------------------------------------------------------------------------
# 26b. Bug regression: Project-bound item icons and overlay UI must be
# transparent runtime sprites, not opaque generated previews.
# ---------------------------------------------------------------------------
def test_transparent_item_and_overlay_ui_assets():
    print("\n[26b] Transparent item and overlay UI assets")

    item_runtime_dir = os.path.join(PROJECT_ROOT, "assets/sprites/items")
    item_source_dir = os.path.join(PROJECT_ROOT, "assets/generated/items")
    item_names = sorted(name for name in os.listdir(item_runtime_dir) if name.endswith(".png"))
    item_records_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image_gen_items_transparent_2026_04_30.jsonl")
    if os.path.exists(item_records_path):
        item_records = [json.loads(line) for line in open(item_records_path, encoding="utf-8") if line.strip()]
        if len(item_records) == len(item_names):
            ok("Transparent item manifest covers every runtime item PNG")
        else:
            fail("Transparent item manifest count does not match runtime item PNG count")
    else:
        fail("Missing transparent item image_gen manifest")

    for name in item_names:
        source_path = os.path.join(item_source_dir, f"ch1_{name}")
        runtime_path = os.path.join(item_runtime_dir, name)
        if os.path.exists(source_path) and file_sha256(source_path) == file_sha256(runtime_path):
            ok(f"Transparent item source matches runtime: {name}")
        else:
            fail(f"Transparent item source/runtime mismatch: {name}")
            continue
        stats = png_alpha_stats(runtime_path)
        if stats and stats["size"] == (512, 512) and max(stats["corners"]) <= 8 and stats["transparent_pixels"] >= 1000:
            ok(f"Transparent item has real alpha: {name}")
        else:
            fail(f"Transparent item is opaque or wrong size: {name}")

    ui_specs = {
        "ap_status_bar.png": (512, 96),
        "dialogue_panel.png": (1280, 240),
        "eagle_eye_focus_reticle_ch1.png": (512, 512),
        "eagle_eye_glitch_noise_ch1.png": (1280, 720),
        "eagle_eye_scan_overlay_ch1.png": (1280, 720),
        "evidence_card.png": (512, 384),
        "memory_preview_overlay.png": (1280, 720),
        "popup_panel.png": (768, 768),
        "toolbar_buttons.png": (1024, 256),
        **{f"energy_bar_{i:02d}.png": (512, 96) for i in range(1, 13)},
    }
    ui_records_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image_gen_ui_transparent_2026_04_30.jsonl")
    if os.path.exists(ui_records_path):
        ui_records = [json.loads(line) for line in open(ui_records_path, encoding="utf-8") if line.strip()]
        if len(ui_records) == len(ui_specs):
            ok("Transparent UI manifest covers every overlay UI PNG")
        else:
            fail("Transparent UI manifest count does not match overlay UI PNG count")
    else:
        fail("Missing transparent UI image_gen manifest")

    for rel_path, expected_size in ui_specs.items():
        source_path = os.path.join(PROJECT_ROOT, "assets/generated/ui", rel_path)
        runtime_path = os.path.join(PROJECT_ROOT, "assets/sprites/ui", rel_path)
        if os.path.exists(source_path) and os.path.exists(runtime_path) and file_sha256(source_path) == file_sha256(runtime_path):
            ok(f"Transparent UI source matches runtime: {rel_path}")
        else:
            fail(f"Transparent UI source/runtime mismatch: {rel_path}")
            continue
        stats = png_alpha_stats(runtime_path)
        if stats and stats["size"] == expected_size and max(stats["corners"]) <= 8 and stats["transparent_pixels"] >= 100:
            ok(f"Transparent UI has real alpha: {rel_path}")
        else:
            fail(f"Transparent UI is opaque or wrong size: {rel_path}")


# ---------------------------------------------------------------------------
# 26c. Bug regression: Image assets must stay in flat category roots.
# Deep chapter/variant/state folders made source/runtime wiring drift.
# ---------------------------------------------------------------------------
def test_image_assets_stay_in_flat_category_roots():
    print("\n[26c] Image assets stay in flat category roots")

    disallowed_image_dirs = [
        "assets/generated/characters/transparent_regen",
        "assets/generated/characters/reference_sheets",
        "assets/generated/backgrounds/ch1",
        "assets/generated/backgrounds/variants",
        "assets/generated/cg/ch1",
        "assets/generated/items/ch1",
        "assets/generated/ui/energy_bar_states",
        "assets/sprites/cg/ch1",
        "assets/sprites/locations/variants",
        "assets/sprites/ui/energy_bar_states",
    ]
    image_exts = {".png", ".jpg", ".jpeg", ".webp", ".svg"}

    for rel_dir in disallowed_image_dirs:
        abs_dir = os.path.join(PROJECT_ROOT, rel_dir)
        if not os.path.isdir(abs_dir):
            ok(f"Removed deep image directory: {rel_dir}")
            continue

        images = [
            name
            for name in os.listdir(abs_dir)
            if os.path.splitext(name)[1].lower() in image_exts
        ]
        if images:
            fail(f"Deep image directory still contains images: {rel_dir} -> {', '.join(sorted(images)[:5])}")
        else:
            ok(f"No image files remain in deep directory: {rel_dir}")


# ---------------------------------------------------------------------------
# 27. Bug regression: Dialogue portraits and evidence board must not block play
# Portraits previously overlapped speaker text, and evidence board card layout
# used unsafe Godot integer iteration/conversion when opening the board.
# ---------------------------------------------------------------------------
def test_runtime_ui_playability_regressions():
    print("\n[27] Runtime UI playability regressions")
    location_base = read_file("scripts/ui/location_base.gd")
    dialogue_system = read_file("scripts/gameplay/dialogue_system.gd")
    evidence_board = read_file("scripts/gameplay/evidence_board.gd")
    augmented_vision = read_file("scripts/gameplay/augmented_vision.gd")
    game_manager = read_file("scripts/core/game_manager.gd")
    scanline_shader = read_file("assets/shaders/scanline.gdshader")
    if not location_base or not dialogue_system or not evidence_board or not augmented_vision or not game_manager or not scanline_shader:
        fail("Required UI runtime files not found")
        return

    # Bug regression: dialogue_panel.png must render as one complete HUD texture,
    # not as a stretched StyleBoxTexture that distorts red/blue frame alignment.
    if (
        "DIALOGUE_FRAME_SOURCE_SIZE := Vector2(1280.0, 240.0)" in location_base
        and "DialogueFrameRoot" in location_base
        and "DialogueFrameTexture" in location_base
        and 'dialogue_frame_texture.texture = _load_ui_texture("dialogue_panel")' in location_base
        and "dialogue_frame_texture.stretch_mode = TextureRect.STRETCH_SCALE" in location_base
        and '_create_generated_panel_style("dialogue_panel"' not in location_base
    ):
        ok("Dialogue HUD uses the complete generated texture as a single aligned frame")
    else:
        fail("Dialogue HUD can still distort dialogue_panel.png as a panel stylebox")

    # Bug regression: portraits should be positioned in the source-image red
    # portrait cell so the lower name plate remains available.
    if (
        "DIALOGUE_PORTRAIT_RECT := Rect2(34.0, 26.0, 174.0, 134.0)" in location_base
        and "_apply_source_rect(portrait_left, DIALOGUE_PORTRAIT_RECT, dialogue_frame_scale)" in location_base
        and "_apply_source_rect(portrait_right, DIALOGUE_PORTRAIT_RECT, dialogue_frame_scale)" in location_base
        and "dialogue_frame_root.add_child(portrait_left)" in location_base
        and "dialogue_frame_root.add_child(portrait_right)" in location_base
        and "portrait_left.clip_contents = true" in location_base
    ):
        ok("Dialogue portraits fit inside the source-image red portrait frame")
    else:
        fail("Dialogue portraits are not bound to the source-image red frame")

    # Bug regression: all dialogue portraits should stay in the left portrait
    # frame so right-side speakers do not cover the room background or choices.
    if 'portrait_right.name = "PortraitRight"' in location_base and '_update_portrait(speaker, mood, "left")' in dialogue_system:
        ok("Dialogue portraits are forced to the left portrait frame")
    else:
        fail("Dialogue portraits can still render on the right side")

    # Bug regression: the speaker name belongs in the lower red name plate, not
    # in the blue dialogue text frame.
    if (
        "DIALOGUE_NAME_RECT := Rect2(24.0, 181.0, 184.0, 34.0)" in location_base
        and "_apply_source_rect(name_label, DIALOGUE_NAME_RECT, dialogue_frame_scale)" in location_base
        and "dialogue_frame_root.add_child(name_label)" in location_base
        and 'character_name_label: Label = find_child("NameLabel", true, false)' in dialogue_system
    ):
        ok("Speaker name renders in the source-image lower red name plate")
    else:
        fail("Speaker name can render inside the blue dialogue text frame")

    # Bug regression: narrator/opening entries often leave name blank, but the
    # red name plate should not disappear while Kai's portrait is shown.
    if "_get_display_name" in dialogue_system and 'return "凱"' in dialogue_system:
        ok("Opening narrator dialogue falls back to Kai name plate text")
    else:
        fail("Opening narrator dialogue can leave the red name plate blank")

    # Bug regression: dialogue text and choices must share the source-image blue
    # frame coordinate system, not independent screen-bottom offsets.
    if (
        "DIALOGUE_BLUE_CONTENT_RECT := Rect2(282.0, 38.0, 910.0, 158.0)" in location_base
        and "_apply_source_rect(dialogue_panel, DIALOGUE_BLUE_CONTENT_RECT, dialogue_frame_scale)" in location_base
        and "dialogue_frame_root.add_child(dialogue_panel)" in location_base
        and "dialogue_panel.clip_contents = true" in location_base
        and "dialogue_margin.set_anchors_preset(Control.PRESET_FULL_RECT)" in location_base
        and "dialogue_text.clip_contents = true" in location_base
    ):
        ok("Dialogue text and choices are constrained to the source-image blue frame")
    else:
        fail("Dialogue text margins can overlap portraits or overflow the frame")

    # Bug regression: dialogue pages without visible choices should sit lower in
    # the blue frame, while choice pages keep top room for the buttons.
    if (
        'dialogue_content_margin: MarginContainer = find_child("DialogueContentMargin", true, false)' in dialogue_system
        and "NO_CHOICE_DIALOGUE_TOP_MARGIN := 28" in dialogue_system
        and "CHOICE_DIALOGUE_TOP_MARGIN := 0" in dialogue_system
        and "_entry_page_will_show_choices(entry)" in dialogue_system
        and "_set_dialogue_content_layout(false)" in dialogue_system
        and "_set_dialogue_content_layout(true)" in dialogue_system
    ):
        ok("No-choice dialogue text is lowered without moving choice layouts")
    else:
        fail("No-choice dialogue text can remain stuck to the top of the blue frame")

    # Bug regression: dialogue text should stay readable without making the
    # compact panel feel oversized.
    if 'name_label.add_theme_font_size_override("font_size", 18 if not InputManager.is_mobile else 14)' in location_base and 'dialogue_text.add_theme_font_size_override("normal_font_size", 24 if not InputManager.is_mobile else 19)' in location_base:
        ok("Speaker name and dialogue text use readable compact typography")
    else:
        fail("Speaker name or dialogue text can regress to small typography")

    if (
        'dialogue_panel: Control = find_child("DialoguePanel", true, false)' in dialogue_system
        and 'find_child("NameLabel", true, false)' in dialogue_system
        and 'find_child("DialogueText", true, false)' in dialogue_system
        and 'find_child("PortraitLeft", true, false)' in dialogue_system
        and 'find_child("ChoicesContainer", true, false)' in dialogue_system
    ):
        ok("DialogueSystem resolves text nodes inside the frame-root layout")
    else:
        fail("DialogueSystem still assumes direct DialoguePanel/VBox node paths")

    # Bug regression: space should work for keyboard players during dialogue,
    # both for fast-forwarding typewriter text and advancing completed lines.
    if "Input.is_key_pressed(KEY_SPACE)" in dialogue_system and "event.keycode == KEY_SPACE" in dialogue_system:
        ok("Dialogue supports Space for fast-forward and advance")
    else:
        fail("Dialogue does not support Space for fast-forward and advance")

    # Bug regression: long dialogue lines must paginate before they overflow
    # the generated right-side text frame.
    if "_split_dialogue_pages" in dialogue_system and "DESKTOP_DIALOGUE_PAGE_CHARS" in dialogue_system and "_has_more_pages()" in dialogue_system:
        ok("DialogueSystem paginates long text into follow-up pages")
    else:
        fail("DialogueSystem does not paginate long text before overflow")

    # Bug regression: dialogue choices should render as contained button frames
    # inside the generated text panel, not as loose text below the frame.
    if "_create_choice_button_style" in dialogue_system and "COMPACT_CHOICE_PROMPT_TEXT_HEIGHT := 34" in dialogue_system and "COMPACT_CHOICE_BUTTON_HEIGHT := 32" in dialogue_system and "choices_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL" in location_base and "DIALOGUE_BLUE_CONTENT_RECT" in location_base:
        ok("Dialogue choices stay boxed inside the blue dialogue frame")
    else:
        fail("Dialogue choices can render outside the generated dialogue frame")

    # Bug regression: three visible choices previously pushed the third button
    # below the blue frame. DialogueSystem should filter choices first, then
    # switch to a compact layout when three choices are visible.
    if "_get_available_choices" in dialogue_system and "compact_choices := choices.size() >= 3" in dialogue_system and 'choices_container.add_theme_constant_override("separation", COMPACT_CHOICE_GAP if compact_layout else NORMAL_CHOICE_GAP)' in dialogue_system:
        ok("DialogueSystem uses compact in-blue-frame layout for three choices")
    else:
        fail("Three-choice dialogue can overflow outside the blue frame")

    if "for i in range(evidence_list.size())" in evidence_board and "var row: int = int(i / cols)" in evidence_board:
        ok("EvidenceBoard card grid uses safe range iteration and int row conversion")
    else:
        fail("EvidenceBoard card grid still uses unsafe iteration or row conversion")

    # Bug regression: eagle-eye/AP energy should use the generated 10-state
    # cyberpunk PNG HUDs, not shader masks or simplified runtime Panel segments.
    energy_state_names = [f"energy_bar_{i:02d}.png" for i in range(1, 11)]
    energy_source_dir = os.path.join(PROJECT_ROOT, "assets/generated/ui")
    energy_runtime_dir = os.path.join(PROJECT_ROOT, "assets/sprites/ui")
    energy_geometry_path = os.path.join(energy_source_dir, "energy_bar_10_equal_slots_geometry.json")
    energy_assets_ok = True
    for name in energy_state_names:
        source_path = os.path.join(energy_source_dir, name)
        runtime_path = os.path.join(energy_runtime_dir, name)
        if not os.path.exists(source_path) or not os.path.exists(runtime_path):
            energy_assets_ok = False
            fail(f"Missing 10-state energy HUD asset: {name}")
            continue
        if get_png_size(source_path) != (512, 96) or get_png_size(runtime_path) != (512, 96):
            energy_assets_ok = False
            fail(f"10-state energy HUD asset has unstable size: {name}")
        if not png_has_alpha(runtime_path):
            energy_assets_ok = False
            fail(f"10-state energy HUD runtime asset lacks alpha: {name}")
        if file_sha256(source_path) != file_sha256(runtime_path):
            energy_assets_ok = False
            fail(f"10-state energy HUD source/runtime SHA mismatch: {name}")
    if energy_assets_ok:
        ok("All 10 texture-swap energy HUD states exist in generated and runtime paths")

    equal_slot_geometry_ok = False
    if os.path.exists(energy_geometry_path):
        with open(energy_geometry_path, "r", encoding="utf-8") as f:
            energy_geometry = json.load(f)
        equal_slot_geometry_ok = (
            energy_geometry.get("slot_count") == 10
            and energy_geometry.get("slot_width") == 25
            and energy_geometry.get("slot_height") == 22
            and energy_geometry.get("slot_gap") == 3
            and energy_geometry.get("slot_origin") == [142, 36]
            and energy_geometry.get("output_size") == [512, 96]
        )
    if equal_slot_geometry_ok:
        ok("10-state energy HUD records equal slot geometry")
    else:
        fail("10-state energy HUD slot geometry is missing or inconsistent")

    if (
        'ENERGY_BAR_STATE_DIR := "res://assets/sprites/ui"' in augmented_vision
        and "EAGLE_EYE_SEGMENT_COUNT := 10" in augmented_vision
        and "EAGLE_EYE_ENERGY_BAR_RECT := Rect2(-536.0, 20.0, 512.0, 96.0)" in augmented_vision
        and "TechEnergyTexture" in augmented_vision
        and "_set_energy_state_texture" in augmented_vision
        and "energy_bar_%02d.png" in augmented_vision
        and "energy_bar.offset_left = EAGLE_EYE_ENERGY_BAR_RECT.position.x" in augmented_vision
        and "energy_bar.offset_right = EAGLE_EYE_ENERGY_BAR_RECT.position.x + EAGLE_EYE_ENERGY_BAR_RECT.size.x" in augmented_vision
        and "energy_bar.visible = is_visible" in augmented_vision
        and "_create_energy_bar_material" not in augmented_vision
        and "_energy_bar_material" not in augmented_vision
        and "_build_energy_widget" not in augmented_vision
        and "Panel.new()" not in augmented_vision
    ):
        ok("Eagle-eye energy swaps 10 generated tech HUD textures without clipping")
    else:
        fail("Eagle-eye energy can regress to shader/Panel segments or clipped HUD")

    # Bug regression: eagle-eye should spend energy in timed segments and allow
    # the reticle to move over the scene to scan visible hotspots.
    if (
        "EAGLE_EYE_DRAIN_INTERVAL := 1.0" in augmented_vision
        and "consume_eagle_eye_energy_amount(GameManager.eagle_eye_max_energy / float(EAGLE_EYE_SEGMENT_COUNT))" in augmented_vision
        and "func consume_eagle_eye_energy_amount(amount: float)" in game_manager
        and "_set_reticle_target(event.position)" in augmented_vision
        and "_scan_hotspots_under_reticle" in augmented_vision
        and 'add_to_group("hotspots")' in read_file("scripts/gameplay/hotspot.gd")
    ):
        ok("Eagle-eye drains timed 10-state energy segments and moves the scanner reticle")
    else:
        fail("Eagle-eye lacks timed drain or movable reticle scanning")

    # Bug regression: the low-energy pressure should come from image states
    # that move from yellow full-charge art toward red low-charge art.
    if (
        "_get_energy_state_index" in augmented_vision
        and "_load_energy_state_texture" in augmented_vision
        and "floori(ratio * EAGLE_EYE_SEGMENT_COUNT)" in augmented_vision
        and energy_assets_ok
        and equal_slot_geometry_ok
    ):
        ok("Eagle-eye energy HUD uses yellow-to-red 10-state texture logic")
    else:
        fail("Eagle-eye energy HUD lacks yellow-to-red texture-state logic")

    # Bug regression: AP label callbacks should target a member reference, not
    # a local label that can become null after scene reloads.
    if "var _ap_label: Label = null" in location_base and "func _update_ap_label" in location_base and "_update_ap_label(remaining)" in location_base:
        ok("LocationBase updates AP through a guarded member label")
    else:
        fail("LocationBase AP update can assign text on a null local label")

    # Bug regression: prompt-only eagle-eye fallback must stay transparent.
    # Sampling TEXTURE on a ColorRect shader rendered a white full-screen panel.
    if "texture(TEXTURE" not in scanline_shader and "COLOR = vec4(tint_color.rgb, alpha)" in scanline_shader:
        ok("Eagle-eye scanline fallback renders transparent HUD tint")
    else:
        fail("Eagle-eye scanline fallback can render as an opaque white panel")

    # Bug regression: generated AP and title-screen PNGs should be consumed by
    # runtime UI, not only stored as generated assets.
    main_menu = read_file("scripts/ui/main_menu.gd") or ""
    if "main_menu_background.png" in main_menu and "_setup_generated_background" in main_menu and "ColorRect" in main_menu:
        ok("Main menu loads generated background with ColorRect fallback")
    else:
        fail("Main menu generated background is not wired with fallback")

    if (
        "APWidget" in location_base
        and "var _ap_status_bar: TextureRect = null" in location_base
        and "_update_ap_status_bar" in location_base
        and "_get_hud_energy_state" in location_base
        and "HUD_ENERGY_SEGMENT_COUNT := 10" in location_base
        and "HUD_ENERGY_BAR_RECT := Rect2(-536.0, 20.0, 512.0, 96.0)" in location_base
        and "energy_bar_%02d.png" in location_base
        and "_set_ap_widget_visible(false)" in location_base
        and "_set_ap_widget_visible(true)" in location_base
    ):
        ok("LocationBase AP widget swaps generated 10-state status-bar textures")
    else:
        fail("LocationBase AP widget does not swap generated 10-state status-bar textures")


# ---------------------------------------------------------------------------
# 27b. Prompt-only UI generation requests
# AP bar and title-screen prompts should be tracked separately from generated
# runtime sprites so tests do not require PNGs before image generation happens.
# ---------------------------------------------------------------------------
def test_image_gen_ui_prompt_requests():
    print("\n[27b] image_gen UI prompt requests")
    prompt_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image_gen_ui_requests.jsonl")
    if not os.path.exists(prompt_path):
        fail("Missing image_gen UI prompt request manifest")
        return

    with open(prompt_path, "r", encoding="utf-8") as f:
        records = [json.loads(line) for line in f if line.strip()]

    required = {
        "dialogue_panel_compact_name_plate": ("assets/sprites/ui/dialogue_panel.png", (1280, 240)),
        "ap_status_bar_hitech": ("assets/sprites/ui/ap_status_bar.png", (512, 96)),
        "main_menu_start_background": ("assets/sprites/ui/main_menu_background.png", (1280, 720)),
    }
    by_id = {record.get("id"): record for record in records}
    for prompt_id, (target_path, expected_size) in required.items():
        record = by_id.get(prompt_id)
        if not record:
            fail(f"Missing image_gen prompt request: {prompt_id}")
            continue
        real_path = os.path.join(PROJECT_ROOT, target_path)
        if (
            record.get("tool") == "image_gen"
            and record.get("target_runtime_path") == target_path
            and record.get("status") == "generated_connected"
            and record.get("prompt")
            and record.get("negative_prompt")
            and os.path.exists(real_path)
            and get_png_size(real_path) == expected_size
        ):
            ok(f"image_gen prompt request generated and connected: {prompt_id}")
        else:
            fail(f"Incomplete image_gen prompt request: {prompt_id}")

    energy_record = by_id.get("energy_bar_states_10_equal_slots")
    energy_runtime_paths = [
        os.path.join(PROJECT_ROOT, "assets/sprites/ui", f"energy_bar_{i:02d}.png")
        for i in range(1, 11)
    ]
    energy_geometry_path = os.path.join(PROJECT_ROOT, "assets/generated/ui/energy_bar_10_equal_slots_geometry.json")
    if (
        energy_record
        and energy_record.get("tool") == "image_gen+deterministic_normalization"
        and energy_record.get("status") == "generated_equalized_connected"
        and energy_record.get("source_imagegen_path")
        and energy_record.get("geometry_path") == "assets/generated/ui/energy_bar_10_equal_slots_geometry.json"
        and energy_record.get("prompt")
        and energy_record.get("negative_prompt")
        and os.path.exists(energy_geometry_path)
        and all(os.path.exists(path) and get_png_size(path) == (512, 96) for path in energy_runtime_paths)
    ):
        ok("image_gen prompt request generated and connected: energy_bar_states_10_equal_slots")
    else:
        fail("Incomplete image_gen prompt request: energy_bar_states_10_equal_slots")


# ---------------------------------------------------------------------------
# 28. Bug regression: Chapter 1 eagle-eye foreshadowing must remain playable.
# The apartment scan should grant evidence, evidence-board deductions should set
# unlock flags, and prompt-only assets must be ready without requiring PNGs yet.
# ---------------------------------------------------------------------------
def test_ch1_eagle_eye_foreshadowing_wiring():
    print("\n[28] Chapter 1 eagle-eye foreshadowing wiring")
    case_content = read_file("scripts/data/case_data.gd") or ""
    dialogue_content = read_file("scripts/data/dialogue_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""
    board_content = read_file("scripts/gameplay/evidence_board.gd") or ""

    required_dialogues = [
        "ch1_kai_eye_glitch_scan",
        "ch1_eye_signature_decode",
        "ch1_dr_chen_eye_warning",
    ]
    for dialogue_id in required_dialogues:
        if f'"{dialogue_id}": [' in dialogue_content:
            ok(f"Chapter 1 eagle-eye dialogue exists: {dialogue_id}")
        else:
            fail(f"Missing Chapter 1 eagle-eye dialogue: {dialogue_id}")

    required_evidence = {
        "broken_memory_player": "memory_capsule",
        "kai_eye_glitch_log": "log",
    }
    for evidence_id, icon_id in required_evidence.items():
        if f'"{evidence_id}": {{' in evidence_content and f'"icon": "{icon_id}"' in evidence_content:
            ok(f"Chapter 1 eagle-eye evidence exists with runtime icon: {evidence_id}")
        else:
            fail(f"Missing or incomplete Chapter 1 eagle-eye evidence: {evidence_id}")

    if '"dialogue": "ch1_kai_eye_glitch_scan"' in case_content and '"requires_evidence": "commission_letter"' in case_content:
        ok("Mei Ling apartment scan action is gated by the accepted case evidence")
    else:
        fail("Mei Ling apartment scan action is not wired to the case evidence gate")

    if '"dialogue": "ch1_eye_signature_decode"' in case_content and '"requires_flag": "deduced_eye_echo_signature"' in case_content:
        ok("Workshop eye-signature decode action requires evidence-board deduction")
    else:
        fail("Workshop eye-signature decode action is not gated by the deduction flag")

    if '"dialogue": "ch1_dr_chen_eye_warning"' in case_content and '"requires_flag": "deduced_player_echo_codec"' in case_content:
        ok("Dr. Chen warning action requires player-codec deduction")
    else:
        fail("Dr. Chen warning action is not gated by the deduction flag")

    expected_connections = [
        '"broken_memory_player": "memory_device_log"',
        '"kai_eye_glitch_log": "data_chip"',
        '"broken_memory_player:memory_device_log": "deduced_player_echo_codec"',
        '"kai_eye_glitch_log:data_chip": "deduced_eye_echo_signature"',
    ]
    for snippet in expected_connections:
        if snippet in board_content:
            ok(f"Evidence board wiring present: {snippet}")
        else:
            fail(f"Missing evidence board wiring: {snippet}")

    if "GameManager.set_dialogue_flag(deduction_flag)" in board_content:
        ok("Correct evidence-board deductions unlock dialogue flags")
    else:
        fail("Evidence-board deductions do not unlock dialogue flags")

    prompt_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image2_ch1_eagle_eye.jsonl")
    if not os.path.exists(prompt_path):
        fail("Missing Chapter 1 eagle-eye prompt manifest")
        return

    with open(prompt_path, "r", encoding="utf-8") as f:
        records = [json.loads(line) for line in f if line.strip()]

    expected_prompt_ids = {
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
    actual_ids = {record.get("id") for record in records}
    missing_ids = expected_prompt_ids - actual_ids
    if missing_ids:
        for prompt_id in sorted(missing_ids):
            fail(f"Missing Chapter 1 eagle-eye prompt record: {prompt_id}")
    else:
        ok("Chapter 1 eagle-eye prompt manifest covers image and audio prompts")

    for record in records:
        output_path = record.get("output_path") or record.get("generated_output_path")
        if record.get("prompt") and output_path and record.get("output_format"):
            ok(f"Chapter 1 prompt complete: {record.get('id')}")
        else:
            fail(f"Incomplete Chapter 1 prompt record: {record}")

    required_assets = {
        "assets/sprites/ui/eagle_eye_scan_overlay_ch1.png": (1280, 720),
        "assets/sprites/ui/eagle_eye_focus_reticle_ch1.png": (512, 512),
        "assets/sprites/ui/eagle_eye_glitch_noise_ch1.png": (1280, 720),
        "assets/sprites/locations/mei_ling_apartment_eye_scan_variant.png": (1280, 720),
        "assets/sprites/cg/cg_kai_eye_glitch.png": (1280, 720),
        "assets/sprites/cg/eagle_eye_activation_cutin_ch1.png": (1280, 720),
        "assets/sprites/items/broken_memory_player.png": (512, 512),
        "assets/sprites/items/kai_eye_glitch_log.png": (512, 512),
    }
    for rel_path, expected_size in required_assets.items():
        real_path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.exists(real_path):
            fail(f"Missing generated eagle-eye runtime asset: {rel_path}")
            continue
        if get_png_size(real_path) == expected_size:
            ok(f"Generated eagle-eye asset ready: {rel_path}")
        else:
            fail(f"Generated eagle-eye asset has wrong size: {rel_path}")

    generated_pairs = {
        "assets/generated/ui/eagle_eye_scan_overlay_ch1.png": "assets/sprites/ui/eagle_eye_scan_overlay_ch1.png",
        "assets/generated/ui/eagle_eye_focus_reticle_ch1.png": "assets/sprites/ui/eagle_eye_focus_reticle_ch1.png",
        "assets/generated/ui/eagle_eye_glitch_noise_ch1.png": "assets/sprites/ui/eagle_eye_glitch_noise_ch1.png",
        "assets/generated/backgrounds/mei_ling_apartment_eye_scan_variant.png": "assets/sprites/locations/mei_ling_apartment_eye_scan_variant.png",
        "assets/generated/cg/cg_kai_eye_glitch.png": "assets/sprites/cg/cg_kai_eye_glitch.png",
        "assets/generated/cg/eagle_eye_activation_cutin_ch1.png": "assets/sprites/cg/eagle_eye_activation_cutin_ch1.png",
        "assets/generated/items/ch1_broken_memory_player.png": "assets/sprites/items/broken_memory_player.png",
        "assets/generated/items/ch1_kai_eye_glitch_log.png": "assets/sprites/items/kai_eye_glitch_log.png",
    }
    for generated_rel, runtime_rel in generated_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path) and file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Generated eagle-eye source matches runtime asset: {runtime_rel}")
        else:
            fail(f"Generated eagle-eye source does not match runtime asset: {runtime_rel}")

    augmented_content = read_file("scripts/gameplay/augmented_vision.gd") or ""
    location_content = read_file("scripts/ui/location_base.gd") or ""
    runtime_checks = [
        ("AugmentedVision loads generated reticle", "eagle_eye_focus_reticle_ch1.png" in augmented_content),
        ("AugmentedVision loads glitch noise", "eagle_eye_glitch_noise_ch1.png" in augmented_content),
        ("AugmentedVision loads activation cut-in", "eagle_eye_activation_cutin_ch1.png" in augmented_content),
        ("LocationBase triggers key clue anomaly", "trigger_glitch_pulse" in location_content),
        ("Evidence prefers dedicated eagle-eye icons", '"preferred_icon": "broken_memory_player"' in evidence_content and '"preferred_icon": "kai_eye_glitch_log"' in evidence_content),
    ]
    for label, passed_check in runtime_checks:
        if passed_check:
            ok(label)
        else:
            fail(label)


# ---------------------------------------------------------------------------
# 29. Bug regression: Chapter 1 family memory branch must be playable.
# The family-memory clue should grant evidence, connect on the evidence board,
# trigger a safe eagle-eye anomaly, and keep placeholder assets replaceable.
# ---------------------------------------------------------------------------
def test_ch1_family_memory_branch():
    print("\n[29] Chapter 1 family memory branch")
    case_content = read_file("scripts/data/case_data.gd") or ""
    dialogue_content = read_file("scripts/data/dialogue_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""
    board_content = read_file("scripts/gameplay/evidence_board.gd") or ""
    location_content = read_file("scripts/ui/location_base.gd") or ""

    if '"ch1_family_memory_clip": [' in dialogue_content and '"ch1_hao_ran_family_motive": [' in dialogue_content:
        ok("Family memory dialogues exist")
    else:
        fail("Missing family memory dialogue branch")

    if '"family_memory_clip": {' in evidence_content and '"preferred_icon": "family_memory_clip"' in evidence_content:
        ok("Family memory evidence has preferred runtime icon")
    else:
        fail("Family memory evidence is missing or has no preferred icon")

    if '"id": "review_family_memory_clip"' in case_content and '"dialogue": "ch1_family_memory_clip"' in case_content and '"requires_evidence": "commission_letter"' in case_content:
        ok("Mei Ling apartment family memory story action is reachable")
    else:
        fail("Family memory story action is not wired in Mei Ling apartment")

    if '"id": "reconstruct_hao_ran_motive"' in case_content and '"requires_flag": "deduced_hao_ran_family_motive"' in case_content and '"requires_evidence": "family_memory_clip"' in case_content:
        ok("Hao Ran motive follow-up is gated by family memory deduction")
    else:
        fail("Hao Ran motive follow-up is not gated by the family memory deduction")

    if '"family_memory_clip": "broken_memory_player"' in board_content and '"family_memory_clip:broken_memory_player": "deduced_hao_ran_family_motive"' in board_content:
        ok("Evidence board links family memory to broken player motive")
    else:
        fail("Evidence board does not unlock the Hao Ran family motive flag")

    if '"give_evidence": "family_memory_clip"' in dialogue_content and '"set_flag": "found_family_memory_clip"' in dialogue_content and '"set_flag": "mei_ling_trust_opened"' in dialogue_content:
        ok("Family memory dialogue grants evidence and trust flags")
    else:
        fail("Family memory dialogue does not grant required evidence or flags")

    if "review_family_memory_clip" in location_content and "trigger_glitch_pulse" in location_content and "mei_ling_apartment_family_memory_variant.png" in location_content:
        ok("Family memory action triggers safe eagle-eye anomaly and scene variant")
    else:
        fail("Family memory action is not wired to eagle-eye anomaly presentation")

    prompt_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image2_ch1_family_memory.jsonl")
    if not os.path.exists(prompt_path):
        fail("Missing Chapter 1 family memory prompt manifest")
        return

    with open(prompt_path, "r", encoding="utf-8") as f:
        records = [json.loads(line) for line in f if line.strip()]
    expected_ids = {
        "family_memory_clip",
        "cg_family_memory_clip",
        "mei_ling_apartment_family_memory_variant",
        "family_memory_fragment",
    }
    actual_ids = {record.get("id") for record in records}
    for prompt_id in sorted(expected_ids - actual_ids):
        fail(f"Missing family memory prompt record: {prompt_id}")
    if expected_ids.issubset(actual_ids):
        ok("Family memory prompt manifest covers image and audio placeholders")

    required_png_assets = {
        "assets/sprites/items/family_memory_clip.png": (512, 512),
        "assets/sprites/cg/cg_family_memory_clip.png": (1280, 720),
        "assets/sprites/locations/mei_ling_apartment_family_memory_variant.png": (1280, 720),
    }
    for rel_path, expected_size in required_png_assets.items():
        real_path = os.path.join(PROJECT_ROOT, rel_path)
        if os.path.exists(real_path) and get_png_size(real_path) == expected_size:
            ok(f"Family memory placeholder PNG ready: {rel_path}")
        else:
            fail(f"Missing or wrong-size family memory placeholder PNG: {rel_path}")

    audio_path = os.path.join(PROJECT_ROOT, "assets/audio/sfx/family_memory_fragment.ogg")
    if os.path.exists(audio_path) and os.path.getsize(audio_path) > 0:
        ok("Family memory placeholder audio target exists")
    else:
        fail("Missing family memory placeholder audio target")

    generated_pairs = {
        "assets/generated/items/ch1_family_memory_clip.png": "assets/sprites/items/family_memory_clip.png",
        "assets/generated/cg/cg_family_memory_clip.png": "assets/sprites/cg/cg_family_memory_clip.png",
        "assets/generated/backgrounds/mei_ling_apartment_family_memory_variant.png": "assets/sprites/locations/mei_ling_apartment_family_memory_variant.png",
        "assets/generated/audio/ch1/family_memory_fragment.ogg": "assets/audio/sfx/family_memory_fragment.ogg",
    }
    for generated_rel, runtime_rel in generated_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path) and file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Family memory generated source matches runtime target: {runtime_rel}")
        else:
            fail(f"Family memory generated source does not match runtime target: {runtime_rel}")


# ---------------------------------------------------------------------------
# 30. Bug regression: Chapter 1 replacement prompts and optional assets must
# stay ready for formal generation without crashing on missing/placeholder SFX.
# ---------------------------------------------------------------------------
def test_ch1_asset_replacement_readiness():
    print("\n[30] Chapter 1 asset replacement readiness")
    manifest_paths = [
        "assets/generated/prompts/image2_ch1_family_memory.jsonl",
        "assets/generated/prompts/audio_ch1_replacement_prompts.jsonl",
    ]
    required_fields = {
        "id",
        "asset_type",
        "target_path",
        "runtime_usage",
        "prompt",
        "negative_prompt",
        "fallback_path",
        "acceptance_notes",
    }
    records_by_id = {}
    for rel_path in manifest_paths:
        path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.exists(path):
            fail(f"Missing replacement manifest: {rel_path}")
            continue
        with open(path, "r", encoding="utf-8") as f:
            records = [json.loads(line) for line in f if line.strip()]
        if records:
            ok(f"Replacement manifest parses: {rel_path}")
        else:
            fail(f"Replacement manifest has no records: {rel_path}")
        for record in records:
            missing = sorted(field for field in required_fields if not record.get(field))
            if missing:
                fail(f"Replacement prompt record missing fields {missing}: {record.get('id')}")
            else:
                ok(f"Replacement prompt record complete: {record.get('id')}")
            records_by_id[record.get("id")] = record

    expected_targets = {
        "family_memory_clip": "assets/sprites/items/family_memory_clip.png",
        "cg_family_memory_clip": "assets/sprites/cg/cg_family_memory_clip.png",
        "mei_ling_apartment_family_memory_variant": "assets/sprites/locations/mei_ling_apartment_family_memory_variant.png",
        "family_memory_fragment": "assets/audio/sfx/family_memory_fragment.ogg",
        "eagle_eye_glitch_sting": "assets/audio/sfx/eagle_eye_glitch_sting.ogg",
        "broken_player_scan": "assets/audio/sfx/broken_player_scan.ogg",
        "memory_signature_reveal": "assets/audio/sfx/memory_signature_reveal.ogg",
    }
    for asset_id, target_path in expected_targets.items():
        record = records_by_id.get(asset_id)
        if record and record.get("target_path") == target_path:
            ok(f"Replacement target path stable: {asset_id}")
        else:
            fail(f"Replacement target path missing or wrong: {asset_id}")

    family_records = []
    family_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image2_ch1_family_memory.jsonl")
    if os.path.exists(family_path):
        with open(family_path, "r", encoding="utf-8") as f:
            family_records = [json.loads(line) for line in f if line.strip()]
    placeholder_records = [record for record in family_records if record.get("status") == "placeholder_connected"]
    if len(placeholder_records) == len(family_records) and family_records:
        ok("Family memory manifest marks current assets as placeholder-connected")
    else:
        fail("Family memory placeholders are not clearly marked")

    audio_manager = read_file("scripts/core/audio_manager.gd") or ""
    augmented = read_file("scripts/gameplay/augmented_vision.gd") or ""
    board = read_file("scripts/gameplay/evidence_board.gd") or ""
    location = read_file("scripts/ui/location_base.gd") or ""
    dialogue_system = read_file("scripts/gameplay/dialogue_system.gd") or ""
    case_content = read_file("scripts/data/case_data.gd") or ""

    runtime_checks = [
        ("AudioManager exposes optional SFX loader", "func play_optional_sfx" in audio_manager),
        ("AudioManager skips non-OggS placeholders", 'signature == "OggS"' in audio_manager),
        ("AugmentedVision wires glitch sting as optional SFX", "EAGLE_EYE_GLITCH_STING_SFX" in augmented and "play_optional_sfx" in augmented),
        ("EvidenceBoard wires deduction reveal as optional SFX", "MEMORY_SIGNATURE_REVEAL_SFX" in board and "play_optional_sfx" in board),
        ("LocationBase wires family and scan SFX as optional", "FAMILY_MEMORY_FRAGMENT_SFX" in location and "BROKEN_PLAYER_SCAN_SFX" in location and "play_optional_sfx" in location),
        ("Family memory action declares story CG", '"story_cg": "cg_family_memory_clip"' in case_content),
        ("LocationBase can show story CG with missing-file fallback", "func _show_story_cg" in location and "if texture == null:" in location),
        ("DialogueSystem supports future story CG entries safely", "func _show_story_cg" in dialogue_system and "func _hide_story_cg" in dialogue_system),
    ]
    for label, passed_check in runtime_checks:
        if passed_check:
            ok(label)
        else:
            fail(label)

    family_audio = os.path.join(PROJECT_ROOT, "assets/audio/sfx/family_memory_fragment.ogg")
    if os.path.exists(family_audio):
        with open(family_audio, "rb") as f:
            header = f.read(4)
        if header != b"OggS" and "placeholder" in (records_by_id.get("family_memory_fragment", {}).get("status", "")):
            ok("Placeholder family memory SFX is documented and skipped until formal OGG replacement")
        elif header == b"OggS":
            ok("Family memory SFX is a formal OGG stream")
        else:
            fail("Family memory SFX placeholder state is not documented")


# ---------------------------------------------------------------------------
# 31. Bug regression: Chapter 1 opening and Mei Ling trust path should be
# longer, playable, and connected to generated image assets.
# ---------------------------------------------------------------------------
def test_ch1_opening_and_mei_ling_trust_expansion():
    print("\n[31] Chapter 1 opening and Mei Ling trust expansion")
    case_content = read_file("scripts/data/case_data.gd") or ""
    dialogue_content = read_file("scripts/data/dialogue_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""
    board_content = read_file("scripts/gameplay/evidence_board.gd") or ""

    if '"show_cg": "cg_kai_office_prologue"' in dialogue_content and "正和科技安全調查員" in dialogue_content:
        ok("New-game opening shows Kai office prologue CG before Mei Ling enters")
    else:
        fail("Opening still lacks the Kai office prologue CG setup")

    expected_dialogues = [
        "ch1_hao_ran_drawer_search",
        "ch1_original_backup_album",
        "ch1_hao_ran_encrypted_message",
    ]
    for dialogue_id in expected_dialogues:
        if f'"{dialogue_id}": [' in dialogue_content:
            ok(f"Chapter 1 expanded dialogue exists: {dialogue_id}")
        else:
            fail(f"Missing expanded Chapter 1 dialogue: {dialogue_id}")

    expected_actions = {
        "inspect_hao_ran_drawer": "ch1_hao_ran_drawer_search",
        "inspect_original_backup_album": "ch1_original_backup_album",
        "decode_hao_ran_last_message": "ch1_hao_ran_encrypted_message",
    }
    for action_id, dialogue_id in expected_actions.items():
        if f'"id": "{action_id}"' in case_content and f'"dialogue": "{dialogue_id}"' in case_content:
            ok(f"Expanded story action wired: {action_id}")
        else:
            fail(f"Expanded story action missing or miswired: {action_id}")

    expected_evidence = {
        "hao_ran_drawer_note": "hao_ran_drawer_note",
        "original_backup_hint": "original_backup_hint",
        "hao_ran_encrypted_message": "log",
    }
    for evidence_id, preferred_or_icon in expected_evidence.items():
        if f'"{evidence_id}": {{' not in evidence_content:
            fail(f"Missing expanded Chapter 1 evidence: {evidence_id}")
            continue
        if f'"preferred_icon": "{preferred_or_icon}"' in evidence_content or f'"icon": "{preferred_or_icon}"' in evidence_content:
            ok(f"Expanded evidence has runtime icon/fallback: {evidence_id}")
        else:
            fail(f"Expanded evidence lacks runtime icon/fallback: {evidence_id}")

    if '"original_backup_hint": "hao_ran_encrypted_message"' in board_content and '"original_backup_hint:hao_ran_encrypted_message": "deduced_mei_ling_original_backup"' in board_content:
        ok("Evidence board connects original backup hint to Hao Ran message")
    else:
        fail("Evidence board does not unlock the Mei Ling original-backup deduction")

    required_assets = {
        "assets/sprites/cg/cg_kai_office_prologue.png": (1280, 720),
        "assets/sprites/cg/cg_mei_ling_apartment_memory_trace.png": (1280, 720),
        "assets/sprites/cg/cg_hao_ran_encrypted_message.png": (1280, 720),
        "assets/sprites/items/hao_ran_drawer_note.png": (512, 512),
        "assets/sprites/items/original_backup_hint.png": (512, 512),
    }
    for rel_path, expected_size in required_assets.items():
        real_path = os.path.join(PROJECT_ROOT, rel_path)
        if os.path.exists(real_path) and get_png_size(real_path) == expected_size:
            ok(f"Generated trust-path asset connected: {rel_path}")
        else:
            fail(f"Missing or wrong-size trust-path asset: {rel_path}")

    generated_pairs = {
        "assets/generated/cg/cg_kai_office_prologue.png": "assets/sprites/cg/cg_kai_office_prologue.png",
        "assets/generated/cg/cg_mei_ling_apartment_memory_trace.png": "assets/sprites/cg/cg_mei_ling_apartment_memory_trace.png",
        "assets/generated/cg/cg_hao_ran_encrypted_message.png": "assets/sprites/cg/cg_hao_ran_encrypted_message.png",
        "assets/generated/items/ch1_hao_ran_drawer_note.png": "assets/sprites/items/hao_ran_drawer_note.png",
        "assets/generated/items/ch1_original_backup_hint.png": "assets/sprites/items/original_backup_hint.png",
    }
    for generated_rel, runtime_rel in generated_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path) and file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Generated trust-path source matches runtime target: {runtime_rel}")
        else:
            fail(f"Generated trust-path source does not match runtime target: {runtime_rel}")

    prompt_path = os.path.join(PROJECT_ROOT, "assets/generated/prompts/image_gen_ch1_opening_trust_path.jsonl")
    if not os.path.exists(prompt_path):
        fail("Missing image_gen prompt manifest for Chapter 1 trust expansion")
        return
    with open(prompt_path, "r", encoding="utf-8") as f:
        records = [json.loads(line) for line in f if line.strip()]
    expected_prompt_ids = {
        "cg_kai_office_prologue",
        "hao_ran_drawer_note",
        "original_backup_hint",
        "cg_hao_ran_encrypted_message",
        "cg_mei_ling_apartment_memory_trace",
    }
    actual_prompt_ids = {record.get("id") for record in records}
    for prompt_id in sorted(expected_prompt_ids - actual_prompt_ids):
        fail(f"Missing image_gen trust-path prompt record: {prompt_id}")
    if expected_prompt_ids.issubset(actual_prompt_ids):
        ok("image_gen trust-path manifest covers all generated assets")


# ---------------------------------------------------------------------------
# 32. Bug regression: Chapter 1 expanded branch must preserve the three-proof
# gate, dual Chapter 2 route flags, and eagle-eye second readings.
# ---------------------------------------------------------------------------
def test_ch1_expanded_dual_route_and_eagle_eye_readings():
    print("\n[32] Chapter 1 expanded dual-route and eagle-eye readings")
    case_content = read_file("scripts/data/case_data.gd") or ""
    dialogue_content = read_file("scripts/data/dialogue_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""
    board_content = read_file("scripts/gameplay/evidence_board.gd") or ""
    game_manager = read_file("scripts/core/game_manager.gd") or ""
    decision_tracker = read_file("scripts/gameplay/decision_tracker.gd") or ""
    location_content = read_file("scripts/ui/location_base.gd") or ""

    expected_dialogues = [
        "ch1_eleven_pm_call_log",
        "ch1_old_city_police_outpost",
        "ch1_street_camera_gap",
        "ch1_abyss_backroom_investigation",
        "ch1_snake_data_chip_choice",
        "ch1_dr_chen_clinic_followup",
        "ch1_three_evidence_inference",
    ]
    for dialogue_id in expected_dialogues:
        if f'"{dialogue_id}": [' in dialogue_content:
            ok(f"Expanded Chapter 1 dialogue exists: {dialogue_id}")
        else:
            fail(f"Missing expanded Chapter 1 dialogue: {dialogue_id}")

    expected_actions = {
        "inspect_eleven_pm_call_log": "ch1_eleven_pm_call_log",
        "visit_old_city_police_outpost": "ch1_old_city_police_outpost",
        "review_east_district_camera_gap": "ch1_street_camera_gap",
        "investigate_abyss_backroom": "ch1_abyss_backroom_investigation",
        "negotiate_snake_data_chip": "ch1_snake_data_chip_choice",
        "visit_dr_chen_clinic": "ch1_dr_chen_clinic_followup",
        "compile_ch1_three_evidence_inference": "ch1_three_evidence_inference",
    }
    for action_id, dialogue_id in expected_actions.items():
        if f'"id": "{action_id}"' in case_content and f'"dialogue": "{dialogue_id}"' in case_content:
            ok(f"Expanded story action wired: {action_id}")
        else:
            fail(f"Expanded story action missing or miswired: {action_id}")

    expected_evidence = [
        "eleven_pm_call_log",
        "rejected_missing_person_report",
        "street_camera_gap",
        "masked_client_receipt",
        "clinic_eye_warning_log",
        "black_market_entry_hint",
    ]
    for evidence_id in expected_evidence:
        if f'"{evidence_id}": {{' in evidence_content:
            ok(f"Expanded Chapter 1 evidence exists: {evidence_id}")
        else:
            fail(f"Missing expanded Chapter 1 evidence: {evidence_id}")

    eye_reading_count = evidence_content.count('"eye_reading"')
    if eye_reading_count >= 10:
        ok("Chapter 1 evidence has broad eagle-eye second readings")
    else:
        fail("Chapter 1 evidence lacks enough eagle-eye second readings")

    required_board_flags = [
        '"eleven_pm_call_log:rejected_missing_person_report": "deduced_police_suppression"',
        '"rejected_missing_person_report:street_camera_gap": "deduced_city_system_suppression"',
        '"masked_client_receipt:stranger_photo": "deduced_ch1_black_market_route"',
        '"clinic_eye_warning_log:masked_client_receipt": "deduced_ch1_three_evidence_gate"',
    ]
    for expected in required_board_flags:
        if expected in board_content:
            ok(f"Expanded evidence-board flag wired: {expected}")
        else:
            fail(f"Missing expanded evidence-board flag: {expected}")

    required_route_flags = [
        "accepted_snake_deal",
        "rejected_snake_deal",
        "black_market_route_opened",
        "clinic_route_opened",
        "echo_trust_axis_seeded",
    ]
    for flag in required_route_flags:
        if flag in dialogue_content or flag in game_manager:
            ok(f"Expanded route flag present: {flag}")
        else:
            fail(f"Missing expanded route flag: {flag}")

    if "eagle_eye_overuse_count" in game_manager and "kai_eye_overuse_warning" in game_manager:
        ok("Eagle-eye overuse count and warning flag are tracked")
    else:
        fail("Eagle-eye overuse count or warning flag is missing")

    if "_get_evidence_reading_text" in board_content and '"eye_reading"' in board_content and "GameManager.eagle_eye_active" in board_content:
        ok("Evidence board displays alternate evidence readings in eagle-eye mode")
    else:
        fail("Evidence board does not expose eagle-eye alternate evidence readings")

    if "/ 37.0" in game_manager and "/ 37.0" in decision_tracker:
        ok("Ending evidence ratio denominator matches expanded evidence count")
    else:
        fail("Ending evidence ratio denominator was not updated for expanded evidence")

    if "compile_ch1_three_evidence_inference" in location_content and "trigger_glitch_pulse" in location_content:
        ok("Expanded Chapter 1 final inference triggers eagle-eye anomaly presentation")
    else:
        fail("Expanded Chapter 1 final inference lacks eagle-eye anomaly presentation")


# ---------------------------------------------------------------------------
# 33. Bug regression: Chapter 1 missing visual assets must be generated,
# runtime-connected, and protected from placeholder fallback.
# ---------------------------------------------------------------------------
def test_ch1_missing_visual_assets_connected():
    print("\n[33] Chapter 1 missing visual assets connected")
    case_content = read_file("scripts/data/case_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""

    background_pairs = {
        "assets/generated/backgrounds/old_city_police_outpost.png": "assets/sprites/locations/old_city_police_outpost.png",
        "assets/generated/backgrounds/dr_chen_clinic.png": "assets/sprites/locations/dr_chen_clinic.png",
        "assets/generated/backgrounds/abyss_bar_backroom.png": "assets/sprites/locations/abyss_bar_backroom.png",
        "assets/generated/backgrounds/east_district_street_camera_gap_variant.png": "assets/sprites/locations/east_district_street_camera_gap_variant.png",
        "assets/generated/backgrounds/hao_ran_workshop_three_evidence_variant.png": "assets/sprites/locations/hao_ran_workshop_three_evidence_variant.png",
    }
    icon_pairs = {
        "assets/generated/items/ch1_commission_letter.png": "assets/sprites/items/commission_letter.png",
        "assets/generated/items/ch1_work_id.png": "assets/sprites/items/work_id.png",
        "assets/generated/items/ch1_receipt.png": "assets/sprites/items/receipt.png",
        "assets/generated/items/ch1_data_chip.png": "assets/sprites/items/data_chip.png",
        "assets/generated/items/ch1_recording.png": "assets/sprites/items/recording.png",
        "assets/generated/items/ch1_photo.png": "assets/sprites/items/photo.png",
        "assets/generated/items/ch1_kai_eye_glitch_log.png": "assets/sprites/items/kai_eye_glitch_log.png",
        "assets/generated/items/ch1_family_memory_clip.png": "assets/sprites/items/family_memory_clip.png",
        "assets/generated/items/ch1_broken_memory_player.png": "assets/sprites/items/broken_memory_player.png",
        "assets/generated/items/ch1_eleven_pm_call_log.png": "assets/sprites/items/eleven_pm_call_log.png",
        "assets/generated/items/ch1_rejected_missing_person_report.png": "assets/sprites/items/rejected_missing_person_report.png",
        "assets/generated/items/ch1_street_camera_gap.png": "assets/sprites/items/street_camera_gap.png",
        "assets/generated/items/ch1_masked_client_receipt.png": "assets/sprites/items/masked_client_receipt.png",
        "assets/generated/items/ch1_clinic_eye_warning_log.png": "assets/sprites/items/clinic_eye_warning_log.png",
        "assets/generated/items/ch1_black_market_entry_hint.png": "assets/sprites/items/black_market_entry_hint.png",
    }
    cg_pairs = {
        "assets/generated/cg/cg_ch1_snake_trade_choice.png": "assets/sprites/cg/cg_ch1_snake_trade_choice.png",
        "assets/generated/cg/cg_ch1_three_evidence_inference.png": "assets/sprites/cg/cg_ch1_three_evidence_inference.png",
        "assets/generated/cg/cg_ch1_police_report_rejection.png": "assets/sprites/cg/cg_ch1_police_report_rejection.png",
        "assets/generated/cg/cg_ch1_street_camera_gap.png": "assets/sprites/cg/cg_ch1_street_camera_gap.png",
        "assets/generated/cg/cg_ch1_dr_chen_warning.png": "assets/sprites/cg/cg_ch1_dr_chen_warning.png",
    }

    for generated_rel, runtime_rel in background_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path):
            ok(f"Chapter 1 background source and runtime exist: {runtime_rel}")
        else:
            fail(f"Missing Chapter 1 background source/runtime pair: {runtime_rel}")
            continue
        if get_png_size(generated_path) == (1280, 720) and get_png_size(runtime_path) == (1280, 720):
            ok(f"Chapter 1 background size stable: {runtime_rel}")
        else:
            fail(f"Chapter 1 background size mismatch: {runtime_rel}")
        if file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Chapter 1 background source matches runtime: {runtime_rel}")
        else:
            fail(f"Chapter 1 background source/runtime mismatch: {runtime_rel}")

    for generated_rel, runtime_rel in icon_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path):
            ok(f"Chapter 1 evidence icon source and runtime exist: {runtime_rel}")
        else:
            fail(f"Missing Chapter 1 evidence icon source/runtime pair: {runtime_rel}")
            continue
        if get_png_size(generated_path) == (512, 512) and get_png_size(runtime_path) == (512, 512):
            ok(f"Chapter 1 evidence icon size stable: {runtime_rel}")
        else:
            fail(f"Chapter 1 evidence icon size mismatch: {runtime_rel}")
        if png_has_alpha(generated_path) and png_has_alpha(runtime_path):
            ok(f"Chapter 1 evidence icon keeps alpha channel: {runtime_rel}")
        else:
            fail(f"Chapter 1 evidence icon lacks alpha channel: {runtime_rel}")
        if file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Chapter 1 evidence icon source matches runtime: {runtime_rel}")
        else:
            fail(f"Chapter 1 evidence icon source/runtime mismatch: {runtime_rel}")
        # Bug regression: placeholder line-art item icons were accidentally left in runtime.
        if os.path.getsize(generated_path) >= 100_000 and os.path.getsize(runtime_path) >= 100_000:
            ok(f"Chapter 1 evidence icon is image-gen replacement quality: {runtime_rel}")
        else:
            fail(f"Chapter 1 evidence icon still looks like a tiny placeholder: {runtime_rel}")

    for generated_rel, runtime_rel in cg_pairs.items():
        generated_path = os.path.join(PROJECT_ROOT, generated_rel)
        runtime_path = os.path.join(PROJECT_ROOT, runtime_rel)
        if os.path.exists(generated_path) and os.path.exists(runtime_path):
            ok(f"Chapter 1 story CG source and runtime exist: {runtime_rel}")
        else:
            fail(f"Missing Chapter 1 story CG source/runtime pair: {runtime_rel}")
            continue
        if get_png_size(generated_path) == (1280, 720) and get_png_size(runtime_path) == (1280, 720):
            ok(f"Chapter 1 story CG size stable: {runtime_rel}")
        else:
            fail(f"Chapter 1 story CG size mismatch: {runtime_rel}")
        if file_sha256(generated_path) == file_sha256(runtime_path):
            ok(f"Chapter 1 story CG source matches runtime: {runtime_rel}")
        else:
            fail(f"Chapter 1 story CG source/runtime mismatch: {runtime_rel}")

    expected_icon_fields = {
        "eleven_pm_call_log": "eleven_pm_call_log",
        "rejected_missing_person_report": "rejected_missing_person_report",
        "street_camera_gap": "street_camera_gap",
        "masked_client_receipt": "masked_client_receipt",
        "clinic_eye_warning_log": "clinic_eye_warning_log",
        "black_market_entry_hint": "black_market_entry_hint",
    }
    for evidence_id, icon_id in expected_icon_fields.items():
        pattern = rf'"{evidence_id}": \{{[\s\S]*?"icon": "{icon_id}"'
        if re.search(pattern, evidence_content):
            ok(f"Chapter 1 evidence uses dedicated icon: {evidence_id}")
        else:
            fail(f"Chapter 1 evidence still uses placeholder icon: {evidence_id}")

    expected_story_cgs = {
        "investigate_abyss_backroom": "cg_ch1_snake_trade_choice",
        "negotiate_snake_data_chip": "cg_ch1_snake_trade_choice",
        "compile_ch1_three_evidence_inference": "cg_ch1_three_evidence_inference",
        "visit_old_city_police_outpost": "cg_ch1_police_report_rejection",
        "review_east_district_camera_gap": "cg_ch1_street_camera_gap",
        "visit_dr_chen_clinic": "cg_ch1_dr_chen_warning",
    }
    for action_id, cg_id in expected_story_cgs.items():
        pattern = rf'"id": "{action_id}"[\s\S]*?"story_cg": "{cg_id}"'
        if re.search(pattern, case_content):
            ok(f"Chapter 1 story action declares CG: {action_id}")
        else:
            fail(f"Chapter 1 story action missing CG: {action_id}")


# ---------------------------------------------------------------------------
# 34. Bug regression: Chapter 1 locationization must keep the new police,
# clinic, and backroom locations playable without duplicating moved actions.
# ---------------------------------------------------------------------------
def test_ch1_locationization_and_side_evidence():
    print("\n[34] Chapter 1 locationization and side evidence")
    scene_content = read_file("scripts/core/scene_manager.gd") or ""
    case_content = read_file("scripts/data/case_data.gd") or ""
    dialogue_content = read_file("scripts/data/dialogue_data.gd") or ""
    evidence_content = read_file("scripts/data/evidence_data.gd") or ""
    board_content = read_file("scripts/gameplay/evidence_board.gd") or ""
    location_base = read_file("scripts/ui/location_base.gd") or ""
    dialogue_system = read_file("scripts/gameplay/dialogue_system.gd") or ""
    game_manager = read_file("scripts/core/game_manager.gd") or ""
    decision_tracker = read_file("scripts/gameplay/decision_tracker.gd") or ""
    prompt_doc = read_file("docs/ch1_locationization_evidence_image_prompts.md") or ""

    expected_locations = {
        "old_city_police_outpost": {
            "scene": "scenes/locations/chapter1/old_city_police_outpost.tscn",
            "background": "assets/sprites/locations/old_city_police_outpost.png",
            "parent": "east_district_street",
            "gate": "eleven_pm_call_log",
        },
        "dr_chen_clinic": {
            "scene": "scenes/locations/chapter1/dr_chen_clinic.tscn",
            "background": "assets/sprites/locations/dr_chen_clinic.png",
            "parent": "east_district_street",
            "gate": "kai_eye_glitch_log",
        },
        "abyss_bar_backroom": {
            "scene": "scenes/locations/chapter1/abyss_bar_backroom.tscn",
            "background": "assets/sprites/locations/abyss_bar_backroom.png",
            "parent": "abyss_bar",
            "gate": "stranger_photo",
        },
    }

    for loc_id, data in expected_locations.items():
        if f'"{loc_id}": "res://{data["scene"]}"' in scene_content:
            ok(f"Chapter 1 location scene path registered: {loc_id}")
        else:
            fail(f"Missing Chapter 1 location scene path: {loc_id}")

        if os.path.exists(os.path.join(PROJECT_ROOT, data["scene"])):
            ok(f"Chapter 1 location scene exists: {loc_id}")
        else:
            fail(f"Missing Chapter 1 location scene file: {loc_id}")

        if os.path.exists(os.path.join(PROJECT_ROOT, data["background"])):
            ok(f"Chapter 1 location background exists: {loc_id}")
        else:
            fail(f"Missing Chapter 1 location background: {loc_id}")

        block = re.search(rf'"{loc_id}"\s*:\s*\{{[\s\S]*?"requires_evidence": "{data["gate"]}"[\s\S]*?\n\t\t\t\t\}}', case_content)
        if block and f'"connections": ["{data["parent"]}"]' in block.group(0):
            ok(f"Chapter 1 location gate and parent-only connection wired: {loc_id}")
        else:
            fail(f"Chapter 1 location gate or parent-only connection missing: {loc_id}")

    moved_actions = {
        "visit_old_city_police_outpost": "old_city_police_outpost",
        "visit_dr_chen_clinic": "dr_chen_clinic",
        "investigate_abyss_backroom": "abyss_bar_backroom",
    }
    for action_id, loc_id in moved_actions.items():
        if case_content.count(f'"id": "{action_id}"') == 1 and re.search(rf'"{loc_id}"\s*:\s*\{{[\s\S]*?"id": "{action_id}"', case_content):
            ok(f"Moved story action has a single new-location owner: {action_id}")
        else:
            fail(f"Moved story action is missing or duplicated: {action_id}")

    new_dialogues = [
        "ch1_old_city_police_outpost_enter",
        "ch1_old_city_queue_ticket",
        "ch1_abyss_bar_backroom_enter",
        "ch1_abyss_surveillance_delay_log",
        "ch1_clinic_anonymous_case_note",
    ]
    for dialogue_id in new_dialogues:
        if f'"{dialogue_id}": [' in dialogue_content:
            ok(f"Chapter 1 locationization dialogue exists: {dialogue_id}")
        else:
            fail(f"Missing Chapter 1 locationization dialogue: {dialogue_id}")

    side_evidence = [
        "old_city_queue_ticket",
        "clinic_anonymous_case_note",
        "abyss_surveillance_delay_log",
    ]
    for evidence_id in side_evidence:
        source_path = os.path.join(PROJECT_ROOT, "assets/generated/items", f"ch1_{evidence_id}.png")
        runtime_path = os.path.join(PROJECT_ROOT, "assets/sprites/items", f"{evidence_id}.png")
        if f'"{evidence_id}": {{' in evidence_content and f'"icon": "{evidence_id}"' in evidence_content and '"eye_reading"' in evidence_content:
            ok(f"Chapter 1 side evidence data has dedicated icon and eye reading: {evidence_id}")
        else:
            fail(f"Chapter 1 side evidence data incomplete: {evidence_id}")

        if os.path.exists(source_path) and os.path.exists(runtime_path):
            ok(f"Chapter 1 side evidence icon source and runtime exist: {evidence_id}")
            if get_png_size(runtime_path) == (512, 512):
                ok(f"Chapter 1 side evidence icon size stable: {evidence_id}")
            else:
                fail(f"Chapter 1 side evidence icon size mismatch: {evidence_id}")
            if png_has_alpha(runtime_path):
                ok(f"Chapter 1 side evidence icon keeps alpha channel: {evidence_id}")
            else:
                fail(f"Chapter 1 side evidence icon lacks alpha channel: {evidence_id}")
            if file_sha256(source_path) == file_sha256(runtime_path):
                ok(f"Chapter 1 side evidence icon source matches runtime: {evidence_id}")
            else:
                fail(f"Chapter 1 side evidence icon source/runtime SHA mismatch: {evidence_id}")
        else:
            fail(f"Missing Chapter 1 side evidence icon source or runtime: {evidence_id}")

        if evidence_id in prompt_doc:
            ok(f"Chapter 1 locationization prompt documented: {evidence_id}")
        else:
            fail(f"Chapter 1 locationization prompt missing: {evidence_id}")

    optional_connections = [
        '"old_city_queue_ticket": "rejected_missing_person_report"',
        '"clinic_anonymous_case_note": "clinic_eye_warning_log"',
        '"abyss_surveillance_delay_log": "masked_client_receipt"',
        '"old_city_queue_ticket:rejected_missing_person_report": "deduced_old_city_system_delay"',
        '"clinic_anonymous_case_note:clinic_eye_warning_log": "deduced_clinic_pattern_warning"',
        '"abyss_surveillance_delay_log:masked_client_receipt": "deduced_abyss_paid_silence"',
    ]
    for expected in optional_connections:
        if expected in board_content:
            ok(f"Optional Chapter 1 evidence-board connection wired: {expected}")
        else:
            fail(f"Missing optional Chapter 1 evidence-board connection: {expected}")

    if "hide_after_flag" in location_base and "GameManager.get_dialogue_flag(hide_after_flag)" in location_base:
        ok("LocationBase supports one-shot story actions")
    else:
        fail("LocationBase missing one-shot story action support")

    if "requires_evidence" in location_base and "GameManager.has_evidence(req_evidence)" in location_base:
        ok("LocationBase supports evidence-gated map destinations")
    else:
        fail("LocationBase missing evidence-gated map destination support")

    if "requires_missing_flags" in dialogue_system and "set_flags" in dialogue_system:
        ok("DialogueSystem supports route fallback and multi-flag setting")
    else:
        fail("DialogueSystem missing route fallback or multi-flag support")

    # Bug regression: Snake's first encounter must remain reachable without resolving the route choice.
    snake_intro_action = (
        '"id": "meet_snake_information_broker"' in case_content
        and '"dialogue": "ch1_snake_encounter"' in case_content
        and '"hide_after_flag": "snake_broker_met"' in case_content
    )
    snake_intro_safe = (
        '"ch1_snake_encounter": [' in dialogue_content
        and "snake_broker_met" in dialogue_content
        and "snake_requested_data_chip" in dialogue_content
        and "snake_deal_accepted" not in dialogue_content
    )
    if snake_intro_action and snake_intro_safe:
        ok("Snake first encounter is reachable and separate from route selection")
    else:
        fail("Snake first encounter is unreachable or still mutates route-selection state")

    if "requires_missing_flags" in dialogue_content and "route_unresolved" in dialogue_content:
        ok("Chapter 1 final inference has unresolved-route fallback")
    else:
        fail("Chapter 1 final inference lacks unresolved-route fallback")

    # Bug regression: Snake deal route selection must be one-shot and mutually exclusive.
    snake_action_one_shot = (
        '"id": "negotiate_snake_data_chip"' in case_content
        and '"hide_after_flag": "snake_data_chip_choice_resolved"' in case_content
    )
    snake_accept_guard = re.search(
        r'"next": "snake_trade_accept"[\s\S]*?"requires_missing_flags": \["rejected_snake_deal"\][\s\S]*?"set_flags": \["snake_data_chip_choice_resolved"\]',
        dialogue_content,
    )
    snake_reject_guard = re.search(
        r'"next": "snake_trade_reject"[\s\S]*?"requires_missing_flags": \["accepted_snake_deal"\][\s\S]*?"set_flags": \["snake_data_chip_choice_resolved"\]',
        dialogue_content,
    )
    if snake_action_one_shot and snake_accept_guard and snake_reject_guard:
        ok("Snake data-chip trade is one-shot and route choices are mutually exclusive")
    else:
        fail("Snake data-chip trade can be repeated or route choices are not mutually exclusive")

    if "chapter_1_complete" in game_manager and "chapter_1_route_chosen" in game_manager and "/ 37.0" in game_manager and "/ 37.0" in decision_tracker:
        ok("Chapter 1 completion decisions and 37-evidence denominator wired")
    else:
        fail("Chapter 1 completion decisions or 37-evidence denominator missing")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("=" * 60)
    print("NEON MEMORIES — Data Integrity Tests")
    print("=" * 60)

    test_scene_paths()
    test_case_data_connections()
    test_initial_dialogues()
    test_dialogue_labels()
    test_evidence_ids()
    test_character_portraits()
    test_generated_png_character_portraits()
    test_runtime_portrait_loader_supports_png()
    test_location_backgrounds()
    test_evidence_icons()
    test_no_legacy_svg_assets()
    test_project_structure()
    test_gdscript_quality()
    test_no_invalid_tscn_uids()
    test_class_name_placement()
    test_scene_transition_await()
    test_change_scene_error_handling()
    test_lambda_loop_capture()
    test_button_disable_on_transition()
    test_main_menu_popup_layout_bounds()
    test_no_onready_in_classname_scripts()
    test_ready_null_safety()
    test_dialogue_system_instantiated()
    test_classname_load_safety()
    test_autoload_process_mode()
    test_dialogue_flags_update_decisions()
    test_image2_asset_prompt_manifests()
    test_generated_environment_item_ui_png_assets()
    test_runtime_asset_loader_supports_generated_pngs()
    test_image2_outputs_are_connected_to_runtime_sprites()
    test_runtime_ui_playability_regressions()
    test_image_gen_ui_prompt_requests()
    test_ch1_eagle_eye_foreshadowing_wiring()
    test_ch1_family_memory_branch()
    test_ch1_asset_replacement_readiness()
    test_ch1_opening_and_mei_ling_trust_expansion()
    test_ch1_expanded_dual_route_and_eagle_eye_readings()
    test_ch1_missing_visual_assets_connected()
    test_ch1_locationization_and_side_evidence()

    print("\n" + "=" * 60)
    print(f"Results: {passed} passed, {failed} failed, {warnings} warnings")
    print("=" * 60)

    if failed > 0:
        print("\nFAILED — fix the issues above")
        sys.exit(1)
    else:
        print("\nALL TESTS PASSED")
        sys.exit(0)


if __name__ == "__main__":
    main()
