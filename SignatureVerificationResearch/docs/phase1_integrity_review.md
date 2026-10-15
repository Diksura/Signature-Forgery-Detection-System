# Signature Verification Research — Phase 1 Dataset Integrity Review
**Date:** 15 October 2026  
**Source artifacts:** User-provided `dataset_manifest.csv`, `audit_summary.json`, `audit_issues.csv`, `exact_duplicates.json`, and `BHSig260.zip` (metadata lists only).  
**Scope:** Review of image metadata, filenames, writer mappings and byte-level SHA-256 results. No original signature pixels were available for inspection.

## Executive decision
**Do not train yet.** The datasets have the expected number of decodable images, but there are repeated image files and unresolved label inconsistencies. Keep the originals intact, record quarantine decisions in an external manifest, verify provenance, perform representative visual QA, and agree on a writer-disjoint experimental protocol before generating pairs.

## Summary
| Dataset | Images | SHA-256 duplicate groups | Redundant copies beyond one per group |
| --- | ---: | ---: | ---: |
| CEDAR | 2,640 | 0 | 0 |
| BHSig260 — Bengali | 5,400 | 931 | 994 |
| BHSig260 — Hindi | 8,640 | 29 | 32 |
| UTSig | 8,280 | 12 | 12 |
| **Total** | **24,960** | **972** | **1,038** |

All 24,960 images decoded in the local user's Pillow audit. Each of the 972 groups comprises 2–6 identical-file members (most contain two); 2,010 image paths belong to these groups, corresponding to 1,038 redundant extra copies if one canonical representative is retained per group. SHA-256 catches byte-identical files only, not rotated, recompressed or visually similar duplicates.

There were no cross-writer or cross-dataset exact hash groups under the *current* assigned writer IDs; this alone cannot establish writer ID correctness.

## BHSig260 metadata review (`BHSig260.zip`)
- Bengali `list.genuine`: 2,400 distinct listed filenames; Bengali `list.forgery`: 3,000. All entries resolve to a file in the manifest; no list-vs-file mismatch.
- Hindi `list.genuine`: 3,840; Hindi `list.forgery`: 4,800. All entries resolve to the manifest, including the anomalous writer 123 filenames.
- Hindi directory `123/` contains 24 files named `H-S-124-G-01.tif` through `H-S-124-G-24.tif`, although the 30 forgery files are named for 123. The supplied `list.genuine` *repeats* this anomaly. It does not independently establish which identity is correct; a mirror or upstream metadata may both carry the same mistake.
- Each pair list has **8,964 pairs covering only writers 001–009**. Per writer: 720 genuine–forgery pairs (`0`) and 276 distinct-filename genuine–genuine pairs (`1`); no different-writer impostor pairs. Lists are incomplete for the full corpus and include files that may be byte-identical despite different names. Do not use them as the primary training/test protocol.

## Directly conflicting image categories
UTSig has one byte-identical group with two different categories:
- `UTSig/Forgery/Opposite Hand/15/3.tif`
- `UTSig/Genuine/15/24.tif`

One identical file cannot independently substantiate these two different acquisition labels. Quarantine both paths pending source verification. This is a *category conflict*, not evidence that all UTSig labels are wrong.

## BHSig260 Bengali concern
- 931 duplicate groups, 994 redundant files (18.4% of 5,400 paths).
- 95 of 100 Bengali writers have at least one duplicate group.
- Examples include genuine–genuine as well as forgery–forgery duplicates. Byte-level repeats reduce the number of independent observations and can distort pair sampling and reported results.

**Provisional choice:** Hold the entire Bengali subset out of the first experiments until its source can be compared with an independent creator-authorized copy, or a documented investigation establishes appropriate use. Do not discard it permanently.

## Safe curation policy
1. Never edit, delete, rename or re-label the original `data/raw` files.
2. Quarantine *all* samples associated with BHSig260 Hindi writer IDs **123 and 124** until the conflicting names can be resolved; this conservative hold encompasses 108 image paths.
3. Quarantine *both* UTSig paths in the conflicting-category hash group.
4. Hold the entire Bengali subset for further source review; its duplicates remain documented rather than silently excluded.
5. Among remaining within-writer-and-category identical copies, retain only one deterministic canonical path in a **candidate** manifest; flag extra copies in the review file.
6. Confirm any remaining quality, provenance and permission issues, and perform representative visual/content inspection prior to marking candidates suitable for research training.

The provided script `prepare_curation.py` implements this *provisional, metadata-only* policy. It does not attempt to infer correct authorship from the filenames, and it never touches image bytes.

## Output of `prepare_curation.py` on the uploaded reports
| Flag | Image paths |
| --- | ---: |
| `HOLD_BENGALI_QUALITY` | 5,400 |
| `QUARANTINE_WRITER_ID` | 108 |
| `QUARANTINE_CONFLICTING_HASH` | 2 |
| `REDUNDANT_EXACT_COPY` | 43 |
| `CANDIDATE_ONLY` | **19,407** |
| **All paths** | **24,960** |

`CANDIDATE_ONLY` means **not blocked by currently known metadata-level concerns**, not yet confirmed valid. Includes: CEDAR 2,640, BHSig Hindi 8,500, UTSig 8,267. These counts are provisional.

The original audit's 1,038 redundant copies count includes duplicates inside the held Bengali set and one UTSig cross-category pair. Therefore it does not equal the 43 redundant copies flagged for exclusion among the non-held, non-conflicting subsets by this curation policy.

## Research next steps
1. Review representative original image pixels locally for unintended blank/incorrect content, suspicious near-duplicates, and actual sampling differences. Test visually similar duplicates with a perceptual hash separately, and manually inspect any cross-writer lookalikes before decisions.
2. Seek creator-authorized dataset documentation or a trusted original release to resolve Hindi writer 123/124 and assess whether Bengali repeats originate in the distributed copy. Do **not** guess or silently rename.
3. Define a documented protocol: writer-disjoint train/validation/test, no augmentation before partitioning, genuine–genuine positives, genuine–targeted-forgery negatives, and different-writer impostor negatives; fixed seed and cross-dataset held-out testing.
4. Freeze versioned metadata and excluded-path lists. The *research publication* should disclose exclusion policy and effective sample counts.
5. Only then implement first reproducible PyTorch baseline; treat the old unfinished Siamese notebook as non-evidence.

### Tool usage
At the root of `SignatureVerificationResearch`:

```bash
cp /path/to/downloaded/prepare_curation.py src/prepare_curation.py
python src/prepare_curation.py
```

Requires no new dependencies. Reads `data/manifests/dataset_manifest.csv` and `data/manifests/exact_duplicates.json`, then writes: `curation_review.csv`, `candidate_unique_manifest.csv`, and `curation_summary.json` in that same `manifests` folder.

**Caution:** The new candidate manifest is not a final experiment split and should not yet be used for training. Only license-permitted metadata/code belongs in public Git; keep source images private when required.
