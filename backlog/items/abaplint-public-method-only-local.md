---
target: abaplint
title: 'Report a public method that is only called inside its own class'
summary: 'abapOpenChecks 058 "Method is only referenced locally. Should be changed to private or protected" - unused_methods checks private and protected methods only, nothing reports a public one with no caller outside'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'ATC export of an S/4HANA EWM system (2026-11-24), abapOpenChecks 058: 143 findings "Method is only referenced locally. Should be changed to private or protected." - 120 in Z2UI5_ classes (Z2UI5_CL_POPUP_CONTEXT 16, Z2UI5_CL_TM_CONTEXT 14, Z2UI5_CL_UI5_APP_START 10, Z2UI5_CL_UI5_UTIL_CONTEXT 10), 22 in /KRO/ (S5S)'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated project with a control finding firing: a PUBLIC method helper called once from another method of the same FINAL class - no finding; unused_methods documents "Checks private and protected methods"'
---

# Report a public method that is only called inside its own class

```abap
CLASS zcl_x DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS run.
    METHODS helper RETURNING VALUE(rv) TYPE i.   " only called by run( )
ENDCLASS.
```

A public method nothing outside the class calls is API surface without a
user: it cannot be changed or removed without searching every consumer, and
it tells the reader it is meant to be called from outside. abapOpenChecks
(058) and the code inspector report it; abaplint's `unused_methods` checks
private and protected methods only, so nothing does.

**Proposal.** A new rule (or an `unused_methods` option): report a PUBLIC
method of a global class that has references from its own class only, across
the whole project - "only used inside zcl_x, make it private (or protected)".
Needs the where-used over the registry `unused_methods` already builds.

**Not reported.**

- interface methods (`zif~m`) and methods declared in an interface;
- redefinitions, and methods a subclass in the project redefines (protected
  is the fix there, an option);
- constructor, class_constructor, event handlers, FOR TESTING methods;
- methods with no reference at all (that is "unused", another finding);
- classes meant as API - a configurable list of class name patterns (for
  example a library's `z2ui5_cl_*` public facade), or classes with no
  subclass and no caller in a project that is a library: a project-level
  option `"isLibrary": true` turns the rule off for public classes.

**Where.** a new rule next to `unused_methods`. **Effort:** M (the scope list
is what decides whether it is usable).

**Source.** ATC on a consumer system (S5S and the abap2UI5 addons installed
there).
