---
target: abaplint
title: 'Hardcoded values: system fields compared with literals, icon codes as literals'
summary: 'sy-uname/sy-sysid/sy-mandt compared with a literal, literal paths/URLs, and icon codes like ''@00@'' instead of ICON_ constants are values that belong in configuration or constants'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abapOpenChecks check 010 (larshp/abapOpenChecks docs/_checks/10.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Hardcoded values: system fields compared with literals, icon codes as literals

One rule over literals in code, one option per kind. Magic numbers (abaplint-magic-number, #3296) stay separate: upstream is unconvinced, and they should not ride along. Credentials stay separate too (security).

Merged on 2026-10-12 from the items `abaplint-hardcoded-system-specifics`, `abaplint-icon-literal`.

## Report comparisons of sy-uname/sy-sysid/sy-mandt/sy-host with literals and literal paths/URLs

```abap
IF sy-uname = 'JDOE'.
IF sy-sysid = 'PRD'.
OPEN DATASET '/usr/sap/tmp/x' FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
```

**Proposal.** Report the comparisons, literal absolute paths in DATASET statements and literal URLs/IPs in create_by_url.

**Not reported.** Test classes.

**Source.** Sonar S5115/S1313; abapOpenChecks 102.

## Report icon codes written as literals ('@00@') instead of ICON_ constants

An icon code is a four-character literal between @ signs; the ICON type pool has a constant for each.

```abap
lv_icon = '@00@'.
```

Instead:

```abap
lv_icon = icon_okay.
```

**Proposal.** Report a character literal matching '@[0-9A-Z]{2}@' (optionally followed by a quick-info part) in code.

**Not reported.** Literals in comments and string templates that are clearly not icons; test classes (option).

**Source.** abapOpenChecks check 010.

**Where.** a new rule, one option per check. **Effort:** S.
