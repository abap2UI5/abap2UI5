CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory             FOR TESTING RAISING cx_static_check.
    METHODS test_factory_open_ui5    FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
    METHODS test_open_ui5_flag_init  FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory(
      i_js     = `console.log("hello");`
      i_result = `DONE` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_equals( exp = `DONE`
                                        act = lo_pop->result( ) ).
  ENDMETHOD.

  METHOD test_factory_open_ui5.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory_check_open_ui5( ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory( `alert(1);` ).

    cl_abap_unit_assert=>assert_equals( exp = `LOADED`
                                        act = lo_pop->result( ) ).
  ENDMETHOD.

  METHOD test_open_ui5_flag_init.
    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory_check_open_ui5( ).

    cl_abap_unit_assert=>assert_false( lo_pop->mv_is_open_ui5 ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_init_displays_script FOR TESTING RAISING cx_static_check.
    METHODS test_timer_finished       FOR TESTING RAISING cx_static_check.
    METHODS test_info_open_ui5        FOR TESTING RAISING cx_static_check.
    METHODS test_info_sap_ui5         FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD client_create.

    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = io_app.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

  ENDMETHOD.

  METHOD roundtrip_event.

    client_create( io_app ).
    io_app->check_initialized = abap_true.
    mo_action->ms_actual-event = iv_event.
    io_app->main( mi_client ).

  ENDMETHOD.

  METHOD test_init_displays_script.

    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory( `console.log('x');` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `script` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Timer` ) ).

  ENDMETHOD.

  METHOD test_timer_finished.

    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory( `console.log('x');` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `TIMER_FINISHED` ).

    cl_abap_unit_assert=>assert_equals( exp = `LOADED`
                                        act = lo_pop->result( ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_info_open_ui5.

    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory_check_open_ui5( ).
    lo_pop->ui5_gav = `com.sap.ui5.dist:OPENUI5:zip`.
    roundtrip_event( io_app   = lo_pop
                     iv_event = `INFO_FINISHED` ).

    cl_abap_unit_assert=>assert_true( lo_pop->mv_is_open_ui5 ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_info_sap_ui5.

    DATA(lo_pop) = z2ui5_cl_pop_js_loader=>factory_check_open_ui5( ).
    lo_pop->ui5_gav = `com.sap.ui5.dist:sapui5:zip`.
    roundtrip_event( io_app   = lo_pop
                     iv_event = `INFO_FINISHED` ).

    cl_abap_unit_assert=>assert_false( lo_pop->mv_is_open_ui5 ).

  ENDMETHOD.

ENDCLASS.
