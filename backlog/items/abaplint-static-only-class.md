---
target: abaplint
title: 'Report classes with only static methods (Clean ABAP: prefer objects to static classes)'
summary: 'a class of only CLASS-METHODS cannot be mocked or injected; abapOpenChecks and Clean ABAP report it'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 093 (larshp/abapOpenChecks docs/_checks/93.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report classes with only static methods (Clean ABAP: prefer objects to static classes)

Static-only classes couple every caller to the implementation.

```abap
CLASS zcl_util DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS a.
    CLASS-METHODS b.
ENDCLASS.
```

**Proposal.** Report a class whose methods are all static (excluding class_constructor), with options for factories (a static method returning an instance of the class) and exception classes.

**Not reported.** Classes with any instance method; exception classes; test classes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 093.
