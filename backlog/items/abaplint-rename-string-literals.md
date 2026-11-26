---
target: abaplint
title: 'rename: optionally rename the old names in string literals'
summary: abaplint --rename rewrites references, never literals, so a renamed tree still names the original objects in its strings - it blocks the rename of samples (140 class-name literals), samples-controls (676 in a trial, the generated overview) and custom-controls-customer (c_ns, c_ns_uri); abap2UI5 keeps its sources literal-free with a gate instead; upstream PR #4719 is open
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4719
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abap2UI5 main: .github/scripts/rename-literal-gate.mjs (check:rename on the sources, --renamed on the renamed tree in build-rename) exists because the rename keeps literals - a literal naming an object made every app start of a renamed installation look up the original (no user exit found)'
  - 'samples origin/main a3b0c03, 2026-11-26: 140 literals of the form z2ui5_cl_smp_... in src (the overview app and apps navigating by class name)'
  - 'samples-controls origin/main 415b255, the shared addon rename.mjs: "rename: 676 problem(s) in the renamed src/", almost all in the generated overview z2ui5_cl_smpc_app_000'
  - 'custom-controls-customer 65f5b4b: z2ui5_cl_ccc.clas.abap:25/27 CONSTANTS c_ns VALUE `z2ui5_ccc`, c_ns_uri VALUE `z2ui5_ccc.cc` - the resource root of its BSP, reported by the rename''s literal check'
  - 'gh search 2026-11-26: abaplint/abaplint#4719 "rename: optionally rename the old names in string literals" open (2026-11-25); no release carries it'
---

# rename: optionally rename the old names in string literals

## Why

A namespace rename has to produce an installation that works, not one that
compiles. Code that names an object dynamically - `CREATE OBJECT ... TYPE
(lv_name)`, a navigation to an app by class name, a resource path - holds the
name in a literal, and `--rename` leaves it as it was. The renamed system then
looks up the ORIGINAL object, which either does not exist or is the other
installation.

Blocked today:

- **samples** - 140 class-name literals; a renamed copy opens the original apps.
- **samples-controls** - 676 literals in a trial, the generated overview app.
- **custom-controls-customer** - `c_ns` / `c_ns_uri`, the resource root of its BSP.

abap2UI5 itself avoids literals (`rename-literal-gate.mjs`) - possible for a
framework, not for a corpus of 900 apps whose overview lists them by name.

## Proposed

#4719 (open): an opt-in config flag that replaces an old object name inside a
string literal or string template when it is the whole literal (case kept as
written), so `'Z2UI5_CL_SMP_APP_001'` becomes `'ZMYUI5_CL_SMP_APP_001'`.
Opt-in, because a literal that merely contains the text (a log message) is not
a reference.
