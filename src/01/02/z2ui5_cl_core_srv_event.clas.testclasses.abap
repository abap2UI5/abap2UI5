CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.
    METHODS event         FOR TESTING.
    METHODS event_backend FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD event.

    DATA(lo_event) = NEW z2ui5_cl_core_srv_event( ).
    DATA(lv_event) = lo_event->get_event( `POST` ).

    cl_abap_unit_assert=>assert_equals( exp = `.eB(['POST'])`
                                        act = lv_event ).

  ENDMETHOD.

  METHOD event_backend.

    DATA(lo_event) = NEW z2ui5_cl_core_srv_event( ).
    DATA(lv_event) = lo_event->get_event_client( z2ui5_if_client=>cs_event-popover_close ).

    cl_abap_unit_assert=>assert_equals( exp = `.eF('POPOVER_CLOSE')`
                                        act = lv_event ).

  ENDMETHOD.
ENDCLASS.
