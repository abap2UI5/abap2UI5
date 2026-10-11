---
target: abaplint
title: 'Report a UTF-8 BOM at the start of a .abap file'
summary: 'xml_bom requires the BOM on XML files; an .abap file that starts with one gives abapGit diffs and import trouble, and nothing reports it'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5 check:abapgit decides it today (abap-check §1, bom row); no abaplint rule covers the .abap half'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a UTF-8 BOM at the start of a .abap file

```abap
(file starts with EF BB BF)
```

**Proposal.** Report an .abap file whose first bytes are the UTF-8 BOM, with a quick fix.

**Not reported.** XML files (xml_bom).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abap2UI5 abap-check §1.
