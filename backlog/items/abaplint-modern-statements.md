---
target: abaplint
title: 'Modern statements: += instead of x = x + …, to_upper( ) instead of TRANSLATE, condense( ) instead of CONDENSE'
summary: 'three statements with a shorter modern form; abaplint has no finding for them yet - one rule with a quick fix each, gated on the syntax version'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on: no rule reports it'
---

# Modern statements: += instead of x = x + …, to_upper( ) instead of TRANSLATE, condense( ) instead of CONDENSE

Same family as use_new and prefer_raise_exception_new: an older statement with a newer equivalent and a mechanical quick fix.

## Prefer calculation assignment operators (+=, -=, *=, /=)

```abap
lv_count = lv_count + 1.
```

Instead:

```abap
lv_count += 1.
```

**Proposal.** From v754 on, report x = x + y / x - y / x * y / x / y where the target is the left operand; quick fix to x += y.

**Not reported.** Below v754; targets with offset/length.

## Replace TRANSLATE … TO UPPER/LOWER CASE with to_upper( )/to_lower( )

```abap
TRANSLATE lv_name TO UPPER CASE.
```

Instead:

```abap
lv_name = to_upper( lv_name ).
```

**Proposal.** Report TRANSLATE … TO UPPER/LOWER CASE; quick fix to lv = to_upper( lv ).

**Not reported.** TRANSLATE … USING (no direct function).

## Replace CONDENSE with condense( )

```abap
CONDENSE lv_text.
```

Instead:

```abap
lv_text = condense( lv_text ).
```

**Proposal.** Report CONDENSE [NO-GAPS]; quick fix to lv = condense( lv ) / condense( val = lv del = ` ` ).

**Not reported.** Below v702; operands of type c where the result type matters (option).

**Where.** a new rule, one option per check. **Effort:** S.
