---
target: abaplint
title: 'Report OPTIONAL importing parameters (Clean ABAP: split the method instead)'
summary: 'optional parameters leave the caller guessing which combinations are valid; code-pal reports them'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check optional-parameters (SAP/code-pal-for-abap docs/checks/optional-parameters.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report OPTIONAL importing parameters (Clean ABAP: split the method instead)

```abap
METHODS read IMPORTING iv_id TYPE string iv_mode TYPE string OPTIONAL.
```

**Proposal.** Report OPTIONAL (and DEFAULT, option) on IMPORTING parameters of methods.

**Not reported.** Constructors (option); SAP-defined signatures (void).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check optional-parameters.
