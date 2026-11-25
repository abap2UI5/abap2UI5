---
target: abap2ui5-linter
title: 'Report an app attribute that references a class without if_serializable_object'
summary: 'an object reference an app keeps in an attribute is dropped without a word when the draft is written if its class is not serializable, and is initial on the next roundtrip - the view builder is the usual one'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-23
evidence:
  - 'src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap, ltcl_05_draft->dead_objects_stay_quiet (shape S15, ltcl_shp_dead) - the framework pins the behaviour: "not serializable, so gone; and nothing raised on the way"'
  - 'a downstream app repository, review of 2026-11 - three attributes TYPE REF TO z2ui5_cl_ui5_view_builder on app classes (the scan field form, the page a parent app hands its sub-app, the main page of a tab container); they work because each is set and read inside one roundtrip, and nothing says so'
  - '@abap2ui5/linter 0.11.0 - client-handle-capture reports the client kept in an attribute; no rule covers any other non-serializable reference'
---

# Report an app attribute that references a class without if_serializable_object

## Motivation

An app instance is serialized into the draft after every roundtrip and
restored before the next one. An object reference in an attribute survives
that only when its class implements `if_serializable_object`. When it does
not, the framework does not fail the draft: the reference is left out and the
attribute is initial on the next roundtrip. Nothing is raised and nothing is
logged, on purpose - one helper an app forgot must not end the request.

That makes the mistake quiet. An attribute like

```abap
DATA mo_form TYPE REF TO z2ui5_cl_ui5_view_builder.
```

is fine while every use sits in the roundtrip that set it, and turns into a
null reference the first time somebody reads it one roundtrip later - in code
that looks exactly like the code that works. The app author has no way to see
the difference short of knowing how the draft is written.

## Current behaviour

- `z2ui5_cl_ui5_srv_model` drops the reference when the draft is written; the
  test `dead_objects_stay_quiet` asserts that it comes back initial and that
  nothing is raised.
- `docs/agents/building-apps.md` says to create such objects in the method
  that uses them and never keep them in an attribute - as prose, for the
  language model provider.
- The linter has `client-handle-capture` for the one reference every app
  holds. No rule looks at the others.

## Proposed rule

`nonserializable-attribute`, severity warning.

Report an instance attribute (`DATA`, any visibility) of a class that
implements `z2ui5_if_app`, typed `REF TO <class>`, when `<class>` is known not
to implement `if_serializable_object`:

- a class of the checked source tree, read from its definition (the interface
  list of the class and of its superclasses);
- the framework classes an app can name, as a fixed list shipped with the
  linter - today `z2ui5_cl_ui5_view_builder` is the one that matters.

Message: the reference is initial on the next roundtrip; keep it in a local
variable, or pass it as a parameter, or rebuild it per roundtrip.

## What it must not report

- `client` and other `REF TO z2ui5_if_client` attributes -
  `client-handle-capture` owns those.
- `REF TO <interface>`: the class behind it is not known statically.
- A class the linter cannot resolve (SAP standard, an addon that is not in
  the checked paths). Unknown is not "not serializable"; a rule that guesses
  here reports every `REF TO cl_...` in every app.
- `REF TO data` and `REF TO object` - the framework handles generic data
  references itself, and `object` says nothing.
- Class attributes (`CLASS-DATA`) - they are not part of the instance the
  draft holds.
- A reference in a helper class that is not an app. It is only a problem when
  an app keeps that helper, and then the helper is the finding.

## Example

```abap
CLASS zcl_my_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
    DATA mo_form TYPE REF TO z2ui5_cl_ui5_view_builder.   " reported
    DATA mo_log  TYPE REF TO zcl_my_log.                  " reported when zcl_my_log is in
                                                          " the tree without if_serializable_object
    DATA mi_input TYPE REF TO zif_my_input.               " not reported: an interface
    DATA mo_alv  TYPE REF TO cl_salv_table.               " not reported: not resolvable
ENDCLASS.
```
