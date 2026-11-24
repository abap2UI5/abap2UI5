---
target: abaplint
title: 'unsecure_fae: a FOR ALL ENTRIES guarded by IF itab IS NOT INITIAL is reported'
summary: 'the rule reports EVERY FOR ALL ENTRIES - the guard detection is a "todo" in its source - so no code change silences it and a consumer excludes whole files; S5S excludes 27'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/issues/2384
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 80891c9: abaplint.jsonc excludes 27 files from unsecure_fae - every FOR ALL ENTRIES in them was reviewed and is guarded by IF <itab> IS NOT INITIAL, an early RETURN or a driver table provably filled, except one deliberately unguarded site (/KRO/UI502_CL_APP_014 FACTORY); the exclusion also hides every FAE added to those files later'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: IF it IS NOT INITIAL. SELECT * FROM t000 FOR ALL ENTRIES IN @it WHERE mandt = @it-table_line INTO TABLE @lt_t000. ENDIF. - "Unsecure FAE (unsecure_fae)"'
  - 'abaplint/abaplint#2384 (open since 2022-02) reports the same shape'
---

# unsecure_fae: a FOR ALL ENTRIES guarded by IF itab IS NOT INITIAL is reported

```abap
IF it IS NOT INITIAL.
  SELECT * FROM t000
    FOR ALL ENTRIES IN @it          " Unsecure FAE
    WHERE mandt = @it-table_line
    INTO TABLE @lt_t000.
ENDIF.
```

**Current behaviour.** `rules/unsecure_fae.ts` reports every
`SQLForAllEntries` expression of a syntax-clean object; the check whether the
driver table is tested for emptiness is a `// todo` in the loop. The rule is
tagged experimental - but it is on in `abaplint --default`, and a consumer
that switches it on gets one finding per FAE that no code change can remove.

**Proposal.** Report a FAE only when no guard dominates it. A guard is, for
the driver table `itab` of `FOR ALL ENTRIES IN itab`:

1. an enclosing `IF` / `ELSEIF` whose condition is `itab IS NOT INITIAL`,
   `lines( itab ) > 0` / `<> 0` / `>= 1`, or contains one of these joined by
   `AND`;
2. an earlier `IF itab IS INITIAL. RETURN.` (or `CHECK itab IS NOT INITIAL.`,
   `CONTINUE`/`EXIT` in a loop) in the same block, with no write to `itab` in
   between.

**Not reported.** A FAE under either guard. **Still reported:** a guard on a
different table; a guard joined with `OR`; a write to `itab` between the guard
and the SELECT; a guard in the caller (out of reach - an option could accept a
`##`-pragma or pseudo comment instead).

**Where.** `unsecure_fae`. **Effort:** M.

**Cost of the false positive.** S5S excludes 27 files from the rule, so a new
unguarded FAE in any of them is not reported either.

**Source.** S5S (a consumer system).

A PR is being prepared from oblomov-dev/fork-abaplint. The upstream issue
(abaplint/abaplint#2384) has the same example; this item adds the scope.
