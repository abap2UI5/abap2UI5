---
target: abaplint
title: 'rename: a new name over 30 characters stops the whole rename with a bare "Name not allowed"'
summary: when a renamed name exceeds the object type's limit, --rename throws "Name not allowed" without naming the object, and there is no option to shorten it - it blocks rfc-connector (a 30-character handler) and sql-console, and blocked custom-controls until its four classes over 25 were shortened on 2026-11-26; upstream issues #1589 (2020) and #3784 (strip to 30) are open
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/issues/3784
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 cli.js Renamer.rename: `else if (newName.length > obj.getAllowedNaming().maxLength) { throw new Error("Name not allowed"); }` - neither the object nor the new name is in the message'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): custom-controls stops at Z2UI5_CL_CCI_SIGNATURE_PAD; over 25 characters are z2ui5_cl_cci_rich_text_editor (29), _barcode_scanner (28), _network_status (27), _signature_pad (26); rfc-connector has Z2UI5_CL_RFC_CONNECTOR_HANDLER (30); sql-console Z2UI5_CL_SQL_NATIVE_CONSOLE_ST (30)'
  - 'abap2UI5 and every addon with a rename cap their names at 25 characters by hand (rename.jsonc header, samples-stack object_naming) so that a 10-character prefix fits - a rule abaplint cannot enforce for the rename, only object_naming can'
  - 'custom-controls DEV 2026-11-26: the four classes shortened (z2ui5_cl_cci_rich_text, _barcode_scan, _net_status, _signature; breaking, changelog.txt) - npm run rename with the full 10 characters, 70 files, 0 issues; the cap renameMaxLength 6 is gone'
  - 'gh search 2026-11-26: abaplint/abaplint#1589 "--rename fails if renamed class name is >30 chars" open since 2020-12-03; #3784 "automatic renaming - add option to strip the filename to 30" open since 2025-12-05'
---

# rename: a new name over 30 characters

## Current behaviour

A pattern `^z2ui5_(.*)$` -> `zmyui5_$1` over a class named
`z2ui5_cl_cci_rich_text_editor` (29) gives 30+ characters, and the rename
stops with `Error: Name not allowed` - no object, no new name, no file. The
only way to find it is the line abaplint printed before the error.

## Blocked today

rfc-connector (its handler, 30 characters), sql-console (four classes).
custom-controls was blocked by four classes until it shortened them
(2026-11-26, breaking). Every other repository caps its names at 25 by hand.

## Proposed

1. The error names the object and the new name (cheap, #1589).
2. #3784: an option that shortens a name over the limit deterministically
   (cut to the limit, or a configured map `oldName -> newName` that takes
   precedence over the patterns), so a repository with a few long names can
   be renamed without renaming its objects for everyone.
