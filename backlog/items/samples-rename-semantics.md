---
target: abap2ui5
title: 'Sample corpora must be renameable: the work list for samples, samples-controls and samples-stack'
summary: decided 2026-11-26 - every sample corpus must be renameable together with the framework; work list - samples (check-rename against an unrenamed framework, 140 class-name literals), samples-controls (no rename, 676 literals in the overview), samples-stack (object types abaplint cannot rename) - via abaplint #4719 or derived class names, and the new abaplint renamer items
priority: high
state: open
first_seen: 2026-11-26
checked_upstream: 2026-11-26
upstream: abap2UI5/samples
evidence:
  - 'samples origin/main a3b0c03, npm run rename (.github/abaplint/rename_test.jsonc) 2026-11-26: 0 issues, 294 files - pattern ^z2ui5(.*)$ -> zabap2ui5$1 over src/*.* only, abap2UI5 main a plain dependency (not renamed), no literal check; 140 literals of the form ''z2ui5_cl_smp_...'' in src (z2ui5_cl_smp_app_000 and others)'
  - 'samples-controls origin/main 415b255, the shared addon rename.mjs on a copy with the core narrowed to src/0[0-2]: "zxxxxxxxxx_cl_smpc_app_000.clas.abap:15184: the literal ''z2ui5_cl_smpc_app_599'' names Z2UI5_CL_SMPC_APP_599 - the rename does not rewrite a literal" ... "rename: 676 problem(s) in the renamed src/"; names fit (longest 24, all CLAS)'
  - 'samples-stack origin/main 7538290: BDEF, DDLS, SRVD, SRVB, SAPC, SAMC, SUSH, G4BA, SMIM objects and the SICF z2ui5_apc_smp_202689da8c04c25e7370ed1ba2 (40); 58 class-name literals'
---

# Sample corpora and the rename

## What is there

- **samples** has `check-rename`. It renames the sample classes to
  `zabap2ui5…` (9 characters, not the 10 the framework allows) and leaves the
  framework unrenamed. The result runs only on an **unrenamed** abap2UI5. It
  also checks no literals: the overview and the apps that navigate by class
  name hold 140 literals, which in a renamed copy open the original classes,
  or nothing.
- **samples-controls** has no rename. Its names fit (longest 24). A trial with
  the addons' `rename.mjs` reports 676 literals, almost all in the generated
  overview `z2ui5_cl_smpc_app_000`.
- **samples-stack** cannot be renamed by abaplint (RAP, APC, IAM, SMIM; one
  SICF name of 40 characters).

## Decision (2026-11-26): yes, they must be renameable

Every repository of the ecosystem has to rename into a customer namespace,
the sample corpora included - a renamed abap2UI5 without its samples is an
installation nobody can try. The work list:

1. **samples** - replace `check-rename` with the addons' `rename.mjs` (it
   renames the framework along, with the full 10-character prefix, and checks
   literals). Then the 140 class-name literals: either abaplint renames them
   (`abaplint-rename-string-literals`, PR #4719, opt-in), or the overview and
   the navigating apps derive the name - from a typed reference, or from
   their own name's prefix (`cl_abap_classdescr=>get_class_name( me )`, then
   replace the part after the prefix).
2. **samples-controls** - the same `rename.mjs` (names fit, longest 24). The
   676 literals are almost all in the generated overview
   `z2ui5_cl_smpc_app_000`: its generator emits derived names, or #4719 covers
   them.
3. **samples-stack** - the classes rename like the others (capped at 25);
   the objects around them need abaplint renamers that do not exist yet:
   `abaplint-rename-cds-rap` (DDLS, BDEF, SRVD, SRVB),
   `abaplint-rename-gateway-objects` (G4BA),
   `abaplint-rename-connectivity-mime-objects` (SAPC, SAMC, SMIM),
   `abaplint-rename-authorization-objects` (SUSH). Until they are released,
   the rename of samples-stack covers the packages without them, and says so.
4. Each repository's AGENTS.md and docs advanced/renaming.md state that the
   samples rename with the framework, and with which name.

## Reproduce

    cd samples && npm ci && npm run rename        # green, proves names only
    cp ../layout-management/.github/scripts/rename.mjs samples-controls/.github/scripts/  # then narrow abap2UI5 to /src/0[0-2]/ and run it
