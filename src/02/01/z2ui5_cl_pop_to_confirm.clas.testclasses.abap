CLASS ltcl_test DEFINITION DEFERRED.
CLASS ltcl_test_events DEFINITION DEFERRED.
CLASS z2ui5_cl_pop_to_confirm DEFINITION LOCAL FRIENDS ltcl_test ltcl_test_events.

CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_constants        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Are you sure?` ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_defaults.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Delete?` ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Popup To Confirm`
                                        act = lo_pop->title ).
    cl_abap_unit_assert=>assert_equals( exp = `sap-icon://question-mark`
                                        act = lo_pop->icon ).
    cl_abap_unit_assert=>assert_equals( exp = `OK`
                                        act = lo_pop->button_text_confirm ).
    cl_abap_unit_assert=>assert_equals( exp = `Cancel`
                                        act = lo_pop->button_text_cancel ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_pop_to_confirm=>cs_event-confirmed
                                        act = lo_pop->event_confirm ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_pop_to_confirm=>cs_event-canceled
                                        act = lo_pop->event_canceled ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory(
      i_question_text       = `Proceed?`
      i_title               = `Custom Title`
      i_icon                = `sap-icon://warning`
      i_button_text_confirm = `Yes`
      i_button_text_cancel  = `No` ).

    cl_abap_unit_assert=>assert_equals( exp = `Proceed?`
                                        act = lo_pop->question_text ).
    cl_abap_unit_assert=>assert_equals( exp = `Custom Title`
                                        act = lo_pop->title ).
    cl_abap_unit_assert=>assert_equals( exp = `sap-icon://warning`
                                        act = lo_pop->icon ).
    cl_abap_unit_assert=>assert_equals( exp = `Yes`
                                        act = lo_pop->button_text_confirm ).
    cl_abap_unit_assert=>assert_equals( exp = `No`
                                        act = lo_pop->button_text_cancel ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Test?` ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

  ENDMETHOD.

  METHOD test_constants.

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_pop_to_confirm=>cs_event-confirmed ).
    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_pop_to_confirm=>cs_event-canceled ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_events DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_default_events_differ FOR TESTING RAISING cx_static_check.
    METHODS test_custom_events         FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_events IMPLEMENTATION.

  METHOD test_default_events_differ.

    cl_abap_unit_assert=>assert_differs(
      act = z2ui5_cl_pop_to_confirm=>cs_event-confirmed
      exp = z2ui5_cl_pop_to_confirm=>cs_event-canceled ).

  ENDMETHOD.

  METHOD test_custom_events.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory(
      i_question_text = `Sure?`
      i_event_confirm = `MY_CONFIRM`
      i_event_cancel  = `MY_CANCEL` ).

    cl_abap_unit_assert=>assert_equals( exp = `MY_CONFIRM`
                                        act = lo_pop->event_confirm ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_CANCEL`
                                        act = lo_pop->event_canceled ).
    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).

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

    METHODS test_init_displays_popup  FOR TESTING RAISING cx_static_check.
    METHODS test_confirm              FOR TESTING RAISING cx_static_check.
    METHODS test_cancel               FOR TESTING RAISING cx_static_check.
    METHODS test_custom_event_confirm FOR TESTING RAISING cx_static_check.

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

  METHOD test_init_displays_popup.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( i_question_text = `Are you sure?`
                                                     i_title         = `My Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Are you sure?` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Title` ) ).
    cl_abap_unit_assert=>assert_false( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Sure?` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_pop_to_confirm=>cs_event-confirmed
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( `Sure?` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CANCEL` ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_pop_to_confirm=>cs_event-canceled
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

  METHOD test_custom_event_confirm.

    DATA(lo_pop) = z2ui5_cl_pop_to_confirm=>factory( i_question_text = `Sure?`
                                                     i_event_confirm = `MY_CONFIRM` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_CONFIRM`
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

ENDCLASS.
