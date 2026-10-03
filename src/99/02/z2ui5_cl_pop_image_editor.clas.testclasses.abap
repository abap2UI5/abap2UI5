CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_defaults FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    lo_pop = z2ui5_cl_pop_image_editor=>factory(
      iv_image       = `data:image/png;base64,AAAA`
      iv_title       = `Edit`
      iv_save_text   = `Done`
      iv_cancel_text = `Abort` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_factory_defaults.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    lo_pop = z2ui5_cl_pop_image_editor=>factory( `test_img` ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
  ENDMETHOD.

  METHOD test_result_initial.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    DATA ls_result TYPE z2ui5_cl_pop_image_editor=>t_result.
    lo_pop = z2ui5_cl_pop_image_editor=>factory( `test_img` ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = `test_img`
                                        act = ls_result-image ).
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

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_save                FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.

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

  METHOD test_init_displays_popup.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    DATA lv_xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    lo_pop = z2ui5_cl_pop_image_editor=>factory( iv_image = `data:image/png;base64,OLD`
                                                       iv_title = `Image Title` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).


    lv_xml = popup_displayed_xml( ).

    temp2 = boolc( lv_xml CS `Image Title` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

  ENDMETHOD.

  METHOD test_save.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    DATA temp4 TYPE string_table.
    lo_pop = z2ui5_cl_pop_image_editor=>factory( `data:image/png;base64,OLD` ).
    client_create( lo_pop ).
    mo_action->mo_app->mv_check_initialized = abap_true.
    mo_action->ms_actual-event = `SAVE`.

    CLEAR temp4.
    INSERT `data:image/png;base64,NEW` INTO TABLE temp4.
    mo_action->ms_actual-t_event_arg = temp4.

    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = `data:image/png;base64,NEW`
                                        act = lo_pop->result( )-image ).
    cl_abap_unit_assert=>assert_true( popup_destroy_queued( ) ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_image_editor.
    lo_pop = z2ui5_cl_pop_image_editor=>factory( `data:image/png;base64,OLD` ).
    client_create( lo_pop ).
    mo_action->mo_app->mv_check_initialized = abap_true.
    mo_action->ms_actual-event = `CANCEL`.

    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( popup_destroy_queued( ) ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
