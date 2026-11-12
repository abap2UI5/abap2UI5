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
"! The sort is a merge sort of the row numbers and the comparison is done
"! on keys taken from the rows once: SORT ... BY (name) sorts nothing in
"! the transpiled runtime, and a comparison per pair that reads the cells
"! through ASSIGN COMPONENT would read every cell log2( n ) times.
CLASS z2ui5_cl_ui5_srv_window DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_t_index TYPE STANDARD TABLE OF i WITH EMPTY KEY.

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
    "! model path of the table, the rows wanted, the sorters and the filter
    "! groups as JSON. Applied to the windowed attribute with that path;
    "! abap_false when there is none
    CLASS-METHODS event_apply
      IMPORTING
        t_arg         TYPE string_table
        attri         TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri
      RETURNING
        VALUE(result) TYPE abap_bool.

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
    TYPES ty_t_key TYPE STANDARD TABLE OF ty_s_key WITH EMPTY KEY.

    " one sorter with the key of every row of the table, by row number
    TYPES:
      BEGIN OF ty_s_sort_col,
        kind       TYPE ty_kind,
        descending TYPE abap_bool,
        t_key      TYPE ty_t_key,
      END OF ty_s_sort_col.
    TYPES ty_t_sort_col TYPE STANDARD TABLE OF ty_s_sort_col WITH EMPTY KEY.

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
    TYPES ty_t_cond TYPE STANDARD TABLE OF ty_s_cond WITH EMPTY KEY.

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

    DATA(lt_cond) = cond_prepare( tab      = tab
                                  t_filter = t_filter ).
    LOOP AT tab ASSIGNING <row>.
      DATA(lv_row) = sy-tabix.
      IF lt_cond IS INITIAL OR filter_row( row    = <row>
                                           t_cond = lt_cond ) = abap_true.
        APPEND lv_row TO result.
      ENDIF.
    ENDLOOP.

    IF t_sort IS INITIAL OR lines( result ) < 2.
      RETURN.
    ENDIF.
    DATA(lt_col) = sort_cols( tab    = tab
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

    CREATE DATA result LIKE tab.
    ASSIGN result->* TO <result>.
    " the transpiled runtime copies the rows along with CREATE DATA ... LIKE
    CLEAR <result>.

    LOOP AT t_index INTO DATA(lv_row) TO count.
      READ TABLE tab INDEX lv_row ASSIGNING <row>.
      IF sy-subrc = 0.
        INSERT <row> INTO TABLE <result>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD event_apply.

    DATA lv_wanted TYPE i.

    DATA(lv_path)   = VALUE string( t_arg[ 1 ] OPTIONAL ).
    DATA(lv_count)  = VALUE string( t_arg[ 2 ] OPTIONAL ).
    DATA(lv_sort)   = VALUE string( t_arg[ 3 ] OPTIONAL ).
    DATA(lv_filter) = VALUE string( t_arg[ 4 ] OPTIONAL ).

    LOOP AT attri->* REFERENCE INTO DATA(lr_attri)      "#EC CI_SORTSEQ
         WHERE bind = abap_true AND window_size > 0.
      IF lr_attri->name_client <> lv_path.
        CONTINUE.
      ENDIF.

      lr_attri->t_window_sort   = parse_sort( lv_sort ).
      lr_attri->t_window_filter = parse_filter( lv_filter ).
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
          APPEND VALUE #( path       = lv_name
                          descending = li_json->get_boolean( |{ lv_sorter }/DESCENDING| ) ) TO result.
        ENDLOOP.
      CATCH cx_root.
        " a sort the server cannot read is no sort - the order of the table
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
            APPEND VALUE #( group    = lv_group
                            path     = to_upper( li_json->get_string( |{ lv_cond }/1| ) )
                            operator = li_json->get_string( |{ lv_cond }/2| )
                            value1   = li_json->get( |{ lv_cond }/3| )
                            value2   = li_json->get( |{ lv_cond }/4| ) ) TO result.
          ENDLOOP.
        ENDLOOP.
      CATCH cx_root.
        " a filter the server cannot read is no filter - every row shows
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD kind_of.

    DATA(lo_type) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data( val ).
    CASE lo_type->absolute_name.
      WHEN `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL` OR `\TYPE=ABAP_BOOLEAN` OR `\TYPE=XSDBOOLEAN`
          OR `\TYPE=FLAG` OR `\TYPE=XFELD`.
        result = `B`.
        RETURN.
    ENDCASE.

    DATA(lv_kind) = z2ui5_cl_ui5_util_context=>rtti_get_type_kind( val ).
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

    CASE kind.
      WHEN `N`.
        result-num = val.
      WHEN `D` OR `T`.
        result-str = COND #( WHEN val IS NOT INITIAL THEN CONV string( val ) ).
      WHEN `B`.
        result-str = COND #( WHEN val IS NOT INITIAL THEN `X` ).
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
        result = COND #( WHEN to_upper( val ) = `TRUE` OR to_upper( val ) = `X` THEN `X` ).
      WHEN OTHERS.
        result = to_upper( val ).
    ENDCASE.
    result = condense( result ).
    IF kind = `D` AND result CO `0`.
      CLEAR result.
    ENDIF.

  ENDMETHOD.

  METHOD cond_prepare.

    LOOP AT t_filter INTO DATA(ls_filter).
      DATA(ls_cond) = VALUE ty_s_cond( group    = ls_filter-group
                                       path     = ls_filter-path
                                       operator = ls_filter-operator
                                       kind     = line_kind( tab  = tab
                                                             path = ls_filter-path )
                                       text1    = to_upper( ls_filter-value1 ) ).
      ls_cond-valid = xsdbool( ls_cond-kind IS NOT INITIAL ).
      IF ls_cond-kind = `N`.
        TRY.
            ls_cond-num1 = COND #( WHEN ls_filter-value1 IS NOT INITIAL THEN ls_filter-value1 ).
            ls_cond-num2 = COND #( WHEN ls_filter-value2 IS NOT INITIAL THEN ls_filter-value2 ).
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

    " the conditions arrive ordered by group: a group is decided when the
    " next one starts, and one group without a hit rejects the row
    result = abap_true.
    lv_group = -1.
    LOOP AT t_cond INTO DATA(ls_cond).
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

    DATA(ls_key) = key_of( val  = <cell>
                           kind = cond-kind ).
    DATA(lv_cmp) = cond_compare( key  = ls_key
                                 cond = cond ).
    CASE cond-operator.
      WHEN `EQ`.
        result = xsdbool( lv_cmp = 0 ).
      WHEN `NE`.
        result = xsdbool( lv_cmp <> 0 ).
      WHEN `LT`.
        result = xsdbool( lv_cmp < 0 ).
      WHEN `LE`.
        result = xsdbool( lv_cmp <= 0 ).
      WHEN `GT`.
        result = xsdbool( lv_cmp > 0 ).
      WHEN `GE`.
        result = xsdbool( lv_cmp >= 0 ).
      WHEN `BT` OR `NB`.
        result = xsdbool( lv_cmp >= 0 AND cond_compare( key    = ls_key
                                                        cond   = cond
                                                        second = abap_true ) <= 0 ).
        IF cond-operator = `NB`.
          result = xsdbool( result = abap_false ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD cond_check_text.

    DATA(lv_len) = strlen( cond-text1 ).
    DATA(lv_text_len) = strlen( text ).
    CASE cond-operator.
      WHEN `Contains` OR `NotContains`.
        result = xsdbool( lv_len = 0 OR find( val = text
                                              sub = cond-text1 ) >= 0 ).
      WHEN `StartsWith` OR `NotStartsWith`.
        result = xsdbool( lv_len <= lv_text_len AND substring( val = text
                                                               len = lv_len ) = cond-text1 ).
      WHEN `EndsWith` OR `NotEndsWith`.
        result = xsdbool( lv_len <= lv_text_len AND substring( val = text
                                                               off = lv_text_len - lv_len ) = cond-text1 ).
    ENDCASE.
    IF cond-operator CS `Not`.
      result = xsdbool( result = abap_false ).
    ENDIF.

  ENDMETHOD.

  METHOD cond_compare.

    IF cond-kind = `N`.
      DATA(lv_num) = COND decfloat34( WHEN second = abap_true THEN cond-num2 ELSE cond-num1 ).
      IF key-num < lv_num.
        result = -1.
      ELSEIF key-num > lv_num.
        result = 1.
      ENDIF.
      RETURN.
    ENDIF.

    DATA(lv_str) = COND string( WHEN second = abap_true THEN cond-str2 ELSE cond-str1 ).
    IF key-str < lv_str.
      result = -1.
    ELSEIF key-str > lv_str.
      result = 1.
    ENDIF.

  ENDMETHOD.

  METHOD sort_cols.

    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <cell> TYPE any.

    LOOP AT t_sort INTO DATA(ls_sort).
      DATA(ls_col) = VALUE ty_s_sort_col( kind       = line_kind( tab  = tab
                                                                  path = ls_sort-path )
                                          descending = ls_sort-descending ).
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
    DATA(lv_lines) = lines( ct_idx ).
    DATA(lv_width) = 1.
    WHILE lv_width < lv_lines.
      CLEAR lt_merged.
      DATA(lv_left) = 1.
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
    DATA(lv_lines) = lines( it_idx ).
    DATA(lv_mid) = nmin( val1 = iv_left + iv_width
                         val2 = lv_lines + 1 ).
    DATA(lv_end) = nmin( val1 = iv_left + 2 * iv_width
                         val2 = lv_lines + 1 ).
    DATA(lv_i) = iv_left.
    DATA(lv_j) = lv_mid.
    WHILE lv_i < lv_mid OR lv_j < lv_end.
      lv_a = COND #( WHEN lv_i < lv_mid THEN VALUE #( it_idx[ lv_i ] OPTIONAL ) ).
      lv_b = COND #( WHEN lv_j < lv_end THEN VALUE #( it_idx[ lv_j ] OPTIONAL ) ).
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

    LOOP AT t_col REFERENCE INTO DATA(lr_col).
      READ TABLE lr_col->t_key INDEX a REFERENCE INTO DATA(lr_a).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      READ TABLE lr_col->t_key INDEX b REFERENCE INTO DATA(lr_b).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF lr_col->kind = `N`.
        IF lr_a->num = lr_b->num.
          CONTINUE.
        ENDIF.
        result = xsdbool( lr_a->num > lr_b->num ).
      ELSE.
        IF lr_a->str = lr_b->str.
          CONTINUE.
        ENDIF.
        result = xsdbool( lr_a->str > lr_b->str ).
      ENDIF.
      IF lr_col->descending = abap_true.
        result = xsdbool( result = abap_false ).
      ENDIF.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
