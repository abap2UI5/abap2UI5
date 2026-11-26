---
target: abap2ui5
title: 'abap-util: npm run rename is the dead mirror of abap2UI5 src/99'
summary: abap-util's npm run rename is the old mirror of abap2UI5 src/{00,99/01} into zabaputil_ and fails with No files found - input/ and src/99 are gone; rename_test (the CI check) passes
priority: low
state: open
first_seen: 2026-11-26
upstream: abap-util/abap-util
evidence:
  - 'abap-util origin/main d444ace, npm run rename 2026-11-26: "generic[1, 1] - Error: No files found, ./.github/abaplint/../../input/abap2UI5/src/{00,99/01}/**/*.* undefined (generic_error) [E]" - .github/abaplint/rename.jsonc maps z2ui5_cl_abap2ui5_* to ZABAPUTIL_CL_*, then .github/scripts/mirror_copy.sh (rm -rf src, cp from the output) - the && keeps it from deleting src/ today'
  - 'npm run rename_test (workflow test_rename): zabaputil_ -> zoblomov_, 0 issues, 94 files'
---

# abap-util: `npm run rename` is the dead mirror of abap2UI5's `src/99`

abap-util has its own prefix `zabaputil_`. Consumers vendor renamed copies of
its classes, so the rename that matters is `rename_test`. It renames the
catalog to `zoblomov_` and passes in CI. No abap2UI5 installation depends on
abap-util being renamed together with it.

`npm run rename` is something else: the former mirror from
`input/abap2UI5/src/{00,99/01}` (classes `z2ui5_cl_abap2ui5_*`) into
`zabaputil_`, followed by `mirror_copy.sh`, which deletes `src/` and copies the
output there. `input/` no longer exists, abap2UI5 has no `src/99` and no
`z2ui5_cl_abap2ui5_*`. The script fails at abaplint, and only the `&&` stops
it from deleting `src/`.

**Proposed:** delete the `rename` script, `.github/abaplint/rename.jsonc` and
`.github/scripts/mirror_copy.sh` (the sync direction is consumer-side now, see
AGENTS.md). Optionally rename `rename_test` to `rename`, so that it matches
the other repositories.
