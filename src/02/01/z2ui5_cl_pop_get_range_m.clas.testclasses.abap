
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lt_filter) = VALUE z2ui5_cl_abap2ui5_context=>ty_t_filter_multi(
      ( name = `CARRID` t_range = VALUE #( ( sign = `I` option = `EQ` low = `AA` ) ) )
      ( name = `CONNID` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range_m=>factory( lt_filter ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lt_filter) = VALUE z2ui5_cl_abap2ui5_context=>ty_t_filter_multi(
      ( name = `FIELD1` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_get_range_m=>factory( lt_filter ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_filter ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS popup_create
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_pop_get_range_m.

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_confirm             FOR TESTING RAISING cx_static_check.
    METHODS test_list_open_calls_pop FOR TESTING RAISING cx_static_check.
    METHODS test_delete_all          FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_create.

    ro_pop = z2ui5_cl_pop_get_range_m=>factory( VALUE #(
        ( name    = `MATNR`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `100` ) ) ) ) ).
    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = ro_pop.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

    ro_pop->z2ui5_if_app~main( mi_client ).
    ro_pop->z2ui5_if_app~check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA(lo_pop) = popup_create( ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Define Filter Conditions` ) ).
    " the filter names live in the model, the list only carries the binding
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `T_FILTER` ) ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_list_open_calls_pop.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `LIST_OPEN`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `MATNR` ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lo_range_pop) = CAST z2ui5_cl_pop_get_range( mo_action->ms_next-o_app_call ).
    cl_abap_unit_assert=>assert_bound( lo_range_pop ).

  ENDMETHOD.

  METHOD test_delete_all.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `POPUP_DELETE_ALL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->ms_result-t_filter[ 1 ]-t_range ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

ENDCLASS.
