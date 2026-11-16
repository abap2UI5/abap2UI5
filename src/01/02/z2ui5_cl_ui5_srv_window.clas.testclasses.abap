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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

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

    DATA temp1 TYPE ltcl_test=>ty_t_row.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    CLEAR temp2.
    temp2-id = 1.
    temp2-name = `banana`.
    temp2-price = `3.50`.
    temp2-date = `20260105`.
    temp2-flag = abap_true.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-id = 2.
    temp2-name = `Apple`.
    temp2-price = `12.00`.
    temp2-date = `20260301`.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-id = 3.
    temp2-name = `cherry`.
    temp2-price = `0.99`.
    temp2-date = `20251231`.
    temp2-flag = abap_true.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-id = 4.
    temp2-name = `apple`.
    temp2-price = `12.00`.
    temp2-date = `20260210`.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-id = 5.
    temp2-name = `Date`.
    temp2-price = `7.25`.
    temp2-date = `20260105`.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.

  ENDMETHOD.

  METHOD index_identity.

    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp3 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    lt_index = z2ui5_cl_ui5_srv_window=>index( rows( ) ).

    CLEAR temp3.
    INSERT 1 INTO TABLE temp3.
    INSERT 2 INTO TABLE temp3.
    INSERT 3 INTO TABLE temp3.
    INSERT 4 INTO TABLE temp3.
    INSERT 5 INTO TABLE temp3.
    cl_abap_unit_assert=>assert_equals( exp = temp3
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_text.

    " case-insensitive; Apple and apple keep the order of the table
    DATA temp5 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp7 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp5.

    temp6-path = `NAME`.
    INSERT temp6 INTO TABLE temp5.

    lt_index = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = temp5 ).

    CLEAR temp7.
    INSERT 2 INTO TABLE temp7.
    INSERT 4 INTO TABLE temp7.
    INSERT 1 INTO TABLE temp7.
    INSERT 3 INTO TABLE temp7.
    INSERT 5 INTO TABLE temp7.
    cl_abap_unit_assert=>assert_equals( exp = temp7
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_number_descending.

    DATA temp9 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp10 LIKE LINE OF temp9.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp11 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp9.

    temp10-path = `PRICE`.
    temp10-descending = abap_true.
    INSERT temp10 INTO TABLE temp9.

    lt_index = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = temp9 ).

    CLEAR temp11.
    INSERT 2 INTO TABLE temp11.
    INSERT 4 INTO TABLE temp11.
    INSERT 5 INTO TABLE temp11.
    INSERT 1 INTO TABLE temp11.
    INSERT 3 INTO TABLE temp11.
    cl_abap_unit_assert=>assert_equals( exp = temp11
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_stable_two_keys.

    " by date, the two rows of 2026-01-05 then by name descending
    DATA temp13 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp14 LIKE LINE OF temp13.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp15 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp13.

    CLEAR temp14.
    temp14-path = `DATE`.
    INSERT temp14 INTO TABLE temp13.
    CLEAR temp14.
    temp14-path = `NAME`.
    temp14-descending = abap_true.
    INSERT temp14 INTO TABLE temp13.

    lt_index = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = temp13 ).

    CLEAR temp15.
    INSERT 3 INTO TABLE temp15.
    INSERT 5 INTO TABLE temp15.
    INSERT 1 INTO TABLE temp15.
    INSERT 4 INTO TABLE temp15.
    INSERT 2 INTO TABLE temp15.
    cl_abap_unit_assert=>assert_equals( exp = temp15
                                        act = lt_index ).

  ENDMETHOD.

  METHOD sort_unknown_path.

    DATA temp17 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp18 LIKE LINE OF temp17.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp19 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp17.

    temp18-path = `NOPE`.
    INSERT temp18 INTO TABLE temp17.

    lt_index = z2ui5_cl_ui5_srv_window=>index( tab    = rows( )
                                                     t_sort = temp17 ).

    CLEAR temp19.
    INSERT 1 INTO TABLE temp19.
    INSERT 2 INTO TABLE temp19.
    INSERT 3 INTO TABLE temp19.
    INSERT 4 INTO TABLE temp19.
    INSERT 5 INTO TABLE temp19.
    cl_abap_unit_assert=>assert_equals( exp = temp19
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_contains.

    DATA temp21 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp22 LIKE LINE OF temp21.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp23 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp25 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp26 LIKE LINE OF temp25.
    DATA temp27 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp29 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp30 LIKE LINE OF temp29.
    DATA temp31 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp21.

    temp22-group = 1.
    temp22-path = `NAME`.
    temp22-operator = `Contains`.
    temp22-value1 = `PP`.
    INSERT temp22 INTO TABLE temp21.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp21 ).

    CLEAR temp23.
    INSERT 2 INTO TABLE temp23.
    INSERT 4 INTO TABLE temp23.
    cl_abap_unit_assert=>assert_equals( exp = temp23
                                        act = lt_index ).


    CLEAR temp25.

    temp26-group = 1.
    temp26-path = `NAME`.
    temp26-operator = `StartsWith`.
    temp26-value1 = `ch`.
    INSERT temp26 INTO TABLE temp25.
    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp25 ).

    CLEAR temp27.
    INSERT 3 INTO TABLE temp27.
    cl_abap_unit_assert=>assert_equals( exp = temp27
                                        act = lt_index ).


    CLEAR temp29.

    temp30-group = 1.
    temp30-path = `NAME`.
    temp30-operator = `NotEndsWith`.
    temp30-value1 = `e`.
    INSERT temp30 INTO TABLE temp29.
    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp29 ).

    CLEAR temp31.
    INSERT 1 INTO TABLE temp31.
    INSERT 3 INTO TABLE temp31.
    cl_abap_unit_assert=>assert_equals( exp = temp31
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_number.

    DATA temp33 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp34 LIKE LINE OF temp33.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp35 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp37 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp38 LIKE LINE OF temp37.
    DATA temp39 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp33.

    temp34-group = 1.
    temp34-path = `PRICE`.
    temp34-operator = `GT`.
    temp34-value1 = `5`.
    INSERT temp34 INTO TABLE temp33.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp33 ).

    CLEAR temp35.
    INSERT 2 INTO TABLE temp35.
    INSERT 4 INTO TABLE temp35.
    INSERT 5 INTO TABLE temp35.
    cl_abap_unit_assert=>assert_equals( exp = temp35
                                        act = lt_index ).


    CLEAR temp37.

    temp38-group = 1.
    temp38-path = `PRICE`.
    temp38-operator = `EQ`.
    temp38-value1 = `12`.
    INSERT temp38 INTO TABLE temp37.
    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp37 ).

    CLEAR temp39.
    INSERT 2 INTO TABLE temp39.
    INSERT 4 INTO TABLE temp39.
    cl_abap_unit_assert=>assert_equals( exp = temp39
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_between_date.

    " the browser writes a date as the model carries it, yyyy-MM-dd
    DATA temp41 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp42 LIKE LINE OF temp41.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp43 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp45 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp46 LIKE LINE OF temp45.
    DATA temp47 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp41.

    temp42-group = 1.
    temp42-path = `DATE`.
    temp42-operator = `BT`.
    temp42-value1 = `2026-01-01`.
    temp42-value2 = `2026-02-28`.
    INSERT temp42 INTO TABLE temp41.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp41 ).

    CLEAR temp43.
    INSERT 1 INTO TABLE temp43.
    INSERT 4 INTO TABLE temp43.
    INSERT 5 INTO TABLE temp43.
    cl_abap_unit_assert=>assert_equals( exp = temp43
                                        act = lt_index ).


    CLEAR temp45.

    temp46-group = 1.
    temp46-path = `DATE`.
    temp46-operator = `NB`.
    temp46-value1 = `2026-01-01`.
    temp46-value2 = `2026-02-28`.
    INSERT temp46 INTO TABLE temp45.
    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp45 ).

    CLEAR temp47.
    INSERT 2 INTO TABLE temp47.
    INSERT 3 INTO TABLE temp47.
    cl_abap_unit_assert=>assert_equals( exp = temp47
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_or_and.

    " (name contains an OR name contains rr) AND price < 10
    DATA temp49 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp50 LIKE LINE OF temp49.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp51 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp49.

    temp50-group = 1.
    temp50-path = `NAME`.
    temp50-operator = `Contains`.
    temp50-value1 = `an`.
    INSERT temp50 INTO TABLE temp49.
    temp50-group = 1.
    temp50-path = `NAME`.
    temp50-operator = `Contains`.
    temp50-value1 = `rr`.
    INSERT temp50 INTO TABLE temp49.
    temp50-group = 2.
    temp50-path = `PRICE`.
    temp50-operator = `LT`.
    temp50-value1 = `10`.
    INSERT temp50 INTO TABLE temp49.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp49 ).

    CLEAR temp51.
    INSERT 1 INTO TABLE temp51.
    INSERT 3 INTO TABLE temp51.
    cl_abap_unit_assert=>assert_equals( exp = temp51
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_boolean.

    " the model carries an abap_bool as true / false
    DATA temp53 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp54 LIKE LINE OF temp53.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp55 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp53.

    temp54-group = 1.
    temp54-path = `FLAG`.
    temp54-operator = `EQ`.
    temp54-value1 = `true`.
    INSERT temp54 INTO TABLE temp53.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp53 ).

    CLEAR temp55.
    INSERT 1 INTO TABLE temp55.
    INSERT 3 INTO TABLE temp55.
    cl_abap_unit_assert=>assert_equals( exp = temp55
                                        act = lt_index ).

  ENDMETHOD.

  METHOD filter_unknown_path.

    DATA temp57 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp58 LIKE LINE OF temp57.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp57.

    temp58-group = 1.
    temp58-path = `NOPE`.
    temp58-operator = `EQ`.
    temp58-value1 = `x`.
    INSERT temp58 INTO TABLE temp57.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_filter = temp57 ).
    cl_abap_unit_assert=>assert_initial( lt_index ).

  ENDMETHOD.

  METHOD filter_then_sort.

    DATA temp59 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp60 LIKE LINE OF temp59.
    DATA temp1 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp61 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    CLEAR temp59.

    temp60-path = `PRICE`.
    INSERT temp60 INTO TABLE temp59.

    CLEAR temp1.

    temp2-group = 1.
    temp2-path = `FLAG`.
    temp2-operator = `EQ`.
    temp2-value1 = `true`.
    INSERT temp2 INTO TABLE temp1.

    lt_index = z2ui5_cl_ui5_srv_window=>index(
        tab      = rows( )
        t_sort   = temp59
        t_filter = temp1 ).

    CLEAR temp61.
    INSERT 3 INTO TABLE temp61.
    INSERT 1 INTO TABLE temp61.
    cl_abap_unit_assert=>assert_equals( exp = temp61
                                        act = lt_index ).

  ENDMETHOD.

  METHOD rows_window.

    DATA lt_result TYPE ty_t_row.
    FIELD-SYMBOLS <result> TYPE ty_t_row.

    DATA lt_rows TYPE ltcl_test=>ty_t_row.
    DATA temp63 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA lr_rows TYPE REF TO data.
    FIELD-SYMBOLS <temp65> LIKE LINE OF lt_result.
    DATA temp66 LIKE sy-tabix.
    FIELD-SYMBOLS <temp67> LIKE LINE OF lt_result.
    DATA temp68 LIKE sy-tabix.
    lt_rows = rows( ).

    CLEAR temp63.
    INSERT 4 INTO TABLE temp63.
    INSERT 2 INTO TABLE temp63.
    INSERT 5 INTO TABLE temp63.

    lr_rows = z2ui5_cl_ui5_srv_window=>rows( tab     = lt_rows
                                                   t_index = temp63
                                                   count   = 2 ).
    ASSIGN lr_rows->* TO <result>.
    lt_result = <result>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_result ) ).


    temp66 = sy-tabix.
    READ TABLE lt_result INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = <temp65>-id ).


    temp68 = sy-tabix.
    READ TABLE lt_result INDEX 2 ASSIGNING <temp67>.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp67>-id ).

  ENDMETHOD.

  METHOD parse_sort.

    DATA lt_sort TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp69 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp70 LIKE LINE OF temp69.
    lt_sort = z2ui5_cl_ui5_srv_window=>parse_sort( `[{"PATH":"name","DESCENDING":true},{"PATH":"ID"}]` ).

    CLEAR temp69.

    CLEAR temp70.
    temp70-path = `NAME`.
    temp70-descending = abap_true.
    INSERT temp70 INTO TABLE temp69.
    CLEAR temp70.
    temp70-path = `ID`.
    INSERT temp70 INTO TABLE temp69.
    cl_abap_unit_assert=>assert_equals( exp = temp69
                                        act = lt_sort ).

  ENDMETHOD.

  METHOD parse_filter.

    DATA lt_filter TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp71 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp72 LIKE LINE OF temp71.
    lt_filter = z2ui5_cl_ui5_srv_window=>parse_filter(
        `[[["NAME","Contains","ab"],["NAME","EQ","x"]],[["PRICE","BT",1,9.5]]]` ).

    CLEAR temp71.

    CLEAR temp72.
    temp72-group = 1.
    temp72-path = `NAME`.
    temp72-operator = `Contains`.
    temp72-value1 = `ab`.
    INSERT temp72 INTO TABLE temp71.
    CLEAR temp72.
    temp72-group = 1.
    temp72-path = `NAME`.
    temp72-operator = `EQ`.
    temp72-value1 = `x`.
    INSERT temp72 INTO TABLE temp71.
    CLEAR temp72.
    temp72-group = 2.
    temp72-path = `PRICE`.
    temp72-operator = `BT`.
    temp72-value1 = `1`.
    temp72-value2 = `9.5`.
    INSERT temp72 INTO TABLE temp71.
    cl_abap_unit_assert=>assert_equals(
        exp = temp71
        act = lt_filter ).

  ENDMETHOD.

  METHOD parse_broken.

    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_sort( `[{` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `nope` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>parse_filter( `` ) ).

  ENDMETHOD.

  METHOD event_apply.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp73 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp74 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp75 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lr_attri->*.
    DATA temp4 LIKE sy-tabix.
    DATA temp77 TYPE string_table.
    FIELD-SYMBOLS <temp79> LIKE LINE OF lr_attri->*.
    DATA temp80 LIKE sy-tabix.
    DATA temp5 TYPE string_table.
    DATA temp81 LIKE temp5.
    DATA lv_count LIKE LINE OF temp81.
      DATA temp82 TYPE string_table.
      FIELD-SYMBOLS <temp84> LIKE LINE OF lr_attri->*.
      DATA temp85 LIKE sy-tabix.
    DATA temp86 TYPE string_table.
    FIELD-SYMBOLS <temp88> LIKE LINE OF lr_attri->*.
    DATA temp89 LIKE sy-tabix.

    CREATE DATA lr_attri.

    CLEAR temp73.
    temp73-name = `MT_ROWS`.
    temp73-name_client = `/MT_ROWS`.
    temp73-bind = abap_true.
    temp73-window_size = 50.
    temp73-window_count = 150.
    INSERT temp73
           INTO TABLE lr_attri->*.

    CLEAR temp74.
    temp74-name = `MV_X`.
    temp74-name_client = `/MV_X`.
    temp74-bind = abap_true.
    INSERT temp74 INTO TABLE lr_attri->*.


    CLEAR temp75.
    INSERT `/MT_ROWS` INTO TABLE temp75.
    INSERT `100` INTO TABLE temp75.
    INSERT `[{"PATH":"NAME"}]` INTO TABLE temp75.
    INSERT `[[["NAME","Contains","a"]]]` INTO TABLE temp75.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = temp75
        attri = lr_attri ) ).




    temp4 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp3>.
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = ls_attri-window_count ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_sort ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_attri-t_window_filter ) ).

    " fewer than one window is one window

    CLEAR temp77.
    INSERT `/MT_ROWS` INTO TABLE temp77.
    INSERT `3` INTO TABLE temp77.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp77
                                          attri = lr_attri ).


    temp80 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp79>.
    sy-tabix = temp80.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp79>.
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

    CLEAR temp5.
    INSERT `1 0` INTO TABLE temp5.
    INSERT `99999999999` INTO TABLE temp5.
    INSERT `-5` INTO TABLE temp5.
    INSERT `abc` INTO TABLE temp5.
    INSERT ` ` INTO TABLE temp5.

    temp81 = temp5.

    LOOP AT temp81 INTO lv_count.

      CLEAR temp82.
      INSERT `/MT_ROWS` INTO TABLE temp82.
      INSERT lv_count INTO TABLE temp82.
      z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp82
                                            attri = lr_attri ).


      temp85 = sy-tabix.
      READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp84>.
      sy-tabix = temp85.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      ls_attri = <temp84>.
      cl_abap_unit_assert=>assert_equals( exp = 50
                                          act = ls_attri-window_count
                                          msg = lv_count ).
    ENDLOOP.

    " surrounding blanks are not part of the number

    CLEAR temp86.
    INSERT `/MT_ROWS` INTO TABLE temp86.
    INSERT ` 200 ` INTO TABLE temp86.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp86
                                          attri = lr_attri ).


    temp89 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp88>.
    sy-tabix = temp89.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp88>.
    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_attri-window_count ).

  ENDMETHOD.

  METHOD event_apply_unknown.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA temp90 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp91 TYPE string_table.

    CREATE DATA lr_attri.

    CLEAR temp90.
    temp90-name = `MV_X`.
    temp90-name_client = `/MV_X`.
    temp90-bind = abap_true.
    INSERT temp90 INTO TABLE lr_attri->*.

    " a table that is not windowed is not touched

    CLEAR temp91.
    INSERT `/MV_X` INTO TABLE temp91.
    INSERT `100` INTO TABLE temp91.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp91
                                                                             attri = lr_attri ) ).

  ENDMETHOD.

  METHOD attri_sorted.

    " what z2ui5_cl_ui5_srv_bind=>window_adopt leaves after
    " window_bind_tab( val = mt_rows window = 2 t_sort = NAME t_filter = PRICE > 1 )
    DATA temp93 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp94 LIKE LINE OF temp93.
    DATA lt_sort LIKE temp93.
    DATA temp95 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp96 LIKE LINE OF temp95.
    DATA lt_filter LIKE temp95.
    DATA temp97 TYPE z2ui5_if_ui5_types=>ty_s_attri.
    CLEAR temp93.

    temp94-path = `NAME`.
    temp94-descending = abap_true.
    INSERT temp94 INTO TABLE temp93.

    lt_sort = temp93.

    CLEAR temp95.

    temp96-group = 1.
    temp96-path = `PRICE`.
    temp96-operator = `GT`.
    temp96-value1 = `1`.
    INSERT temp96 INTO TABLE temp95.

    lt_filter = temp95.
    CREATE DATA result.

    CLEAR temp97.
    temp97-name = `MT_ROWS`.
    temp97-name_client = `/MT_ROWS`.
    temp97-bind = abap_true.
    temp97-window_size = 2.
    temp97-window_count = 2.
    temp97-t_window_sort = lt_sort.
    temp97-t_window_sort_set = lt_sort.
    temp97-t_window_filter = lt_filter.
    temp97-t_window_filter_set = lt_filter.
    INSERT temp97
           INTO TABLE result->*.

  ENDMETHOD.

  METHOD event_grow_keeps_order.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA ls_before TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lr_attri->*.
    DATA temp8 LIKE sy-tabix.
    DATA temp98 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lr_attri->*.
    DATA temp10 LIKE sy-tabix.
    DATA temp11 TYPE string_table.
    DATA temp100 LIKE temp11.
    DATA lv_nothing LIKE LINE OF temp100.
      DATA temp101 TYPE string_table.
      FIELD-SYMBOLS <temp103> LIKE LINE OF lr_attri->*.
      DATA temp104 LIKE sy-tabix.
    DATA temp105 TYPE string_table.
    DATA temp107 TYPE string_table.
    FIELD-SYMBOLS <temp109> LIKE LINE OF lr_attri->*.
    DATA temp110 LIKE sy-tabix.
    DATA temp111 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp112 LIKE LINE OF temp111.

    lr_attri = attri_sorted( ).



    temp8 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_before = <temp7>.

    " "More": the path and the rows wanted, nothing else

    CLEAR temp98.
    INSERT `/MT_ROWS` INTO TABLE temp98.
    INSERT `4` INTO TABLE temp98.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp98
                                                                            attri = lr_attri ) ).



    temp10 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp9>.
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_attri-window_count ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                        act = ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).

    " an argument that is there and says nothing is the same request

    CLEAR temp11.
    INSERT `` INTO TABLE temp11.
    INSERT ` ` INTO TABLE temp11.
    INSERT `null` INTO TABLE temp11.

    temp100 = temp11.

    LOOP AT temp100 INTO lv_nothing.

      CLEAR temp101.
      INSERT `/MT_ROWS` INTO TABLE temp101.
      INSERT `6` INTO TABLE temp101.
      INSERT lv_nothing INTO TABLE temp101.
      INSERT lv_nothing INTO TABLE temp101.
      z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp101
                                            attri = lr_attri ).


      temp104 = sy-tabix.
      READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp103>.
      sy-tabix = temp104.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      ls_attri = <temp103>.
      cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                          act = ls_attri-t_window_sort
                                          msg = lv_nothing ).
      cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                          act = ls_attri-t_window_filter
                                          msg = lv_nothing ).
    ENDLOOP.

    " the user sorts by another column, then grows: the user's sort stays

    CLEAR temp105.
    INSERT `/MT_ROWS` INTO TABLE temp105.
    INSERT `2` INTO TABLE temp105.
    INSERT `[{"PATH":"ID"}]` INTO TABLE temp105.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp105
                                          attri = lr_attri ).

    CLEAR temp107.
    INSERT `/MT_ROWS` INTO TABLE temp107.
    INSERT `4` INTO TABLE temp107.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp107
                                          attri = lr_attri ).


    temp110 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp109>.
    sy-tabix = temp110.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp109>.

    CLEAR temp111.

    temp112-path = `ID`.
    INSERT temp112 INTO TABLE temp111.
    cl_abap_unit_assert=>assert_equals( exp = temp111
                                        act = ls_attri-t_window_sort ).
    " and what the app passed is still on record: the same t_sort from the
    " app keeps the user's, a different one replaces it (srv_bind)
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort_set
                                        act = ls_attri-t_window_sort_set ).

  ENDMETHOD.

  METHOD event_names_one_part.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA ls_before TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lr_attri->*.
    DATA temp14 LIKE sy-tabix.
    DATA temp113 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lr_attri->*.
    DATA temp16 LIKE sy-tabix.
    DATA temp115 TYPE string_table.
    DATA ls_sorted TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lr_attri->*.
    DATA temp18 LIKE sy-tabix.
    DATA temp117 TYPE z2ui5_if_ui5_types=>ty_t_window_sort.
    DATA temp118 LIKE LINE OF temp117.
    DATA temp119 TYPE string_table.
    FIELD-SYMBOLS <temp121> LIKE LINE OF lr_attri->*.
    DATA temp122 LIKE sy-tabix.

    lr_attri = attri_sorted( ).



    temp14 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_before = <temp13>.

    " filter( ) on the binding: the sort is not named and stays the app's

    CLEAR temp113.
    INSERT `/MT_ROWS` INTO TABLE temp113.
    INSERT `2` INTO TABLE temp113.
    INSERT `` INTO TABLE temp113.
    INSERT `[[["NAME","Contains","a"]]]` INTO TABLE temp113.
    z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = temp113
        attri = lr_attri ).



    temp16 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp15>.
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_sort
                                        act = ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_attri-t_window_filter ) ).

    " sort( ) on the binding: the filter is not named and stays

    CLEAR temp115.
    INSERT `/MT_ROWS` INTO TABLE temp115.
    INSERT `2` INTO TABLE temp115.
    INSERT `[{"PATH":"PRICE"}]` INTO TABLE temp115.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp115
                                          attri = lr_attri ).



    temp18 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_sorted = <temp17>.

    CLEAR temp117.

    temp118-path = `PRICE`.
    INSERT temp118 INTO TABLE temp117.
    cl_abap_unit_assert=>assert_equals( exp = temp117
                                        act = ls_sorted-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = ls_sorted-t_window_filter ).

    " sort( [] ) clears the sort - an empty list is said, not missing

    CLEAR temp119.
    INSERT `/MT_ROWS` INTO TABLE temp119.
    INSERT `2` INTO TABLE temp119.
    INSERT `[]` INTO TABLE temp119.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp119
                                          attri = lr_attri ).


    temp122 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp121>.
    sy-tabix = temp122.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_sorted = <temp121>.
    cl_abap_unit_assert=>assert_initial( ls_sorted-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = ls_sorted-t_window_filter ).

  ENDMETHOD.

  METHOD event_filter_anded.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA ls_before TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lr_attri->*.
    DATA temp20 LIKE sy-tabix.
    DATA temp123 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lr_attri->*.
    DATA temp22 LIKE sy-tabix.
    DATA temp125 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp126 LIKE LINE OF temp125.
    DATA temp127 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp129 TYPE string_table.
    FIELD-SYMBOLS <temp131> LIKE LINE OF lr_attri->*.
    DATA temp132 LIKE sy-tabix.
    DATA temp133 TYPE string_table.
    FIELD-SYMBOLS <temp135> LIKE LINE OF lr_attri->*.
    DATA temp136 LIKE sy-tabix.

    lr_attri = attri_sorted( ).



    temp20 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_before = <temp19>.

    " the user filters a column: ANDed with the app's PRICE > 1

    CLEAR temp123.
    INSERT `/MT_ROWS` INTO TABLE temp123.
    INSERT `2` INTO TABLE temp123.
    INSERT `` INTO TABLE temp123.
    INSERT `[[["NAME","Contains","a"],["NAME","EQ","cherry"]]]` INTO TABLE temp123.
    z2ui5_cl_ui5_srv_window=>event_apply(
        t_arg = temp123
        attri = lr_attri ).



    temp22 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp21>.

    CLEAR temp125.

    temp126-group = 1.
    temp126-path = `PRICE`.
    temp126-operator = `GT`.
    temp126-value1 = `1`.
    INSERT temp126 INTO TABLE temp125.
    temp126-group = 2.
    temp126-path = `NAME`.
    temp126-operator = `Contains`.
    temp126-value1 = `a`.
    INSERT temp126 INTO TABLE temp125.
    temp126-group = 2.
    temp126-path = `NAME`.
    temp126-operator = `EQ`.
    temp126-value1 = `cherry`.
    INSERT temp126 INTO TABLE temp125.
    cl_abap_unit_assert=>assert_equals(
        exp = temp125
        act = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter_set
                                        act = ls_attri-t_window_filter_set ).
    " cherry costs 0.99: the app's filter still holds it back. Name
    " descending: Date, banana, apple, Apple

    CLEAR temp127.
    INSERT 5 INTO TABLE temp127.
    INSERT 1 INTO TABLE temp127.
    INSERT 2 INTO TABLE temp127.
    INSERT 4 INTO TABLE temp127.
    cl_abap_unit_assert=>assert_equals(
        exp = temp127
        act = z2ui5_cl_ui5_srv_window=>index( tab      = rows( )
                                              t_sort   = ls_attri-t_window_sort
                                              t_filter = ls_attri-t_window_filter ) ).

    " growing keeps both parts

    CLEAR temp129.
    INSERT `/MT_ROWS` INTO TABLE temp129.
    INSERT `4` INTO TABLE temp129.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp129
                                          attri = lr_attri ).


    temp132 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp131>.
    sy-tabix = temp132.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = ls_attri-t_window_filter
                                        act = <temp131>-t_window_filter ).

    " the user clears the column filter: the app's part is what is left

    CLEAR temp133.
    INSERT `/MT_ROWS` INTO TABLE temp133.
    INSERT `2` INTO TABLE temp133.
    INSERT `` INTO TABLE temp133.
    INSERT `[]` INTO TABLE temp133.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp133
                                          attri = lr_attri ).


    temp136 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp135>.
    sy-tabix = temp136.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp135>.
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_initial( ls_attri-t_window_filter_ui ).

  ENDMETHOD.

  METHOD event_old_frontend.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA ls_before TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp23> LIKE LINE OF lr_attri->*.
    DATA temp24 LIKE sy-tabix.
    DATA temp137 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lr_attri->*.
    DATA temp26 LIKE sy-tabix.

    lr_attri = attri_sorted( ).



    temp24 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp23>.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_before = <temp23>.

    " its "More" re-sends the binding's own lists, empty after an app sort:
    " the sort is replaced, as it was - the app's filter is not the
    " binding's to clear and stays

    CLEAR temp137.
    INSERT `/MT_ROWS` INTO TABLE temp137.
    INSERT `4` INTO TABLE temp137.
    INSERT `[]` INTO TABLE temp137.
    INSERT `[]` INTO TABLE temp137.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp137
                                          attri = lr_attri ).



    temp26 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp25>.
    cl_abap_unit_assert=>assert_initial( ls_attri-t_window_sort ).
    cl_abap_unit_assert=>assert_equals( exp = ls_before-t_window_filter
                                        act = ls_attri-t_window_filter ).

  ENDMETHOD.

  METHOD grown_window_rows.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    FIELD-SYMBOLS <window> TYPE ty_t_row.
    DATA lt_rows TYPE ltcl_test=>ty_t_row.
    DATA ls_first TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lr_attri->*.
    DATA temp28 LIKE sy-tabix.
    DATA lt_first TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp139 TYPE string_table.
    DATA ls_attri TYPE z2ui5_if_ui5_types=>ty_s_attri.
    FIELD-SYMBOLS <temp29> LIKE LINE OF lr_attri->*.
    DATA temp30 LIKE sy-tabix.
    DATA lt_index TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    DATA temp141 TYPE z2ui5_cl_ui5_srv_window=>ty_t_index.
    FIELD-SYMBOLS <temp143> LIKE LINE OF lt_index.
    DATA temp144 LIKE sy-tabix.
    DATA lr_window TYPE REF TO data.
    FIELD-SYMBOLS <temp145> LIKE LINE OF <window>.
    DATA temp146 LIKE sy-tabix.
    FIELD-SYMBOLS <temp147> LIKE LINE OF <window>.
    DATA temp148 LIKE sy-tabix.

    " the app sorted and filtered, the list grew: the rows the response
    " sends continue the first window, and position 3 - what
    " window_get_row( ) answers and where a cell edit lands - is the third
    " row of that order, not of the table
    lr_attri = attri_sorted( ).

    lt_rows = rows( ).



    temp28 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_first = <temp27>.

    lt_first = z2ui5_cl_ui5_srv_window=>index( tab      = lt_rows
                                                     t_sort   = ls_first-t_window_sort
                                                     t_filter = ls_first-t_window_filter ).


    CLEAR temp139.
    INSERT `/MT_ROWS` INTO TABLE temp139.
    INSERT `4` INTO TABLE temp139.
    z2ui5_cl_ui5_srv_window=>event_apply( t_arg = temp139
                                          attri = lr_attri ).



    temp30 = sy-tabix.
    READ TABLE lr_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <temp29>.
    sy-tabix = temp30.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_attri = <temp29>.

    lt_index = z2ui5_cl_ui5_srv_window=>index( tab      = lt_rows
                                                     t_sort   = ls_attri-t_window_sort
                                                     t_filter = ls_attri-t_window_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lt_first
                                        act = lt_index ).

    CLEAR temp141.
    INSERT 5 INTO TABLE temp141.
    INSERT 1 INTO TABLE temp141.
    INSERT 2 INTO TABLE temp141.
    INSERT 4 INTO TABLE temp141.
    cl_abap_unit_assert=>assert_equals( exp = temp141
                                        act = lt_index ).


    temp144 = sy-tabix.
    READ TABLE lt_index INDEX 3 ASSIGNING <temp143>.
    sy-tabix = temp144.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <temp143> ).


    lr_window = z2ui5_cl_ui5_srv_window=>rows( tab     = lt_rows
                                                     t_index = lt_index
                                                     count   = ls_attri-window_count ).
    ASSIGN lr_window->* TO <window>.
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( <window> ) ).


    temp146 = sy-tabix.
    READ TABLE <window> INDEX 1 ASSIGNING <temp145>.
    sy-tabix = temp146.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Date`
                                        act = <temp145>-name ).


    temp148 = sy-tabix.
    READ TABLE <window> INDEX 3 ASSIGNING <temp147>.
    sy-tabix = temp148.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `Apple`
                                        act = <temp147>-name ).

  ENDMETHOD.

  METHOD filter_merge.

    " the groups of the two never run into each other, whatever numbers
    " they came with - the app's 0 and 0 are one group, the binding's 1 is
    " another one than the app's 1
    DATA temp149 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp150 LIKE LINE OF temp149.
    DATA temp31 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp32 LIKE LINE OF temp31.
    DATA lt_merged TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp151 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp152 LIKE LINE OF temp151.
    DATA temp153 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    DATA temp33 TYPE z2ui5_if_ui5_types=>ty_t_window_filter.
    CLEAR temp149.

    temp150-group = 0.
    temp150-path = `NAME`.
    temp150-operator = `EQ`.
    temp150-value1 = `a`.
    INSERT temp150 INTO TABLE temp149.
    temp150-group = 0.
    temp150-path = `NAME`.
    temp150-operator = `EQ`.
    temp150-value1 = `b`.
    INSERT temp150 INTO TABLE temp149.
    temp150-group = 1.
    temp150-path = `PRICE`.
    temp150-operator = `GT`.
    temp150-value1 = `1`.
    INSERT temp150 INTO TABLE temp149.

    CLEAR temp31.

    temp32-group = 1.
    temp32-path = `ID`.
    temp32-operator = `LT`.
    temp32-value1 = `9`.
    INSERT temp32 INTO TABLE temp31.

    lt_merged = z2ui5_cl_ui5_srv_window=>filter_merge(
        t_app = temp149
        t_ui  = temp31 ).

    CLEAR temp151.

    temp152-group = 1.
    temp152-path = `NAME`.
    temp152-operator = `EQ`.
    temp152-value1 = `a`.
    INSERT temp152 INTO TABLE temp151.
    temp152-group = 1.
    temp152-path = `NAME`.
    temp152-operator = `EQ`.
    temp152-value1 = `b`.
    INSERT temp152 INTO TABLE temp151.
    temp152-group = 2.
    temp152-path = `PRICE`.
    temp152-operator = `GT`.
    temp152-value1 = `1`.
    INSERT temp152 INTO TABLE temp151.
    temp152-group = 3.
    temp152-path = `ID`.
    temp152-operator = `LT`.
    temp152-value1 = `9`.
    INSERT temp152 INTO TABLE temp151.
    cl_abap_unit_assert=>assert_equals(
        exp = temp151
        act = lt_merged ).


    CLEAR temp153.

    CLEAR temp33.
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_srv_window=>filter_merge( t_app = temp153
                                                                                t_ui  = temp33 ) ).

  ENDMETHOD.

ENDCLASS.
