CLASS zcl_tst_window DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id       TYPE i,
        name     TYPE string,
        price    TYPE p LENGTH 8 DECIMALS 2,
        selected TYPE abap_bool,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    " the sap.m.Table, 50 rows at a time
    DATA mt_rows TYPE ty_t_row.
    " the sap.ui.table.Table, 30 rows at a time
    DATA mt_grid TYPE ty_t_row.
    " what CHECK found - the ids of the selected rows
    DATA mv_result TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
    METHODS fill.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_window IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    " e2e fixture for the windowed table (window.spec.js): 250 rows in two
    " tables, bound with _bind( window = n ). The browser holds a window of
    " each, grows it, and sorts and filters it on the server; CHECK reads
    " back which rows the user selected - in the table's own row order,
    " whatever order the browser showed them in
    IF client->check_on_init( ).
      fill( ).
      view_display( ).
    ELSEIF client->check_on_navigated( ).
      view_display( ).
    ELSEIF client->check_on_event( `CHECK` ).
      CLEAR mv_result.
      LOOP AT mt_rows INTO DATA(ls_row) WHERE selected = abap_true.
        mv_result = |{ mv_result }{ ls_row-id };|.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD fill.

    DO 250 TIMES.
      " the price runs in a different order than the id
      APPEND VALUE #( id    = sy-index
                      name  = |Item { sy-index }|
                      price = ( sy-index * 37 ) MOD 251 ) TO mt_rows.
    ENDDO.
    mt_grid = mt_rows.

  ENDMETHOD.


  METHOD view_display.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA tab  TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA grid TYPE REF TO z2ui5_cl_ui5_view_builder.

    view = z2ui5_cl_ui5_view_builder=>factory( ).
    page = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `xmlns:t`      v = `sap.ui.table`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`
        )->ele( `Shell`
            )->ele( `Page`
                )->a( n = `title` v = `WINDOW` ).

    page->ele( `OverflowToolbar`
        )->tag( `SearchField`
            )->a( n = `id`     v = `search`
            )->a( n = `width`  v = `12rem`
            )->a( n = `search` v = client->follow_up_action( val   = client->cs_event-binding_call
                                                             t_arg = VALUE #( ( `tab` )
                                                                              ( `items` )
                                                                              ( `filter` )
                                                                              ( `NAME` )
                                                                              ( `Contains` )
                                                                              ( `${$parameters>/query}` ) ) )
        )->tag( `Button`
            )->a( n = `id`    v = `sortPrice`
            )->a( n = `text`  v = `Price descending`
            )->a( n = `press` v = client->follow_up_action( val   = client->cs_event-binding_call
                                                            t_arg = VALUE #( ( `tab` )
                                                                             ( `items` )
                                                                             ( `sort` )
                                                                             ( `PRICE` )
                                                                             ( `X` ) ) )
        )->tag( `Button`
            )->a( n = `id`    v = `check`
            )->a( n = `text`  v = `Check`
            )->a( n = `press` v = client->_event( `CHECK` )
        )->tag( `Text`
            )->a( n = `id`   v = `total`
            )->a( n = `text` v = |\{/__WINDOW{ client->_bind_path( mt_rows ) }/TOTAL\} rows|
        )->tag( `Text`
            )->a( n = `id`   v = `result`
            )->a( n = `text` v = client->_bind( mv_result ) ).

    tab = page->ele( `Table`
        )->a( n = `id`               v = `tab`
        )->a( n = `items`            v = client->_bind( val    = mt_rows
                                                        window = 50 )
        )->a( n = `growing`          v = `true`
        )->a( n = `growingThreshold` v = `20` ).
    tab->ele( `columns`
        )->ele( `Column`
            )->tag( `Text`
                )->a( n = `text` v = `Name`
        )->end(
        )->ele( `Column`
            )->tag( `Text`
                )->a( n = `text` v = `Price`
        )->end(
        )->ele( `Column`
            )->tag( `Text`
                )->a( n = `text` v = `Selected` ).
    tab->ele( `items`
        )->ele( `ColumnListItem`
            )->ele( `cells`
                )->tag( `Text`
                    )->a( n = `text` v = `{NAME}`
                )->tag( `Text`
                    )->a( n = `text` v = `{PRICE}`
                )->tag( `CheckBox`
                    )->a( n = `selected` v = `{SELECTED}` ).

    grid = page->ele( n = `Table` ns = `t`
        )->a( n = `id`              v = `grid`
        )->a( n = `rows`            v = client->_bind( val    = mt_grid
                                                       window = 30 )
        )->a( n = `visibleRowCount` v = `10` ).
    grid->ele( n = `columns` ns = `t`
        )->ele( n = `Column` ns = `t`
            )->a( n = `sortProperty`   v = `NAME`
            )->a( n = `filterProperty` v = `NAME`
            )->ele( n = `label` ns = `t`
                )->tag( `Label`
                    )->a( n = `text` v = `Name`
            )->end(
            )->ele( n = `template` ns = `t`
                )->tag( `Text`
                    )->a( n = `text` v = `{NAME}` ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
