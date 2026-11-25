---
target: abaplint
title: 'The 702 downport writes WITH KEY KEY primary_key for itab[ KEY primary_key COMPONENTS ... ]'
summary: 'a table expression naming the primary key explicitly is lowered to READ TABLE ... WITH KEY KEY primary_key ..., which does not compile on 7.02'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'abap-util and abap2UI5, 2026-11-25, while READ TABLE ... WITH TABLE KEY was rewritten to table expressions: itab[ KEY primary_key COMPONENTS name = x ] came out of the downport as READ TABLE itab WITH KEY KEY primary_key name = x ..., which the 702 lint reports'
---

# The 702 downport writes `WITH KEY KEY primary_key`

```abap
ASSIGN itab[ KEY primary_key COMPONENTS name = lv_name ] TO <row>.
```

is lowered to `READ TABLE itab WITH KEY KEY primary_key name = lv_name ...`.
The 7.02 form is `READ TABLE itab WITH TABLE KEY name = lv_name` (the primary
key) or `WITH KEY name COMPONENTS ...` for a secondary key.

## Proposal

For `KEY primary_key COMPONENTS` emit `WITH TABLE KEY <components>`; for a
named secondary key keep `WITH KEY <name> COMPONENTS <components>`.

## Workaround

Name the components without the key name when they cover the unique key, or
keep `READ TABLE ... WITH TABLE KEY` (abap-check, section 4).
