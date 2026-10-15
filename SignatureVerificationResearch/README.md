### File Structure

```
SignatureVerificationResearch/
    │
    ├── data/
    │   ├── raw/
    │   │   ├── CEDAR/
    │   │   ├── BHSig260/
    │   │   └── UTSig/
    │   │
    │   ├── manifests/
    │   └── processed/
    │
    ├── experiments/
    ├── models/
    ├── src/
    ├── results/
    └── docs/
```

## Process

1. Phase 1A - Dataset structure audit report

    src/audit_datasets.py

    Output -->
        data/manifests/audit_issues.csv
        data/manifests/audit_summary.json
        data/manifests/dataset_manifest.csv
        data/manifests/exact_duplicates.json

    Terminal Output -->
        docs/Terminal/Phase 1A Terminal Output

    Docs -->
        docs/dataset_structure_audit.md


    After Process Review -->
        docs/phase1_integrity_review.md

2. Phase 1B - Image-content quality validation
    

    src/audit_datasets.py

    Output -->
        data/manifests/candidate_unique_manifest.csv
        data/manifests/curation_review.csv
        data/manifests/curation_summary.json

    Terminal Output -->
        docs/Terminal/Phase 1B Terminal Output


    After Process Review -->
        