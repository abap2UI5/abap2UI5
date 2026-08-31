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
    " a bound filter is stored on mt_attri and serialized into the draft
    " with the rest of the app state (z2ui5_cl_ui5_srv_bind->check_raise_new
    " is the gate) - z2ui5_if_ajson_filter, unlike z2ui5_if_ajson_mapping,
    " does not compose if_serializable_object, so every filter class the
    " framework itself hands into a binding declares it here
    INTERFACES if_serializable_object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_empty_filter_keep_rows IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.

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
        rv_keep = xsdbool( is_node-value <> `0` ).
      ELSE.
        " string & bool & null
        rv_keep = xsdbool( is_node-value IS NOT INITIAL ).
      ENDIF.
    ELSE.
      " children = 0 on open for initially empty nodes and on close for
      " fully filtered ones
      rv_keep = xsdbool( is_node-children > 0 ).
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
    " serialized into the draft when bound - see lcl_empty_filter_keep_rows
    INTERFACES if_serializable_object.

    METHODS constructor
      IMPORTING
        it_paths TYPE string_table.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

ENDCLASS.


CLASS lcl_initial_paths_filter IMPLEMENTATION.

  METHOD constructor.

    LOOP AT it_paths INTO DATA(lv_path).
      DATA(lv_name) = to_upper( lv_path ).
      " a caller may write the field with or without a leading slash
      IF lv_name CS `/`.
        SPLIT lv_name AT `/` INTO TABLE DATA(lt_parts).
        lv_name = VALUE #( lt_parts[ lines( lt_parts ) ] OPTIONAL ).
      ENDIF.
      IF lv_name IS NOT INITIAL AND NOT line_exists( mt_names[ table_line = lv_name ] ). "#EC CI_SORTSEQ
        INSERT lv_name INTO TABLE mt_names.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    " only a VALUE node can be initial - opening and closing an array or an
    " object always passes, or the structure around a dropped field would go
    IF iv_visit <> z2ui5_if_ajson_filter=>visit_type-value.
      RETURN.
    ENDIF.

    " to_upper( ) is hoisted on purpose - it must NOT sit inside the table
    " expression. The downporter rewrites line_exists( tab[ k = x ] ) into
    " READ TABLE tab WITH KEY k = x, and a WITH KEY operand is not a general
    " expression position before 7.40: 7.02/7.31 parse `to_upper( )` there as
    " a method call and the whole class pool fails to compile with "method
    " TO_UPPER is unknown" (#2664). In a plain assignment the built-in is fine
    " on 7.02, so the variable is all it takes.
    DATA(lv_name) = to_upper( is_node-name ).
    IF NOT line_exists( mt_names[ table_line = lv_name ] ). "#EC CI_SORTSEQ
      RETURN.
    ENDIF.

    IF is_node-type = z2ui5_if_ajson_types=>node_type-number.
      rv_keep = xsdbool( is_node-value <> `0` ).
    ELSE.
      rv_keep = xsdbool( is_node-value IS NOT INITIAL ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


" The serializable AND combination of two filters, behind
" z2ui5_if_client~_bind( omit_initial* ) when the caller supplied a filter of
" their own: both have to pass.
"
" NOT the vendored z2ui5_cl_ajson_filter_lib=>create_and_filter: its filter
" class does not implement if_serializable_object, and the combined ref is
" stored on mt_attri and serialized into the draft - the vendored form
" passed every check here (the transpiler does not enforce serializability)
" and failed only at db_save on a real system, as an APP_SERIALIZATION_ERROR
" naming nothing. Serializing this class serializes both member refs, so the
" caller's own filter still has to be serializable - check_raise_new says so
" at bind time.
CLASS lcl_and_filter DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    INTERFACES if_serializable_object.

    METHODS constructor
      IMPORTING
        ii_first  TYPE REF TO z2ui5_if_ajson_filter
        ii_second TYPE REF TO z2ui5_if_ajson_filter.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mi_first  TYPE REF TO z2ui5_if_ajson_filter.
    DATA mi_second TYPE REF TO z2ui5_if_ajson_filter.

ENDCLASS.


CLASS lcl_and_filter IMPLEMENTATION.

  METHOD constructor.

    mi_first  = ii_first.
    mi_second = ii_second.

  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = mi_first->keep_node( is_node  = is_node
                                   iv_visit = iv_visit ).
    IF rv_keep = abap_true.
      rv_keep = mi_second->keep_node( is_node  = is_node
                                      iv_visit = iv_visit ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
