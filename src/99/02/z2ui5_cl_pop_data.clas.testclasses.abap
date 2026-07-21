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
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA temp1 LIKE lt_tab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    CLEAR temp1.

    temp2-name = `A`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `B`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.


    lo_pop = z2ui5_cl_pop_data=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_struc.
    DATA:
      BEGIN OF ls_data,
        field1 TYPE string VALUE `hello`,
        field2 TYPE i VALUE 42,
      END OF ls_data.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    lo_pop = z2ui5_cl_pop_data=>factory( ls_data ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_data ).
  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    lo_pop = z2ui5_cl_pop_data=>factory( val   = lt_tab
                                               title = `My Data` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name  TYPE string,
        count TYPE i,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_init_table_calls_popup  FOR TESTING RAISING cx_static_check.
    METHODS test_init_struct_calls_popup FOR TESTING RAISING cx_static_check.
    METHODS test_event_leaves            FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD client_create.

    DATA temp1 TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT temp1 TYPE z2ui5_cl_core_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = io_app.
    CREATE OBJECT mi_client TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    io_app->check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_init_table_calls_popup.

    DATA temp3 TYPE ty_t_tab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_tab LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    DATA temp5 TYPE REF TO z2ui5_cl_pop_table.
    DATA lo_table_pop LIKE temp5.
    CLEAR temp3.

    temp4-name = `row1`.
    temp4-count = 1.
    INSERT temp4 INTO TABLE temp3.

    lt_tab = temp3.

    lo_pop = z2ui5_cl_pop_data=>factory( val   = lt_tab
                                               title = `Data Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    temp5 ?= mo_action->ms_next-o_app_call.

    lo_table_pop = temp5.
    cl_abap_unit_assert=>assert_bound( lo_table_pop ).

  ENDMETHOD.

  METHOD test_init_struct_calls_popup.

    DATA temp6 TYPE ty_s_row.
    DATA ls_row LIKE temp6.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    CLEAR temp6.
    temp6-name = `row1`.
    temp6-count = 1.

    ls_row = temp6.

    lo_pop = z2ui5_cl_pop_data=>factory( ls_row ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_call ).

  ENDMETHOD.

  METHOD test_event_leaves.

    DATA temp7 TYPE ty_t_tab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lt_tab LIKE temp7.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_data.
    CLEAR temp7.

    temp8-name = `row1`.
    INSERT temp8 INTO TABLE temp7.

    lt_tab = temp7.

    lo_pop = z2ui5_cl_pop_data=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `ANY_EVENT` ).

    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
