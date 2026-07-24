
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory            FOR TESTING RAISING cx_static_check.
    METHODS test_factory_util_error FOR TESTING RAISING cx_static_check.
    METHODS test_factory_custom     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
        DATA lv_val TYPE i.
        DATA lx TYPE REF TO cx_root.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.

    TRY.

        lv_val = 1 / 0 ##NEEDED.

      CATCH cx_root INTO lx.
    ENDTRY.


    lo_pop = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_util_error.

    DATA lx TYPE REF TO z2ui5_cx_a2ui5_error.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.
    CREATE OBJECT lx TYPE z2ui5_cx_a2ui5_error EXPORTING val = `test error`.

    lo_pop = z2ui5_cl_pop_error=>factory( lx ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_custom.

    DATA lx TYPE REF TO z2ui5_cx_a2ui5_error.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.
    CREATE OBJECT lx TYPE z2ui5_cx_a2ui5_error EXPORTING val = `custom error`.

    lo_pop = z2ui5_cl_pop_error=>factory(
      x_root  = lx
      i_title = `My Error Title` ).
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

    METHODS test_init_displays_error FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_closes      FOR TESTING RAISING cx_static_check.

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

  METHOD test_init_displays_error.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.
    DATA temp2 TYPE REF TO z2ui5_cx_a2ui5_error.
    DATA lv_xml LIKE mo_action->ms_next-s_set-s_popup-xml.
    DATA temp1 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    CREATE OBJECT temp2 TYPE z2ui5_cx_a2ui5_error EXPORTING VAL = `MY_ERROR_TEXT`.
    lo_pop = z2ui5_cl_pop_error=>factory( temp2 ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    lv_xml = mo_action->ms_next-s_set-s_popup-xml.

    temp1 = boolc( lv_xml CS `MY_ERROR_TEXT` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp3 = boolc( lv_xml CS `Error` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_confirm_closes.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_error.
    DATA temp3 TYPE REF TO z2ui5_cx_a2ui5_error.
    CREATE OBJECT temp3 TYPE z2ui5_cx_a2ui5_error EXPORTING VAL = `MY_ERROR_TEXT`.
    lo_pop = z2ui5_cl_pop_error=>factory( temp3 ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
