CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_pop_to_select DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory              FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title        FOR TESTING RAISING cx_static_check.
    METHODS test_factory_refs_bound   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_data_count   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_default_title FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = `1` )
                      ( name = `B` value = `2` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_multi.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory(
      i_tab   = lt_tab
      i_title = `Custom` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom`
                                        act = lo_pop->title ).

  ENDMETHOD.

  METHOD test_factory_refs_bound.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).
    cl_abap_unit_assert=>assert_bound( ls_result-row ).
    cl_abap_unit_assert=>assert_bound( ls_result-table ).

  ENDMETHOD.

  METHOD test_factory_data_count.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` ) ( name = `B` ) ( name = `C` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_to_select=>factory( lt_tab ).

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lo_pop->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD test_factory_default_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lo_single) = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    DATA(lo_multi)  = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = `Single Select`
                                        act = lo_single->title ).
    cl_abap_unit_assert=>assert_equals( exp = `Multi Select`
                                        act = lo_multi->title ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        name  TYPE string,
        count TYPE i,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    METHODS client_create
      IMPORTING
        io_app TYPE REF TO z2ui5_if_app.

    METHODS popup_create
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_pop_to_select.

    METHODS select_row
      IMPORTING
        io_pop   TYPE REF TO z2ui5_cl_pop_to_select
        iv_index TYPE i.

    METHODS test_init_displays_dialog FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_selected_row FOR TESTING RAISING cx_static_check.
    METHODS test_cancel               FOR TESTING RAISING cx_static_check.
    METHODS test_search_filters       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD client_create.

    mo_action = NEW #( NEW z2ui5_cl_core_handler( `` ) ).
    mo_action->mo_app->mo_app = io_app.
    mi_client = NEW z2ui5_cl_core_client( mo_action ).

  ENDMETHOD.

  METHOD popup_create.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `alpha` count = 1 )
                                   ( name = `bravo` count = 2 ) ).
    ro_pop = z2ui5_cl_pop_to_select=>factory( i_tab             = lt_tab
                                              i_event_confirmed = `SEL_OK`
                                              i_event_canceled  = `SEL_CANCEL` ).
    client_create( ro_pop ).

    " first roundtrip builds the internal popup table and renders the dialog
    ro_pop->z2ui5_if_app~main( mi_client ).
    ro_pop->z2ui5_if_app~check_initialized = abap_true.

  ENDMETHOD.

  METHOD select_row.

    FIELD-SYMBOLS <lt_pop> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lv_sel> TYPE any.

    ASSIGN io_pop->mr_tab_popup->* TO <lt_pop>.
    READ TABLE <lt_pop> ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX iv_index.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `POPUP_TABLE_ROW_NOT_FOUND` ).
    ENDIF.
    ASSIGN COMPONENT `ZZSELKZ` OF STRUCTURE <ls_row> TO <lv_sel>.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `ZZSELKZ_COLUMN_NOT_FOUND` ).
    ENDIF.
    <lv_sel> = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_dialog.

    DATA(lo_pop) = popup_create( ).

    FIELD-SYMBOLS <lt_pop> TYPE STANDARD TABLE.
    ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>.

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <lt_pop> ) ).
    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `TableSelectDialog` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Single Select` ) ).

  ENDMETHOD.

  METHOD test_confirm_selected_row.

    DATA(lo_pop) = popup_create( ).
    select_row( io_pop   = lo_pop
                iv_index = 2 ).

    mo_action->ms_actual-event = `CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).

    FIELD-SYMBOLS <lt_result> TYPE STANDARD TABLE.
    ASSIGN ls_result-table->* TO <lt_result>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <lt_result> ) ).

    READ TABLE <lt_result> ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX 1.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `RESULT_ROW_NOT_FOUND` ).
    ENDIF.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <ls_row> TO FIELD-SYMBOL(<lv_name>).
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `NAME_COLUMN_NOT_FOUND` ).
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `bravo`
                                        act = <lv_name> ).

    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_equals( exp = `SEL_OK`
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_equals( exp = `SEL_CANCEL`
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

  METHOD test_search_filters.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `SEARCH`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `bravo` ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    FIELD-SYMBOLS <lt_pop> TYPE STANDARD TABLE.
    ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <lt_pop> ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

ENDCLASS.
