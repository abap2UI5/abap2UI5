
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi     FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = `1` )
                      ( name = `B` value = `2` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_multi.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory(
      i_tab   = lt_tab
      i_title = `Custom` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

ENDCLASS.
