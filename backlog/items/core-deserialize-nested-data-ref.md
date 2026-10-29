---
target: open-abap
title: 'CALL TRANSFORMATION id: a data reference in a component of a structure or a line of a table comes back without its type - ASSIGN ref->* TO <table> fails'
summary: 'a REF TO data that is a component of a structure - also of a line of an internal table - is serialized, but restored as a data object that is not the table it pointed to: ASSIGN ls_back-ref->* TO <t> (FIELD-SYMBOLS <t> TYPE STANDARD TABLE) raises ASSIGN_TYPE_CONFLICT, a LOOP over it table.getArrayLength is not a function. A REF TO data that is a direct attribute of a serialized object comes back as it was'
priority: medium
state: open
first_seen: 2026-10-24
upstream: open-abap/open-abap-core
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - the report kept the copies of the field catalog of each grid (z2ui5_cl_cgui_gui_alv_grid) as a REF TO data in a line of a table attribute; after the roundtrip, set_fieldcat( ) looped over it and died with TypeError: table.getArrayLength is not a function. The copies are direct attributes of the report now (mr_cgui_grid_fieldcat), which come back'
  - 'measured 2026-10-24 with @abap2ui5/node-runtime 1.146.0 in a unit test: a structure with a REF TO data component (CREATE DATA ... LIKE a table, filled) and a table of such lines, CALL TRANSFORMATION id SOURCE root = ls_root RESULT XML lv_xml and back RESULT root = ls_back; ASSIGN ls_back-top->* TO <t> raised ASSIGN_TYPE_CONFLICT'
---

# A data reference in a structure comes back without its type

## What happens

```abap
TYPES: BEGIN OF ty_s_line,
         name TYPE c LENGTH 30,
       END OF ty_s_line,
       ty_t_line TYPE STANDARD TABLE OF ty_s_line WITH EMPTY KEY,
       BEGIN OF ty_s_root,
         top TYPE REF TO data,
       END OF ty_s_root.
DATA ls_root TYPE ty_s_root.
DATA ls_back TYPE ty_s_root.
DATA lv_xml TYPE string.
FIELD-SYMBOLS <t> TYPE STANDARD TABLE.

DATA(lt_line) = VALUE ty_t_line( ( name = 'A' ) ( name = 'B' ) ).
CREATE DATA ls_root-top LIKE lt_line.
ASSIGN ls_root-top->* TO <t>.
<t> = lt_line.
CALL TRANSFORMATION id SOURCE root = ls_root RESULT XML lv_xml.
CALL TRANSFORMATION id SOURCE XML lv_xml RESULT root = ls_back.
ASSIGN ls_back-top->* TO <t>.
" ABAP: <t> is the table of two lines
" transpiled: ASSIGN_TYPE_CONFLICT - the restored object is no table
```

The same happens to a REF TO data in a line of an internal table. A REF TO data that is a direct attribute of a serialized object is restored correctly. abap2UI5 keeps its own data references that way, for example the copy of an ALV's table.

## The change

When the heap entry of a data reference (`<prg:NAME id="dN">` written by `lcl_heap->add_data( )`) is read back for a component of a structure or a line of a table, create the data object with the type that was written: the table type and its line type. Then fill it, as is done for an attribute of an object.

## Example

```abap
CALL TRANSFORMATION id SOURCE root = ls_root RESULT XML lv_xml.
CALL TRANSFORMATION id SOURCE XML lv_xml RESULT root = ls_back.
ASSIGN ls_back-top->* TO <t>.
cl_abap_unit_assert=>assert_equals( act = lines( <t> ) exp = 2 ).
```
