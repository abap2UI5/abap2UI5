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
  - 'DEV of samples, samples-controls and samples-stack, 2026-11-26: the overview apps no longer carry class-name literals - their catalogues write the class without z2ui5_ and own_prefix( ) puts the installation''s prefix in front at runtime (samples 135, samples-controls 676 via its generator, samples-stack 59). What #4719 is still needed for, listed in package.json config.renameLiterals and printed on every npm run rename: samples z2ui5_cl_smp_app_104 (starts its sub-apps 105/112 by name and calls Z2UI5_IF_APP~MAIN dynamically - the dynamic instantiation is the lesson) and 105 (shows its own name), 7 literals; custom-controls c_ns (its library class) and two demo texts; custom-controls-customer z2ui5_cl_ccc=>c_ns'
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
  Since 2026-11-26 (DEV) the overview derives its names; seven literals in
  `z2ui5_cl_smp_app_104`/`105` remain, kept and listed by the rename.
- **samples-controls** - 676 literals in a trial, the generated overview app;
  since 2026-11-26 (DEV) its generator writes derived names.
- **custom-controls-customer** - `c_ns` / `c_ns_uri`, the resource root of its BSP.

abap2UI5 itself avoids literals (`rename-literal-gate.mjs`) - possible for a
framework, not for a corpus of 900 apps whose overview lists them by name.

## Proposed

#4719 (open): an opt-in config flag that replaces an old object name inside a
string literal or string template when it is the whole literal (case kept as
written), so `'Z2UI5_CL_SMP_APP_001'` becomes `'ZMYUI5_CL_SMP_APP_001'`.
Opt-in, because a literal that merely contains the text (a log message) is not
a reference.
