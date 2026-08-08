CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_pop_table DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title    FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_row_ref  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_data_copy FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    TYPES temp3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp3.
    DATA temp1 LIKE lt_tab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp1.

    temp2-name = `A`.
    temp2-value = `1`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `B`.
    temp2-value = `2`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.


    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).

  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    TYPES temp5 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp5.
    DATA temp3 LIKE lt_tab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp3.

    temp4-col = `X`.
    INSERT temp4 INTO TABLE temp3.
    lt_tab = temp3.


    lo_pop = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Custom Title` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom Title`
                                        act = lo_pop->title ).
  ENDMETHOD.

  METHOD test_result_initial.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    TYPES temp6 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp6.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    DATA ls_result TYPE z2ui5_cl_pop_table=>ty_s_result.
    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
  ENDMETHOD.

  METHOD test_factory_row_ref.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    TYPES temp7 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp7.
    DATA temp5 LIKE lt_tab.
    DATA temp6 LIKE LINE OF temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    DATA ls_result TYPE z2ui5_cl_pop_table=>ty_s_result.
    CLEAR temp5.

    temp6-col = `X`.
    INSERT temp6 INTO TABLE temp5.
    lt_tab = temp5.


    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_bound( ls_result-row ).
  ENDMETHOD.

  METHOD test_factory_data_copy.
    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    TYPES temp9 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp9.
    DATA temp7 LIKE lt_tab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp7.

    temp8-name = `A`.
    temp8-value = `1`.
    INSERT temp8 INTO TABLE temp7.
    temp8-name = `B`.
    temp8-value = `2`.
    INSERT temp8 INTO TABLE temp7.
    temp8-name = `C`.
    temp8-value = `3`.
    INSERT temp8 INTO TABLE temp7.
    lt_tab = temp7.


    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).


    ASSIGN lo_pop->mr_tab->* TO <tab>.

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).
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

    METHODS test_init_displays_table FOR TESTING RAISING cx_static_check.
    METHODS test_confirm             FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.

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

  METHOD test_init_displays_table.

    DATA temp9 TYPE ty_t_tab.
    DATA temp10 LIKE LINE OF temp9.
    DATA lt_tab LIKE temp9.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    DATA lv_xml LIKE mo_action->ms_next-s_set-s_popup-xml.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    CLEAR temp9.

    temp10-name = `row1`.
    temp10-count = 1.
    INSERT temp10 INTO TABLE temp9.
    temp10-name = `row2`.
    temp10-count = 2.
    INSERT temp10 INTO TABLE temp9.

    lt_tab = temp9.

    lo_pop = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Pick a row` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    lv_xml = mo_action->ms_next-s_set-s_popup-xml.

    temp1 = boolc( lv_xml CS `Pick a row` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = boolc( lv_xml CS `{NAME}` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = boolc( lv_xml CS `{COUNT}` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA temp11 TYPE ty_t_tab.
    DATA temp12 LIKE LINE OF temp11.
    DATA lt_tab LIKE temp11.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp11.

    temp12-name = `row1`.
    INSERT temp12 INTO TABLE temp11.

    lt_tab = temp11.

    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA temp13 TYPE ty_t_tab.
    DATA temp14 LIKE LINE OF temp13.
    DATA lt_tab LIKE temp13.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_table.
    CLEAR temp13.

    temp14-name = `row1`.
    INSERT temp14 INTO TABLE temp13.

    lt_tab = temp13.

    lo_pop = z2ui5_cl_pop_table=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `CANCEL` ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
