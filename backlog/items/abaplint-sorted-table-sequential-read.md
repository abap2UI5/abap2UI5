---
target: abaplint
title: 'Report a sequential read on a sorted table'
summary: 'LOOP/DELETE/MODIFY … WHERE and READ … WITH KEY on a SORTED table whose condition does not start at the first key component (or compares it with CP) scan every row - ATC reports "Possible sequential read on a sorted table" and wants a key access or `"#EC CI_SORTSEQ`'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/2490
first_seen: 2026-11-11
checked_upstream: 2026-11-11
upstream: abaplint/abaplint
evidence:
  - 'ATC on an ABAP Cloud trial system, 2026-11-10: "Possible sequential read on a sorted table" (check "Low Performance Operations on Internal Tables") on z2ui5_cl_ajson line 209, `DELETE mt_json_tree WHERE path CP lv_parent_path.` - mt_json_tree is SORTED … WITH UNIQUE KEY path name; silenced with the pseudo comment in abap2UI5/mirror-ajson#34'
  - 'probed 2026-11-11 against abaplint 2.120.92 with every default rule on (abaplint -d, v750 and Cloud): DELETE … WHERE path CP, DELETE … WHERE of a non-key component, LOOP … WHERE of the second key component and READ … WITH KEY of a non-key component on a sorted table - no rule reports any of the four'
  - 'abaplint/abaplint#2490 "new rule: Possible sequential read" is open - found by a tracker search on 2026-11-11, read by its title only (the repository was not readable from the session that wrote this)'
---

# Report a sequential read on a sorted table

A sorted table is declared for its key access. A condition the key cannot
serve is evaluated row by row, exactly like on a standard table - the
declaration promises a binary search and the statement does a full scan.
SAP's ATC check "Low Performance Operations on Internal Tables" reports it as
*Possible sequential read on a sorted table*, on every system that runs the
default variant, ABAP Cloud included.

```abap
TYPES ty_nodes TYPE SORTED TABLE OF ty_node WITH UNIQUE KEY path name.
DATA mt_tree TYPE ty_nodes.

DELETE mt_tree WHERE path CP lv_pattern.          " first key component, but CP
DELETE mt_tree WHERE type = lv_type.              " not a key component
LOOP AT mt_tree INTO ls_node WHERE name = lv_name. " second key component only
ENDLOOP.
READ TABLE mt_tree INTO ls_node WITH KEY type = lv_type.
```

**Proposal.** For a table whose type is statically known as SORTED, report
`LOOP AT … WHERE`, `DELETE … WHERE`, `MODIFY … WHERE` and `READ TABLE … WITH
KEY` (and the table expression `itab[ … ]`) when the condition gives the key
no initial part to work with: the first component of the key in use is not
compared with `=` (or `EQ`), joined by `AND`. The key in use is the primary
key, or the secondary key named by `USING KEY`.

**Not reported.**

- A condition that fixes a leading part of the key with `=` - the rest of the
  condition may be anything.
- `WITH TABLE KEY`, and an access by index.
- A statement that carries `"#EC CI_SORTSEQ`: the author has seen it and there
  is no key access to offer (a pattern match on the key, as in the AJSON line
  above).
- Standard and hashed tables, generic table types, and a table whose type is
  not known statically.
- A dynamic WHERE condition.

**Where.** a new rule; the analysis is the one `check_syntax` already does for
abaplint/abaplint#4549 (a LOOP over a sorted secondary key without an
optimizable comparison of its first component), applied to the primary key as
a finding instead of a syntax error. **Effort:** M.

**Source.** ATC check "Low Performance Operations on Internal Tables", pseudo
comment CI_SORTSEQ.
