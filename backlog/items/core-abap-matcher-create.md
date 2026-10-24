---
target: open-abap
title: 'open-abap-core: `cl_abap_matcher=>create( )` and `matcher->replace_all( )` are missing - the classic regex API of a report does not check'
summary: 'cl_abap_matcher of open-abap-core has the instance methods (find_all, find_next, match, get_submatch, get_offset, get_length) and the PCRE factory, but not the static `create( pattern text ignore_case )` most code uses nor `replace_all( )` / `text`; abaplint resolves the class from open-abap-core and stops on `Method "create" not found`, so code with the classic regex objects is out before it can run'
priority: low
state: open
first_seen: 2026-10-24
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui) - 11 converted report snippets that build a matcher with `cl_abap_matcher=>create( pattern = ... text = ... )` fail the syntax check of the transpile with `check_syntax: Method "create" not found, methodCallChain`; across the snippets `cl_abap_matcher=>create` is called 16 times, `->replace_all( )` twice'
  - 'read 2026-10-24 in @abap2ui5/node-runtime 1.148.0 `output/open-abap-core/cl_abap_matcher.clas.mjs` - its methods are constructor, find_all, find_next, get_length, get_offset, get_submatch and match; `cl_abap_regex.clas.mjs` has create_matcher( ) and the static create_pcre( )'
---

# open-abap-core: `cl_abap_matcher=>create( )` is missing

```abap
DATA(lo_matcher) = cl_abap_matcher=>create( pattern     = `(\d+)-(\d+)`
                                            text        = `10-20`
                                            ignore_case = abap_true ).
" system:     a matcher over the text
" open-abap:  check_syntax: Method "create" not found
```

## The change

In open-abap-core `cl_abap_matcher`, add the static `create( pattern text
ignore_case simple_regex no_submatches )` as `NEW cl_abap_regex( pattern
ignore_case )->create_matcher( text )`, and the instance `replace_all(
newtext )` / `replace_found( )` with the attribute `text` - the
replacement over the matches `find_all( )` already finds.

## Example

```abap
DATA(lo_matcher) = cl_abap_matcher=>create( pattern = `o` text = `foo` ).
cl_abap_unit_assert=>assert_equals( act = lo_matcher->replace_all( `0` ) exp = 2 ).
cl_abap_unit_assert=>assert_equals( act = lo_matcher->text exp = `f00` ).
```
