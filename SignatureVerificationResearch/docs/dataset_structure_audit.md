# Signature Verification Research — Phase 1A: Filename & Directory Audit

**Date:** 2026-10-15  
**Inputs:** `dataset_files.txt` (24,977 paths) and `dataset_folders.txt` (733 directories)  
**Scope:** Filename and directory inspection only. This audit did **not** inspect the actual image bytes, file hashes, visual labels, licensing, or image quality.

## Summary

- 24,960 image paths and 17 non-image paths (mostly OS metadata and some research metadata).
- 430 distinct writer identifiers across three datasets (CEDAR 55, BHSig260 260, UTSig 115); this is a sum of per-dataset identities, not evidence that real-world subjects do not overlap.
- No duplicate path strings in the supplied file listing.
- Expected image counts and per-class sample numbering are present, with **one notable writer-ID inconsistency** involving 24 BHSig260 Hindi filenames.

| Dataset | Writers | Genuine | Forgery (all types) | Total |
|---|---:|---:|---:|---:|
| CEDAR | 55 | 1,320 | 1,320 | 2,640 |
| BHSig260 Bengali | 100 | 2,400 | 3,000 | 5,400 |
| BHSig260 Hindi | 160 | 3,840 | 4,800 | 8,640 |
| UTSig | 115 | 3,105 | 5,175 | 8,280 |
| **Total** | **430** | **10,665** | **14,295** | **24,960** |

UTSig non-genuine samples are organized as `Simple` (4,140), `Skilled` (690), and `Opposite Hand` (345). Preserve these dataset-native categories separately in the research manifest; do not treat all three as identical attack types.

## Actionable anomaly: BHSig260 Hindi, subject 123

These **24 images are physically in** `BHSig260/Hindi/123/` but carry **writer 124 in the filename**:

- `BHSig260/Hindi/123/H-S-124-G-01.tif`
- ...
- `BHSig260/Hindi/123/H-S-124-G-24.tif`

The `BHSig260/Hindi/124/` folder separately holds its own `H-S-124-G-01.tif` through `H-S-124-G-24.tif`, and `BHSig260/Hindi/123/` includes 30 correctly numbered forged files `H-S-123-F-*.tif`.

**Do not rename or reassign these images automatically.** They may be misnamed, misplaced, or duplicated. The next audit should compare SHA-256 hashes and selected visual examples between the two writer folders, review the source documentation, and decide how to quarantine unresolved labels. Until resolved, exclude ambiguous images (and potentially both affected writer identities) from any split or evaluation.

## Dataset naming structures observed

- **CEDAR:** `full_org/original_{writer}_{sample}.png` and `full_forg/forgeries_{writer}_{sample}.png`, writers 1–55, 24 per class per writer.
- **BHSig260:** `Bengali|Hindi/{writer:03d}/[B|H]-S-{writer}-[G|F]-{sample:02d}.tif`, 24 genuine and 30 forged per writer.
- **UTSig:** `Genuine/{writer}/{sample}.tif`, `Forgery/Skilled/{writer}/{sample}.tif`, `Forgery/Simple/{writer}/{sample}.tif`, and `Forgery/Opposite Hand/{writer}/{sample}.tif`; 27 genuine, 6 skilled, 36 simple and 3 opposite-hand per writer. Simple forgery samples use indices 11–16, 21–26, 31–36, 41–46, 51–56, 61–66.

## Next phase: actual file validation (on the user's Mac)

Run `audit_datasets.py` inside `SignatureVerificationResearch/src/`. It reads `data/raw/` without modifying any image and produces:

- `data/manifests/dataset_manifest.csv`: per-image inferred metadata, byte size, pixel dimensions, format, SHA-256, and decode status.
- `data/manifests/audit_issues.csv`: label mismatches, decoding failures, filename problems, class count issues, and byte-identical duplicates.
- `data/manifests/audit_summary.json`: summary counts and issue frequencies.
- `data/manifests/exact_duplicates.json`: all byte-identical image groups.

**Interpretation:** The manifest's `consistent_filename` value means the folder and filename agree; it does *not* mean the real writer or forgery label has been independently verified. An absence of SHA-256 duplicates also does not rule out visually identical images with differing encoding or crop. Manual image review and a perceptual near-duplicate audit are separate later tasks.

## Research protocol decisions still pending

Do not commit to training, writer splits, or model comparisons until the data-integrity audit is completed and anomalous identities are dealt with. Preserve all dataset-specific forgery types. Plan disjoint writer splits and reserve one separate dataset for external evaluation without using it to tune hyperparameters or thresholds.
