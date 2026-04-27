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

    sprites_dir = os.path.join(PROJECT_ROOT, "assets/sprites/characters")
    missing_png = 0
    invalid_size = 0
    for i, char_id in enumerate(chars):
        if i >= len(mood_blocks):
            continue
        moods = re.findall(r'"(\w+)"', mood_blocks[i])
        for mood in moods:
            png_path = os.path.join(sprites_dir, f"{char_id}_{mood}.png")
            if os.path.exists(png_path):
                ok(f"Generated PNG: {char_id}_{mood}.png")
                size = get_png_size(png_path)
                if size == (256, 384):
                    ok(f"Generated PNG size: {char_id}_{mood}.png is 256x384")
                else:
                    fail(f"Generated PNG wrong size: {char_id}_{mood}.png is {size}, expected 256x384")
                    invalid_size += 1
            else:
                fail(f"Missing generated PNG portrait: {char_id}_{mood}.png")
                missing_png += 1

    if missing_png == 0:
        ok("Generated PNG portraits cover all CharacterData moods")
    if invalid_size == 0:
        ok("Generated PNG portraits all use 256x384 runtime size")


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

    # Bug regression: left portrait needs an explicit right offset; otherwise
    # the TextureRect can have zero or negative width when anchored bottom-left.
    if "portrait_left.offset_right" in location_base and "portrait_right.offset_left" in location_base:
        ok("Dialogue portraits have explicit left/right bounds")
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
        ("backgrounds", "assets/generated/backgrounds", "assets/sprites/locations"),
        ("items", "assets/generated/items", "assets/sprites/items"),
        ("ui", "assets/generated/ui", "assets/sprites/ui"),
    ]

    checked = 0
    for label, generated_rel, sprite_rel in mappings:
        generated_dir = os.path.join(PROJECT_ROOT, generated_rel)
        sprite_dir = os.path.join(PROJECT_ROOT, sprite_rel)
        if not os.path.isdir(generated_dir):
            warn(f"No generated {label} directory found: {generated_rel}")
            continue

        for file_name in sorted(os.listdir(generated_dir)):
            if not file_name.lower().endswith(".png"):
                continue
            generated_path = os.path.join(generated_dir, file_name)
            sprite_path = os.path.join(sprite_dir, file_name)
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
    scanline_shader = read_file("assets/shaders/scanline.gdshader")
    if not location_base or not dialogue_system or not evidence_board or not augmented_vision or not scanline_shader:
        fail("Required UI runtime files not found")
        return

    # Bug regression: dialogue text must reserve horizontal room so visible
    # character portraits cannot cover the speaker name or line text.
    if "DialogueContentMargin" in location_base and "side_text_margin" in location_base:
        ok("Dialogue panel reserves side margins for character portraits")
    else:
        fail("Dialogue panel content can overlap character portraits")

    # Bug regression: portraits should sit above the dialogue text area rather
    # than inside the text flow where they cover Chinese dialogue.
    if "portrait_bottom_gap" in location_base and "portrait_size" in location_base:
        ok("Dialogue portraits have fixed responsive bounds above the text area")
    else:
        fail("Dialogue portraits do not have fixed responsive bounds")

    # Bug regression: all dialogue portraits should be anchored to the lower-left
    # portrait frame so right-side speakers do not cover the room background or choices.
    if 'portrait_right.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)' in location_base and '_update_portrait(speaker, mood, "left")' in dialogue_system:
        ok("Dialogue portraits are forced to the left portrait frame")
    else:
        fail("Dialogue portraits can still render on the right side")

    if 'dialogue_margin.add_theme_constant_override("margin_left", side_text_margin)' in location_base and 'dialogue_margin.add_theme_constant_override("margin_right", 32)' in location_base:
        ok("Dialogue text reserves the left portrait area without wasting right-side width")
    else:
        fail("Dialogue text margins can overlap portraits or clip right-side text")

    if 'find_child("NameLabel", true, false)' in dialogue_system and 'find_child("DialogueText", true, false)' in dialogue_system:
        ok("DialogueSystem resolves text nodes after margin-container layout")
    else:
        fail("DialogueSystem still assumes direct DialoguePanel/VBox node paths")

    # Bug regression: space should work for keyboard players during dialogue,
    # both for fast-forwarding typewriter text and advancing completed lines.
    if "Input.is_key_pressed(KEY_SPACE)" in dialogue_system and "event.keycode == KEY_SPACE" in dialogue_system:
        ok("Dialogue supports Space for fast-forward and advance")
    else:
        fail("Dialogue does not support Space for fast-forward and advance")

    if "for i in range(evidence_list.size())" in evidence_board and "var row: int = int(i / cols)" in evidence_board:
        ok("EvidenceBoard card grid uses safe range iteration and int row conversion")
    else:
        fail("EvidenceBoard card grid still uses unsafe iteration or row conversion")

    # Bug regression: eagle-eye energy bar should not sit over the top-right AP
    # label while inactive.
    if "energy_bar.offset_top = 46" in augmented_vision and "energy_bar.visible = false" in augmented_vision and "energy_bar.visible = is_visible" in augmented_vision:
        ok("Eagle-eye energy bar stays below AP and is hidden while inactive")
    else:
        fail("Eagle-eye energy bar can overlap the AP label")

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

    if "ap_status_bar" in location_base and "APWidget" in location_base and "_update_ap_label" in location_base:
        ok("LocationBase AP widget uses generated status bar")
    else:
        fail("LocationBase AP widget does not use generated AP status bar")


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
        "assets/sprites/locations/variants/mei_ling_apartment_eye_scan_variant.png": (1280, 720),
        "assets/sprites/cg/ch1/cg_kai_eye_glitch.png": (1280, 720),
        "assets/sprites/cg/ch1/eagle_eye_activation_cutin_ch1.png": (1280, 720),
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
        "assets/generated/backgrounds/variants/mei_ling_apartment_eye_scan_variant.png": "assets/sprites/locations/variants/mei_ling_apartment_eye_scan_variant.png",
        "assets/generated/cg/ch1/cg_kai_eye_glitch.png": "assets/sprites/cg/ch1/cg_kai_eye_glitch.png",
        "assets/generated/cg/ch1/eagle_eye_activation_cutin_ch1.png": "assets/sprites/cg/ch1/eagle_eye_activation_cutin_ch1.png",
        "assets/generated/items/ch1/broken_memory_player.png": "assets/sprites/items/broken_memory_player.png",
        "assets/generated/items/ch1/kai_eye_glitch_log.png": "assets/sprites/items/kai_eye_glitch_log.png",
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
        "assets/sprites/cg/ch1/cg_family_memory_clip.png": (1280, 720),
        "assets/sprites/locations/variants/mei_ling_apartment_family_memory_variant.png": (1280, 720),
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
        "assets/generated/items/ch1/family_memory_clip.png": "assets/sprites/items/family_memory_clip.png",
        "assets/generated/cg/ch1/cg_family_memory_clip.png": "assets/sprites/cg/ch1/cg_family_memory_clip.png",
        "assets/generated/backgrounds/variants/mei_ling_apartment_family_memory_variant.png": "assets/sprites/locations/variants/mei_ling_apartment_family_memory_variant.png",
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
