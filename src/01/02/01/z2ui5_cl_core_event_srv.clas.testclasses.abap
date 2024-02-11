CLASS ltcl_test_db DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    METHODS event FOR TESTING.
    METHODS event_backend FOR TESTING.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_db IMPLEMENTATION.

  METHOD event.

    DATA(lo_event) = NEW z2ui5_cl_core_event_srv( ).
    DATA(lv_event) = lo_event->get_event( `POST`).

    cl_abap_unit_assert=>assert_equals(
      act = lv_event
      exp = `onEvent({'EVENT':'POST','METHOD':'TEST','CHECK_VIEW_DESTROY':false})` ).

  ENDMETHOD.

  METHOD event_backend.

    DATA(lo_event) = NEW z2ui5_cl_core_event_srv( ).
    DATA(lv_event) = lo_event->get_event_client( z2ui5_if_client=>cs_event-popover_close ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_event
      exp = `onEventFrontend({'EVENT':'POPOVER_CLOSE'})` ).

  ENDMETHOD.
ENDCLASS.
