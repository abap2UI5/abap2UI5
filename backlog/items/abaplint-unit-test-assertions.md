---
target: abaplint
title: 'Unit-test assertions: pointless, imprecise or missing'
summary: 'assertions that cannot fail (act = exp, two literals), assert_equals where assert_true/assert_subrc says it, ASSERT instead of cl_abap_unit_assert in tests, exp before act, and an expected exception without fail( ) - one rule over FOR TESTING code'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'ATC on an ABAP Cloud trial system, 2026-11-10: "Tolerable Assertion Error: Unicode_Characters: FAIL" on z2ui5_cl_ajson - the test called fail( level = tolerable ) in the CATCH of a class that does not exist there, a warning on every run; replaced by a fallback in abap2UI5/mirror-ajson#34. Probed 2026-11-11 against abaplint 2.120.92, every default rule on: not reported'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Unit-test assertions: pointless, imprecise or missing

All checks look at calls in FOR TESTING classes; one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-pointless-unit-assert`, `abaplint-test-expected-exception-fail`.

## Report unit-test assertions whose act and exp are identical or both literals

```abap
cl_abap_unit_assert=>assert_equals( act = 1 exp = 1 ).
```

**Proposal.** Report calls of cl_abap_unit_assert=>assert_* (and methods named *assert*) where act and exp are token-identical or both literals.

**Not reported.** Asserts with only act (assert_bound, assert_true).

## Report a test that expects an exception but never calls fail( )

```abap
TRY.
    cut->run( ).
  CATCH zcx_error.
ENDTRY.
```

**Proposal.** In FOR TESTING methods report TRY blocks whose CATCH is empty or only asserts and whose TRY part has no cl_abap_unit_assert=>fail( ) after the call.

**Not reported.** Tests that assert in the TRY part.

**Source.** Clean ABAP 'Use FAIL to check for expected exceptions'.

## Report fail( ) with a tolerable level as the answer to a missing prerequisite

```abap
TRY.
    CALL METHOD (lv_class)=>uccpi
      EXPORTING
        uccp = 4660
      RECEIVING
        char = lv_char.
  CATCH cx_sy_dyn_call_illegal_class.
    cl_abap_unit_assert=>fail( level = if_aunit_constants=>tolerable ).
ENDTRY.
```

The test cannot run here, and says so with a failure. ATC lists it as a warning on every run of every system that lacks the prerequisite - a finding nobody can fix in that system.

**Proposal.** Report `cl_abap_unit_assert=>fail( )` (and `abort( )`) with `level = …tolerable` / `…severity-low` when it is the only statement of a CATCH block for a `cx_sy_dyn_call_*` or `cx_sy_create_object_error` class. The message says to provide a fallback or to leave the test quietly.

**Not reported.** A fail( ) of any other level; a tolerable fail( ) outside a CATCH; a CATCH that does anything else.

**Source.** sbcgua/ajson, test `unicode_characters`.

## Use assert_true / assert_false instead of assert_equals with abap_true

```abap
cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_true ).
```

Instead:

```abap
cl_abap_unit_assert=>assert_true( lv_ok ).
```

**Proposal.** Report assert_equals/assert_differs whose exp is abap_true/abap_false; quick fix to assert_true/assert_false.

**Not reported.** act of a type other than abap_bool.

## Use assert_subrc instead of assert_equals on sy-subrc

```abap
cl_abap_unit_assert=>assert_equals( act = sy-subrc exp = 0 ).
```

Instead:

```abap
cl_abap_unit_assert=>assert_subrc( ).
```

**Proposal.** Report assert_equals with act = sy-subrc; quick fix to assert_subrc( exp = … ).

**Not reported.** -

## Use cl_abap_unit_assert instead of ASSERT in test classes

```abap
METHOD test_read.
  ASSERT lv_count = 2.
```

Instead:

```abap
cl_abap_unit_assert=>assert_equals( act = lv_count exp = 2 ).
```

**Proposal.** Report the ASSERT statement in FOR TESTING classes; an ASSERT dumps the run instead of failing the test. The production-code counterpart is abaplint-assert-in-production.

**Not reported.** Helper classes that are not FOR TESTING.

## Standardize the order act before exp

```abap
cl_abap_unit_assert=>assert_equals( exp = 2 act = lv_count ).
```

**Proposal.** Report calls of cl_abap_unit_assert methods that pass exp before act (configurable order); quick fix reorders.

**Not reported.** -

**Where.** a new rule, one option per check. **Effort:** S.
