
CLASS ltcl_output_stub DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_output_stub IMPLEMENTATION.

  METHOD get.

    result = `<p><span class="heading1">Hello cl_demo_output</span></p>`.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_as_page  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory( NEW ltcl_output_stub( ) ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory(
      i_output      = NEW ltcl_output_stub( )
      i_title       = `My Output`
      i_icon        = `sap-icon://hint`
      i_button_text = `Close`
      i_stretch     = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_as_page.

    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory(
      i_output  = NEW ltcl_output_stub( )
      i_as_page = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

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

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_toggle_fullscreen   FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_closes      FOR TESTING RAISING cx_static_check.

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

    " any object without a GET method works - the HTML extraction is guarded
    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory( i_output = NEW z2ui5_cx_a2ui5_error( `x` )
                                                      i_title  = `Demo Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_true( xsdbool( mo_action->ms_next-s_set-s_popup-xml CS `Demo Title` ) ).

  ENDMETHOD.

  METHOD test_toggle_fullscreen.

    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory( NEW z2ui5_cx_a2ui5_error( `x` ) ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `TOGGLE_FULLSCREEN` ).

    " popup is destroyed and re-rendered as a full page
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_not_initial( mo_action->ms_next-s_set-s_view-xml ).

  ENDMETHOD.

  METHOD test_confirm_closes.

    DATA(lo_pop) = z2ui5_cl_pop_demo_output=>factory( NEW z2ui5_cx_a2ui5_error( `x` ) ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
