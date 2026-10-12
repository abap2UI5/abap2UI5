---
target: abaplint
title: 'Report MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno'
summary: 're-raising the last message through the sy-msg fields hides the message from the where-used list and shows whatever message happens to be in sy'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 071 (larshp/abapOpenChecks docs/_checks/71.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

The message shown is decided at runtime by whatever set sy-msgid last.

```abap
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
```

**Proposal.** Report MESSAGE whose ID, TYPE or NUMBER is a sy-msg* field.

**Not reported.** MESSAGE … INTO for logging the current message (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 071.
