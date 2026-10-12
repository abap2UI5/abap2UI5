---
target: abaplint
title: 'A read that needs a SORT the table did not get: BINARY SEARCH and DELETE ADJACENT DUPLICATES'
summary: 'READ TABLE … BINARY SEARCH and DELETE ADJACENT DUPLICATES … COMPARING silently give wrong results unless the table is sorted by those fields - the same ''is there a matching SORT before this'' analysis'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 201560c (''bug fixing'', added the SORT)'
  - '16 sites unsorted within their method in current trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abapGit/abapGit 6cbc78d (#6121, ITAB_DUPLICATE_KEY afterwards)'
  - 'abap2xlsx/abap2xlsx f44f7ba, 5d80ca2 (#461)'
  - 'latent today: abapGit src/objects/zcl_abapgit_object_shi3.clas.abap:484 sorts BY id and compares spras id'
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
