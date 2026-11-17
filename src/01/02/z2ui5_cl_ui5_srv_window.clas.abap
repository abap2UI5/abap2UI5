"! The windowed table of window_bind_tab( ): the browser holds the first
"! rows of the table in the order its list binding asked for - sorted and
"! filtered here, on the server - and asks for more as it scrolls or grows.
"!
"! The order is never stored: index( ) computes it from the table and the
"! sorters and the filter kept on the attribute (ty_s_attri-t_window_*)
"! whenever it is needed - for the rows a response sends, and for the row
"! a delta of the next request means. Between the two the table does not
"! change (the delta is applied before main( ) runs), and the sort is
"! stable, so both see the same order. Row n of the client array is row
"! index[ n + 1 ] of the table.
"!
"! The sorters and the filter are kept HERE, on the attribute, and nowhere
"! else - one order per windowed table. Who may change it: the app, with
"! t_sort / t_filter of window_bind_tab( ) when they differ from the ones it
"! passed before (z2ui5_cl_ui5_srv_bind=>window_adopt), and the list binding
"! in the browser, when sort( ) or filter( ) is called on it (event_apply).
"! A request that asks for more rows is neither: it means more rows of the
"! SAME order. The sort has one owner at a time - the last one to set it.
"! The filter has two parts, the app's and the binding's, which are ANDed
"! (filter_merge): a column filter the user sets narrows what the app
"! filtered, and neither side drops the other's.
"!
"! The sort is a merge sort of the row numbers and the comparison is done
"! on keys taken from the rows once: SORT ... BY (name) sorts nothing in
"! the transpiled runtime, and a comparison per pair that reads the cells
"! through ASSIGN COMPONENT would read every cell log2( n ) times.
CLASS z2ui5_cl_ui5_srv_window DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_t_index TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    "! the row numbers of tab in the order the browser sees them: the rows
    "! the filter lets through, sorted by the sorters. A sorter or a
    "! condition naming no component of the row is ignored (a sorter) or
    "! matches nothing (a condition)
    CLASS-METHODS index
      IMPORTING
        tab           TYPE STANDARD TABLE
        t_sort        TYPE z2ui5_if_ui5_types=>ty_t_window_sort OPTIONAL
        t_filter      TYPE z2ui5_if_ui5_types=>ty_t_window_filter OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_index.

    "! the rows index[ 1 ] ... index[ count ] of tab, as a table of the
    "! type of tab - what the response sends for the attribute
    CLASS-METHODS rows
      IMPORTING
        tab           TYPE STANDARD TABLE
        t_index       TYPE ty_t_index
        count         TYPE i
      RETURNING
        VALUE(result) TYPE REF TO data.

    "! the window event (z2ui5_if_ui5_types=>cs_event_window): t_arg is the
    "! model path of the table and the rows wanted, then - only when the
    "! binding was told to sort or to filter - the sorters and the filter
    "! groups as JSON. Applied to the windowed attribute with that path;
    "! abap_false when there is none
    CLASS-METHODS event_apply
      IMPORTING
        t_arg         TYPE string_table
        attri         TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the filter index( ) reads: the app's conditions and the ones of the
    "! list binding, ANDed - the groups of both, numbered anew from 1 in the
    "! order they come, so a group of one never runs into a group of the other
    CLASS-METHODS filter_merge
      IMPORTING
        t_app         TYPE z2ui5_if_ui5_types=>ty_t_window_filter
        t_ui          TYPE z2ui5_if_ui5_types=>ty_t_window_filter
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_window_filter.

    "! the sorters as the frontend sends them:
    "! `[{"PATH":"NAME","DESCENDING":true}, ...]`
    CLASS-METHODS parse_sort
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_window_sort.

    "! the filter as the frontend sends it - the groups (ANDed), each an
    "! array of conditions (ORed), each `[path, operator, value1, value2]`:
    "! `[[["NAME","Contains","ab"]],[["PRICE","GT",100]]]`
    CLASS-METHODS parse_filter
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_window_filter.

  PROTECTED SECTION.
  PRIVATE SECTION.
    " the kind a component is compared as: N a number, D a date, T a time,
    " B a boolean, S everything else (case-insensitive text)
    TYPES ty_kind TYPE c LENGTH 1.

    TYPES:
      BEGIN OF ty_s_key,
        num TYPE decfloat34,
        str TYPE string,
      END OF ty_s_key.
    TYPES ty_t_key TYPE STANDARD TABLE OF ty_s_key WITH DEFAULT KEY.

    " one sorter with the key of every row of the table, by row number
    TYPES:
      BEGIN OF ty_s_sort_col,
        kind       TYPE ty_kind,
        descending TYPE abap_bool,
        t_key      TYPE ty_t_key,
      END OF ty_s_sort_col.
    TYPES ty_t_sort_col TYPE STANDARD TABLE OF ty_s_sort_col WITH DEFAULT KEY.

    " one condition, its values taken apart once for every row
    TYPES:
      BEGIN OF ty_s_cond,
        group    TYPE i,
        path     TYPE string,
        kind     TYPE ty_kind,
        operator TYPE string,
        num1     TYPE decfloat34,
        num2     TYPE decfloat34,
        str1     TYPE string,
        str2     TYPE string,
        " the value as typed, upper case - what Contains and its kin look for
        text1    TYPE string,
        valid    TYPE abap_bool,
      END OF ty_s_cond.
    TYPES ty_t_cond TYPE STANDARD TABLE OF ty_s_cond WITH DEFAULT KEY.

    "! abap_true when a window request names this part of the order - a
    "! JSON array, `[]` included. Missing, empty or `null` it says nothing
    CLASS-METHODS arg_is_said
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS filter_append
      IMPORTING
        t_filter  TYPE z2ui5_if_ui5_types=>ty_t_window_filter
      CHANGING
        cv_group  TYPE i
        ct_result TYPE z2ui5_if_ui5_types=>ty_t_window_filter.

    CLASS-METHODS kind_of
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_kind.

    CLASS-METHODS line_kind
      IMPORTING
        tab           TYPE STANDARD TABLE
        path          TYPE string
      RETURNING
        VALUE(result) TYPE ty_kind.

    "! the cell as a sort key - a number in num, everything else in str
    CLASS-METHODS key_of
      IMPORTING
        val           TYPE any
        kind          TYPE ty_kind
      RETURNING
        VALUE(result) TYPE ty_s_key.

    "! the cell as the browser shows it - what Contains and its kin search
    CLASS-METHODS text_of
      IMPORTING
        val           TYPE any
        kind          TYPE ty_kind
      RETURNING
        VALUE(result) TYPE string.

    "! a value of a condition as a key of the kind of its component
    CLASS-METHODS value_key
      IMPORTING
        val           TYPE string
        kind          TYPE ty_kind
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS cond_prepare
      IMPORTING
        tab           TYPE STANDARD TABLE
        t_filter      TYPE z2ui5_if_ui5_types=>ty_t_window_filter
      RETURNING
        VALUE(result) TYPE ty_t_cond.

    CLASS-METHODS filter_row
      IMPORTING
        row           TYPE any
        t_cond        TYPE ty_t_cond
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cond_check
      IMPORTING
        row           TYPE any
        cond          TYPE ty_s_cond
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cond_check_text
      IMPORTING
        text          TYPE string
        cond          TYPE ty_s_cond
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! -1, 0 or 1: the cell against a value of the condition
    CLASS-METHODS cond_compare
      IMPORTING
        key           TYPE ty_s_key
        cond          TYPE ty_s_cond
        second        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS sort_cols
      IMPORTING
        tab           TYPE STANDARD TABLE
        t_sort        TYPE z2ui5_if_ui5_types=>ty_t_window_sort
      RETURNING
        VALUE(result) TYPE ty_t_sort_col.

    CLASS-METHODS sort_index
      IMPORTING
        t_col  TYPE ty_t_sort_col
      CHANGING
        ct_idx TYPE ty_t_index.

    CLASS-METHODS sort_merge
      IMPORTING
        t_col     TYPE ty_t_sort_col
        it_idx    TYPE ty_t_index
        iv_left   TYPE i
        iv_width  TYPE i
      CHANGING
        ct_merged TYPE ty_t_index.

    "! abap_true when row a comes after row b
    CLASS-METHODS sort_after
      IMPORTING
        t_col         TYPE ty_t_sort_col
        a             TYPE i
        b             TYPE i
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_cl_ui5_srv_window IMPLEMENTATION.

  METHOD index.

    FIELD-SYMBOLS <row> TYPE any.

    DATA lt_cond TYPE z2ui5_cl_ui5_srv_window=>ty_t_cond.
      DATA lv_row LIKE sy-tabix.
    DATA lt_col TYPE z2ui5_cl_ui5_srv_window=>ty_t_sort_col.
    lt_cond = cond_prepare( tab      = tab
                                  t_filter = t_filter ).
    LOOP AT tab ASSIGNING <row>.

      lv_row = sy-tabix.
      IF lt_cond IS INITIAL OR filter_row( row    = <row>
                                           t_cond = lt_cond ) = abap_true.
        APPEND lv_row TO result.
      ENDIF.
    ENDLOOP.

    IF t_sort IS INITIAL OR lines( result ) < 2.
      RETURN.
    ENDIF.

    lt_col = sort_cols( tab    = tab
                              t_sort = t_sort ).
    IF lt_col IS INITIAL.
      RETURN.
    ENDIF.
    sort_index( EXPORTING t_col  = lt_col
                CHANGING  ct_idx = result ).

  ENDMETHOD.

  METHOD rows.

    FIELD-SYMBOLS <result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>    TYPE any.
    DATA lv_row LIKE LINE OF t_index.

    CREATE DATA result LIKE tab.
    ASSIGN result->* TO <result>.
    " the transpiled runtime copies the rows along with CREATE DATA ... LIKE
    CLEAR <result>.


    LOOP AT t_index INTO lv_row TO count.
      READ TABLE tab INDEX lv_row ASSIGNING <row>.
      IF sy-subrc = 0.
        INSERT <row> INTO TABLE <result>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD event_apply.

    DATA lv_wanted TYPE i.

    DATA temp154 TYPE string.
    DATA temp155 TYPE string.
    DATA lv_path LIKE temp154.
    DATA temp156 TYPE string.
    DATA temp157 TYPE string.
    DATA lv_count LIKE temp156.
    DATA temp158 TYPE string.
    DATA temp159 TYPE string.
    DATA lv_sort LIKE temp158.
    DATA temp160 TYPE string.
    DATA temp161 TYPE string.
    DATA lv_filter LIKE temp160.
    DATA temp162 LIKE LINE OF attri->*.
    DATA lr_attri LIKE REF TO temp162.
    CLEAR temp154.

    READ TABLE t_arg INTO temp155 INDEX 1.
    IF sy-subrc = 0.
      temp154 = temp155.
    ENDIF.

    lv_path = temp154.

    CLEAR temp156.

    READ TABLE t_arg INTO temp157 INDEX 2.
    IF sy-subrc = 0.
      temp156 = temp157.
    ENDIF.

    lv_count = temp156.

    CLEAR temp158.

    READ TABLE t_arg INTO temp159 INDEX 3.
    IF sy-subrc = 0.
      temp158 = temp159.
    ENDIF.

    lv_sort = temp158.

    CLEAR temp160.

    READ TABLE t_arg INTO temp161 INDEX 4.
    IF sy-subrc = 0.
      temp160 = temp161.
    ENDIF.

    lv_filter = temp160.



    LOOP AT attri->* REFERENCE INTO lr_attri      "#EC CI_SORTSEQ
         WHERE bind = abap_true AND window_size > 0.
      IF lr_attri->name_client <> lv_path.
        CONTINUE.
      ENDIF.

      " A request changes the part of the order it NAMES, and a request
      " for more rows names none: the order lives on the attribute, the
      " browser is not told it, so it has nothing to send back. Every
      " request used to carry the binding's own sorters and filters and
      " they replaced what was kept here - an order the app had set with
      " t_sort / t_filter never reached the binding, so the first "More"
      " sent an empty list and the rows came back in the table's own order,
      " unfiltered, and window_get_row( ) and the next cell edit followed
      " that. Handing the order to the binding instead, to have it sent
      " back, was the alternative: it makes every request carry a copy
      " that can be stale (a request built before the response of a
      " roundtrip in which the app changed the sort would undo it) and
      " sends the filter through two conversions for nothing.
      " A sort replaces the sort, whoever set it. A filter replaces the
      " binding's part and leaves the app's, which stays ANDed. A frontend
      " from before this (a page still open over an update) names both in
      " every request: its sort still replaces, as it did, its filter is
      " only ever the binding's part
      IF arg_is_said( lv_sort ) = abap_true.
        lr_attri->t_window_sort = parse_sort( lv_sort ).
      ENDIF.
      IF arg_is_said( lv_filter ) = abap_true.
        lr_attri->t_window_filter_ui = parse_filter( lv_filter ).
        lr_attri->t_window_filter    = filter_merge( t_app = lr_attri->t_window_filter_set
                                                     t_ui  = lr_attri->t_window_filter_ui ).
      ENDIF.
      " never fewer than one window - the browser asks for the first one
      " again after a sort or a filter changed. The count comes from the
      " browser: condensed, digits only and nine of them at most, as
      " z2ui5_cl_ui5_frontend=>set_opt_int reads a number - `1 0` passed a
      " check that allowed blanks and a longer digit string overflowed, and
      " either raised out of event_apply, which runs outside every TRY, as
      " a 500 for a value that only sizes the window. A count past the rows
      " there are costs nothing: rows( ) stops at the end of the index
      lv_count = condense( lv_count ).
      IF lv_count IS NOT INITIAL AND lv_count CO `0123456789` AND strlen( lv_count ) <= 9.
        lv_wanted = lv_count.
      ENDIF.
      lr_attri->window_count = nmax( val1 = lv_wanted
                                     val2 = lr_attri->window_size ).
      result = abap_true.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

  METHOD arg_is_said.

    DATA lv_val TYPE string.
    DATA temp1 TYPE xsdboolean.
    lv_val = condense( val ).

    temp1 = boolc( lv_val IS NOT INITIAL AND lv_val <> `null` ).
    result = temp1.

  ENDMETHOD.

  METHOD filter_merge.

    DATA lv_group TYPE i.

    filter_append( EXPORTING t_filter  = t_app
                   CHANGING  cv_group  = lv_group
                             ct_result = result ).
    filter_append( EXPORTING t_filter  = t_ui
                   CHANGING  cv_group  = lv_group
                             ct_result = result ).

  ENDMETHOD.

  METHOD filter_append.

    DATA lv_last TYPE i.

    " a group is the run of conditions with one number, as filter_row( )
    " reads it - the app numbers its groups as it likes, the binding's
    " start at 1 again
    DATA ls_filter LIKE LINE OF t_filter.
    LOOP AT t_filter INTO ls_filter.
      IF sy-tabix = 1 OR ls_filter-group <> lv_last.
        cv_group = cv_group + 1.
      ENDIF.
      lv_last = ls_filter-group.
      ls_filter-group = cv_group.
      APPEND ls_filter TO ct_result.
    ENDLOOP.

  ENDMETHOD.

  METHOD parse_sort.

    DATA lv_json TYPE string.
        DATA li_json TYPE REF TO z2ui5_cl_ajson.
        DATA temp163 TYPE string_table.
        DATA lv_member LIKE LINE OF temp163.
          DATA lv_sorter TYPE string.
          DATA lv_name TYPE string.
          DATA temp164 TYPE z2ui5_if_ui5_types=>ty_s_window_sort.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ajson=>parse( lv_json ).

        temp163 = li_json->members( `/` ).

        LOOP AT temp163 INTO lv_member.

          lv_sorter = |/{ lv_member }|.

          lv_name = to_upper( li_json->get_string( |{ lv_sorter }/PATH| ) ).
          IF lv_name IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR temp164.
          temp164-path = lv_name.
          temp164-descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ).
          APPEND temp164 TO result.
        ENDLOOP.
      CATCH cx_root.
        " a sort the server cannot read is no sort - the order of the table
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD parse_filter.

    DATA lv_json  TYPE string.
    DATA lv_group TYPE i.
        DATA li_json TYPE REF TO z2ui5_cl_ajson.
        DATA temp165 TYPE string_table.
        DATA lv_g LIKE LINE OF temp165.
          DATA temp166 TYPE string_table.
          DATA lv_c LIKE LINE OF temp166.
            DATA lv_cond TYPE string.
            DATA temp167 TYPE z2ui5_if_ui5_types=>ty_s_window_filter.
    lv_json = condense( val ).
    IF lv_json IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        li_json = z2ui5_cl_ajson=>parse( lv_json ).

        temp165 = li_json->members( `/` ).

        LOOP AT temp165 INTO lv_g.
          lv_group = lv_group + 1.

          temp166 = li_json->members( |/{ lv_g }| ).

          LOOP AT temp166 INTO lv_c.

            lv_cond = |/{ lv_g }/{ lv_c }|.

            CLEAR temp167.
            temp167-group = lv_group.
            temp167-path = to_upper( li_json->get_string( |{ lv_cond }/1| ) ).
            temp167-operator = li_json->get_string( |{ lv_cond }/2| ).
            temp167-value1 = li_json->get( |{ lv_cond }/3| ).
            temp167-value2 = li_json->get( |{ lv_cond }/4| ).
            APPEND temp167 TO result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter the server cannot read is no filter - every row shows
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD kind_of.

    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA lv_kind TYPE string.
    lo_type = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data( val ).
    CASE lo_type->absolute_name.
      WHEN `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL` OR `\TYPE=ABAP_BOOLEAN` OR `\TYPE=XSDBOOLEAN`
          OR `\TYPE=FLAG` OR `\TYPE=XFELD`.
        result = `B`.
        RETURN.
    ENDCASE.


    lv_kind = z2ui5_cl_ui5_util_context=>rtti_get_type_kind( val ).
    IF lv_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_date.
      result = `D`.
    ELSEIF lv_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_time.
      result = `T`.
    ELSEIF lv_kind CA `bsI8PFae`.
      " int1, int2, int, int8, packed, float, decfloat16, decfloat34
      result = `N`.
    ELSE.
      result = `S`.
    ENDIF.

  ENDMETHOD.

  METHOD line_kind.

    DATA lr_line TYPE REF TO data.
    FIELD-SYMBOLS <line> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.

    CREATE DATA lr_line LIKE LINE OF tab.
    ASSIGN lr_line->* TO <line>.
    ASSIGN COMPONENT path OF STRUCTURE <line> TO <comp>.
    IF sy-subrc <> 0 OR <comp> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    result = kind_of( <comp> ).

  ENDMETHOD.

  METHOD key_of.
        DATA temp168 TYPE string.
        DATA temp34 TYPE z2ui5_cl_ui5_srv_window=>ty_s_key-str.
        DATA temp169 TYPE z2ui5_cl_ui5_srv_window=>ty_s_key-str.

    CASE kind.
      WHEN `N`.
        result-num = val.
      WHEN `D` OR `T`.

        temp168 = val.

        IF val IS NOT INITIAL.
          temp34 = temp168.
        ELSE.
          CLEAR temp34.
        ENDIF.
        result-str = temp34.
      WHEN `B`.

        IF val IS NOT INITIAL.
          temp169 = `X`.
        ELSE.
          CLEAR temp169.
        ENDIF.
        result-str = temp169.
      WHEN OTHERS.
        result-str = to_upper( |{ val }| ).
    ENDCASE.

  ENDMETHOD.

  METHOD text_of.

    DATA lv_raw TYPE string.

    IF val IS INITIAL AND ( kind = `D` OR kind = `T` ).
      RETURN.
    ENDIF.
    lv_raw = |{ val }|.
    CASE kind.
      WHEN `D`.
        result = |{ lv_raw(4) }-{ lv_raw+4(2) }-{ lv_raw+6(2) }|.
      WHEN `T`.
        result = |{ lv_raw(2) }:{ lv_raw+2(2) }:{ lv_raw+4(2) }|.
      WHEN OTHERS.
        result = to_upper( lv_raw ).
    ENDCASE.

  ENDMETHOD.

  METHOD value_key.
        DATA temp170 TYPE string.

    CASE kind.
      WHEN `D`.
        result = replace( val  = val
                          sub  = `-`
                          with = ``
                          occ  = 0 ).
      WHEN `T`.
        result = replace( val  = val
                          sub  = `:`
                          with = ``
                          occ  = 0 ).
      WHEN `B`.

        IF to_upper( val ) = `TRUE` OR to_upper( val ) = `X`.
          temp170 = `X`.
        ELSE.
          CLEAR temp170.
        ENDIF.
        result = temp170.
      WHEN OTHERS.
        result = to_upper( val ).
    ENDCASE.
    result = condense( result ).
    IF kind = `D` AND result CO `0`.
      CLEAR result.
    ENDIF.

  ENDMETHOD.

  METHOD cond_prepare.

    DATA ls_filter LIKE LINE OF t_filter.
      DATA temp171 TYPE ty_s_cond.
      DATA ls_cond LIKE temp171.
      DATA temp2 TYPE xsdboolean.
            DATA temp172 TYPE z2ui5_cl_ui5_srv_window=>ty_s_cond-num1.
            DATA temp173 TYPE z2ui5_cl_ui5_srv_window=>ty_s_cond-num2.
    LOOP AT t_filter INTO ls_filter.

      CLEAR temp171.
      temp171-group = ls_filter-group.
      temp171-path = ls_filter-path.
      temp171-operator = ls_filter-operator.
      temp171-kind = line_kind( tab = tab path = ls_filter-path ).
      temp171-text1 = to_upper( ls_filter-value1 ).

      ls_cond = temp171.

      temp2 = boolc( ls_cond-kind IS NOT INITIAL ).
      ls_cond-valid = temp2.
      IF ls_cond-kind = `N`.
        TRY.

            IF ls_filter-value1 IS NOT INITIAL.
              temp172 = ls_filter-value1.
            ELSE.
              CLEAR temp172.
            ENDIF.
            ls_cond-num1 = temp172.

            IF ls_filter-value2 IS NOT INITIAL.
              temp173 = ls_filter-value2.
            ELSE.
              CLEAR temp173.
            ENDIF.
            ls_cond-num2 = temp173.
          CATCH cx_root.
            " a value that is no number matches no number
            ls_cond-valid = abap_false.
        ENDTRY.
      ELSE.
        ls_cond-str1 = value_key( val  = ls_filter-value1
                                  kind = ls_cond-kind ).
        ls_cond-str2 = value_key( val  = ls_filter-value2
                                  kind = ls_cond-kind ).
      ENDIF.
      APPEND ls_cond TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_row.

    DATA lv_group TYPE i.
    DATA lv_hit   TYPE abap_bool.
    DATA ls_cond LIKE LINE OF t_cond.

    " the conditions arrive ordered by group: a group is decided when the
    " next one starts, and one group without a hit rejects the row
    result = abap_true.
    lv_group = -1.

    LOOP AT t_cond INTO ls_cond.
      IF ls_cond-group <> lv_group.
        IF lv_group <> -1 AND lv_hit = abap_false.
          result = abap_false.
          RETURN.
        ENDIF.
        lv_group = ls_cond-group.
        lv_hit = abap_false.
      ENDIF.
      IF lv_hit = abap_false.
        lv_hit = cond_check( row  = row
                             cond = ls_cond ).
      ENDIF.
    ENDLOOP.
    result = lv_hit.

  ENDMETHOD.

  METHOD cond_check.

    FIELD-SYMBOLS <cell> TYPE any.
    DATA ls_key TYPE z2ui5_cl_ui5_srv_window=>ty_s_key.
    DATA lv_cmp TYPE i.
        DATA temp3 TYPE xsdboolean.
        DATA temp4 TYPE xsdboolean.
        DATA temp5 TYPE xsdboolean.
        DATA temp6 TYPE xsdboolean.
        DATA temp7 TYPE xsdboolean.
        DATA temp8 TYPE xsdboolean.
        DATA temp9 TYPE xsdboolean.
          DATA temp10 TYPE xsdboolean.

    IF cond-valid = abap_false.
      RETURN.
    ENDIF.
    ASSIGN COMPONENT cond-path OF STRUCTURE row TO <cell>.
    IF sy-subrc <> 0 OR <cell> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    CASE cond-operator.
      WHEN `Contains` OR `NotContains` OR `StartsWith` OR `NotStartsWith` OR `EndsWith` OR `NotEndsWith`.
        result = cond_check_text( text = text_of( val  = <cell>
                                                  kind = cond-kind )
                                  cond = cond ).
        RETURN.
    ENDCASE.


    ls_key = key_of( val  = <cell>
                           kind = cond-kind ).

    lv_cmp = cond_compare( key  = ls_key
                                 cond = cond ).
    CASE cond-operator.
      WHEN `EQ`.

        temp3 = boolc( lv_cmp = 0 ).
        result = temp3.
      WHEN `NE`.

        temp4 = boolc( lv_cmp <> 0 ).
        result = temp4.
      WHEN `LT`.

        temp5 = boolc( lv_cmp < 0 ).
        result = temp5.
      WHEN `LE`.

        temp6 = boolc( lv_cmp <= 0 ).
        result = temp6.
      WHEN `GT`.

        temp7 = boolc( lv_cmp > 0 ).
        result = temp7.
      WHEN `GE`.

        temp8 = boolc( lv_cmp >= 0 ).
        result = temp8.
      WHEN `BT` OR `NB`.

        temp9 = boolc( lv_cmp >= 0 AND cond_compare( key = ls_key cond = cond second = abap_true ) <= 0 ).
        result = temp9.
        IF cond-operator = `NB`.

          temp10 = boolc( result = abap_false ).
          result = temp10.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD cond_check_text.

    DATA lv_len TYPE i.
    DATA lv_text_len TYPE i.
        DATA temp11 TYPE xsdboolean.
        DATA temp12 TYPE xsdboolean.
        DATA temp13 TYPE xsdboolean.
      DATA temp14 TYPE xsdboolean.
    lv_len = strlen( cond-text1 ).

    lv_text_len = strlen( text ).
    CASE cond-operator.
      WHEN `Contains` OR `NotContains`.

        temp11 = boolc( lv_len = 0 OR find( val = text sub = cond-text1 ) >= 0 ).
        result = temp11.
      WHEN `StartsWith` OR `NotStartsWith`.

        temp12 = boolc( lv_len <= lv_text_len AND substring( val = text len = lv_len ) = cond-text1 ).
        result = temp12.
      WHEN `EndsWith` OR `NotEndsWith`.

        temp13 = boolc( lv_len <= lv_text_len AND substring( val = text off = lv_text_len - lv_len ) = cond-text1 ).
        result = temp13.
    ENDCASE.
    IF cond-operator CS `Not`.

      temp14 = boolc( result = abap_false ).
      result = temp14.
    ENDIF.

  ENDMETHOD.

  METHOD cond_compare.
      DATA temp174 TYPE decfloat34.
      DATA lv_num LIKE temp174.
    DATA temp175 TYPE string.
    DATA lv_str LIKE temp175.

    IF cond-kind = `N`.

      IF second = abap_true.
        temp174 = cond-num2.
      ELSE.
        temp174 = cond-num1.
      ENDIF.

      lv_num = temp174.
      IF key-num < lv_num.
        result = -1.
      ELSEIF key-num > lv_num.
        result = 1.
      ENDIF.
      RETURN.
    ENDIF.


    IF second = abap_true.
      temp175 = cond-str2.
    ELSE.
      temp175 = cond-str1.
    ENDIF.

    lv_str = temp175.
    IF key-str < lv_str.
      result = -1.
    ELSEIF key-str > lv_str.
      result = 1.
    ENDIF.

  ENDMETHOD.

  METHOD sort_cols.

    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <cell> TYPE any.

    DATA ls_sort LIKE LINE OF t_sort.
      DATA temp176 TYPE ty_s_sort_col.
      DATA ls_col LIKE temp176.
    LOOP AT t_sort INTO ls_sort.

      CLEAR temp176.
      temp176-kind = line_kind( tab = tab path = ls_sort-path ).
      temp176-descending = ls_sort-descending.

      ls_col = temp176.
      IF ls_col-kind IS INITIAL.
        CONTINUE.
      ENDIF.
      LOOP AT tab ASSIGNING <row>.
        ASSIGN COMPONENT ls_sort-path OF STRUCTURE <row> TO <cell>.
        IF sy-subrc <> 0.
          " every row has the component line_kind( ) found on the line type
          RETURN.
        ENDIF.
        APPEND key_of( val  = <cell>
                       kind = ls_col-kind ) TO ls_col-t_key.
      ENDLOOP.
      APPEND ls_col TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD sort_index.

    DATA lt_merged TYPE ty_t_index.

    " bottom up: runs of width 1, 2, 4, ... merged pairwise - stable, so
    " rows the sorters do not tell apart keep the order of the table
    DATA lv_lines TYPE i.
    DATA lv_width TYPE i.
      DATA lv_left TYPE i.
    lv_lines = lines( ct_idx ).

    lv_width = 1.
    WHILE lv_width < lv_lines.
      CLEAR lt_merged.

      lv_left = 1.
      WHILE lv_left <= lv_lines.
        sort_merge( EXPORTING t_col     = t_col
                              it_idx    = ct_idx
                              iv_left   = lv_left
                              iv_width  = lv_width
                    CHANGING  ct_merged = lt_merged ).
        lv_left = lv_left + 2 * lv_width.
      ENDWHILE.
      ct_idx = lt_merged.
      lv_width = lv_width * 2.
    ENDWHILE.

  ENDMETHOD.

  METHOD sort_merge.

    DATA lv_a TYPE i.
    DATA lv_b TYPE i.

    " the runs [left, mid) and [mid, end) into one
    DATA lv_lines TYPE i.
    DATA lv_mid TYPE i.
    DATA lv_end TYPE i.
    DATA lv_i LIKE iv_left.
    DATA lv_j LIKE lv_mid.
      DATA temp177 TYPE i.
      DATA temp178 TYPE i.
      DATA temp35 TYPE i.
      DATA temp179 TYPE i.
      DATA temp180 TYPE i.
      DATA temp36 TYPE i.
    lv_lines = lines( it_idx ).

    lv_mid = nmin( val1 = iv_left + iv_width
                         val2 = lv_lines + 1 ).

    lv_end = nmin( val1 = iv_left + 2 * iv_width
                         val2 = lv_lines + 1 ).

    lv_i = iv_left.

    lv_j = lv_mid.
    WHILE lv_i < lv_mid OR lv_j < lv_end.

      CLEAR temp177.

      READ TABLE it_idx INTO temp178 INDEX lv_i.
      IF sy-subrc = 0.
        temp177 = temp178.
      ENDIF.

      IF lv_i < lv_mid.
        temp35 = temp177.
      ELSE.
        CLEAR temp35.
      ENDIF.
      lv_a = temp35.

      CLEAR temp179.

      READ TABLE it_idx INTO temp180 INDEX lv_j.
      IF sy-subrc = 0.
        temp179 = temp180.
      ENDIF.

      IF lv_j < lv_end.
        temp36 = temp179.
      ELSE.
        CLEAR temp36.
      ENDIF.
      lv_b = temp36.
      " the right one only when the left one really comes after it - stable
      IF lv_j < lv_end AND ( lv_i >= lv_mid OR sort_after( t_col = t_col
                                                          a      = lv_a
                                                          b      = lv_b ) = abap_true ).
        APPEND lv_b TO ct_merged.
        lv_j = lv_j + 1.
      ELSE.
        APPEND lv_a TO ct_merged.
        lv_i = lv_i + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD sort_after.

    DATA temp181 LIKE LINE OF t_col.
    DATA lr_col LIKE REF TO temp181.
      DATA lr_a TYPE REF TO z2ui5_cl_ui5_srv_window=>ty_s_key.
      DATA lr_b TYPE REF TO z2ui5_cl_ui5_srv_window=>ty_s_key.
        DATA temp15 TYPE xsdboolean.
        DATA temp16 TYPE xsdboolean.
        DATA temp17 TYPE xsdboolean.
    LOOP AT t_col REFERENCE INTO lr_col.

      READ TABLE lr_col->t_key INDEX a REFERENCE INTO lr_a.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      READ TABLE lr_col->t_key INDEX b REFERENCE INTO lr_b.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF lr_col->kind = `N`.
        IF lr_a->num = lr_b->num.
          CONTINUE.
        ENDIF.

        temp15 = boolc( lr_a->num > lr_b->num ).
        result = temp15.
      ELSE.
        IF lr_a->str = lr_b->str.
          CONTINUE.
        ENDIF.

        temp16 = boolc( lr_a->str > lr_b->str ).
        result = temp16.
      ENDIF.
      IF lr_col->descending = abap_true.

        temp17 = boolc( result = abap_false ).
        result = temp17.
      ENDIF.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
