---
target: abaplint
title: 'Report messages and message-based exception texts that nothing in the repository uses'
summary: 'a T100 message no MESSAGE, RAISE … MESSAGE or exception text refers to is dead text that still gets translated'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 035/036 (larshp/abapOpenChecks docs/_checks/35.md, docs/_checks/36.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report messages and message-based exception texts that nothing in the repository uses

```abap
MSAG ZMSG message 042, referenced nowhere
```

**Proposal.** Report MSAG messages (and T100 keys of exception classes) without a static reference in the repository; option to skip messages used dynamically.

**Not reported.** Messages of SAP classes; repositories that are libraries for others (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 035/036.
