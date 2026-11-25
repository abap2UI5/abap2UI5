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

    DATA(lv_val) = condense( val ).
    IF lv_val IS NOT INITIAL AND lv_val CO `0123456789` AND strlen( lv_val ) <= 9.
      result = lv_val.
    ENDIF.

  ENDMETHOD.

  METHOD parse_sort.

    DATA lv_json TYPE string.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_json) = z2ui5_cl_ajson=>parse( lv_json ).
        LOOP AT li_json->members( `/` ) INTO DATA(lv_member).
          DATA(lv_sorter) = |/{ lv_member }|.
          DATA(lv_name) = to_upper( li_json->get_string( |{ lv_sorter }/PATH| ) ).
          IF lv_name IS INITIAL.
            CONTINUE.
          ENDIF.
          INSERT VALUE #( path       = lv_name
                          descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ) ) INTO TABLE result.
        ENDLOOP.
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
            INSERT VALUE #( group    = lv_group
                            path     = to_upper( li_json->get_string( |{ lv_cond }/1| ) )
                            operator = li_json->get_string( |{ lv_cond }/2| )
                            value1   = li_json->get( |{ lv_cond }/3| )
                            value2   = li_json->get( |{ lv_cond }/4| ) ) INTO TABLE result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter that cannot be read is no filter - every row
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
