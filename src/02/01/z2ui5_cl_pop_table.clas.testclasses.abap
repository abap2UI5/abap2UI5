CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory         FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title   FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = `1` ) ( name = `B` value = `2` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).
  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Custom Title` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
  ENDMETHOD.

ENDCLASS.
