---
target: abaplint
title: 'unsecure_fae: the IS NOT INITIAL guard it asks for changes the result - say so, and report the guard that leaves the target stale'
summary: 'an empty FOR ALL ENTRIES table selects every row, the usual IF itab IS NOT INITIAL guard selects none - the rule (guard detection merged in abaplint#4706) treats the guard as the fix, while for a count or an "all" filter it is the bug'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository: abaplint.jsonc excluded 27 files from unsecure_fae - every FOR ALL ENTRIES in them was reviewed and is guarded by IF <itab> IS NOT INITIAL, an early RETURN or a driver table provably filled, except one deliberately unguarded site'
  - 'probed 2026-11-24 against abaplint 2.120.116: IF it IS NOT INITIAL. SELECT … FOR ALL ENTRIES IN @it … ENDIF. was reported as "Unsecure FAE" - the guard detection was a todo in rules/unsecure_fae.ts (still so in 2.120.118)'
  - 'filed as abaplint/abaplint#2384 (open since 2022-02, the same shape); fixed by abaplint/abaplint#4706, merged 2026-11-24 and closing #2384: an IF/ELSEIF on itab IS NOT INITIAL / lines( itab ) > 0, an IF itab IS INITIAL. RETURN. or a CHECK itab IS NOT INITIAL counts as the check - not yet in a release (2.120.118 is the latest on npm)'
  - 'a downstream app repository, review of 2026-11 - a mix indicator computed with a guarded FOR ALL ENTRIES gave "none" for an empty driver table where "all" was meant; it was restored with a SELECT COUNT(*) without FOR ALL ENTRIES for the empty case'
---

# unsecure_fae: the IS NOT INITIAL guard it asks for changes the result

The first half of this item - "a guarded FAE is reported" - is fixed
upstream (abaplint/abaplint#4706, merged 2026-11-24, closing #2384). What
is left is what the guard means.

```abap
" every row when lt_matnr is empty
SELECT matnr FROM mara FOR ALL ENTRIES IN @lt_matnr
  WHERE matnr = @lt_matnr-table_line INTO TABLE @lt_mara.

" no row when lt_matnr is empty - and lt_mara keeps what it held before
IF lt_matnr IS NOT INITIAL.
  SELECT matnr FROM mara FOR ALL ENTRIES IN @lt_matnr
    WHERE matnr = @lt_matnr-table_line INTO TABLE @lt_mara.
ENDIF.
```

**Current behaviour.** `unsecure_fae` reports the first form and, from
#4706 on, accepts the second. The two are not the same query: an empty
driver table means *every row* without the guard and *no row* with it.
Most of the time "no row" is what the author meant, which is why the guard
is the usual fix - but for a count, an existence test or a filter that is
empty when the user set none, "every row" was meant, and the guard silently
turns it into "none". The rule's message ("Unsecure FAE") and its
documentation do not say there are two remedies, so the guard is added
mechanically.

**Proposal.**

1. **The message and the documentation** name both meanings: "an empty
   driver table selects every row; guard it with IF … IS NOT INITIAL when no
   row is meant, select without FOR ALL ENTRIES when every row is".
2. **An option `guardLeavesTargetStale`** (default on): report a guarded FAE
   whose `INTO TABLE` target is neither cleared nor freshly declared before
   the guard and has no `ELSE` branch that writes it - the empty case then
   leaves the previous content, which is neither meaning. The usual place is
   a LOOP that runs the guarded SELECT per group.

**Not reported.** A guarded FAE into an inline declaration
(`INTO TABLE @DATA(lt)` - initial on the empty path) or into a target
cleared before the guard; a guard with an `ELSE` that writes the target; an
`APPENDING TABLE` target (appending nothing is the intent).

**Where.** `unsecure_fae`. **Effort:** S.

**Source.** A downstream app repository.
