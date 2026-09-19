
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( i_file = `test_content`
                                                  i_name = `test.csv` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `test_content`
                                        act = lo_pop->mv_value ).
    cl_abap_unit_assert=>assert_equals( exp = `data:text/csv;base64,`
                                        act = lo_pop->mv_type ).
    cl_abap_unit_assert=>assert_equals( exp = `test.csv`
                                        act = lo_pop->mv_name ).
    " 12 characters -> 0.01 kB, must not truncate to 0
    cl_abap_unit_assert=>assert_equals( exp = `0.01`
                                        act = lo_pop->mv_size ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( `abc` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS popup_displayed_xml
      RETURNING
        VALUE(result) TYPE string.

    METHODS popup_destroy_queued
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_init_displays_popup  FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_starts_dl    FOR TESTING RAISING cx_static_check.
    METHODS test_callback_closes      FOR TESTING RAISING cx_static_check.
    METHODS test_cancel_closes        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_displayed_xml.

    DATA temp1 TYPE string.
    DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_system_action.
    CLEAR temp1.

    READ TABLE mo_action->ms_next-t_action_front INTO temp2 WITH KEY slot = z2ui5_if_client=>cs_view-popup method = z2ui5_if_ui5_types=>cs_slot_action-display.
    IF sy-subrc = 0.
      temp1 = temp2-xml.
    ENDIF.
    result = temp1.

  ENDMETHOD.


  METHOD popup_destroy_queued.

    DATA temp3 LIKE sy-subrc.
    DATA temp1 TYPE xsdboolean.
    READ TABLE mo_action->ms_next-t_action_front WITH KEY slot = z2ui5_if_client=>cs_view-popup method = z2ui5_if_ui5_types=>cs_slot_action-destroy TRANSPORTING NO FIELDS.
    temp3 = sy-subrc.

    temp1 = boolc( temp3 = 0 ).
    result = temp1.

  ENDMETHOD.


  METHOD client_create.

    DATA temp1 TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT temp1 TYPE z2ui5_cl_ui5_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = io_app.
    CREATE OBJECT mi_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = mo_action.

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    mo_action->mo_app->mv_check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    DATA lv_xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( i_file  = `col1;col2`
                                                  i_title = `Download Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    lv_xml = popup_displayed_xml( ).

    temp2 = boolc( lv_xml CS `Download Title` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = boolc( lv_xml CS `iframe` ).
    cl_abap_unit_assert=>assert_false( temp3 ).

  ENDMETHOD.

  METHOD test_confirm_starts_dl.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    DATA lv_xml TYPE string.
    DATA temp4 TYPE xsdboolean.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( `col1;col2` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    " confirm re-renders the popup with the hidden download iframe and timer

    lv_xml = popup_displayed_xml( ).

    temp4 = boolc( lv_xml CS `iframe` ).
    cl_abap_unit_assert=>assert_true( temp4 ).
    cl_abap_unit_assert=>assert_false( popup_destroy_queued( ) ).

  ENDMETHOD.

  METHOD test_callback_closes.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( `col1;col2` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `CALLBACK_DOWNLOAD` ).

    cl_abap_unit_assert=>assert_true( popup_destroy_queued( ) ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_cancel_closes.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_file_dl.
    lo_pop = z2ui5_cl_pop_file_dl=>factory( `col1;col2` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CANCEL` ).

    cl_abap_unit_assert=>assert_true( popup_destroy_queued( ) ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
