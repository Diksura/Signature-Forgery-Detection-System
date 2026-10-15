#!/usr/bin/env python3
"""Non-destructive structural, decoding, and SHA-256 audit for the research datasets.

Put this file in SignatureVerificationResearch/src/ and run from anywhere:
    python3 src/audit_datasets.py

Requires: pip install pillow

Original images remain unchanged. Output goes to data/manifests/.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

try:
    from PIL import Image, UnidentifiedImageError
except ImportError:
    raise SystemExit("Pillow is required. Install it with: python3 -m pip install pillow")

IMAGE_EXTENSIONS = {".png", ".tif", ".tiff", ".jpg", ".jpeg", ".bmp"}
EXPECTED_FORMAT = {".png": "PNG", ".tif": "TIFF", ".tiff": "TIFF", ".jpg": "JPEG", ".jpeg": "JPEG", ".bmp": "BMP"}
EXPECTED = {
    ("CEDAR", "all", "genuine"): (55, 24),
    ("CEDAR", "all", "forgery"): (55, 24),
    ("BHSig260", "Bengali", "genuine"): (100, 24),
    ("BHSig260", "Bengali", "forgery"): (100, 30),
    ("BHSig260", "Hindi", "genuine"): (160, 24),
    ("BHSig260", "Hindi", "forgery"): (160, 30),
    ("UTSig", "all", "genuine"): (115, 27),
    ("UTSig", "all", "simple_forgery"): (115, 36),
    ("UTSig", "all", "skilled_forgery"): (115, 6),
    ("UTSig", "all", "opposite_hand"): (115, 3),
}
FIELDS = ["relative_path", "dataset", "subset", "folder_writer_id", "filename_writer_id", "target_writer_id", "sample_type", "sample_no", "label_status", "file_size", "width", "height", "image_mode", "image_format", "sha256", "decode_status"]


def get_metadata(path: Path) -> dict:
    parts = path.parts
    out = dict(dataset=parts[0] if parts else "", subset="", folder_writer_id="", filename_writer_id="", target_writer_id="", sample_type="", sample_no="", label_status="unparsed")
    if len(parts) == 3 and parts[0] == "CEDAR" and parts[1] in ("full_org", "full_forg"):
        cls = "genuine" if parts[1] == "full_org" else "forgery"
        prefix = "original" if cls == "genuine" else "forgeries"
        m = re.fullmatch(rf"{prefix}_(\d+)_(\d+)\.png", parts[-1])
        if m:
            writer_id, no = int(m[1]), int(m[2])
            out.update(subset="all", folder_writer_id=str(writer_id), filename_writer_id=str(writer_id), target_writer_id=f"CEDAR:{writer_id:03d}", sample_type=cls, sample_no=str(no), label_status="consistent_filename")
    elif len(parts) == 4 and parts[0] == "BHSig260" and parts[1] in ("Bengali", "Hindi"):
        m = re.fullmatch(r"([BH])-S-(\d+)-([GF])-(\d+)\.tif", parts[-1])
        if m and parts[2].isdigit():
            folder_writer = int(parts[2]); named_writer = int(m[2]); language = parts[1]
            consistent = (m[1] == ("B" if language == "Bengali" else "H") and folder_writer == named_writer)
            out.update(subset=language, folder_writer_id=str(folder_writer), filename_writer_id=str(named_writer), target_writer_id=f"BHSig260-{language}:{folder_writer:03d}" if consistent else "", sample_type="genuine" if m[3] == "G" else "forgery", sample_no=str(int(m[4])), label_status="consistent_filename" if consistent else "WRITER_ID_CONFLICT")
    elif parts[0] == "UTSig" and len(parts) in (4, 5):
        if parts[1] == "Genuine" and len(parts) == 4:
            cls, folder_writer, name = "genuine", parts[2], parts[3]
        elif parts[1] == "Forgery" and len(parts) == 5 and parts[2] in ("Simple", "Skilled", "Opposite Hand"):
            cls = {"Simple": "simple_forgery", "Skilled": "skilled_forgery", "Opposite Hand": "opposite_hand"}[parts[2]]
            folder_writer, name = parts[3], parts[4]
        else:
            return out
        m = re.fullmatch(r"(\d+)\.tif", name)
        if m and folder_writer.isdigit():
            wid = int(folder_writer)
            out.update(subset="all", folder_writer_id=str(wid), filename_writer_id=str(wid), target_writer_id=f"UTSig:{wid:03d}", sample_type=cls, sample_no=str(int(m[1])), label_status="consistent_filename")
    return out


def digest_sha256(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def save_csv(path: Path, cols: list[str], rows: list[dict]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


def main():
    default_base = Path(__file__).resolve().parent.parent
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=default_base / "data" / "raw")
    p.add_argument("--output", type=Path, default=default_base / "data" / "manifests")
    args = p.parse_args()
    root = args.root.expanduser().resolve()
    output = args.output.expanduser().resolve()
    if not root.is_dir():
        p.error(f"Dataset directory does not exist: {root}")
    if output == root or root in output.parents:
        p.error("Output directory must be outside the raw dataset directory.")
    output.mkdir(parents=True, exist_ok=True)
    files = sorted(f for f in root.rglob("*") if f.is_file() or f.is_symlink())
    rows, issues = [], []
    others = []
    for idx, f in enumerate(files, 1):
        rel = f.relative_to(root)
        if f.suffix.lower() not in IMAGE_EXTENSIONS:
            others.append(str(rel))
            continue
        r = {"relative_path": rel.as_posix(), **get_metadata(rel)}
        r.update(file_size="", width="", height="", image_mode="", image_format="", sha256="", decode_status="not_checked")
        if f.is_symlink():
            r["decode_status"] = "skipped_symlink"
            issues.append({"kind": "SYMLINK", "relative_path": rel.as_posix(), "detail": "Skipped symbolic link for safety"})
        else:
            try:
                r["file_size"] = f.stat().st_size
                r["sha256"] = digest_sha256(f)
                with Image.open(f) as im:
                    r["width"], r["height"] = im.size
                    r["image_mode"], r["image_format"] = im.mode, im.format
                    im.load()  # actual pixel decoding, not simply checking the extension
                r["decode_status"] = "ok"
                if r["image_format"] != EXPECTED_FORMAT.get(f.suffix.lower()):
                    issues.append({"kind": "FORMAT_MISMATCH", "relative_path": rel.as_posix(), "detail": f"{r['image_format']} file with {f.suffix} extension"})
                if r["width"] <= 0 or r["height"] <= 0:
                    issues.append({"kind": "BAD_DIMENSIONS", "relative_path": rel.as_posix(), "detail": "Invalid image dimensions"})
            except Exception as exc:
                r["decode_status"] = "ERROR"
                issues.append({"kind": "DECODE_OR_READ_ERROR", "relative_path": rel.as_posix(), "detail": f"{type(exc).__name__}: {str(exc)[:200]}"})
        if r["label_status"] != "consistent_filename":
            issues.append({"kind": r["label_status"].upper(), "relative_path": rel.as_posix(), "detail": f"Folder writer={r['folder_writer_id']}, filename writer={r['filename_writer_id']}; not safe to assign target identity"})
        rows.append(r)
        if idx % 1000 == 0:
            print(f"Processed {idx:,} / {len(files):,} files", flush=True)

    # Structural writer/sample counts; identifies missing writer IDs and incomplete classes.
    groups = defaultdict(list)
    for r in rows:
        if r["label_status"] == "consistent_filename":
            groups[(r["dataset"], r["subset"], r["sample_type"], int(r["folder_writer_id"]))].append(r)
    count_issues = []
    for (dataset, subset, kind), (num_writers, per_writer) in EXPECTED.items():
        for wid in range(1, num_writers + 1):
            samples = groups.get((dataset, subset, kind, wid), [])
            actual = {int(r["sample_no"]) for r in samples}
            if dataset == "UTSig" and kind == "simple_forgery":
                expected_ids = {t * 10 + u for t in range(1, 7) for u in range(1, 7)}
            else:
                expected_ids = set(range(1, per_writer + 1))
            if actual != expected_ids or len(samples) != len(actual):
                count_issues.append({"kind": "COUNT_OR_SEQUENCE_MISMATCH", "relative_path": f"{dataset}/{subset}/writer:{wid}", "detail": f"{kind}: found={len(samples)}, expected={per_writer}, missing={sorted(expected_ids - actual)[:30]}, unexpected={sorted(actual - expected_ids)[:30]}"})
    issues.extend(count_issues)

    byhash = defaultdict(list)
    for r in rows:
        if r["sha256"]:
            byhash[r["sha256"]].append(r["relative_path"])
    duplicate_groups = [{"sha256": k, "count": len(v), "paths": v} for k, v in byhash.items() if len(v) > 1]
    for dup in duplicate_groups:
        issues.append({"kind": "EXACT_FILE_DUPLICATE", "relative_path": dup["paths"][0], "detail": "Other matching files: " + "; ".join(dup["paths"][1:10])})

    save_csv(output / "dataset_manifest.csv", FIELDS, rows)
    save_csv(output / "audit_issues.csv", ["kind", "relative_path", "detail"], issues)
    summary = {
        "note": "File counts and names alone do not prove writer-label correctness; SHA-256 detects byte-identical files only.",
        "root": str(root),
        "image_count": len(rows),
        "non_image_files": others,
        "by_dataset": dict(Counter(r["dataset"] for r in rows)),
        "by_dataset_and_class": {"/".join(key): n for key, n in sorted(Counter((r["dataset"], r["subset"], r["sample_type"]) for r in rows).items())},
        "decode_status": dict(Counter(r["decode_status"] for r in rows)),
        "label_status": dict(Counter(r["label_status"] for r in rows)),
        "issue_types": dict(Counter(x["kind"] for x in issues)),
        "duplicate_group_count": len(duplicate_groups),
    }
    (output / "audit_summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    (output / "exact_duplicates.json").write_text(json.dumps(duplicate_groups, indent=2), encoding="utf-8")
    print("\nAudit complete. Original images were not modified.")
    print(json.dumps({k: v for k, v in summary.items() if k not in ("non_image_files", "by_dataset_and_class")}, indent=2))
    print("Output:", output)
    return 0 if not issues else 2  # issues require review; outputs are still written

if __name__ == "__main__":
    sys.exit(main())
