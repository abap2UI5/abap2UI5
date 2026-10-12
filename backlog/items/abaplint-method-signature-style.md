---
target: abaplint
title: 'Method signature style: boolean IMPORTING, OPTIONAL parameters, boolean methods without is_/has_'
summary: 'three Clean ABAP signature checks - boolean input parameters, OPTIONAL parameters, and methods returning abap_bool whose name does not say so'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Method signature style: boolean IMPORTING, OPTIONAL parameters, boolean methods without is_/has_

All three read METHODS definitions only; one rule, one option per check, all off by default.

Merged on 2026-10-12 from the items `abaplint-boolean-input-parameter`, `abaplint-optional-parameters`, `abaplint-boolean-method-naming`.

## Report boolean IMPORTING parameters (Clean ABAP: split the method instead)

```abap
METHODS update IMPORTING iv_do_save TYPE abap_bool.
```

**Proposal.** Report IMPORTING parameters typed abap_bool/xfeld/boolean in method definitions, except for set_* methods with a single parameter (option).

**Not reported.** Setters; event handlers; RAP handler signatures.

## Report OPTIONAL importing parameters (Clean ABAP: split the method instead)

```abap
METHODS read IMPORTING iv_id TYPE string iv_mode TYPE string OPTIONAL.
```

**Proposal.** Report OPTIONAL (and DEFAULT, option) on IMPORTING parameters of methods.

**Not reported.** Constructors (option); SAP-defined signatures (void).

## Report methods returning abap_bool whose name does not say so (is_/has_/…)

```abap
METHODS valid RETURNING VALUE(rv) TYPE abap_bool.
```

Instead:

```abap
METHODS is_valid RETURNING VALUE(rv) TYPE abap_bool.
```

**Proposal.** Report a method whose RETURNING is abap_bool (or boolean/xfeld) and whose name does not start with a configurable prefix list.

**Not reported.** Interface methods implemented from SAP interfaces (void).

**Where.** a new rule, one option per check. **Effort:** S.
