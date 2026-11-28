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

    DATA temp1 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    CLEAR temp1.
    INSERT `/MT_ROWS` INTO TABLE temp1.
    INSERT `ROWS` INTO TABLE temp1.
    INSERT `MORE` INTO TABLE temp1.
    INSERT `100` INTO TABLE temp1.
    INSERT `50` INTO TABLE temp1.

    ls_req = z2ui5_cl_ui5_srv_window=>request(
        temp1 ).

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
    DATA temp3 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    DATA temp5 TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp6 LIKE LINE OF temp5.
    CLEAR temp3.
    INSERT `/MT_ROWS` INTO TABLE temp3.
    INSERT `ROWS` INTO TABLE temp3.
    INSERT `SORT` INTO TABLE temp3.
    INSERT `100` INTO TABLE temp3.
    INSERT `50` INTO TABLE temp3.
    INSERT `[{"PATH":"NAME","DESCENDING":true}]` INTO TABLE temp3.

    ls_req = z2ui5_cl_ui5_srv_window=>request(
        temp3 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-sort
                                        act = ls_req-reason ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 50
                                        act = ls_req-top ).

    CLEAR temp5.

    temp6-path = `NAME`.
    temp6-descending = abap_true.
    INSERT temp6 INTO TABLE temp5.
    cl_abap_unit_assert=>assert_equals( exp = temp5
                                        act = ls_req-t_sort ).

  ENDMETHOD.

  METHOD request_filter.

    DATA temp7 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    DATA temp9 TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp10 LIKE LINE OF temp9.
    DATA temp11 TYPE z2ui5_if_client=>ty_t_bind_tab_filter.
    DATA temp12 LIKE LINE OF temp11.
    CLEAR temp7.
    INSERT `/MT_ROWS` INTO TABLE temp7.
    INSERT `ROWS` INTO TABLE temp7.
    INSERT `FILTER` INTO TABLE temp7.
    INSERT `0` INTO TABLE temp7.
    INSERT `50` INTO TABLE temp7.
    INSERT `[{"PATH":"ID"}]` INTO TABLE temp7.
    INSERT `[[["NAME","Contains","ab"]]]` INTO TABLE temp7.

    ls_req = z2ui5_cl_ui5_srv_window=>request(
        temp7 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-filter
                                        act = ls_req-reason ).
    " the sorters of the binding come along - the whole state of the columns

    CLEAR temp9.

    temp10-path = `ID`.
    INSERT temp10 INTO TABLE temp9.
    cl_abap_unit_assert=>assert_equals( exp = temp9
                                        act = ls_req-t_sort ).

    CLEAR temp11.

    temp12-group = 1.
    temp12-path = `NAME`.
    temp12-operator = `Contains`.
    temp12-value1 = `ab`.
    INSERT temp12 INTO TABLE temp11.
    cl_abap_unit_assert=>assert_equals(
        exp = temp11
        act = ls_req-t_filter ).

  ENDMETHOD.

  METHOD request_unknown_reason.

    " what the app cannot tell apart is a request for more rows
    DATA temp13 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    CLEAR temp13.
    INSERT `/MT_ROWS` INTO TABLE temp13.
    INSERT `ROWS` INTO TABLE temp13.
    INSERT `SOMETHING` INTO TABLE temp13.
    INSERT `10` INTO TABLE temp13.
    INSERT `5` INTO TABLE temp13.
    INSERT `[{"PATH":"NAME"}]` INTO TABLE temp13.

    ls_req = z2ui5_cl_ui5_srv_window=>request(
        temp13 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-more
                                        act = ls_req-reason ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_initial( ls_req-t_sort ).

  ENDMETHOD.

  METHOD request_bad_counts.

    " a count the browser sent wrong is 0 - never a dump
    DATA temp15 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    DATA temp17 TYPE string_table.
    CLEAR temp15.
    INSERT `/MT_ROWS` INTO TABLE temp15.
    INSERT `ROWS` INTO TABLE temp15.
    INSERT `MORE` INTO TABLE temp15.
    INSERT `1 0` INTO TABLE temp15.
    INSERT `9999999999` INTO TABLE temp15.

    ls_req = z2ui5_cl_ui5_srv_window=>request(
        temp15 ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-top ).


    CLEAR temp17.
    INSERT `/MT_ROWS` INTO TABLE temp17.
    INSERT `ROWS` INTO TABLE temp17.
    INSERT `MORE` INTO TABLE temp17.
    INSERT `-5` INTO TABLE temp17.
    INSERT ` 7 ` INTO TABLE temp17.
    ls_req = z2ui5_cl_ui5_srv_window=>request( temp17 ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_req-skip ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = ls_req-top ).

  ENDMETHOD.

  METHOD request_empty.

    DATA temp19 TYPE string_table.
    DATA ls_req TYPE z2ui5_if_client=>ty_s_window_request.
    CLEAR temp19.

    ls_req = z2ui5_cl_ui5_srv_window=>request( temp19 ).

    cl_abap_unit_assert=>assert_initial( ls_req-path ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_window_reason-more
                                        act = ls_req-reason ).

  ENDMETHOD.

  METHOD event.

    DATA temp20 TYPE string_table.
    DATA temp22 TYPE string_table.
    CLEAR temp20.
    INSERT `/MT_ROWS` INTO TABLE temp20.
    INSERT `ROWS` INTO TABLE temp20.
    cl_abap_unit_assert=>assert_equals( exp = `ROWS`
                                        act = z2ui5_cl_ui5_srv_window=>event( temp20 ) ).

    CLEAR temp22.
    INSERT `/MT_ROWS` INTO TABLE temp22.
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>event( temp22 ) ).

  ENDMETHOD.

  METHOD parse_sort.

    DATA lt_sort TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp24 TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp25 LIKE LINE OF temp24.
    DATA lv_json TYPE string.
    FIELD-SYMBOLS <temp26> LIKE LINE OF lt_sort.
    DATA temp27 LIKE sy-tabix.
    FIELD-SYMBOLS <temp28> LIKE LINE OF lt_sort.
    DATA temp29 LIKE sy-tabix.
    FIELD-SYMBOLS <temp30> LIKE LINE OF lt_sort.
    DATA temp31 LIKE sy-tabix.
    lt_sort = z2ui5_cl_ui5_srv_window=>parse_sort( `[{"PATH":"name","DESCENDING":true},{"PATH":"ID"},{"PATH":""}]` ).

    CLEAR temp24.

    CLEAR temp25.
    temp25-path = `NAME`.
    temp25-descending = abap_true.
    INSERT temp25 INTO TABLE temp24.
    CLEAR temp25.
    temp25-path = `ID`.
    INSERT temp25 INTO TABLE temp24.
    cl_abap_unit_assert=>assert_equals( exp = temp24
                                        act = lt_sort ).

    " eleven sorters keep the order they came in - ajson names the array
    " members as text, and `10` sorts before `2` there

    lv_json = `[`.
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


    temp27 = sy-tabix.
    READ TABLE lt_sort INDEX 2 ASSIGNING <temp26>.
    sy-tabix = temp27.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `C2`
                                        act = <temp26>-path ).


    temp29 = sy-tabix.
    READ TABLE lt_sort INDEX 10 ASSIGNING <temp28>.
    sy-tabix = temp29.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `C10`
                                        act = <temp28>-path ).


    temp31 = sy-tabix.
    READ TABLE lt_sort INDEX 11 ASSIGNING <temp30>.
    sy-tabix = temp31.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `C11`
                                        act = <temp30>-path ).

  ENDMETHOD.

  METHOD parse_filter.

    DATA lt_filter TYPE z2ui5_if_client=>ty_t_bind_tab_filter.
    DATA temp32 TYPE z2ui5_if_client=>ty_t_bind_tab_filter.
    DATA temp33 LIKE LINE OF temp32.
    DATA temp34 TYPE z2ui5_if_client=>ty_t_bind_tab_filter.
    DATA temp35 LIKE LINE OF temp34.
    DATA lt_sort TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp36 TYPE z2ui5_if_client=>ty_t_bind_tab_sort.
    DATA temp37 LIKE LINE OF temp36.
    lt_filter = z2ui5_cl_ui5_srv_window=>parse_filter(
        `[[["NAME","Contains","ab"],["NAME","EQ","x"]],[["PRICE","BT",1,9.5]]]` ).

    CLEAR temp32.

    CLEAR temp33.
    temp33-group = 1.
    temp33-path = `NAME`.
    temp33-operator = `Contains`.
    temp33-value1 = `ab`.
    INSERT temp33 INTO TABLE temp32.
    CLEAR temp33.
    temp33-group = 1.
    temp33-path = `NAME`.
    temp33-operator = `EQ`.
    temp33-value1 = `x`.
    INSERT temp33 INTO TABLE temp32.
    CLEAR temp33.
    temp33-group = 2.
    temp33-path = `PRICE`.
    temp33-operator = `BT`.
    temp33-value1 = `1`.
    temp33-value2 = `9.5`.
    INSERT temp33 INTO TABLE temp32.
    cl_abap_unit_assert=>assert_equals(
        exp = temp32
        act = lt_filter ).

    " path and operator are the browser's and end up in the app's WHERE:
    " a path that cannot name a component and an operator off the list are
    " dropped, the rest of the filter stays
    lt_filter = z2ui5_cl_ui5_srv_window=>parse_filter(
        `[[["NAME) OR (1 = 1","EQ","x"],["NAME","EQ' OR 'x","y"],["NAME","EQ","z"]],` &&
        `[["","GT",1],["/NS/F","GE",2]]]` ).

    CLEAR temp34.

    temp35-group = 1.
    temp35-path = `NAME`.
    temp35-operator = `EQ`.
    temp35-value1 = `z`.
    INSERT temp35 INTO TABLE temp34.
    temp35-group = 2.
    temp35-path = `/NS/F`.
    temp35-operator = `GE`.
    temp35-value1 = `2`.
    INSERT temp35 INTO TABLE temp34.
    cl_abap_unit_assert=>assert_equals(
        exp = temp34
        act = lt_filter ).


    lt_sort = z2ui5_cl_ui5_srv_window=>parse_sort( `[{"PATH":"NAME DESCENDING, (SELECT"},{"PATH":"id"}]` ).

    CLEAR temp36.

    temp37-path = `ID`.
    INSERT temp37 INTO TABLE temp36.
    cl_abap_unit_assert=>assert_equals( exp = temp36
                                        act = lt_sort ).

  ENDMETHOD.

  METHOD parse_broken.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_sort( `[{` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `nope` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `` ) ).

  ENDMETHOD.

ENDCLASS.
