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

    " the sap.m.Table, 50 rows at a time - event ROWS
    DATA mt_rows TYPE ty_t_row.
    " the sap.ui.table.Table, 30 rows at a time - event GRID, bound as REF #( mt_grid )
    " abap2ui5lint-disable-next-line unbound-public-attribute -- bound through window_bind_tab( val = REF #( mt_grid ) ), which the linter does not follow yet
    DATA mt_grid TYPE ty_t_row.
    " a table behind a data reference: 40 rows, 10 at a time - event TAB
    DATA mr_tab TYPE REF TO data.
    " what CHECK and ROW found
    DATA mv_result TYPE string.
    " the rows there are in all - passed as total = to window_bind_tab( ),
    " and read anew by every response: a window event only sets them
    " abap2ui5lint-disable-next-line unbound-public-attribute -- the total of window_bind_tab( ), read by the framework
    DATA mv_rows_total TYPE i.
    " abap2ui5lint-disable-next-line unbound-public-attribute -- the total of window_bind_tab( ), read by the framework
    DATA mv_grid_total TYPE i.
    " abap2ui5lint-disable-next-line unbound-public-attribute -- the total of window_bind_tab( ), read by the framework
    DATA mv_tab_total TYPE i.

  PROTECTED SECTION.

    TYPES:
      BEGIN OF ty_s_query,
        t_sort   TYPE z2ui5_if_client=>ty_t_bind_tab_sort,
        " the app's own filter (event FILTER) and the binding's, ANDed
        t_filter TYPE z2ui5_if_client=>ty_t_bind_tab_filter,
        t_column TYPE z2ui5_if_client=>ty_t_bind_tab_filter,
      END OF ty_s_query.

    DATA client TYPE REF TO z2ui5_if_client.
    " the "database": 250 rows - the app reads windows of it, the way a
    " SELECT with ORDER BY, WHERE, OFFSET and UP TO n ROWS would
    DATA mt_db TYPE ty_t_row.
    DATA ms_rows TYPE ty_s_query.
    DATA ms_grid TYPE ty_s_query.
    DATA ms_tab TYPE ty_s_query.

    METHODS view_display.

    "! rows skip + 1 to skip + top of the database in the order and the
    "! filter of the query, appended to ct_rows (cleared first for skip 0);
    "! cv_total gets the count of all rows the filter lets through
    METHODS select
      IMPORTING
        skip     TYPE i
        top      TYPE i
        is_query TYPE ty_s_query
      CHANGING
        ct_rows  TYPE ty_t_row
        cv_total TYPE i.

    "! the browser's request of one table: more rows, or a new sort or
    "! column filter from the first row on
    METHODS on_window
      CHANGING
        cs_query TYPE ty_s_query
        ct_rows  TYPE ty_t_row
        cv_total TYPE i.

    METHODS check_row
      IMPORTING
        is_row        TYPE ty_s_row
        it_filter     TYPE z2ui5_if_client=>ty_t_bind_tab_filter
      RETURNING
        VALUE(result) TYPE abap_bool.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_window IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    FIELD-SYMBOLS <tab> TYPE ty_t_row.

    me->client = client.

    " e2e fixture for the windowed table (window.spec.js): the app holds
    " the rows the browser shows and loads, sorts, filters and counts them
    " itself - the framework only hands the browser's requests over as the
    " events ROWS, GRID and TAB with get( )-r_event_data
    IF client->check_on_init( ).
      DO 250 TIMES.
        " the price runs in a different order than the id
        APPEND VALUE #( id    = sy-index
                        name  = |Item { sy-index }|
                        price = ( sy-index * 37 ) MOD 251 ) TO mt_db.
      ENDDO.
      CREATE DATA mr_tab TYPE ty_t_row.
      ASSIGN mr_tab->* TO <tab>.
      select( EXPORTING skip = 0 top = 50 is_query = ms_rows CHANGING ct_rows = mt_rows cv_total = mv_rows_total ).
      select( EXPORTING skip = 0 top = 30 is_query = ms_grid CHANGING ct_rows = mt_grid cv_total = mv_grid_total ).
      " the list reads the first 40 rows only
      ms_tab-t_filter = VALUE #( ( group = 1 path = `ID` operator = `LE` value1 = `40` ) ).
      select( EXPORTING skip = 0 top = 10 is_query = ms_tab CHANGING ct_rows = <tab> cv_total = mv_tab_total ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_navigated( ).
      view_display( ).
      RETURN.
    ENDIF.

    ASSIGN mr_tab->* TO <tab>.
    CASE client->get( )-event.
      " abap2ui5lint-disable-next-line handler-without-event -- the window event of mt_rows, sent by the list binding
      WHEN `ROWS`.
        on_window( CHANGING cs_query = ms_rows ct_rows = mt_rows cv_total = mv_rows_total ).
      " abap2ui5lint-disable-next-line handler-without-event -- the window event of mt_grid, sent by the list binding
      WHEN `GRID`.
        on_window( CHANGING cs_query = ms_grid ct_rows = mt_grid cv_total = mv_grid_total ).
      " abap2ui5lint-disable-next-line handler-without-event -- the window event of mr_tab, sent by the list binding
      WHEN `TAB`.
        on_window( CHANGING cs_query = ms_tab ct_rows = <tab> cv_total = mv_tab_total ).
      WHEN `CHECK`.
        CLEAR mv_result.
        LOOP AT mt_rows INTO DATA(ls_row) WHERE selected = abap_true.
          mv_result = |{ mv_result }{ ls_row-id };|.
        ENDLOOP.
      WHEN `PRESET`.
        " the app sorts: the highest id first, from the first row on
        ms_rows-t_sort = VALUE #( ( path = `ID` descending = abap_true ) ).
        select( EXPORTING skip = 0 top = 50 is_query = ms_rows CHANGING ct_rows = mt_rows cv_total = mv_rows_total ).
      " abap2ui5lint-disable-next-line handler-without-event -- posted by window.spec.js: the app filters mt_rows, or clears its filter
      WHEN `FILTER`.
        CLEAR ms_rows-t_filter.
        IF client->get_event_arg( ) IS NOT INITIAL.
          ms_rows-t_filter = VALUE #( ( group = 1 path = `NAME` operator = `Contains` value1 = client->get_event_arg( ) ) ).
        ENDIF.
        select( EXPORTING skip = 0 top = 50 is_query = ms_rows CHANGING ct_rows = mt_rows cv_total = mv_rows_total ).
      WHEN `ROW`.
        " the binding path of the row pressed, /MT_ROWS/5 - the row of
        " mt_rows with that index, the table IS what the browser shows
        DATA(lv_path) = client->get_event_arg( ).
        DATA(lv_slash) = find( val = lv_path
                               sub = `/`
                               occ = -1 ).
        DATA(lv_pos) = CONV i( substring( val = lv_path
                                          off = lv_slash + 1 ) ) + 1.
        mv_result = COND #( WHEN lv_pos <= lines( mt_rows ) THEN |{ mt_rows[ lv_pos ]-id }| ELSE `none` ).
    ENDCASE.

  ENDMETHOD.


  METHOD on_window.

    FIELD-SYMBOLS <req> TYPE z2ui5_if_client=>ty_s_window_request.

    DATA(lr_req) = client->get( )-r_event_data.
    ASSIGN lr_req->* TO <req>.
    DATA(ls_req) = <req>.

    CASE ls_req-reason.
      WHEN client->cs_window_reason-more.
        select( EXPORTING skip     = lines( ct_rows )
                          top      = ls_req-top
                          is_query = cs_query
                CHANGING  ct_rows  = ct_rows
                          cv_total = cv_total ).
      WHEN OTHERS.
        " SORT and FILTER carry the whole state of the columns
        cs_query-t_sort   = ls_req-t_sort.
        cs_query-t_column = ls_req-t_filter.
        select( EXPORTING skip     = 0
                          top      = ls_req-top
                          is_query = cs_query
                CHANGING  ct_rows  = ct_rows
                          cv_total = cv_total ).
    ENDCASE.

  ENDMETHOD.


  METHOD select.

    DATA lt_hit TYPE ty_t_row.

    LOOP AT mt_db INTO DATA(ls_row).
      IF check_row( is_row = ls_row it_filter = is_query-t_filter ) = abap_true
          AND check_row( is_row = ls_row it_filter = is_query-t_column ) = abap_true.
        APPEND ls_row TO lt_hit.
      ENDIF.
    ENDLOOP.
    cv_total = lines( lt_hit ).

    " ORDER BY - one column is enough for the fixture
    DATA(ls_sort) = VALUE #( is_query-t_sort[ 1 ] OPTIONAL ).
    CASE ls_sort-path.
      WHEN `ID`.
        IF ls_sort-descending = abap_true.
          SORT lt_hit BY id DESCENDING.
        ELSE.
          SORT lt_hit BY id.
        ENDIF.
      WHEN `NAME`.
        IF ls_sort-descending = abap_true.
          SORT lt_hit BY name DESCENDING.
        ELSE.
          SORT lt_hit BY name.
        ENDIF.
      WHEN `PRICE`.
        IF ls_sort-descending = abap_true.
          SORT lt_hit BY price DESCENDING id.
        ELSE.
          SORT lt_hit BY price id.
        ENDIF.
    ENDCASE.

    " OFFSET skip, UP TO top ROWS
    IF skip = 0.
      CLEAR ct_rows.
    ENDIF.
    LOOP AT lt_hit INTO ls_row FROM skip + 1.
      IF sy-tabix > skip + top.
        EXIT.
      ENDIF.
      APPEND ls_row TO ct_rows.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_row.

    DATA lv_hit TYPE abap_bool.
    DATA lv_group TYPE i.

    " the conditions of one group ORed, the groups ANDed
    result = abap_true.
    LOOP AT it_filter INTO DATA(ls_cond).
      IF ls_cond-group <> lv_group.
        IF lv_group IS NOT INITIAL AND lv_hit = abap_false.
          result = abap_false.
          RETURN.
        ENDIF.
        lv_group = ls_cond-group.
        lv_hit = abap_false.
      ENDIF.
      DATA(lv_cell) = to_upper( SWITCH string( ls_cond-path
                                               WHEN `ID` THEN |{ is_row-id }|
                                               WHEN `NAME` THEN is_row-name ) ).
      DATA(lv_value) = to_upper( ls_cond-value1 ).
      CASE ls_cond-operator.
        WHEN `Contains`.
          lv_hit = xsdbool( lv_hit = abap_true OR lv_cell CS lv_value ).
        WHEN `EndsWith`.
          lv_hit = xsdbool( lv_hit = abap_true OR ( strlen( lv_cell ) >= strlen( lv_value )
                     AND substring( val = lv_cell off = strlen( lv_cell ) - strlen( lv_value ) ) = lv_value ) ).
        WHEN `EQ`.
          lv_hit = xsdbool( lv_hit = abap_true OR lv_cell = lv_value ).
        WHEN `LE`.
          lv_hit = xsdbool( lv_hit = abap_true OR is_row-id <= CONV i( ls_cond-value1 ) ).
      ENDCASE.
    ENDLOOP.
    IF lv_group IS NOT INITIAL AND lv_hit = abap_false.
      result = abap_false.
    ENDIF.

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
            )->a( n = `id`    v = `preset`
            )->a( n = `text`  v = `Highest id first`
            )->a( n = `press` v = client->_event( `PRESET` )
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
        )->a( n = `items`            v = client->window_bind_tab( val    = mt_rows
                                                                  total  = mv_rows_total
                                                                  event  = `ROWS`
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
        )->a( n = `rows`            v = client->window_bind_tab( val    = REF #( mt_grid )
                                                                 total  = mv_grid_total
                                                                 event  = `GRID`
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
        )->a( n = `items`   v = client->window_bind_tab( val    = mr_tab
                                                         total  = mv_tab_total
                                                         event  = `TAB`
                                                         window = 10 )
        )->a( n = `growing` v = `true`
        )->ele( `items`
            )->tag( `StandardListItem`
                )->a( n = `title` v = `{NAME}` ).

    client->view_display( view->stringify( ) ).
  ENDMETHOD.

ENDCLASS.
