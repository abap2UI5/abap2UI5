
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

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA(lt_range) = VALUE z2ui5_cl_abap2ui5_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA(lt_range) = VALUE z2ui5_cl_abap2ui5_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` )
      ( sign = `I` option = `BT` low = `200` high = `300` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA(lt_range) = VALUE z2ui5_cl_abap2ui5_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `A` )
      ( sign = `E` option = `EQ` low = `B` )
      ( sign = `I` option = `GE` low = `C` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

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

    ro_pop = z2ui5_cl_pop_get_range=>factory( ).
    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = ro_pop.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

    " first roundtrip builds mt_filter and renders the dialog
    ro_pop->z2ui5_if_app~main( mi_client ).
    ro_pop->z2ui5_if_app~check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA(lo_pop) = popup_create( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_not_initial( mo_action->ms_next-s_set-s_popup-xml ).

  ENDMETHOD.

  METHOD test_confirm_builds_range.

    DATA(lo_pop) = popup_create( ).
    lo_pop->mt_filter[ 1 ]-option = `EQ`.
    lo_pop->mt_filter[ 1 ]-low    = `ABC`.

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = ls_result-t_range[ 1 ]-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`
                                        act = ls_result-t_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = ls_result-t_range[ 1 ]-low ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

  METHOD test_confirm_skips_empty.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->result( )-t_range ).
    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD test_add_row.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `POPUP_ADD`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

  METHOD test_delete_row.

    DATA(lo_pop) = popup_create( ).
    DATA(lv_key) = lo_pop->mt_filter[ 1 ]-key.

    mo_action->ms_actual-event = `POPUP_DELETE`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( lv_key ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->mt_filter ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).

  ENDMETHOD.

ENDCLASS.
