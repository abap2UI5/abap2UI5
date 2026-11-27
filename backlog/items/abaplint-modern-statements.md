---
target: abaplint
title: 'Modern statements: += instead of x = x + …, condense( ) instead of CONDENSE'
summary: 'two statements with a shorter modern form; abaplint has no finding for them yet - one rule with a quick fix each, gated on the syntax version (TRANSLATE, the third, shipped as an option of obsolete_statement)'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on: no rule reports it'
  - 'abaplint/abaplint#4552 (open pull request, 2026-11-10, not ours) adds a `translate` option to obsolete_statement with a quick fix to to_upper( )/to_lower( ) - the TRANSLATE part of this item; the += and condense( ) parts are not covered. Seen by the upstream search of 2026-11-14'
  - 'abaplint/abaplint#4552 merged 2026-11-21 and is in 2.120.121: probed 2026-11-27 against abaplint main, TRANSLATE s TO UPPER CASE reports "TRANSLATE is obsolete" (obsolete_statement); c = c + 1 and CONDENSE s are still silent with every default rule on - the two parts left'
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
