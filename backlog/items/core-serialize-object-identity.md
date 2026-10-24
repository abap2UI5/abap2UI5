---
target: open-abap
title: 'CALL TRANSFORMATION id of objects: no identity - a cycle of references never ends, an object referenced twice comes back as two'
summary: 'lcl_heap->add_object( ) of kernel_call_transformation serializes the attributes of a serializable object every time a reference to it is met, with a new id - there is no table of the objects already written; a cycle (a control that holds its handler, the handler that holds the control) recurses until the request dies of it (the server hangs), and two references to one object are restored as two objects, so a change through one is not seen through the other. ABAP writes every object once and refers to it by id'
priority: high
state: open
first_seen: 2026-10-24
upstream: open-abap/open-abap-core
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - the stand-ins of the SAP GUI controls kept the handlers of SET HANDLER in the control, the handler class (a local class with if_serializable_object) kept the controls: the first roundtrip of the converted report hung in kernel_call_transformation.clas.locals.mjs (run -> add_object -> run, paused in the inspector); with the handlers in the report the run ended, but one handler set for two events came back as two copies, and CLEAR mo_box in on_close was not seen by on_function. The report now keeps each handler object once in a table of its own'
  - 'measured 2026-10-24 with @abap2ui5/node-runtime 1.146.0: add_object( ) increments mv_counter and appends the object to mv_data unconditionally; add_data( ) the same for a data reference'
---

# CALL TRANSFORMATION id of objects: no identity

## What happens

```abap
CLASS lcl DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    DATA other TYPE REF TO lcl.
ENDCLASS.
CLASS lcl IMPLEMENTATION.
ENDCLASS.

DATA(lo_a) = NEW lcl( ).
DATA(lo_b) = NEW lcl( ).
lo_a->other = lo_b.
lo_b->other = lo_a.
CALL TRANSFORMATION id SOURCE a = lo_a RESULT XML DATA(lv_xml).
" ABAP: <asx:heap> with o1 and o2, each written once, href="#o2" / href="#o1"
" transpiled: add_object( ) of lo_a, of lo_b, of lo_a, ... - it never returns
```

Without a cycle the result is wrong instead of endless:

```abap
DATA(lo_x) = NEW lcl( ).
DATA(ls_s) = VALUE ty_s( one = lo_x two = lo_x ).
" serialized and restored: ls_s-one <> ls_s-two - two objects
```

abap2UI5 serializes the app this way on every roundtrip, so an app whose objects refer to each other hangs the request, and an app that holds one object in two places gets two after the first roundtrip.

## The change

In `lcl_heap`, keep a table of the objects already written (the reference and its id). `add_object( )` first looks the reference up and returns its id when it is there; otherwise it inserts the reference with the new id **before** it serializes the attributes, so that a cycle finds it. Do the same for `add_data( )`. On the way back, a `href="#oN"` that is met twice resolves to the one object of id N.

## Example

```abap
CALL TRANSFORMATION id SOURCE a = lo_a RESULT XML DATA(lv_xml).
CALL TRANSFORMATION id SOURCE XML lv_xml RESULT a = lo_r.
cl_abap_unit_assert=>assert_equals( act = lo_r->other->other exp = lo_r ).
```
