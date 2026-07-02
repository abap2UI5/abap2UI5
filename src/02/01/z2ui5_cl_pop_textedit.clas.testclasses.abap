
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_with_txt FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title    FOR TESTING RAISING cx_static_check.
    METHODS test_factory_editable FOR TESTING RAISING cx_static_check.
    METHODS test_factory_stretch  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_with_txt.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory(
      i_textarea       = `Some initial text`
      i_title          = `My Editor`
      i_check_editable = abap_true ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_equals( exp = `Some initial text`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory(
      i_textarea = `hello`
      i_title    = `Custom Title` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom Title`
                                        act = lo_pop->mv_title ).

  ENDMETHOD.

  METHOD test_factory_editable.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory(
      i_textarea       = `text`
      i_check_editable = abap_true ).

    cl_abap_unit_assert=>assert_true( lo_pop->mv_check_editable ).

    DATA(lo_pop2) = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_false( lo_pop2->mv_check_editable ).

  ENDMETHOD.

  METHOD test_factory_stretch.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory(
      i_stretch_active = abap_false ).

    cl_abap_unit_assert=>assert_false( lo_pop->mv_stretch_active ).

    DATA(lo_pop2) = z2ui5_cl_pop_textedit=>factory( ).
    cl_abap_unit_assert=>assert_true( lo_pop2->mv_stretch_active ).

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
    METHODS test_confirm             FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.

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

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( i_textarea = `Hello Text`
                                                   i_title    = `Editor Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Editor Title` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `TextArea` ) ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( `Hello Text` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_TEXTAREA_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = `Hello Text`
                                        act = lo_pop->result( )-text ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lo_pop) = z2ui5_cl_pop_textedit=>factory( `Hello Text` ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_TEXTAREA_CANCEL` ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

ENDCLASS.
