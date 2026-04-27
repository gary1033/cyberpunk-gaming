#!/usr/bin/env python3
"""
NEON MEMORIES - Data Integrity Tests
Validates game data cross-references without requiring Godot engine.
Parses .gd and .tscn files to check scene paths, dialogue IDs,
evidence connections, asset files, and more.
"""

import os
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
                candidates = [
                    os.path.join(sprites_dir, f"{char_id}_{mood}.png"),
                    os.path.join(sprites_dir, f"{char_id}_{mood}.svg"),
                ]
                existing = [path for path in candidates if os.path.exists(path)]
                if existing:
                    ok(f"Portrait: {os.path.basename(existing[0])}")
                else:
                    fail(f"Missing portrait: {char_id}_{mood}.png or .svg")


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
# 6c. Bug regression: Runtime portrait loaders prefer PNG with SVG fallback
# New generated art is PNG, while legacy art remains SVG for fallback safety.
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

        if "_load_character_portrait" in content and '"png"' in content and '"svg"' in content:
            ok(f"{rel_path}: loads PNG portraits with SVG fallback")
        else:
            fail(f"{rel_path}: missing PNG/SVG portrait loader")


# ---------------------------------------------------------------------------
# 7. Location background SVG files
# ---------------------------------------------------------------------------
def test_location_backgrounds():
    print("\n[7] Location background SVG files")
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
        svg_path = os.path.join(sprites_dir, f"{loc_id}.svg")
        if os.path.exists(svg_path):
            ok(f"Background: {loc_id}.svg")
        else:
            fail(f"Missing background: {loc_id}.svg")


# ---------------------------------------------------------------------------
# 8. Evidence icon SVG files
# ---------------------------------------------------------------------------
def test_evidence_icons():
    print("\n[8] Evidence icon SVG files")
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
        svg_path = os.path.join(sprites_dir, f"{icon}.svg")
        if os.path.exists(svg_path):
            ok(f"Icon: {icon}.svg")
        else:
            fail(f"Missing icon: {icon}.svg")


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
        else:
            fail("_trigger_initial_dialogue is a stub — initial dialogue will never play")
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
    dialogue_content = read_file("scripts/data/dialogue_data.gd")
    if not game_manager or not dialogue_content:
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
    test_project_structure()
    test_gdscript_quality()
    test_no_invalid_tscn_uids()
    test_class_name_placement()
    test_scene_transition_await()
    test_change_scene_error_handling()
    test_lambda_loop_capture()
    test_button_disable_on_transition()
    test_no_onready_in_classname_scripts()
    test_ready_null_safety()
    test_dialogue_system_instantiated()
    test_classname_load_safety()
    test_autoload_process_mode()
    test_dialogue_flags_update_decisions()

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
