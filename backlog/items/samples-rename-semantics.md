---
target: abap2ui5
title: 'Sample corpora and the rename: what samples'' check-rename proves, and that samples-controls/-stack have none'
summary: The samples' check-rename renames the sample classes against an unrenamed framework and checks no literals (140 class-name literals, the overview opens the originals); samples-controls has no rename (676 literal problems in a trial), samples-stack cannot have one - decide whether a sample corpus is renameable at all and make the check say that
priority: low
state: open
first_seen: 2026-11-26
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

## Decision needed

Is "samples on a renamed abap2UI5" a use case?

- **No:** say so in each AGENTS.md and in docs advanced/renaming.md. Then
  either drop samples' `check-rename`, or rename its purpose to what it proves
  (the sample names leave 4 characters of headroom).
- **Yes (samples and samples-controls):** take the addons' `rename.mjs` (it
  renames the framework along and checks literals). Make the overview apps
  derive the class name from a typed reference or from their own name's
  prefix (`cl_abap_classdescr=>get_class_name( me )`) instead of literals; the
  generator of `z2ui5_cl_smpc_app_000` would emit that. samples-stack stays
  out.

## Reproduce

    cd samples && npm ci && npm run rename        # green, proves names only
    cp ../layout-management/.github/scripts/rename.mjs samples-controls/.github/scripts/  # then narrow abap2UI5 to /src/0[0-2]/ and run it
