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
    " the sap.ui.table.Table, 30 rows at a time - bound as REF #( mt_grid )
    " abap2ui5lint-disable-next-line unbound-public-attribute -- bound through _bind_tab( val = REF #( mt_grid ) ), which the linter does not follow yet
    DATA mt_grid TYPE ty_t_row.
    " what CHECK found - the ids of the selected rows
    DATA mv_result TYPE string.
    " the order the app sets on mt_rows - PRESET puts the highest id first
    DATA mt_sort TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    " a table behind a data reference: 40 rows, 10 at a time
    DATA mr_tab TYPE REF TO data.

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
    " tables and 40 behind a data reference, bound with _bind_tab( ). The
    " browser holds a window of
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
    " abap2ui5lint-disable-next-line handler-without-event -- posted by window.spec.js: the app sets the order of mt_rows
    ELSEIF client->check_on_event( `PRESET` ).
      mt_sort = VALUE #( ( path = `ID` descending = abap_true ) ).
      view_display( ).
    " abap2ui5lint-disable-next-line handler-without-event -- posted by window.spec.js: the view rendered again, the order unchanged
    ELSEIF client->check_on_event( `RERENDER` ).
      view_display( ).
    ELSEIF client->check_on_event( `ROW` ).
      " the binding path of the row pressed, /MT_ROWS/5: a position in the
      " order the browser shows, the table's row from _bind_tab_row( )
      DATA(lv_path) = client->get_event_arg( ).
      DATA(lv_slash) = find( val = lv_path
                             sub = `/`
                             occ = -1 ).
      DATA(lv_pos) = CONV i( substring( val = lv_path
                                        off = lv_slash + 1 ) ).
      DATA(lv_row) = client->_bind_tab_row( val = mt_rows
                                            row = lv_pos + 1 ).
      mv_result = COND #( WHEN lv_row > 0 THEN |{ mt_rows[ lv_row ]-id }| ELSE `none` ).
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

    FIELD-SYMBOLS <tab> TYPE ty_t_row.
    CREATE DATA mr_tab TYPE ty_t_row.
    ASSIGN mr_tab->* TO <tab>.
    <tab> = mt_rows.
    DELETE <tab> FROM 41.

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
        )->a( n = `items`            v = client->_bind_tab( val    = mt_rows
                                                            window = 50
                                                            t_sort = mt_sort )
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
            )->a( n = `type`  v = `Active`
            )->a( n = `press` v = client->_event( val   = `ROW`
                                                  t_arg = VALUE #( ( `$event.oSource.getBindingContext().getPath()` ) ) )
            )->ele( `cells`
                )->tag( `Text`
                    )->a( n = `text` v = `{NAME}`
                )->tag( `Text`
                    )->a( n = `text` v = `{PRICE}`
                )->tag( `CheckBox`
                    )->a( n = `selected` v = `{SELECTED}` ).

    grid = page->ele( n = `Table` ns = `t`
        )->a( n = `id`              v = `grid`
        )->a( n = `rows`            v = client->_bind_tab( val    = REF #( mt_grid )
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

    " the table behind a data reference: bound as what it points to,
    " /MR_TAB/* in the model
    page->ele( `List`
        )->a( n = `id`      v = `list`
        )->a( n = `items`   v = client->_bind_tab( val    = mr_tab
                                                   window = 10 )
        )->a( n = `growing` v = `true`
        )->ele( `items`
            )->tag( `StandardListItem`
                )->a( n = `title` v = `{NAME}` ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
