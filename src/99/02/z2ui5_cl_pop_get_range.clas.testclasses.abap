
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_empty       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_range     FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_range_count FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_row   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi_range FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_empty.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA temp1 TYPE z2ui5_cl_a2ui5_context=>ty_t_range.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_range LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp1.

    temp2-sign = `I`.
    temp2-option = `EQ`.
    temp2-low = `100`.
    INSERT temp2 INTO TABLE temp1.

    lt_range = temp1.


    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).

    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA temp3 TYPE z2ui5_cl_a2ui5_context=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_range LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp3.

    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `100`.
    INSERT temp4 INTO TABLE temp3.
    temp4-sign = `I`.
    temp4-option = `BT`.
    temp4-low = `200`.
    temp4-high = `300`.
    INSERT temp4 INTO TABLE temp3.

    lt_range = temp3.


    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    lo_pop = z2ui5_cl_pop_get_range=>factory( ).

    ls_result = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA temp5 TYPE z2ui5_cl_a2ui5_context=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_range LIKE temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    CLEAR temp5.

    temp6-sign = `I`.
    temp6-option = `EQ`.
    temp6-low = `A`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `E`.
    temp6-option = `EQ`.
    temp6-low = `B`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `I`.
    temp6-option = `GE`.
    temp6-low = `C`.
    INSERT temp6 INTO TABLE temp5.

    lt_range = temp5.


    lo_pop = z2ui5_cl_pop_get_range=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    " 3 input rows + 1 empty row appended by factory
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS popup_create
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_pop_get_range.

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_builds_range FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_skips_empty FOR TESTING RAISING cx_static_check.
    METHODS test_add_row             FOR TESTING RAISING cx_static_check.
    METHODS test_delete_row          FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_create.
    DATA temp1 TYPE REF TO z2ui5_cl_core_handler.

    ro_pop = z2ui5_cl_pop_get_range=>factory( ).

    CREATE OBJECT temp1 TYPE z2ui5_cl_core_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = ro_pop.
    CREATE OBJECT mi_client TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.

    " first roundtrip builds mt_filter and renders the dialog
    ro_pop->z2ui5_if_app~main( mi_client ).
    ro_pop->z2ui5_if_app~check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = popup_create( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_not_initial( mo_action->ms_next-s_set-s_popup-xml ).

  ENDMETHOD.

  METHOD test_confirm_builds_range.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lo_pop->mt_filter.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lo_pop->mt_filter.
    DATA temp10 LIKE sy-tabix.
    DATA ls_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
    DATA temp11 LIKE LINE OF ls_result-t_range.
    DATA temp12 LIKE sy-tabix.
    DATA temp13 LIKE LINE OF ls_result-t_range.
    DATA temp14 LIKE sy-tabix.
    DATA temp15 LIKE LINE OF ls_result-t_range.
    DATA temp16 LIKE sy-tabix.
    lo_pop = popup_create( ).


    temp8 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp7>-option = `EQ`.


    temp10 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp9>-low    = `ABC`.

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).


    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).


    temp12 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = temp11-sign ).


    temp14 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ`
                                        act = temp13-option ).


    temp16 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 INTO temp15.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = temp15-low ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_confirm_skips_empty.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->result( )-t_range ).
    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD test_add_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `POPUP_ADD`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

  METHOD test_delete_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    DATA lv_key TYPE z2ui5_cl_pop_get_range=>ty_s_filter_pop-key.
    DATA temp2 LIKE LINE OF lo_pop->mt_filter.
    DATA temp3 LIKE sy-tabix.
    DATA temp17 TYPE string_table.
    lo_pop = popup_create( ).



    temp3 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 INTO temp2.
    sy-tabix = temp3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_key = temp2-key.

    mo_action->ms_actual-event = `POPUP_DELETE`.

    CLEAR temp17.
    INSERT lv_key INTO TABLE temp17.
    mo_action->ms_actual-t_event_arg = temp17.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->mt_filter ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_get_range.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

ENDCLASS.
