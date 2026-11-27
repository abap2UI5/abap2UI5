CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS request_more FOR TESTING RAISING cx_static_check.
    METHODS request_sort FOR TESTING RAISING cx_static_check.
    METHODS request_filter FOR TESTING RAISING cx_static_check.
    METHODS request_unknown_reason FOR TESTING RAISING cx_static_check.
    METHODS request_bad_counts FOR TESTING RAISING cx_static_check.
    METHODS request_empty FOR TESTING RAISING cx_static_check.
    METHODS event FOR TESTING RAISING cx_static_check.
    METHODS parse_sort FOR TESTING RAISING cx_static_check.
    METHODS parse_filter FOR TESTING RAISING cx_static_check.
    METHODS parse_broken FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD request_more.

    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request(
        VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `MORE` ) ( `100` ) ( `50` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `/MT_ROWS`
                                        act = ls_req-path ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-more
                                        act = ls_req-reason ).
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 50
                                        act = ls_req-top ).
    cl_abap_unit_assert=>assert_initial( ls_req-t_sort ).
    cl_abap_unit_assert=>assert_initial( ls_req-t_filter ).

  ENDMETHOD.

  METHOD request_sort.

    " a sort starts from the first row again - a skip sent with it is dropped
    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request(
        VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `SORT` ) ( `100` ) ( `50` )
                 ( `[{"PATH":"NAME","DESCENDING":true}]` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-sort
                                        act = ls_req-reason ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 50
                                        act = ls_req-top ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_client=>ty_t_bind_tab_sort( ( path = `NAME` descending = abap_true ) )
                                        act = ls_req-t_sort ).

  ENDMETHOD.

  METHOD request_filter.

    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request(
        VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `FILTER` ) ( `0` ) ( `50` ) ( `[{"PATH":"ID"}]` )
                 ( `[[["NAME","Contains","ab"]]]` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-filter
                                        act = ls_req-reason ).
    " the sorters of the binding come along - the whole state of the columns
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_client=>ty_t_bind_tab_sort( ( path = `ID` ) )
                                        act = ls_req-t_sort ).
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_if_client=>ty_t_bind_tab_filter( ( group = 1 path = `NAME` operator = `Contains` value1 = `ab` ) )
        act = ls_req-t_filter ).

  ENDMETHOD.

  METHOD request_unknown_reason.

    " what the app cannot tell apart is a request for more rows
    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request(
        VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `SOMETHING` ) ( `10` ) ( `5` ) ( `[{"PATH":"NAME"}]` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-more
                                        act = ls_req-reason ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_initial( ls_req-t_sort ).

  ENDMETHOD.

  METHOD request_bad_counts.

    " a count the browser sent wrong is 0 - never a dump
    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request(
        VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `MORE` ) ( `1 0` ) ( `9999999999` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-top ).

    ls_req = z2ui5_cl_ui5_srv_window=>request( VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ( `MORE` ) ( `-5` ) ( ` 7 ` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = ls_req-top ).

  ENDMETHOD.

  METHOD request_empty.

    DATA(ls_req) = z2ui5_cl_ui5_srv_window=>request( VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( ls_req-path ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-more
                                        act = ls_req-reason ).

  ENDMETHOD.

  METHOD event.

    cl_abap_unit_assert=>assert_equals( exp = `ROWS`
                                        act = z2ui5_cl_ui5_srv_window=>event( VALUE #( ( `/MT_ROWS` ) ( `ROWS` ) ) ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>event( VALUE #( ( `/MT_ROWS` ) ) ) ).

  ENDMETHOD.

  METHOD parse_sort.

    DATA(lt_sort) = z2ui5_cl_ui5_srv_window=>parse_sort( `[{"PATH":"name","DESCENDING":true},{"PATH":"ID"},{"PATH":""}]` ).
    cl_abap_unit_assert=>assert_equals( exp = VALUE z2ui5_if_client=>ty_t_bind_tab_sort( ( path = `NAME` descending = abap_true )
                                                                                         ( path = `ID` ) )
                                        act = lt_sort ).

    " eleven sorters keep the order they came in - ajson names the array
    " members as text, and `10` sorts before `2` there
    DATA(lv_json) = `[`.
    DO 11 TIMES.
      IF sy-index > 1.
        lv_json = lv_json && `,`.
      ENDIF.
      lv_json = lv_json && |\{"PATH":"C{ sy-index }"\}|.
    ENDDO.
    lv_json = lv_json && `]`.
    lt_sort = z2ui5_cl_ui5_srv_window=>parse_sort( lv_json ).
    cl_abap_unit_assert=>assert_equals( exp = 11
                                        act = lines( lt_sort ) ).
    cl_abap_unit_assert=>assert_equals( exp = `C2`
                                        act = lt_sort[ 2 ]-path ).
    cl_abap_unit_assert=>assert_equals( exp = `C10`
                                        act = lt_sort[ 10 ]-path ).
    cl_abap_unit_assert=>assert_equals( exp = `C11`
                                        act = lt_sort[ 11 ]-path ).

  ENDMETHOD.

  METHOD parse_filter.

    DATA(lt_filter) = z2ui5_cl_ui5_srv_window=>parse_filter(
        `[[["NAME","Contains","ab"],["NAME","EQ","x"]],[["PRICE","BT",1,9.5]]]` ).
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE z2ui5_if_client=>ty_t_bind_tab_filter(
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

ENDCLASS.
