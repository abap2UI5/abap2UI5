---
target: abaplint
title: 'MESSAGE usage: dialog messages in global classes, messages passed through the sy-msg fields'
summary: 'two MESSAGE checks - MESSAGE TYPE E/A/X and WRITE in methods of global classes (no dialog there, use exceptions), and MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno, which hides the message from the where-used list'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abapOpenChecks check 071 (larshp/abapOpenChecks docs/_checks/71.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# MESSAGE usage: dialog messages in global classes, messages passed through the sy-msg fields

Both read the MESSAGE statement; one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-message-in-class-method`, `abaplint-message-sy-msg-passthrough`.

## Report MESSAGE TYPE E/A/X and WRITE in methods of global classes

```abap
METHOD read.
  MESSAGE e001(zmsg).
ENDMETHOD.
```

**Proposal.** Report MESSAGE without RAISING of type E, A or X, and WRITE, in global class methods.

**Not reported.** MESSAGE … INTO; MESSAGE … RAISING; type S/I/W.


**Source.** abapOpenChecks 57; Clean ABAP.

## Report MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

The message shown is decided at runtime by whatever set sy-msgid last.

```abap
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
```

**Proposal.** Report MESSAGE whose ID, TYPE or NUMBER is a sy-msg* field.

**Not reported.** MESSAGE … INTO for logging the current message (option).


**Source.** abapOpenChecks check 071.

**Where.** a new rule, one option per check. **Effort:** S.
