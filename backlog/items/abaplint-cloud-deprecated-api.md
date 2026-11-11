---
target: abaplint
title: 'Report SAP objects that are deprecated or missing in ABAP Cloud, with their successor'
summary: 'IF_AUNIT_CONSTANTS is deprecated in ABAP Cloud (successor IF_ABAP_UNIT_CONSTANT) and CL_ABAP_CONV_IN_CE does not exist there - ATC reports the first, and the second is only found when the code runs; a curated list with successors would report both, including a class named in a literal for a dynamic call'
priority: low
state: open
first_seen: 2026-11-11
checked_upstream: 2026-11-11
upstream: abaplint/abaplint
evidence:
  - 'ATC on an ABAP Cloud trial system, 2026-11-10: "Interface IF_AUNIT_CONSTANTS is deprecated. Use Interface IF_ABAP_UNIT_CONSTANT instead." (check "usage of deprecated and decommissioned objects") on the test class of z2ui5_cl_ajson, `cl_abap_unit_assert=>fail( level = if_aunit_constants=>tolerable )`'
  - 'same run: the unit test Unicode_Characters ended in a tolerable failure because `CL_ABAP_CONV_IN_CE` - named in a literal and called with CALL METHOD (name)=>uccpi - does not exist in ABAP Cloud; both removed in abap2UI5/mirror-ajson#34'
  - 'ABAP Unit on the same system, 2026-11-11: z2ui5_cx_ui5_util_error out of z2ui5_cl_ui5_util_http=>client_create - a test reached `CL_HTTP_CLIENT`, named in a literal and called with CALL METHOD (name)=>create_by_url, a class ABAP Cloud does not have (successor CL_WEB_HTTP_CLIENT_MANAGER)'
  - 'probed 2026-11-11 against abaplint 2.120.92 with every default rule on (abaplint -d, v750 and Cloud): neither line is reported - the dynamic call draws no_dynamic_stuff, which says nothing about the class'
  - 'tracker search 2026-11-11: abaplint/abaplint#1547 "CL_AUNIT_ASSERT is obsolete" is open and asks for one object of this family; nothing covers the list or ABAP Cloud'
---

# Report SAP objects that are deprecated or missing in ABAP Cloud, with their successor

Code that has to run from an old release up to ABAP Cloud names SAP objects
that changed on the way. Two things happen to them, and a system reports only
one:

- the object is **deprecated** and a successor is released - ATC says so on
  every run, as an information that never goes away;
- the object is **not there at all** - a static reference is a syntax error,
  but portable code reaches such a class dynamically on purpose, and then
  nothing reports it until the statement runs.

```abap
" deprecated in ABAP Cloud, successor IF_ABAP_UNIT_CONSTANT
cl_abap_unit_assert=>fail( level = if_aunit_constants=>tolerable ).

" not available in ABAP Cloud, successor CL_ABAP_CONV_CODEPAGE
lv_class = 'CL_ABAP_CONV_IN_CE'.
CALL METHOD (lv_class)=>uccpi
  EXPORTING
    uccp = 4660
  RECEIVING
    char = lv_char.
```

**Proposal.** Ship a curated list of SAP objects with their state in ABAP
Cloud (deprecated, not released) and the successor, and report

1. a static reference to a listed object, and
2. a literal that is exactly the name of a listed object and is the operand of
   a dynamic `CALL METHOD (…)=>`, `CREATE OBJECT … TYPE (…)` or
   `cl_abap_typedescr=>describe_by_name( )` - directly, or through a variable
   the literal was assigned to in the same method.

The message names the successor. The list is data, not code: an entry is the
object, its state and its successor, so a project can extend it.

**Not reported.**

- Repository-defined objects.
- A dynamic reference inside a `TRY` that also names the successor in another
  branch of the same method - that is the portable pattern, and the code
  already handles the missing class.
- Anything when the configured syntax version is not Cloud and the rule's
  option for "also report on other versions" is off: on 7.02 the successor
  usually does not exist, and reporting there asks for code that cannot be
  written.

**Where.** a new rule next to `cloud_types` (which decides object *types*, not
objects). It is the upper-bound sibling of the per-release list in
`abaplint-release-api-availability`: that one reports an API used below the
release that introduced it, this one an API used in an environment that
retired it. One list can carry both. **Effort:** L - the rule is small, the
list is the work.

**Source.** ATC check "usage of deprecated and decommissioned objects"; the
released-API state and successor SAP publishes per object.
