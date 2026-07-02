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
