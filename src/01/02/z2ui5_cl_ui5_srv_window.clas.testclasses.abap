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
    cl_abap_unit_assert=>assert_initial( ls_attri-t_window_sort ).

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

ENDCLASS.
