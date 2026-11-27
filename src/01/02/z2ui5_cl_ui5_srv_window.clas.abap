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

    result-path   = VALUE string( t_arg[ 1 ] OPTIONAL ).
    result-reason = to_upper( condense( VALUE string( t_arg[ 3 ] OPTIONAL ) ) ).
    result-skip   = count_of( VALUE string( t_arg[ 4 ] OPTIONAL ) ).
    result-top    = count_of( VALUE string( t_arg[ 5 ] OPTIONAL ) ).

    " a SORT and a FILTER carry the binding's sorters AND filter - the
    " whole state of the columns - and start again from the first row
    IF result-reason = z2ui5_if_client=>cs_window_reason-sort
        OR result-reason = z2ui5_if_client=>cs_window_reason-filter.
      result-t_sort   = parse_sort( VALUE string( t_arg[ 6 ] OPTIONAL ) ).
      result-t_filter = parse_filter( VALUE string( t_arg[ 7 ] OPTIONAL ) ).
      CLEAR result-skip.
    ELSE.
      result-reason = z2ui5_if_client=>cs_window_reason-more.
    ENDIF.

  ENDMETHOD.

  METHOD event.

    result = VALUE string( t_arg[ 2 ] OPTIONAL ).

  ENDMETHOD.

  METHOD count_of.

    IF z2ui5_cl_ui5_util_context=>check_int_digits( val ) = abap_true.
      result = condense( val ).
    ENDIF.

  ENDMETHOD.

  METHOD parse_sort.

    DATA lv_json  TYPE string.
    DATA lv_index TYPE i.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_json) = z2ui5_cl_ajson=>parse( lv_json ).
        " by index, not over members( ): ajson sorts the member names as
        " text, so an eleventh sorter (`10`) came before the third (`2`)
        DATA(lv_count) = lines( li_json->members( `/` ) ).
        WHILE lv_index < lv_count.
          lv_index = lv_index + 1.
          DATA(lv_sorter) = |/{ lv_index }|.
          DATA(lv_name) = to_upper( li_json->get_string( |{ lv_sorter }/PATH| ) ).
          IF path_valid( lv_name ) = abap_false.
            CONTINUE.
          ENDIF.
          INSERT VALUE #( path       = lv_name
                          descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ) ) INTO TABLE result.
        ENDWHILE.
      CATCH cx_root.
        " a sort that cannot be read is no sort - the app's own order
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD parse_filter.

    DATA lv_json  TYPE string.
    DATA lv_group TYPE i.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_json) = z2ui5_cl_ajson=>parse( lv_json ).
        LOOP AT li_json->members( `/` ) INTO DATA(lv_g).
          lv_group = lv_group + 1.
          LOOP AT li_json->members( |/{ lv_g }| ) INTO DATA(lv_c).
            DATA(lv_cond) = |/{ lv_g }/{ lv_c }|.
            DATA(lv_path) = to_upper( li_json->get_string( |{ lv_cond }/1| ) ).
            DATA(lv_operator) = li_json->get_string( |{ lv_cond }/2| ).
            " path and operator are the browser's, and the app builds its
            " WHERE from them: a condition that names no component or no
            " documented operator is no condition
            IF path_valid( lv_path ) = abap_false OR operator_valid( lv_operator ) = abap_false.
              CONTINUE.
            ENDIF.
            INSERT VALUE #( group    = lv_group
                            path     = lv_path
                            operator = lv_operator
                            value1   = li_json->get( |{ lv_cond }/3| )
                            value2   = li_json->get( |{ lv_cond }/4| ) ) INTO TABLE result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter that cannot be read is no filter - every row
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD path_valid.

    IF val IS INITIAL.
      RETURN.
    ENDIF.
    result = xsdbool( val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/` ).

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
