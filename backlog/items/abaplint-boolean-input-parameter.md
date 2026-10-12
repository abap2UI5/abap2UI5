---
target: abaplint
title: 'Report boolean IMPORTING parameters (Clean ABAP: split the method instead)'
summary: 'a boolean input parameter usually means the method does two things; code-pal reports it, setters excepted'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check boolean-input-parameter (SAP/code-pal-for-abap docs/checks/boolean-input-parameter.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report boolean IMPORTING parameters (Clean ABAP: split the method instead)

```abap
METHODS update IMPORTING iv_do_save TYPE abap_bool.
```

**Proposal.** Report IMPORTING parameters typed abap_bool/xfeld/boolean in method definitions, except for set_* methods with a single parameter (option).

**Not reported.** Setters; event handlers; RAP handler signatures.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check boolean-input-parameter.
