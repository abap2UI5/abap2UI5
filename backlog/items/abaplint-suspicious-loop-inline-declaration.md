---
target: abaplint
title: 'suspicious_loop: a WHILE whose counter is advanced through an inline-declared variable is reported as unchanged'
summary: 'WHILE lv_from <= lv_total. DATA(lv_to) = lv_from + n - 1. ... lv_from = lv_to + 1. ENDWHILE. - reported as "sets lv_from to the same value in every iteration"; with lv_to declared before the loop it is not'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 80891c9: /KRO/UI501_SLG1 loads application logs in packages - WHILE lv_from <= lv_total. DATA(lv_to) = lv_from + p_pack - 1. ... lv_from = lv_to + 1. ENDWHILE. - the loop terminates; suspicious_loop says it runs once or forever'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: the shape above reports "WHILE condition does not change after the first iteration, the loop body sets lv_from to the same value in every iteration, the loop runs once or forever (suspicious_loop)"; the same method with DATA lv_to TYPE i. before the loop and lv_to = lv_from + 10 - 1. inside it is not reported'
---

# suspicious_loop: a WHILE whose counter is advanced through an inline-declared variable is reported as unchanged

```abap
DATA(lv_from) = 1.
WHILE lv_from <= lv_total.            " suspicious_loop: sets lv_from to the same value
  DATA(lv_to) = lv_from + 10 - 1.     " in every iteration, the loop runs once or forever
  " ... process lv_from to lv_to
  lv_from = lv_to + 1.
ENDWHILE.
```

`lv_to` depends on `lv_from`, and `lv_from` on `lv_to`, so the condition
changes every iteration and the loop ends.

**Current behaviour.** `rules/suspicious_loop.ts`, `unchangedCondition`:
`sameValueWrite` accepts `lv_from = lv_to + 1.` as "the same value every
iteration" when no local the source reads is written inside the loop. The
write of `lv_to` is its inline declaration `DATA(lv_to) = ...`, and that is
not counted among `lv_to`'s writes - with `DATA lv_to TYPE i.` before the loop
and a plain `lv_to = ...` inside it, the rule is silent.

**Proposal.** Count an inline declaration (`DATA(x) =`, `FINAL(x) =`,
`INTO DATA(x)`, `REFERENCE INTO DATA(x)`, `ASSIGNING FIELD-SYMBOL(<x>)`) inside
the loop body as a write of `x` at that statement, in `sameValueWrite` and in
the "the body does not write" check.

**Not reported.** A condition variable assigned from a local that is
(re)declared inline in the loop body. **Still reported:** the shape whose source
really is constant - `lv_from = lv_start + 1.` with `lv_start` not written in
the loop.

**Where.** `suspicious_loop`. **Effort:** S.

**Source.** S5S (a consumer system).

A PR is being prepared from oblomov-dev/fork-abaplint.
