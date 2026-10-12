---
target: abaplint
title: 'Class design: static-only classes, constant interfaces, public methods outside an interface'
summary: 'three structural Clean ABAP checks - a class of only static methods, an interface of only constants, public instance methods that are not interface methods'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Class design: static-only classes, constant interfaces, public methods outside an interface

All three read class and interface definitions only; one rule, one option per check, all off by default.

Merged on 2026-10-12 from the items `abaplint-static-only-class`, `abaplint-constants-interface`, `abaplint-public-method-not-in-interface`.

## Report classes with only static methods (Clean ABAP: prefer objects to static classes)

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

## Report interfaces that contain only constants

```abap
INTERFACE zif_consts PUBLIC.
  CONSTANTS c_a TYPE i VALUE 1.
ENDINTERFACE.
```

**Proposal.** Report an INTERFACE whose components are all CONSTANTS (and TYPES, option).

**Not reported.** Interfaces with any method, event or data.

## Report public instance methods that are not part of an interface

```abap
CLASS zcl_svc DEFINITION PUBLIC FINAL.
  PUBLIC SECTION.
    METHODS run.
ENDCLASS.
```

**Proposal.** Report METHODS in the PUBLIC SECTION of a global class that are not REDEFINITION and not constructor, when the class implements no interface or the method is not an interface method.

**Not reported.** CLASS-METHODS; exception classes; test classes; constructor.

**Where.** a new rule, one option per check. **Effort:** S.
