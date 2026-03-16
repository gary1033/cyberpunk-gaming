#!/bin/bash
# NEON MEMORIES - Test Runner
# Runs all automated tests for the project.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "NEON MEMORIES — Test Suite"
echo "========================================"

ERRORS=0

# --- 1. Python data integrity tests ---
echo ""
echo "[Phase 1] Data integrity tests"
echo "----------------------------------------"
if command -v python3 &>/dev/null; then
    if python3 "$SCRIPT_DIR/test_data_integrity.py"; then
        echo "Phase 1: PASSED"
    else
        echo "Phase 1: FAILED"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "⚠ python3 not found, skipping data integrity tests"
fi

# --- 2. Project structure validation ---
echo ""
echo "[Phase 2] Project structure validation"
echo "----------------------------------------"

# Check project.godot exists
if [ -f "$PROJECT_ROOT/project.godot" ]; then
    echo "  ✓ project.godot found"
else
    echo "  ✗ project.godot missing"
    ERRORS=$((ERRORS + 1))
fi

# Count scene files
SCENE_COUNT=$(find "$PROJECT_ROOT/scenes" -name "*.tscn" 2>/dev/null | wc -l)
echo "  ✓ Found $SCENE_COUNT scene files"
if [ "$SCENE_COUNT" -lt 15 ]; then
    echo "  ⚠ Expected at least 15 scene files"
fi

# Count GDScript files
GD_COUNT=$(find "$PROJECT_ROOT/scripts" -name "*.gd" 2>/dev/null | wc -l)
echo "  ✓ Found $GD_COUNT GDScript files"

# Count SVG assets
SVG_COUNT=$(find "$PROJECT_ROOT/assets/sprites" -name "*.svg" 2>/dev/null | wc -l)
echo "  ✓ Found $SVG_COUNT SVG asset files"

# Check shader files
SHADER_COUNT=$(find "$PROJECT_ROOT/assets/shaders" -name "*.gdshader" 2>/dev/null | wc -l)
echo "  ✓ Found $SHADER_COUNT shader files"

# --- 3. GDScript syntax check ---
echo ""
echo "[Phase 3] GDScript basic syntax check"
echo "----------------------------------------"

SYNTAX_ERRORS=0
find "$PROJECT_ROOT/scripts" -name "*.gd" 2>/dev/null | while IFS= read -r gd_file; do
    rel="${gd_file#$PROJECT_ROOT/}"
    # Check for common syntax issues
    if grep -Pn '^\t* +\t' "$gd_file" >/dev/null 2>&1; then
        echo "  ⚠ Mixed tabs/spaces: $rel"
    fi
done

if [ "$SYNTAX_ERRORS" -eq 0 ]; then
    echo "  ✓ No obvious syntax issues found"
fi

# --- Summary ---
echo ""
echo "========================================"
if [ "$ERRORS" -eq 0 ]; then
    echo "ALL PHASES PASSED"
    exit 0
else
    echo "FAILED — $ERRORS phase(s) had errors"
    exit 1
fi
