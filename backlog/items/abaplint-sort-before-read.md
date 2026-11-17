---
target: abaplint
title: 'A read that needs a SORT the table did not get: BINARY SEARCH and DELETE ADJACENT DUPLICATES'
summary: 'READ TABLE … BINARY SEARCH and DELETE ADJACENT DUPLICATES … COMPARING silently give wrong results unless the table is sorted by those fields - the same ''is there a matching SORT before this'' analysis'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4587
first_seen: 2026-10-11
checked_upstream: 2026-11-17
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 201560c (''bug fixing'', added the SORT)'
  - '16 sites unsorted within their method in current trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abapGit/abapGit 6cbc78d (#6121, ITAB_DUPLICATE_KEY afterwards)'
  - 'abap2xlsx/abap2xlsx f44f7ba, 5d80ca2 (#461)'
  - 'latent today: abapGit src/objects/zcl_abapgit_object_shi3.clas.abap:484 sorts BY id and compares spras id'
  - 'checked 2026-11-17 while writing the rule sort_before_read: three of the cited fixes are not this shape. abapGit 201560c turned a SORTED table into a standard table plus a SORT; in abapGit 6cbc78d and abap2xlsx f44f7ba/5d80ca2 the SORT before already matched the COMPARING. The shape itself is abapGit e124e3e (abapGit/abapGit#7283, SORT lt_texts BY spras became BY spras node_id)'
  - 'the latent abapGit zcl_abapgit_object_shi3 site (SORT lt_titles BY id, then COMPARING spras id) is fixed in abapGit/abapGit#8010 (2026-11-17), found with the rule; after it the rule reports nothing over abapGit src'
  - 'filed 2026-11-17 as abaplint/abaplint#4587, the rule sort_before_read'
---

# A read that needs a SORT the table did not get: BINARY SEARCH and DELETE ADJACENT DUPLICATES

Both look backwards from the statement for a SORT of the same table by the same leading fields; one rule with both statements.

Merged on 2026-10-12 from the items `abaplint-binary-search-sort`, `abaplint-adjacent-duplicates-sort`.

## Report READ TABLE … BINARY SEARCH without a matching SORT

```abap
SORT lt BY b.
READ TABLE lt WITH KEY a = 1 BINARY SEARCH TRANSPORTING NO FIELDS.
```

**Proposal.** Report BINARY SEARCH on a locally filled standard table whose last SORT in the method is missing or does not lead with the WITH KEY fields in order.

**Not reported.** Tables filled outside the method.

**Source.** abapGit fix history; Sonar.

## Report DELETE ADJACENT DUPLICATES … COMPARING without a matching SORT before it

```abap
SORT lt_titles BY id.
DELETE ADJACENT DUPLICATES FROM lt_titles COMPARING spras id.
```

**Proposal.** Report DELETE ADJACENT DUPLICATES on a standard table filled in the method when the nearest earlier SORT of it does not lead with the COMPARING fields, or there is none and no SELECT … ORDER BY.

**Not reported.** Tables sorted elsewhere (parameters, attributes); sorted tables.

**Source.** abapGit, abap2xlsx fix history; Sonar S1673.

**Where.** a new rule, one option per check. **Effort:** M.
