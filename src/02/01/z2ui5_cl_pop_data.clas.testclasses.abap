CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory_table  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_struc  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_table.
    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ( name = `B` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_struc.
    DATA:
      BEGIN OF ls_data,
        field1 TYPE string VALUE `hello`,
        field2 TYPE i VALUE 42,
      END OF ls_data.

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( ls_data ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lo_pop) = z2ui5_cl_pop_data=>factory( val   = lt_tab
                                               title = `My Data` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

ENDCLASS.
