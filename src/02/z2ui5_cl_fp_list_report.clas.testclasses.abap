CLASS ltcl_client_mock DEFINITION FINAL FOR TESTING.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client PARTIALLY IMPLEMENTED.

    DATA mv_on_init         TYPE abap_bool.
    DATA mv_event           TYPE string.
    DATA mt_event_arg       TYPE string_table.
    DATA mv_view            TYPE string.
    DATA mv_popup           TYPE string.
    DATA mv_popup_destroyed TYPE abap_bool.
    DATA mv_model_updated   TYPE abap_bool.

ENDCLASS.


CLASS ltcl_client_mock IMPLEMENTATION.

  METHOD z2ui5_if_client~check_on_init.
    result = mv_on_init.
  ENDMETHOD.

  METHOD z2ui5_if_client~check_on_event.
    result = xsdbool( mv_event = val ).
  ENDMETHOD.

  METHOD z2ui5_if_client~get_event_arg.
    result = VALUE #( mt_event_arg[ v ] OPTIONAL ).
  ENDMETHOD.

  METHOD z2ui5_if_client~view_display.
    mv_view = val.
  ENDMETHOD.

  METHOD z2ui5_if_client~popup_display.
    mv_popup = val.
  ENDMETHOD.

  METHOD z2ui5_if_client~popup_destroy.
    mv_popup_destroyed = abap_true.
  ENDMETHOD.

  METHOD z2ui5_if_client~view_model_update.
    mv_model_updated = abap_true.
  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.
    result = `{/BIND}`.
  ENDMETHOD.

  METHOD z2ui5_if_client~_event.
    result = |handler:{ val }|.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_subclass DEFINITION FINAL FOR TESTING
  INHERITING FROM z2ui5_cl_fp_list_report.

  PUBLIC SECTION.
    DATA mv_custom_event_handled TYPE abap_bool.

  PROTECTED SECTION.
    METHODS on_event REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_subclass IMPLEMENTATION.

  METHOD on_event.
    IF client->check_on_event( `MY_CUSTOM_ACTION` ) = abap_true.
      mv_custom_event_handled = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_row,
        product    TYPE string,
        city_name  TYPE string,
        stock      TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_deep,
        plain  TYPE string,
        t_deep TYPE ty_t_row,
      END OF ty_s_deep.
    TYPES ty_t_deep TYPE STANDARD TABLE OF ty_s_deep WITH EMPTY KEY.

    METHODS get_data
      RETURNING
        VALUE(result) TYPE ty_t_row.

    METHODS get_app_initialized
      IMPORTING
        io_client     TYPE REF TO ltcl_client_mock
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fp_list_report.

    METHODS test_factory_copies_data   FOR TESTING RAISING cx_static_check.
    METHODS test_columns_derived       FOR TESTING RAISING cx_static_check.
    METHODS test_columns_skip_deep     FOR TESTING RAISING cx_static_check.
    METHODS test_columns_custom        FOR TESTING RAISING cx_static_check.
    METHODS test_init_renders_view     FOR TESTING RAISING cx_static_check.
    METHODS test_search_filters        FOR TESTING RAISING cx_static_check.
    METHODS test_sort_cycles           FOR TESTING RAISING cx_static_check.
    METHODS test_row_opens_detail      FOR TESTING RAISING cx_static_check.
    METHODS test_detail_close          FOR TESTING RAISING cx_static_check.
    METHODS test_subclass_escape_hatch FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD get_data.

    result = VALUE #( ( product = `Notebook`
                        city_name = `Berlin`
                        stock = 10 )
                      ( product = `Phone`
                        city_name = `Paris`
                        stock = 5 )
                      ( product = `Screen`
                        city_name = `Berlin`
                        stock = 2 ) ).

  ENDMETHOD.


  METHOD get_app_initialized.

    result = z2ui5_cl_fp_list_report=>factory( t_data = get_data( )
                                               title  = `Products` ).
    io_client->mv_on_init = abap_true.
    result->z2ui5_if_app~main( io_client ).
    io_client->mv_on_init = abap_false.

  ENDMETHOD.


  METHOD test_factory_copies_data.

    FIELD-SYMBOLS <tab> TYPE ty_t_row.

    DATA(lo_app) = z2ui5_cl_fp_list_report=>factory( get_data( ) ).

    ASSIGN lo_app->mr_data->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Notebook`
                                        act = <tab>[ 1 ]-product ).

  ENDMETHOD.


  METHOD test_columns_derived.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = get_app_initialized( lo_client ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_column ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Product`
                                        act = lo_app->mt_column[ 1 ]-label ).
    cl_abap_unit_assert=>assert_equals( exp = `City Name`
                                        act = lo_app->mt_column[ 2 ]-label ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_column[ 3 ]-visible ).

  ENDMETHOD.


  METHOD test_columns_skip_deep.

    DATA lt_deep TYPE ty_t_deep.

    lt_deep = VALUE #( ( plain = `A` ) ).

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = z2ui5_cl_fp_list_report=>factory( lt_deep ).
    lo_client->mv_on_init = abap_true.
    lo_app->z2ui5_if_app~main( lo_client ).

    " the nested table component cannot be rendered as text - only the
    " plain component becomes a column
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_column ) ).
    cl_abap_unit_assert=>assert_equals( exp = `PLAIN`
                                        act = lo_app->mt_column[ 1 ]-name ).

  ENDMETHOD.


  METHOD test_columns_custom.

    DATA lt_columns TYPE z2ui5_cl_fp_list_report=>ty_t_column.

    " rows appended one by one - in a multi-row VALUE constructor whose
    " rows fill different fields the transpiler reuses the work area
    " without clearing it between rows, so row 2 would inherit row 1's
    " label
    APPEND VALUE #( name = `STOCK` label = `On Stock` visible = abap_true ) TO lt_columns.
    APPEND VALUE #( name = `PRODUCT` visible = abap_true ) TO lt_columns.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = z2ui5_cl_fp_list_report=>factory(
        t_data  = get_data( )
        columns = lt_columns ).
    lo_client->mv_on_init = abap_true.
    lo_app->z2ui5_if_app~main( lo_client ).

    " custom columns keep set, order and labels - a missing label is
    " beautified from the component name
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_app->mt_column ) ).
    cl_abap_unit_assert=>assert_equals( exp = `On Stock`
                                        act = lo_app->mt_column[ 1 ]-label ).
    cl_abap_unit_assert=>assert_equals( exp = `Product`
                                        act = lo_app->mt_column[ 2 ]-label ).

  ENDMETHOD.


  METHOD test_init_renders_view.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    get_app_initialized( lo_client ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*<Table*`
                                         act = lo_client->mv_view ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<SearchField*`
                                         act = lo_client->mv_view ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*text="City Name"*`
                                         act = lo_client->mv_view ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*text="{CITY_NAME}"*`
                                         act = lo_client->mv_view ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*handler:Z2UI5_FP_ROW*`
                                         act = lo_client->mv_view ).

  ENDMETHOD.


  METHOD test_search_filters.

    FIELD-SYMBOLS <disp> TYPE ty_t_row.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = get_app_initialized( lo_client ).

    " in the real roundtrip the two-way binding writes the search value
    " into the attribute before the event handler runs
    lo_app->mv_search = `berlin`.
    lo_client->mv_event = lo_app->cs_evt-search.
    lo_app->z2ui5_if_app~main( lo_client ).

    ASSIGN lo_app->mr_display->* TO <disp>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <disp> ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_client->mv_model_updated ).

    lo_app->mv_search = ``.
    lo_app->z2ui5_if_app~main( lo_client ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <disp> ) ).

  ENDMETHOD.


  METHOD test_sort_cycles.

    FIELD-SYMBOLS <disp> TYPE ty_t_row.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = get_app_initialized( lo_client ).

    ASSIGN lo_app->mr_display->* TO <disp>.

    " first press: ascending
    lo_client->mv_event = lo_app->cs_evt-sort.
    lo_client->mt_event_arg = VALUE #( ( `STOCK` ) ).
    lo_app->z2ui5_if_app~main( lo_client ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <disp>[ 1 ]-stock ).

    " second press: descending
    lo_app->z2ui5_if_app~main( lo_client ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = <disp>[ 1 ]-stock ).

    " third press: sorting off - original order again
    lo_app->z2ui5_if_app~main( lo_client ).
    cl_abap_unit_assert=>assert_equals( exp = `Notebook`
                                        act = <disp>[ 1 ]-product ).

  ENDMETHOD.


  METHOD test_row_opens_detail.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = get_app_initialized( lo_client ).

    " the row press sends the 0-based binding context index
    lo_client->mv_event = lo_app->cs_evt-row_press.
    lo_client->mt_event_arg = VALUE #( ( `1` ) ).
    lo_app->z2ui5_if_app~main( lo_client ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_detail ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Phone`
                                        act = lo_app->mt_detail[ 1 ]-value ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<Dialog*`
                                         act = lo_client->mv_popup ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<DisplayListItem*`
                                         act = lo_client->mv_popup ).

  ENDMETHOD.


  METHOD test_detail_close.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = get_app_initialized( lo_client ).

    lo_client->mv_event = lo_app->cs_evt-detail_close.
    lo_app->z2ui5_if_app~main( lo_client ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_client->mv_popup_destroyed ).

  ENDMETHOD.


  METHOD test_subclass_escape_hatch.

    DATA(lo_client) = NEW ltcl_client_mock( ).
    DATA(lo_app) = NEW ltcl_subclass( ).

    " a subclass instance behaves like any factory-built floorplan once
    " the data refs are seeded
    DATA(lo_template) = z2ui5_cl_fp_list_report=>factory( get_data( ) ).
    lo_app->mr_data = lo_template->mr_data.
    lo_app->mr_display = lo_template->mr_display.

    lo_client->mv_on_init = abap_true.
    lo_app->z2ui5_if_app~main( lo_client ).
    lo_client->mv_on_init = abap_false.

    " an event the floorplan does not know reaches the subclass hook
    lo_client->mv_event = `MY_CUSTOM_ACTION`.
    lo_app->z2ui5_if_app~main( lo_client ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mv_custom_event_handled ).

  ENDMETHOD.

ENDCLASS.
