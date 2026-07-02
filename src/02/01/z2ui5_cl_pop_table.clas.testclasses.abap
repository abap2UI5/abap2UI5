CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_pop_table DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_factory          FOR TESTING RAISING cx_static_check.
    METHODS test_factory_title    FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_row_ref  FOR TESTING RAISING cx_static_check.
    METHODS test_factory_data_copy FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = `1` ) ( name = `B` value = `2` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_bound( lo_pop->mr_tab ).

  ENDMETHOD.

  METHOD test_factory_title.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Custom Title` ).

    cl_abap_unit_assert=>assert_equals( exp = `Custom Title`
                                        act = lo_pop->title ).
  ENDMETHOD.

  METHOD test_result_initial.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_result-check_confirmed ).
  ENDMETHOD.

  METHOD test_factory_row_ref.
    TYPES:
      BEGIN OF ty_row,
        col TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col = `X` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_bound( ls_result-row ).
  ENDMETHOD.

  METHOD test_factory_data_copy.
    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = `1` )
                      ( name = `B` value = `2` )
                      ( name = `C` value = `3` ) ).

    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lo_pop->mr_tab->* TO <tab>.

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).
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

    METHODS roundtrip_event
      IMPORTING
        io_app   TYPE REF TO z2ui5_if_app
        iv_event TYPE string.

    METHODS test_init_displays_table FOR TESTING RAISING cx_static_check.
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

  METHOD test_init_displays_table.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `row1` count = 1 )
                                   ( name = `row2` count = 2 ) ).
    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( i_tab   = lt_tab
                                                i_title = `Pick a row` ).
    client_create( lo_pop ).

    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lv_xml) = mo_action->ms_next-s_set-s_popup-xml.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Pick a row` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `{NAME}` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `{COUNT}` ) ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `row1` ) ).
    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `BUTTON_CONFIRM` ).

    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lt_tab) = VALUE ty_t_tab( ( name = `row1` ) ).
    DATA(lo_pop) = z2ui5_cl_pop_table=>factory( lt_tab ).
    roundtrip_event( io_app   = lo_pop
                     iv_event = `CANCEL` ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( mo_action->ms_next-s_set-s_popup-check_destroy ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

ENDCLASS.
