#!/usr/bin/env python3
"""Prepare a NON-DESTRUCTIVE, PROVISIONAL signature dataset curation review.

IMPORTANT: The candidate manifest is NOT validated training data. Visual/content
review, provenance, licenses, and experimental protocol must be approved first.
"""
from __future__ import annotations

import argparse
import csv
import json
from collections import Counter
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parent.parent,
                        help='Root directory of SignatureVerificationResearch')
    args = parser.parse_args()
    manifest_dir = args.root / 'data' / 'manifests'
    manifest_path = manifest_dir / 'dataset_manifest.csv'
    duplicates_path = manifest_dir / 'exact_duplicates.json'

    if not manifest_path.is_file() or not duplicates_path.is_file():
        parser.error(f'Expected {manifest_path} and {duplicates_path}. Run audit_datasets.py first.')

    with manifest_path.open(newline='', encoding='utf-8') as fp:
        rdr = csv.DictReader(fp)
        cols = rdr.fieldnames
        assert cols and 'relative_path' in cols and 'sha256' in cols
        records = list(rdr)
    with duplicates_path.open(encoding='utf-8') as fp:
        groups = json.load(fp)

    path_map = {r['relative_path']: r for r in records}
    if len(path_map) != len(records):
        parser.error('Manifest contains duplicate relative_path entries; stop and investigate.')

    hold_hashes: dict[str, str] = {}
    extra_paths = set()
    group_members = set()
    for group in groups:
        paths = group['paths']
        if len(paths) < 2 or any(p not in path_map for p in paths):
            parser.error('Duplicate group contains invalid path or fewer than two paths.')
        expected_sha = group['sha256']
        if any(path_map[p]['sha256'] != expected_sha for p in paths):
            parser.error('Duplicate group does not match manifest hashes.')
        group_members.update(paths)
        types = {path_map[p]['sample_type'] for p in paths}
        target_ids = {path_map[p]['target_writer_id'] for p in paths}
        if len(types) != 1 or len(target_ids) != 1:
            hold_hashes[expected_sha] = (
                'conflicting_sample_types' if len(types) != 1 else 'conflicting_writer_identities'
            )
        else:
            extra_paths.update(sorted(paths)[1:])

    # Conservative policy: until the original creators confirm identity mapping,
    # keep BOTH Hindi writer 123 and writer 124 out of experiments.
    quarantine_hindi_writers = {'123', '124'}
    out = []
    for row in records:
        path = row['relative_path']
        if row['dataset'] == 'BHSig260' and row['subset'] == 'Hindi' and row['folder_writer_id'] in quarantine_hindi_writers:
            status, reason = 'QUARANTINE_WRITER_ID', 'Unresolved Hindi writer 123/124 identity mapping'
        elif row['sha256'] in hold_hashes:
            status, reason = 'QUARANTINE_CONFLICTING_HASH', hold_hashes[row['sha256']]
        elif row['label_status'] != 'consistent_filename':
            status, reason = 'QUARANTINE_LABEL_ANOMALY', row['label_status']
        elif row['dataset'] == 'BHSig260' and row['subset'] == 'Bengali':
            status, reason = 'HOLD_BENGALI_QUALITY', 'High rate of repeated samples; source review needed'
        elif path in extra_paths:
            status, reason = 'REDUNDANT_EXACT_COPY', 'Same SHA-256 as another sample with same class and writer'
        else:
            status, reason = 'CANDIDATE_ONLY', 'Pending visual/content, provenance and license checks'
        out.append({**row, 'curation_status': status, 'curation_reason': reason,
                    'in_duplicate_group': path in group_members})

    with (manifest_dir / 'curation_review.csv').open('w', newline='', encoding='utf-8') as fp:
        writer = csv.DictWriter(fp, fieldnames=cols + ['curation_status', 'curation_reason', 'in_duplicate_group'])
        writer.writeheader()
        writer.writerows(out)

    candidate = [row for row in out if row['curation_status'] == 'CANDIDATE_ONLY']
    with (manifest_dir / 'candidate_unique_manifest.csv').open('w', newline='', encoding='utf-8') as fp:
        writer = csv.DictWriter(fp, fieldnames=cols)
        writer.writeheader()
        writer.writerows({col: row[col] for col in cols} for row in candidate)

    statuses = dict(sorted(Counter(row['curation_status'] for row in out).items()))
    summary = {
        'warning': 'Provisional metadata-only curation. No images inspected. NOT training approved.',
        'original_image_count': len(records),
        'curation_status_counts': statuses,
        'candidate_count': len(candidate),
        'candidate_by_dataset': dict(sorted(Counter(
            row['dataset'] + '/' + row['subset'] for row in candidate
        ).items())),
        'quarantined_hindi_writer_ids': sorted(quarantine_hindi_writers),
        'held_bengali': True,
        'total_duplicate_groups': len(groups),
        'conflicting_hash_groups': len(hold_hashes),
        'next_step': 'Verify original dataset provenance and perform visual/label QA before any split or training.',
    }
    with (manifest_dir / 'curation_summary.json').open('w', encoding='utf-8') as fp:
        json.dump(summary, fp, indent=2)
        fp.write('\n')
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
