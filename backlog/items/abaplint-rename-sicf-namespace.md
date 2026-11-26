---
target: abaplint
title: 'rename SICF: into a custom namespace, and the namespace node'
summary: renaming an ICF node into a registered namespace (/CA2UI5/) - merged upstream as #4717 and #4718 on 2026-11-25/26, but no release carries them yet (2.120.120 is older); recorded so nobody refiles it - delete when the abaplint pin is a release with both
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4718
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'gh search 2026-11-26: abaplint/abaplint#4717 "rename SICF: into a custom namespace" merged 2026-11-25 17:37 UTC; #4718 "rename SICF: the node of the namespace is created" merged 2026-11-26 09:50 UTC; #4715 (abapGit file name follows the new name) closed unmerged'
  - 'npm view @abaplint/cli: the newest release is 2.120.120, published 2026-11-25 13:57 UTC - before either merge, so neither is in a release abap2UI5 or an addon can pin'
  - 'abap2UI5 main: build-rename with /CA2UI5/ renames src/03 (the ICF node /sap/bc/z2ui5) with tools/bsp_rename, not with abaplint; abap-agent-runtime keeps the name of its ICF node at 9 characters for the same rename'
---

# rename SICF: into a custom namespace, and the namespace node

Merged upstream, not released. abaplint's SICF renamer (from 2.113, #3789)
renames a node to another customer name; #4717 renames it into a registered
namespace (`/ca2ui5/`) and #4718 creates the namespace's own node the new
service sits below.

**Nothing to file.** This item exists so the request is not filed again while
the change waits for a release. When abap2UI5's `@abaplint/cli` pin is a
release that carries both, `tools/bsp_rename` can leave the ICF node of
`src/03/01` to abaplint (the BSP half waits for
`abaplint-rename-wapa`), and this item is deleted.
