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

    DATA temp28 TYPE string.
    DATA temp29 TYPE string.
    DATA temp30 TYPE string.
    DATA temp31 TYPE string.
    DATA temp32 TYPE string.
    DATA temp33 TYPE string.
    DATA temp34 TYPE string.
    DATA temp35 TYPE string.
      DATA temp36 TYPE string.
      DATA temp37 TYPE string.
      DATA temp38 TYPE string.
      DATA temp39 TYPE string.
    CLEAR temp28.

    READ TABLE t_arg INTO temp29 INDEX 1.
    IF sy-subrc = 0.
      temp28 = temp29.
    ENDIF.
    result-path   = temp28.

    CLEAR temp30.

    READ TABLE t_arg INTO temp31 INDEX 3.
    IF sy-subrc = 0.
      temp30 = temp31.
    ENDIF.
    result-reason = to_upper( condense( temp30 ) ).

    CLEAR temp32.

    READ TABLE t_arg INTO temp33 INDEX 4.
    IF sy-subrc = 0.
      temp32 = temp33.
    ENDIF.
    result-skip   = count_of( temp32 ).

    CLEAR temp34.

    READ TABLE t_arg INTO temp35 INDEX 5.
    IF sy-subrc = 0.
      temp34 = temp35.
    ENDIF.
    result-top    = count_of( temp34 ).

    " a SORT and a FILTER carry the binding's sorters AND filter - the
    " whole state of the columns - and start again from the first row
    IF result-reason = z2ui5_if_client=>cs_window_reason-sort
        OR result-reason = z2ui5_if_client=>cs_window_reason-filter.

      CLEAR temp36.

      READ TABLE t_arg INTO temp37 INDEX 6.
      IF sy-subrc = 0.
        temp36 = temp37.
      ENDIF.
      result-t_sort   = parse_sort( temp36 ).

      CLEAR temp38.

      READ TABLE t_arg INTO temp39 INDEX 7.
      IF sy-subrc = 0.
        temp38 = temp39.
      ENDIF.
      result-t_filter = parse_filter( temp38 ).
      CLEAR result-skip.
    ELSE.
      result-reason = z2ui5_if_client=>cs_window_reason-more.
    ENDIF.

  ENDMETHOD.

  METHOD event.

    DATA temp40 TYPE string.
    DATA temp41 TYPE string.
    CLEAR temp40.

    READ TABLE t_arg INTO temp41 INDEX 2.
    IF sy-subrc = 0.
      temp40 = temp41.
    ENDIF.
    result = temp40.

  ENDMETHOD.

  METHOD count_of.

    DATA lv_val TYPE string.
    lv_val = condense( val ).
    IF lv_val IS NOT INITIAL AND lv_val CO `0123456789` AND strlen( lv_val ) <= 9.
      result = lv_val.
    ENDIF.

  ENDMETHOD.

  METHOD parse_sort.

    DATA lv_json TYPE string.
        DATA li_json TYPE REF TO z2ui5_cl_ajson.
        DATA temp42 TYPE string_table.
        DATA lv_member LIKE LINE OF temp42.
          DATA lv_sorter TYPE string.
          DATA lv_name TYPE string.
          DATA temp43 TYPE z2ui5_if_client=>ty_s_bind_tab_sort.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ajson=>parse( lv_json ).

        temp42 = li_json->members( `/` ).

        LOOP AT temp42 INTO lv_member.

          lv_sorter = |/{ lv_member }|.

          lv_name = to_upper( li_json->get_string( |{ lv_sorter }/PATH| ) ).
          IF lv_name IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR temp43.
          temp43-path = lv_name.
          temp43-descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ).
          INSERT temp43 INTO TABLE result.
        ENDLOOP.
      CATCH cx_root.
        " a sort that cannot be read is no sort - the app's own order
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD parse_filter.

    DATA lv_json  TYPE string.
    DATA lv_group TYPE i.
        DATA li_json TYPE REF TO z2ui5_cl_ajson.
        DATA temp44 TYPE string_table.
        DATA lv_g LIKE LINE OF temp44.
          DATA temp45 TYPE string_table.
          DATA lv_c LIKE LINE OF temp45.
            DATA lv_cond TYPE string.
            DATA temp46 TYPE z2ui5_if_client=>ty_s_bind_tab_filter.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ajson=>parse( lv_json ).

        temp44 = li_json->members( `/` ).

        LOOP AT temp44 INTO lv_g.
          lv_group = lv_group + 1.

          temp45 = li_json->members( |/{ lv_g }| ).

          LOOP AT temp45 INTO lv_c.

            lv_cond = |/{ lv_g }/{ lv_c }|.

            CLEAR temp46.
            temp46-group = lv_group.
            temp46-path = to_upper( li_json->get_string( |{ lv_cond }/1| ) ).
            temp46-operator = li_json->get_string( |{ lv_cond }/2| ).
            temp46-value1 = li_json->get( |{ lv_cond }/3| ).
            temp46-value2 = li_json->get( |{ lv_cond }/4| ).
            INSERT temp46 INTO TABLE result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter that cannot be read is no filter - every row
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
