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
    TYPES temp3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp3.
    DATA temp1 LIKE lt_tab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp1.

    temp2-name = `A`.
    temp2-value = `1`.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = `B`.
    temp2-value = `2`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.


    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_multi.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    TYPES temp5 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp5.
    DATA temp3 LIKE lt_tab.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp3.

    temp4-name = `X`.
    INSERT temp4 INTO TABLE temp3.
    lt_tab = temp3.


    lo_pop = z2ui5_cl_pop_to_select=>factory(
      i_tab         = lt_tab
      i_multiselect = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_result_initial.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    TYPES temp7 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp7.
    DATA temp5 LIKE lt_tab.
    DATA temp6 LIKE LINE OF temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA ls_result TYPE z2ui5_cl_pop_to_select=>ty_s_result.
    CLEAR temp5.

    temp6-name = `A`.
    INSERT temp6 INTO TABLE temp5.
    lt_tab = temp5.


    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).

    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    TYPES temp9 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp9.
    DATA temp7 LIKE lt_tab.
    DATA temp8 LIKE LINE OF temp7.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    CLEAR temp7.

    temp8-name = `A`.
    INSERT temp8 INTO TABLE temp7.
    lt_tab = temp7.


    lo_pop = z2ui5_cl_pop_to_select=>factory(
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
    TYPES temp11 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp11.
    DATA temp9 LIKE lt_tab.
    DATA temp10 LIKE LINE OF temp9.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA ls_result TYPE z2ui5_cl_pop_to_select=>ty_s_result.
    CLEAR temp9.

    temp10-name = `X`.
    INSERT temp10 INTO TABLE temp9.
    lt_tab = temp9.


    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).
    cl_abap_unit_assert=>assert_bound( ls_result-row ).
    cl_abap_unit_assert=>assert_bound( ls_result-table ).

  ENDMETHOD.

  METHOD test_factory_data_count.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    TYPES temp13 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp13.
    DATA temp11 LIKE lt_tab.
    DATA temp12 LIKE LINE OF temp11.
    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    CLEAR temp11.

    temp12-name = `A`.
    INSERT temp12 INTO TABLE temp11.
    temp12-name = `B`.
    INSERT temp12 INTO TABLE temp11.
    temp12-name = `C`.
    INSERT temp12 INTO TABLE temp11.
    lt_tab = temp11.


    lo_pop = z2ui5_cl_pop_to_select=>factory( lt_tab ).


    ASSIGN lo_pop->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD test_factory_default_title.

    TYPES:
      BEGIN OF ty_row,
        name TYPE string,
      END OF ty_row.
    TYPES temp14 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp14.

    DATA lo_single TYPE REF TO z2ui5_cl_pop_to_select.
    DATA lo_multi TYPE REF TO z2ui5_cl_pop_to_select.
    lo_single = z2ui5_cl_pop_to_select=>factory( lt_tab ).

    lo_multi  = z2ui5_cl_pop_to_select=>factory(
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
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

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

    DATA temp1 TYPE REF TO z2ui5_cl_core_handler.
    CREATE OBJECT temp1 TYPE z2ui5_cl_core_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = io_app.
    CREATE OBJECT mi_client TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.

  ENDMETHOD.

  METHOD popup_create.

    DATA temp13 TYPE ty_t_tab.
    DATA temp14 LIKE LINE OF temp13.
    DATA lt_tab LIKE temp13.
    CLEAR temp13.

    temp14-name = `alpha`.
    temp14-count = 1.
    INSERT temp14 INTO TABLE temp13.
    temp14-name = `bravo`.
    temp14-count = 2.
    INSERT temp14 INTO TABLE temp13.

    lt_tab = temp13.
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
    FIELD-SYMBOLS <ls_row> TYPE any.

    ASSIGN io_pop->mr_tab_popup->* TO <lt_pop>.

    READ TABLE <lt_pop> ASSIGNING <ls_row> INDEX iv_index.
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

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    FIELD-SYMBOLS <lt_pop> TYPE STANDARD TABLE.
    DATA lv_xml LIKE mo_action->ms_next-s_set-s_popup-xml.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    lo_pop = popup_create( ).


    ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>.

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <lt_pop> ) ).

    lv_xml = mo_action->ms_next-s_set-s_popup-xml.

    temp1 = boolc( lv_xml CS `TableSelectDialog` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = boolc( lv_xml CS `Single Select` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

  ENDMETHOD.

  METHOD test_confirm_selected_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA ls_result TYPE z2ui5_cl_pop_to_select=>ty_s_result.
    FIELD-SYMBOLS <lt_result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_name> TYPE any.
    lo_pop = popup_create( ).
    select_row( io_pop   = lo_pop
                iv_index = 2 ).

    mo_action->ms_actual-event = `CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).


    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).


    ASSIGN ls_result-table->* TO <lt_result>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <lt_result> ) ).


    READ TABLE <lt_result> ASSIGNING <ls_row> INDEX 1.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `RESULT_ROW_NOT_FOUND` ).
    ENDIF.

    ASSIGN COMPONENT `NAME` OF STRUCTURE <ls_row> TO <lv_name>.
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

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_equals( exp = `SEL_CANCEL`
                                        act = mo_action->ms_next-next_event ).

  ENDMETHOD.

  METHOD test_search_filters.

    DATA lo_pop TYPE REF TO z2ui5_cl_pop_to_select.
    DATA temp15 TYPE string_table.
    FIELD-SYMBOLS <lt_pop> TYPE STANDARD TABLE.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `SEARCH`.

    CLEAR temp15.
    INSERT `bravo` INTO TABLE temp15.
    mo_action->ms_actual-t_event_arg = temp15.
    lo_pop->z2ui5_if_app~main( mi_client ).


    ASSIGN lo_pop->mr_tab_popup->* TO <lt_pop>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <lt_pop> ) ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_update_model ).

  ENDMETHOD.

ENDCLASS.
