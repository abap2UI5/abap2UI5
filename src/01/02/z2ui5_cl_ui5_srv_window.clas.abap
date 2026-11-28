"! The request of a windowed table (window_bind_tab( )) as the app reads
"! it. The browser's list binding sends cs_event_window when it needs more
"! rows or was sorted or filtered; the handler turns that into the app's
"! own event with request( ) as get( )-r_event_data. Nothing else happens
"! here: the framework neither sorts nor filters nor counts the rows - the
"! app loads them, the way an OData service answers $skip, $top, $orderby
"! and $filter.
CLASS z2ui5_cl_ui5_srv_window DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! the arguments of cs_event_window as the frontend sends them
    "! (bundle/webapp/core/WindowModel.js): the model path of the table, the
    "! app's event, the reason, skip, top - then, for SORT and FILTER, the
    "! sorters and the filter groups as JSON
    CLASS-METHODS request
      IMPORTING
        t_arg         TYPE string_table
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_window_request.

    "! the app's event of a window request - the second argument
    CLASS-METHODS event
      IMPORTING
        t_arg         TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

    "! the sorters as the frontend sends them:
    "! `[{"PATH":"NAME","DESCENDING":true}, ...]`
    CLASS-METHODS parse_sort
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_bind_tab_sort.

    "! the filter as the frontend sends it - the groups (ANDed), each an
    "! array of conditions (ORed), each `[path, operator, value1, value2]`:
    "! `[[["NAME","Contains","ab"]],[["PRICE","GT",100]]]`
    CLASS-METHODS parse_filter
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_bind_tab_filter.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! a count from the browser: condensed, digits only and nine of them at
    "! most - anything else is 0. The request comes from the browser, and a
    "! value that only sizes the window must not end the request with a dump
    CLASS-METHODS count_of
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE i.

    "! a sorter's or a condition's path that can name a component of a row:
    "! not empty, and nothing but A-Z, 0-9, _ and / (a namespace, a
    "! sub-component). The app puts it into an ORDER BY or a WHERE - often a
    "! dynamic one - so a path that could not be a component is dropped here
    "! instead of reaching it as written by the browser
    CLASS-METHODS path_valid
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! an operator of the documented list (ty_s_bind_tab_filter) - the
    "! sap.ui.model.FilterOperator values; anything else is dropped
    CLASS-METHODS operator_valid
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_cl_ui5_srv_window IMPLEMENTATION.

  METHOD request.

    DATA temp38 TYPE string.
    DATA temp39 TYPE string.
    DATA temp40 TYPE string.
    DATA temp41 TYPE string.
    DATA temp42 TYPE string.
    DATA temp43 TYPE string.
    DATA temp44 TYPE string.
    DATA temp45 TYPE string.
      DATA temp46 TYPE string.
      DATA temp47 TYPE string.
      DATA temp48 TYPE string.
      DATA temp49 TYPE string.
    CLEAR temp38.

    READ TABLE t_arg INTO temp39 INDEX 1.
    IF sy-subrc = 0.
      temp38 = temp39.
    ENDIF.
    result-path   = temp38.

    CLEAR temp40.

    READ TABLE t_arg INTO temp41 INDEX 3.
    IF sy-subrc = 0.
      temp40 = temp41.
    ENDIF.
    result-reason = to_upper( condense( temp40 ) ).

    CLEAR temp42.

    READ TABLE t_arg INTO temp43 INDEX 4.
    IF sy-subrc = 0.
      temp42 = temp43.
    ENDIF.
    result-skip   = count_of( temp42 ).

    CLEAR temp44.

    READ TABLE t_arg INTO temp45 INDEX 5.
    IF sy-subrc = 0.
      temp44 = temp45.
    ENDIF.
    result-top    = count_of( temp44 ).

    " a SORT and a FILTER carry the binding's sorters AND filter - the
    " whole state of the columns - and start again from the first row
    IF result-reason = z2ui5_if_client=>cs_window_reason-sort
        OR result-reason = z2ui5_if_client=>cs_window_reason-filter.

      CLEAR temp46.

      READ TABLE t_arg INTO temp47 INDEX 6.
      IF sy-subrc = 0.
        temp46 = temp47.
      ENDIF.
      result-t_sort   = parse_sort( temp46 ).

      CLEAR temp48.

      READ TABLE t_arg INTO temp49 INDEX 7.
      IF sy-subrc = 0.
        temp48 = temp49.
      ENDIF.
      result-t_filter = parse_filter( temp48 ).
      CLEAR result-skip.
    ELSE.
      result-reason = z2ui5_if_client=>cs_window_reason-more.
    ENDIF.

  ENDMETHOD.

  METHOD event.

    DATA temp50 TYPE string.
    DATA temp51 TYPE string.
    CLEAR temp50.

    READ TABLE t_arg INTO temp51 INDEX 2.
    IF sy-subrc = 0.
      temp50 = temp51.
    ENDIF.
    result = temp50.

  ENDMETHOD.

  METHOD count_of.

    IF z2ui5_cl_ui5_util_context=>check_int_digits( val ) = abap_true.
      result = condense( val ).
    ENDIF.

  ENDMETHOD.

  METHOD parse_sort.

    DATA lv_json  TYPE string.
    DATA lv_index TYPE i.
        DATA li_json TYPE REF TO z2ui5_cl_ui5_ajs.
        DATA lv_count TYPE i.
          DATA lv_sorter TYPE string.
          DATA lv_name TYPE string.
          DATA temp52 TYPE z2ui5_if_client=>ty_s_bind_tab_sort.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ui5_ajs=>parse( lv_json ).
        " by index, not over members( ): ajson sorts the member names as
        " text, so an eleventh sorter (`10`) came before the third (`2`)

        lv_count = lines( li_json->members( `/` ) ).
        WHILE lv_index < lv_count.
          lv_index = lv_index + 1.

          lv_sorter = |/{ lv_index }|.

          lv_name = to_upper( li_json->get_string( |{ lv_sorter }/PATH| ) ).
          IF path_valid( lv_name ) = abap_false.
            CONTINUE.
          ENDIF.

          CLEAR temp52.
          temp52-path = lv_name.
          temp52-descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ).
          INSERT temp52 INTO TABLE result.
        ENDWHILE.
      CATCH cx_root.
        " a sort that cannot be read is no sort - the app's own order
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD parse_filter.

    DATA lv_json  TYPE string.
    DATA lv_group TYPE i.
        DATA li_json TYPE REF TO z2ui5_cl_ui5_ajs.
        DATA temp53 TYPE string_table.
        DATA lv_g LIKE LINE OF temp53.
          DATA temp54 TYPE string_table.
          DATA lv_c LIKE LINE OF temp54.
            DATA lv_cond TYPE string.
            DATA lv_path TYPE string.
            DATA lv_operator TYPE string.
            DATA temp55 TYPE z2ui5_if_client=>ty_s_bind_tab_filter.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ui5_ajs=>parse( lv_json ).

        temp53 = li_json->members( `/` ).

        LOOP AT temp53 INTO lv_g.
          lv_group = lv_group + 1.

          temp54 = li_json->members( |/{ lv_g }| ).

          LOOP AT temp54 INTO lv_c.

            lv_cond = |/{ lv_g }/{ lv_c }|.

            lv_path = to_upper( li_json->get_string( |{ lv_cond }/1| ) ).

            lv_operator = li_json->get_string( |{ lv_cond }/2| ).
            " path and operator are the browser's, and the app builds its
            " WHERE from them: a condition that names no component or no
            " documented operator is no condition
            IF path_valid( lv_path ) = abap_false OR operator_valid( lv_operator ) = abap_false.
              CONTINUE.
            ENDIF.

            CLEAR temp55.
            temp55-group = lv_group.
            temp55-path = lv_path.
            temp55-operator = lv_operator.
            temp55-value1 = li_json->get( |{ lv_cond }/3| ).
            temp55-value2 = li_json->get( |{ lv_cond }/4| ).
            INSERT temp55 INTO TABLE result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter that cannot be read is no filter - every row
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD path_valid.
    DATA temp1 TYPE xsdboolean.

    IF val IS INITIAL.
      RETURN.
    ENDIF.

    temp1 = boolc( val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/` ).
    result = temp1.

  ENDMETHOD.

  METHOD operator_valid.

    CASE val.
      WHEN `EQ` OR `NE` OR `LT` OR `LE` OR `GT` OR `GE` OR `BT` OR `NB`
          OR `Contains` OR `NotContains` OR `StartsWith` OR `NotStartsWith`
          OR `EndsWith` OR `NotEndsWith`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
