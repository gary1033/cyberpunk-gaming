"""Verify the recorded runtime/source/raw files and literal game references."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def audit(root=ROOT):
    manifest = json.loads((root / "assets/asset_manifest.json").read_text(encoding="utf-8"))
    errors, warnings = [], []

    def check_file(relative, expected_hash=None):
        path = root / relative
        if not path.resolve().is_relative_to(root.resolve()) or Path(relative).is_absolute():
            errors.append("Nonportable path: " + relative)
            return
        if not path.is_file():
            errors.append("Missing file: " + relative)
        elif expected_hash and hashlib.sha256(path.read_bytes()).hexdigest() != expected_hash:
            errors.append("Changed file: " + relative)

    recorded = set()
    for item in manifest["assets"]:
        runtime = item["runtime"]
        if runtime in recorded:
            errors.append("Duplicate runtime entry: " + runtime)
        recorded.add(runtime)
        for key in ("runtime", "source"):
            check_file(item[key], item["sha256"])
        for key in ("prompt_record", "license_record"):
            if key in item:
                check_file(item[key])
        if "raw" in item:
            check_file(item["raw"], item["raw_sha256"])
    actual = {p.relative_to(root).as_posix() for folder, suffix in
              [("assets/sprites", "*.png"), ("assets/audio/bgm", "*.ogg")]
              for p in (root / folder).rglob(suffix)}
    for path in sorted(actual - recorded):
        errors.append("Unrecorded runtime asset: " + path)
    for path in sorted(recorded - actual):
        errors.append("Recorded asset outside runtime inventory: " + path)
    for folder in ("assets/sprites", "assets/audio"):
        for sidecar in (root / folder).rglob("*.import"):
            if not sidecar.with_suffix("").is_file():
                errors.append("Orphan import can advertise a missing resource: " + sidecar.relative_to(root).as_posix())

    preserved_raw = set()
    for path in (root / "assets/generated/prompts").glob("*.jsonl"):
        for line in path.read_text(encoding="utf-8-sig").splitlines():
            if not line.strip():
                continue
            item = json.loads(line)
            if "preserved_raw_path" in item:
                check_file(item["preserved_raw_path"], item.get("raw_sha256"))
                preserved_raw.add(item["preserved_raw_path"])

    optional = {entry["runtime"]: entry for entry in manifest["optional_audio"]}
    for entry in optional.values():
        warnings.append("Optional audio %s: %s" % (entry["status"], entry["runtime"]))
    for folder in ("scripts", "scenes"):
        for path in (root / folder).rglob("*"):
            if path.suffix not in (".gd", ".tscn"):
                continue
            for ref in set(re.findall(r'res://[^"\s]+', path.read_text(encoding="utf-8"))):
                if "%" not in ref and ref[6:] not in optional and not (root / ref[6:]).exists():
                    errors.append("Broken reference in %s: %s" % (path.relative_to(root), ref))
    for path in (root / "docs").glob("*.html"):
        for ref in re.findall(r'(?:src|href)=["\']([^"\']+)', path.read_text(encoding="utf-8")):
            if "${" in ref or ref.startswith(("https:", "http:", "data:", "#")):
                continue
            if not (path.parent / ref.split("#")[0].split("?")[0]).exists():
                errors.append("Broken preview link in %s: %s" % (path.name, ref))
    no_raw = [item["runtime"] for item in manifest["assets"]
              if item["runtime"].endswith(".png") and "raw" not in item]
    return {"runtime_assets": len(recorded), "pngs": sum(p.endswith(".png") for p in recorded),
            "archived_manifest_originals": len(preserved_raw),
            "images_without_separate_raw_record": no_raw,
            "errors": sorted(set(errors)), "warnings": warnings}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = audit()
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Assets: %d; errors: %d; known audio gaps: %d; images without separate raw record: %d" % (
        result["runtime_assets"], len(result["errors"]), len(result["warnings"]),
        len(result["images_without_separate_raw_record"])))
    for error in result["errors"]:
        print("[FAIL] " + error)
    raise SystemExit(bool(result["errors"]))
