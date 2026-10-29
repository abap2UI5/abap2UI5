---
target: open-abap
title: 'transpiler-cli: no manifest of the output - consumers detect the output layout (flat vs 2.14 folders), the boot order and the test list by reading init.mjs and index.mjs as text'
summary: 'the 2.14 change from a flat output to per-library folders broke every consumer that located files by convention; the MCP server now keeps both layouts side by side (`outputLayout`, `flatRunner`, `bootOrder`) by parsing the generated modules, and so does abap2UI5''s `own-apps.mjs` - a `manifest.json` (objects, files, boot order, tests, tables, lib commits, CLI version) written next to `init.mjs` is what every one of them is reconstructing'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/mcp-server `lib/npm-backend.mjs:397-439` (`outputLayout`, `flatRunner`, `bootOrder`; 2026-10) and `:1101`, `:1229-1233` fail on a layout mismatch; abap2UI5 `node/setup/own-apps.mjs` was adapted to the folder layout on 2026-10-09 (`backlog/items/transpiler-cli-library-second-copy.md`)'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/cli/src/output_writer.ts` writes a manifest of file hashes for incremental output (`MANIFEST`), not of objects; the boot order exists only as the import sequence inside `init.mjs`'
checked_upstream: 2026-10-22
---

# transpiler-cli: write `manifest.json`

## The problem

The output folder is read by programs, not only by Node's loader: the
MCP server, abap2UI5's own-apps packer and the agent runtime all need to
know which file holds which object, in what order the runtime boots them,
which objects carry tests and which tables exist. They get it by
regex over `init.mjs` and `index.mjs`, and the 2.14 layout change
(flat → per-library folders) broke all of them at once.

## Proposed change

`output/manifest.json`, written on every run:

```json
{ "cli": "2.14.10", "layout": "folders",
  "libs": [{"name": "open-abap-core", "commit": "239b817", "folder": "open-abap-core"}],
  "objects": [{"name": "ZCL_FOO", "type": "CLAS", "file": "project/zcl_foo.clas.mjs", "lib": null, "tests": true}],
  "boot": ["open-abap-core/cx_root.clas.mjs", "…"],
  "tables": ["ZTAB"] }
```

`output_writer.ts` has the file list and the incremental manifest
already; the object metadata comes from `res.objects`.

## How to file

An issue against abaplint/transpiler; pairs with the `ref` pin item.

