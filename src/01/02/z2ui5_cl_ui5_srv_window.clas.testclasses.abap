CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        name  TYPE string,
        price TYPE p LENGTH 10 DECIMALS 2,
        date  TYPE d,
        flag  TYPE abap_bool,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    CLASS-METHODS rows
      RETURNING
        VALUE(result) TYPE ty_t_row.

    METHODS index_identity FOR TESTING RAISING cx_static_check.
    METHODS sort_text FOR TESTING RAISING cx_static_check.
    METHODS sort_number_descending FOR TESTING RAISING cx_static_check.
    METHODS sort_stable_two_keys FOR TESTING RAISING cx_static_check.
    METHODS sort_unknown_path FOR TESTING RAISING cx_static_check.
    METHODS filter_contains FOR TESTING RAISING cx_static_check.
    METHODS filter_number FOR TESTING RAISING cx_static_check.
    METHODS filter_between_date FOR TESTING RAISING cx_static_check.
    METHODS filter_or_and FOR TESTING RAISING cx_static_check.
    METHODS filter_boolean FOR TESTING RAISING cx_static_check.
    METHODS filter_unknown_path FOR TESTING RAISING cx_static_check.
    METHODS filter_then_sort FOR TESTING RAISING cx_static_check.
    METHODS rows_window FOR TESTING RAISING cx_static_check.
    METHODS parse_sort FOR TESTING RAISING cx_static_check.
    METHODS parse_filter FOR TESTING RAISING cx_static_check.
    METHODS parse_broken FOR TESTING RAISING cx_static_check.
    METHODS event_apply FOR TESTING RAISING cx_static_check.
    METHODS event_apply_unknown FOR TESTING RAISING cx_static_check.
    " a request for more rows names no order and changes none - not the
    " app's sort, not the app's filter, not the user's
    METHODS event_grow_keeps_order FOR TESTING RAISING cx_static_check.
    " sort( ) names the sort alone, filter( ) the filter alone
    METHODS event_names_one_part FOR TESTING RAISING cx_static_check.
    " the binding's filter and the app's are ANDed, each replaced alone
    METHODS event_filter_anded FOR TESTING RAISING cx_static_check.
    " a frontend from before: every request names both, an empty list too
    METHODS event_old_frontend FOR TESTING RAISING cx_static_check.
    " the rows a grown window sends and the row a position means
    METHODS grown_window_rows FOR TESTING RAISING cx_static_check.
    METHODS filter_merge FOR TESTING RAISING cx_static_check.

    "! one windowed attribute /MT_ROWS, window 2, the app's order on it
    METHODS attri_sorted
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD rows.

    result = VALUE #( ( id = 1 name = `banana` price = `3.50`  date = `20260105` flag = abap_true )
                      ( id = 2 name = `Apple`  price = `12.00` date = `20260301` )
                      ( id = 3 name = `cherry` price = `0.99`  date = `20251231` flag = abap_true )
                      ( id = 4 name = `apple`  price = `12.00` date = `20260210` )
                      ( id = 5 name = `Date`   price = `7.25`  date = `20260105` ) ).

  ENDMETHOD.

  METHOD index_identity.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( rows( ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 2 ) ( 3 ) ( 4 ) ( 5 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_text.

    " case-insensitive; Apple and apple keep the order of the table
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = VALUE #( ( path = `NAME` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 4 ) ( 1 ) ( 3 ) ( 5 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_number_descending.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = VALUE #( ( path = `PRICE` descending = abap_true ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 4 ) ( 5 ) ( 1 ) ( 3 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_stable_two_keys.

    " by date, the two rows of 2026-01-05 then by name descending
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = VALUE #( ( path = `DATE` )
                                                                       ( path = `NAME` descending = abap_true ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 3 ) ( 5 ) ( 1 ) ( 4 ) ( 2 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_unknown_path.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = VALUE #( ( path = `NOPE` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 2 ) ( 3 ) ( 4 ) ( 5 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_contains.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `NAME` operator = `Contains` value1 = `PP` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 4 ) )
                                        act = lt_index ).

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `NAME` operator = `StartsWith` value1 = `ch` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 3 ) )
                                        act = lt_index ).

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `NAME` operator = `NotEndsWith` value1 = `e` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 3 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_number.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `PRICE` operator = `GT` value1 = `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 4 ) ( 5 ) )
                                        act = lt_index ).

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `PRICE` operator = `EQ` value1 = `12` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 4 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_between_date.

    " the browser writes a date as the model carries it, yyyy-MM-dd
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `DATE` operator = `BT` value1 = `2026-01-01` value2 = `2026-02-28` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 4 ) ( 5 ) )
                                        act = lt_index ).

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `DATE` operator = `NB` value1 = `2026-01-01` value2 = `2026-02-28` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 2 ) ( 3 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_or_and.

    " (name contains an OR name contains rr) AND price < 10
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `NAME` operator = `Contains` value1 = `an` )
                            ( group = 1 path = `NAME` operator = `Contains` value1 = `rr` )
                            ( group = 2 path = `PRICE` operator = `LT` value1 = `10` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 3 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_boolean.

    " the model carries an abap_bool as true / false
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `FLAG` operator = `EQ` value1 = `true` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 1 ) ( 3 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_unknown_path.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = VALUE #( ( group = 1 path = `NOPE` operator = `EQ` value1 = `x` ) ) ).
    cl_abap_unit_assert=>assert_initial( lt_index ).

  ENDMETHOD.

  METHOD filter_then_sort.

    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_sort   = VALUE #( ( path = `PRICE` ) )
        t_filter = VALUE #( ( group = 1 path = `FLAG` operator = `EQ` value1 = `true` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 3 ) ( 1 ) )
                                        act = lt_index ).

  ENDMETHOD.

  METHOD rows_window.

    DATA lt_result TYPE ty_t_row.
    FIELD-SYMBOLS <result> TYPE ty_t_row.

    DATA(lt_rows) = rows( ).
    DATA(lr_rows) = z2ui5_cl_ui5_srv_window=>rows( tab     = lt_rows
                                                   t_index = VALUE #( ( 4 ) ( 2 ) ( 5 ) )
                                                   count   = 2 ).
    ASSIGN lr_rows->* TO <result>.
    lt_result = <result>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lt_result[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lt_result[ 2 ]-id ).

  ENDMETHOD.

  METHOD parse_sort.

    DATA(lt_sort) = z2ui5_cl_ui5_srv_window=>parse_sort( `[{"PATH":"name","DESCENDING":true},{"PATH":"ID"}]` ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_ui5_types=>ty_t_window_sort( ( path = `NAME` descending = abap_true )
                                                                                          ( path = `ID` ) )
                                        act = lt_sort ).

  ENDMETHOD.

  METHOD parse_filter.

    DATA(lt_filter) = z2ui5_cl_ui5_srv_window=>parse_filter(
        `[[["NAME","Contains","ab"],["NAME","EQ","x"]],[["PRICE","BT",1,9.5]]]` ).
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_if_ui5_types=>ty_t_window_filter(
                  ( group = 1 path = `NAME`  operator = `Contains` value1 = `ab` )
                  ( group = 1 path = `NAME`  operator = `EQ`       value1 = `x` )
                  ( group = 2 path = `PRICE` operator = `BT`       value1 = `1` value2 = `9.5` ) )
        act = lt_filter ).

  ENDMETHOD.

  METHOD parse_broken.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_sort( `[{` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `nope` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `` ) ).

  ENDMETHOD.

  METHOD event_apply.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    CREATE DATA lr_attri.
    INSERT VALUE #( name = `MT_ROWS` name_client = `/MT_ROWS` bind = abap_true window_size = 50 window_count = 150 )
           INTO TABLE lr_attri->*.
    INSERT VALUE #( name = `MV_X` name_client = `/MV_X` bind = abap_true ) INTO TABLE lr_attri->*.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = VALUE #( ( `/MT_ROWS` ) ( `100` ) ( `[{"PATH":"NAME"}]` ) ( `[[["NAME","Contains","a"]]]` ) )
        attri = lr_attri ) ).

    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = ls_attri-window_count ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_sort ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_filter ) ).

    " fewer than one window is one window
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `3` ) )
                                          attri = lr_attri ).
    ls_attri = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = 50
                                        act = ls_attri-window_count ).
    " ... of the order there is: a request that names none keeps it (it
    " cleared the sort and the filter here, and this line asserted that)
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_sort ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_filter ) ).

    " a count from the browser that is no number, has a blank inside or is
    " past the integer range is one window - it raised out of event_apply,
    " which runs outside every TRY, as a 500
    LOOP AT VALUE string_table( ( `1 0` ) ( `99999999999` ) ( `-5` ) ( `abc` ) ( ` ` ) ) INTO DATA(lv_count).
      z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( lv_count ) )
                                            attri = lr_attri ).
      ls_attri = lr_attri->*[ name = `MT_ROWS` ].
      cl_abap_unit_assert=>assert_equals( exp = 50
                                          act = ls_attri-window_count
                                          msg = lv_count ).
    ENDLOOP.

    " surrounding blanks are not part of the number
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( ` 200 ` ) )
                                          attri = lr_attri ).
    ls_attri = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_attri-window_count ).

  ENDMETHOD.

  METHOD event_apply_unknown.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    CREATE DATA lr_attri.
    INSERT VALUE #( name = `MV_X` name_client = `/MV_X` bind = abap_true ) INTO TABLE lr_attri->*.

    " a table that is not windowed is not touched
    cl_abap_unit_assert=>assert_false( z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MV_X` ) ( `100` ) )
                                                                             attri = lr_attri ) ).

  ENDMETHOD.

  METHOD attri_sorted.

    " what z2ui5_cl_ui5_srv_bind=>window_adopt leaves after
    " window_bind_tab( val = mt_rows window = 2 t_sort = NAME t_filter = PRICE > 1 )
    DATA(lt_sort) = VALUE z2ui5_if_ui5_types=>ty_t_window_sort( ( path = `NAME` descending = abap_true ) ).
    DATA(lt_filter) = VALUE z2ui5_if_ui5_types=>ty_t_window_filter(
                          ( group = 1 path = `PRICE` operator = `GT` value1 = `1` ) ).
    CREATE DATA result.
    INSERT VALUE #( name                = `MT_ROWS`
                    name_client         = `/MT_ROWS`
                    bind                = abap_true
                    window_size         = 2
                    window_count        = 2
                    t_window_sort       = lt_sort
                    t_window_sort_set   = lt_sort
                    t_window_filter     = lt_filter
                    t_window_filter_set = lt_filter )
           INTO TABLE result->*.

  ENDMETHOD.

  METHOD event_grow_keeps_order.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    lr_attri = attri_sorted( ).
    DATA(ls_before) = lr_attri->*[ name = `MT_ROWS` ].

    " "More": the path and the rows wanted, nothing else
    cl_abap_unit_assert=>assert_true( z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `4` ) )
                                                                            attri = lr_attri ) ).
    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_attri-window_count ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                        act = ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).

    " an argument that is there and says nothing is the same request
    LOOP AT VALUE string_table( ( `` ) ( ` ` ) ( `null` ) ) INTO DATA(lv_nothing).
      z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `6` ) ( lv_nothing ) ( lv_nothing ) )
                                            attri = lr_attri ).
      ls_attri = lr_attri->*[ name = `MT_ROWS` ].
      cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                          act = ls_attri-t_window_sort
                                          msg = lv_nothing ).
      cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                          act = ls_attri-t_window_filter
                                          msg = lv_nothing ).
    ENDLOOP.

    " the user sorts by another column, then grows: the user's sort stays
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `[{"PATH":"ID"}]` ) )
                                          attri = lr_attri ).
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `4` ) )
                                          attri = lr_attri ).
    ls_attri = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_ui5_types=>ty_t_window_sort( ( path = `ID` ) )
                                        act = ls_attri-t_window_sort ).
    " and what the app passed is still on record: the same t_sort from the
    " app keeps the user's, a different one replaces it (srv_bind)
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort_set
                                        act = ls_attri-t_window_sort_set ).

  ENDMETHOD.

  METHOD event_names_one_part.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    lr_attri = attri_sorted( ).
    DATA(ls_before) = lr_attri->*[ name = `MT_ROWS` ].

    " filter( ) on the binding: the sort is not named and stays the app's
    z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `` ) ( `[[["NAME","Contains","a"]]]` ) )
        attri = lr_attri ).
    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                        act = ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_attri-t_window_filter ) ).

    " sort( ) on the binding: the filter is not named and stays
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `[{"PATH":"PRICE"}]` ) )
                                          attri = lr_attri ).
    DATA(ls_sorted) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_ui5_types=>ty_t_window_sort( ( path = `PRICE` ) )
                                        act = ls_sorted-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = ls_sorted-t_window_filter ).

    " sort( [] ) clears the sort - an empty list is said, not missing
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `[]` ) )
                                          attri = lr_attri ).
    ls_sorted = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_initial( ls_sorted-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = ls_sorted-t_window_filter ).

  ENDMETHOD.

  METHOD event_filter_anded.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    lr_attri = attri_sorted( ).
    DATA(ls_before) = lr_attri->*[ name = `MT_ROWS` ].

    " the user filters a column: ANDed with the app's PRICE > 1
    z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `` ) ( `[[["NAME","Contains","a"],["NAME","EQ","cherry"]]]` ) )
        attri = lr_attri ).
    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_if_ui5_types=>ty_t_window_filter(
                  ( group = 1 path = `PRICE` operator = `GT`       value1 = `1` )
                  ( group = 2 path = `NAME`  operator = `Contains` value1 = `a` )
                  ( group = 2 path = `NAME`  operator = `EQ`       value1 = `cherry` ) )
        act = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter_set
                                        act = ls_attri-t_window_filter_set ).
    " cherry costs 0.99: the app's filter still holds it back. Name
    " descending: Date, banana, apple, Apple
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 5 ) ( 1 ) ( 2 ) ( 4 ) )
        act = z2ui5_cl_ui5_srv_window=>index( tab      = rows( )
                                              t_sort   = ls_attri-t_window_sort
                                              t_filter = ls_attri-t_window_filter ) ).

    " growing keeps both parts
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `4` ) )
                                          attri = lr_attri ).
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = lr_attri->*[ name = `MT_ROWS` ]-t_window_filter ).

    " the user clears the column filter: the app's part is what is left
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `2` ) ( `` ) ( `[]` ) )
                                          attri = lr_attri ).
    ls_attri = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_initial( ls_attri-t_window_filter_ui ).

  ENDMETHOD.

  METHOD event_old_frontend.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    lr_attri = attri_sorted( ).
    DATA(ls_before) = lr_attri->*[ name = `MT_ROWS` ].

    " its "More" re-sends the binding's own lists, empty after an app sort:
    " the sort is replaced, as it was - the app's filter is not the
    " binding's to clear and stays
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `4` ) ( `[]` ) ( `[]` ) )
                                          attri = lr_attri ).
    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    cl_abap_unit_assert=>assert_initial( ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).

  ENDMETHOD.

  METHOD grown_window_rows.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    FIELD-SYMBOLS <window> TYPE ty_t_row.

    " the app sorted and filtered, the list grew: the rows the response
    " sends continue the first window, and position 3 - what
    " window_get_row( ) answers and where a cell edit lands - is the third
    " row of that order, not of the table
    lr_attri = attri_sorted( ).
    DATA(lt_rows) = rows( ).
    DATA(ls_first) = lr_attri->*[ name = `MT_ROWS` ].
    DATA(lt_first) = z2ui5_cl_ui5_srv_window=>index( tab      = lt_rows
                                                     t_sort   = ls_first-t_window_sort
                                                     t_filter = ls_first-t_window_filter ).

    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = VALUE #( ( `/MT_ROWS` ) ( `4` ) )
                                          attri = lr_attri ).
    DATA(ls_attri) = lr_attri->*[ name = `MT_ROWS` ].
    DATA(lt_index) = z2ui5_cl_ui5_srv_window=>index( tab      = lt_rows
                                                     t_sort   = ls_attri-t_window_sort
                                                     t_filter = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lt_first
                                        act = lt_index ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_cl_ui5_srv_window=>ty_t_index( ( 5 ) ( 1 ) ( 2 ) ( 4 ) )
                                        act = lt_index ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lt_index[ 3 ] ).

    DATA(lr_window) = z2ui5_cl_ui5_srv_window=>rows( tab     = lt_rows
                                                     t_index = lt_index
                                                     count   = ls_attri-window_count ).
    ASSIGN lr_window->* TO <window>.
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( <window> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Date`
                                        act = <window>[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `Apple`
                                        act = <window>[ 3 ]-name ).

  ENDMETHOD.

  METHOD filter_merge.

    " the groups of the two never run into each other, whatever numbers
    " they came with - the app's 0 and 0 are one group, the binding's 1 is
    " another one than the app's 1
    DATA(lt_merged) = z2ui5_cl_ui5_srv_window=>filter_merge(
        t_app = VALUE #( ( group = 0 path = `NAME`  operator = `EQ` value1 = `a` )
                         ( group = 0 path = `NAME`  operator = `EQ` value1 = `b` )
                         ( group = 1 path = `PRICE` operator = `GT` value1 = `1` ) )
        t_ui  = VALUE #( ( group = 1 path = `ID`    operator = `LT` value1 = `9` ) ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_if_ui5_types=>ty_t_window_filter(
                  ( group = 1 path = `NAME`  operator = `EQ` value1 = `a` )
                  ( group = 1 path = `NAME`  operator = `EQ` value1 = `b` )
                  ( group = 2 path = `PRICE` operator = `GT` value1 = `1` )
                  ( group = 3 path = `ID`    operator = `LT` value1 = `9` ) )
        act = lt_merged ).

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>filter_merge( t_app = VALUE #( )
                                                                                t_ui  = VALUE #( ) ) ).

  ENDMETHOD.

ENDCLASS.
