*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

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
        DATA temp34 TYPE string.
        DATA temp35 TYPE string.
      DATA temp36 LIKE sy-subrc.
    LOOP AT it_paths INTO lv_path.

      lv_name = to_upper( lv_path ).
      " a caller may write the field with or without a leading slash
      IF lv_name CS `/`.


        SPLIT lv_name AT `/` INTO TABLE lt_parts.

        CLEAR temp34.

        READ TABLE lt_parts INTO temp35 INDEX lines( lt_parts ).
        IF sy-subrc = 0.
          temp34 = temp35.
        ENDIF.
        lv_name = temp34.
      ENDIF.

      READ TABLE mt_names WITH KEY table_line = lv_name TRANSPORTING NO FIELDS.
      temp36 = sy-subrc.
      IF lv_name IS NOT INITIAL AND NOT temp36 = 0.
        INSERT lv_name INTO TABLE mt_names.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.
    DATA temp37 LIKE sy-subrc.
      DATA temp1 TYPE xsdboolean.
      DATA temp2 TYPE xsdboolean.

    rv_keep = abap_true.

    " only a VALUE node can be initial - opening and closing an array or an
    " object always passes, or the structure around a dropped field would go
    IF iv_visit <> z2ui5_if_ajson_filter=>visit_type-value.
      RETURN.
    ENDIF.


    READ TABLE mt_names WITH KEY table_line = to_upper( is_node-name ) TRANSPORTING NO FIELDS.
    temp37 = sy-subrc.
    IF NOT temp37 = 0.
      RETURN.
    ENDIF.

    IF is_node-type = z2ui5_if_ajson_types=>node_type-number.

      temp1 = boolc( is_node-value <> '0' ).
      rv_keep = temp1.
    ELSE.

      temp2 = boolc( is_node-value IS NOT INITIAL ).
      rv_keep = temp2.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
