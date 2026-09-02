CLASS zcl_tst_layout DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_layout,
        name    TYPE string,
        visible TYPE abap_bool,
      END OF ty_s_layout.
    TYPES ty_t_layout TYPE STANDARD TABLE OF ty_s_layout WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_data,
        t_layout TYPE ty_t_layout,
      END OF ty_s_data.

    " the helper object a sub-app keeps in an attribute (sample 333): its
    " own data, bound by the sub-app's view, and a reference to the table
    " the sub-app owns
    DATA ms_data TYPE ty_s_data.
    DATA mr_data TYPE REF TO data.

    CLASS-METHODS factory
      IMPORTING
        i_data        TYPE REF TO data
        vis_cols      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO zcl_tst_layout.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_layout IMPLEMENTATION.

  METHOD factory.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.
    DATA lo_table  TYPE REF TO cl_abap_tabledescr.
    DATA lt_comp   TYPE abap_component_tab.
    DATA ls_layout TYPE ty_s_layout.
    DATA lv_index  TYPE i.

    result = NEW #( ).

    lo_type = cl_abap_typedescr=>describe_by_data_ref( i_data ).
    IF lo_type->kind = cl_abap_typedescr=>kind_table.
      lo_table ?= lo_type.
      lo_struct ?= lo_table->get_table_line_type( ).
    ELSE.
      lo_struct ?= lo_type.
    ENDIF.

    lt_comp = lo_struct->get_components( ).
    LOOP AT lt_comp INTO DATA(ls_comp).
      lv_index = lv_index + 1.
      CLEAR ls_layout.
      ls_layout-name = ls_comp-name.
      IF lv_index <= vis_cols.
        ls_layout-visible = abap_true.
      ENDIF.
      APPEND ls_layout TO result->ms_data-t_layout.
    ENDLOOP.

    result->mr_data = i_data.

  ENDMETHOD.

ENDCLASS.
