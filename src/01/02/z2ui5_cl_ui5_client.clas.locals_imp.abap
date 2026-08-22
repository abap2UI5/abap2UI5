*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

" The row-preserving replacement for ajson's empty filter, behind
" z2ui5_if_client~_bind( omit_initial = abap_true ).
"
" The vendored z2ui5_cl_ajson_filter_lib=>create_empty_filter drops ANY node
" that ends up empty - including an object that IS a table row whose fields
" are all initial. The serialized array then has fewer entries than the
" backend table, and every row behind the gap is shifted: a whole-table
" write-back deletes the omitted row from backend state, and a `__delta` row
" index (0-based client position, applied against the FULL backend table in
" z2ui5_cl_ui5_srv_model=>delta_apply_nodes) lands the edit in the wrong
" row. src/00/01 is mirrored and must not change, so the correction lives
" here: identical to the empty filter EXCEPT that a direct element of an
" array always survives - initial FIELDS still vanish, but the row itself
" stays as {} and the client array keeps the backend's indexing.
CLASS lcl_empty_filter_keep_rows DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

ENDCLASS.


CLASS lcl_empty_filter_keep_rows IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.
        DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.
      DATA temp3 TYPE xsdboolean.

    " ajson numbers array children 1-based in is_node-index and leaves 0 on
    " every object member (lcl_abap_to_json / lcl_filter_runner=>walk), so
    " index > 0 is the reliable "this node is a table row / array element"
    " marker - more robust than parsing the numeric name out of the path
    IF is_node-index > 0.
      rv_keep = abap_true.
      RETURN.
    ENDIF.

    " everything below mirrors the vendored lcl_empty_filter
    IF iv_visit = z2ui5_if_ajson_filter=>visit_type-value.
      IF is_node-type = z2ui5_if_ajson_types=>node_type-number.

        temp1 = boolc( is_node-value <> '0' ).
        rv_keep = temp1.
      ELSE.
        " string & bool & null

        temp2 = boolc( is_node-value IS NOT INITIAL ).
        rv_keep = temp2.
      ENDIF.
    ELSE.
      " children = 0 on open for initially empty nodes and on close for
      " fully filtered ones

      temp3 = boolc( is_node-children > 0 ).
      rv_keep = temp3.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


" The path-scoped counterpart of ajson's empty filter, behind
" z2ui5_if_client~_bind( omit_initial_paths ).
"
" `omit_initial = abap_true` drops EVERY initial field of the bound value, and
" that is too coarse for one shape: a BOOLEAN that has to send abap_false. False
" is itself the initial value, so the blanket filter removes it and the control
" falls back to its own default - true. A bound template whose rows mix
" "leave numeric/enum properties at their default" with "this row is disabled"
" therefore needs the omission scoped to the fields that want it.
"
" Nodes are matched by NAME (the last path segment), which is how a bound row
" is addressed in the view (`{MIN}`, `{MAX}`) - the same field name in a nested
" structure is covered by design, so a caller lists the columns, not paths.
CLASS lcl_initial_paths_filter DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

    METHODS constructor
      IMPORTING
        it_paths TYPE string_table.

  PRIVATE SECTION.
    TYPES temp1_65587aa3fe TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
DATA mt_names TYPE temp1_65587aa3fe.

ENDCLASS.


CLASS lcl_initial_paths_filter IMPLEMENTATION.

  METHOD constructor.

    DATA lv_path LIKE LINE OF it_paths.
      DATA lv_name TYPE string.
        TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_parts TYPE temp2.
        DATA temp50 TYPE string.
        DATA temp51 TYPE string.
      DATA temp52 LIKE sy-subrc.
    LOOP AT it_paths INTO lv_path.

      lv_name = to_upper( lv_path ).
      " a caller may write the field with or without a leading slash
      IF lv_name CS `/`.


        SPLIT lv_name AT `/` INTO TABLE lt_parts.

        CLEAR temp50.

        READ TABLE lt_parts INTO temp51 INDEX lines( lt_parts ).
        IF sy-subrc = 0.
          temp50 = temp51.
        ENDIF.
        lv_name = temp50.
      ENDIF.

      READ TABLE mt_names WITH KEY table_line = lv_name TRANSPORTING NO FIELDS.
      temp52 = sy-subrc.
      IF lv_name IS NOT INITIAL AND NOT temp52 = 0.
        INSERT lv_name INTO TABLE mt_names.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.
    DATA temp53 LIKE sy-subrc.
      DATA temp4 TYPE xsdboolean.
      DATA temp5 TYPE xsdboolean.

    rv_keep = abap_true.

    " only a VALUE node can be initial - opening and closing an array or an
    " object always passes, or the structure around a dropped field would go
    IF iv_visit <> z2ui5_if_ajson_filter=>visit_type-value.
      RETURN.
    ENDIF.


    READ TABLE mt_names WITH KEY table_line = to_upper( is_node-name ) TRANSPORTING NO FIELDS.
    temp53 = sy-subrc.
    IF NOT temp53 = 0.
      RETURN.
    ENDIF.

    IF is_node-type = z2ui5_if_ajson_types=>node_type-number.

      temp4 = boolc( is_node-value <> '0' ).
      rv_keep = temp4.
    ELSE.

      temp5 = boolc( is_node-value IS NOT INITIAL ).
      rv_keep = temp5.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
