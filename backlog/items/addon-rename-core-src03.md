---
target: abap2ui5
title: 'Addon rename: rename.mjs fails on abap2UI5''s src/03 (IF_HTTP_EXTENSION) whenever an addon''s lint config takes the whole core'
summary: The shared rename.mjs lints and renames a cloned dependency as its own source, so an addon whose lint config takes abap2UI5 /src/** fails on src/03 - IF_HTTP_EXTENSION unknown; headless-frontend main is red for it, custom-controls, custom-controls-customer and samples-controls stop there before their real gaps show; the script should take the core as src/0[0-2] itself
priority: medium
state: open
first_seen: 2026-11-26
upstream: abap2UI5-addons
evidence:
  - 'headless-frontend origin/main ddcc1ae, npm run rename, 2026-11-26: ".github/abaplint/rename-deps/abap2ui5/src/03/01/z2ui5_cl_ui5_icf_handler.clas.abap[1, 7] - Implemented interface \"IF_HTTP_EXTENSION\" not found (implement_methods)", "[16, 16] - IF_HTTP_EXTENSION unknown (unknown_types)", "[25, 3] - Method definition \"if_http_extension~handle_request\" not found", "[27, 37] - \"server\" not found" - rename: abaplint found 7 issue(s)'
  - 'the same three/four errors from the shared rename.mjs copied into custom-controls (8a9f78e), custom-controls-customer (8d935fc) and samples-controls (415b255), all with "files": "/src/**/*.*" for abap2UI5 main; green or on to the next gap once the glob is /src/0[0-2]/**/*.*'
  - 'headless-frontend origin/DEV 7d60587 limits the core to /src/0[0-2]/**/*.* and its rename passes (10 files, 0 issues); abap-agent-runtime gets past it by an open-abap-core subset with if_http_extension'
---

# Addon rename: rename.mjs fails on abap2UI5's src/03 whenever an addon's lint config takes the whole core

## What fails

abap2UI5 1.151.0 ships `src/03`: the ICF node `/sap/bc/z2ui5`, the BSP
`Z2UI5` and the handler `z2ui5_cl_ui5_icf_handler`, which implements
`IF_HTTP_EXTENSION`. The interface is not in `steampunk-2305-api(-intersect-702)`,
the API dependency every addon lints with.

In an addon's own lint, abaplint does not report errors inside a dependency,
so an addon config with `"files": "/src/**/*.*"` for abap2UI5 stays green.
`.github/scripts/rename.mjs` treats dependencies differently: it clones every
abap2UI5 / abap2UI5-addons dependency into `.github/abaplint/rename-deps` and
puts it in `global.files`, so that it is renamed along. It also takes over the
dependency's `files` glob (`srcGlob`, since c60b291/6dded4a). Now the core's
`src/03` is the addon's own source as far as the rules are concerned, and
abaplint "renames nothing while one [issue] is open":

    .github/abaplint/rename-deps/abap2ui5/src/03/01/z2ui5_cl_ui5_icf_handler.clas.abap[1, 7]   - Implemented interface "IF_HTTP_EXTENSION" not found (implement_methods) [E]
    .github/abaplint/rename-deps/abap2ui5/src/03/01/z2ui5_cl_ui5_icf_handler.clas.abap[16, 16] - IF_HTTP_EXTENSION unknown (unknown_types) [E]
    ...
    rename: abaplint found 7 issue(s) - it renames nothing while one is open

Who is affected on 2026-11-26:

- headless-frontend main: red (fixed on DEV by narrowing the glob).
- custom-controls, custom-controls-customer, samples-controls: no rename yet,
  but a trial with the shared script stops here, before the gaps that matter
  (WAPA, names over 25 characters, literals) show.

Most addons avoid it today because each one narrows its config to
`/src/0[0-2]/**/*.*` by hand.

## Why the core's src/03 does not belong in an addon's rename

- No addon references an object of `src/03`.
- abaplint cannot rename it correctly anyway. The handler class would be
  renamed, but the SICF node `z2ui5` and the BSP `z2ui5` do not match
  `^z2ui5_`, so they stay. The core renames that package with
  `tools/bsp_rename` (`.github/scripts/rename-service.mjs`).
- `rename.mjs` throws the renamed dependency away (it keeps only the addon's
  `src/`), so nothing is lost by leaving it out.

## Proposed fix (rename.mjs, the same file in every addon)

For the abap2UI5 core clone (`key === "https://github.com/abap2ui5/abap2ui5"`),
use `/src/0[0-2]/**/*.*` whatever the addon's config says. More generally:
never let a clone's `src/03` into `global.files`. Alternatively, add the
open-abap-core `if_http_*` subset (as abap-agent-runtime does) to `others`
when the core clone contains `src/03` - but that lints code the addon does not
own and cannot fix.

Roll the changed script out to every addon in one change (the header says
"change it everywhere").

## Reproduce

    git -C headless-frontend archive origin/main | tar -x -C /tmp/hf && cd /tmp/hf
    npm ci && npm run rename
