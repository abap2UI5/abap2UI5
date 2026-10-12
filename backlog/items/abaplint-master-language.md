---
target: abaplint
title: 'Report objects whose original language differs from the configured one'
summary: 'abapOpenChecks checks the master language; in abapGit files the language sits in the XML (LANGU / MASTER_LANGUAGE), and a wrong one lands on every pull'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 075 (larshp/abapOpenChecks docs/_checks/75.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report objects whose original language differs from the configured one

An object created in the wrong logon language translates badly and shows up as a diff.

```abap
<LANGU>D</LANGU>   (configured: E)
```

**Proposal.** Report object XML whose original-language field differs from a configured language.

**Not reported.** Objects without a language field.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 075.
