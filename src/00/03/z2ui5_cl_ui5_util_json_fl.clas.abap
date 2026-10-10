" The framework's own STATELESS ajson helpers - the no-empty-values filter
" and the upper-case field mapping, both implemented by this class. Neither
" carries any state, so ONE instance of each serves the whole roll area
" instead of a pair of objects per serialization: response_abap_to_json
" built both on every single response, main_json_stringify one per model.
"
" The mapping used to be ajson's own create_upper_case( ): its to_json
" delegates to a field mapping (to_upper plus a READ on a field table that
" is always empty here) and upper-cases the name a second time - three
" calls and a table read per node name, on every cell of every bound
" table. The implementation below is the one line the model needs; what
" it answers is byte for byte what ajson's answered (the test class holds
" both side by side).
"
" Filled lazily on first use, never in a class_constructor: a
" class_constructor has to sit in the PUBLIC SECTION or activation fails on
" a real system while the transpiler stays green - the trap AGENTS.md rule
" 20 names, and the road z2ui5_cl_ui5_view_builder=>gv_escape_specials and
" z2ui5_cl_ui5_user_exit=>gv_csp_default take for the same reason.
"
" Plain comments, not ABAP Doc: SE24 regenerates the CLASS statement from
" the class metadata and would detach a leading "! block from it (see
" z2ui5_cl_ui5_frontend).
CLASS z2ui5_cl_ui5_util_json_fl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    INTERFACES z2ui5_if_ajson_mapping.

    CLASS-METHODS create_no_empty_values
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson_filter.

    "! The upper-case field mapping every model and response serialization
    "! attaches. A caller that needs a mapper of its OWN still builds one -
    "! this is the shared, unconfigurable instance, and nothing may be
    "! stored on an attribute from here: a mapper on mt_attri is serialized
    "! into the draft (z2ui5_cl_ui5_srv_bind=>check_raise_new), and a draft
    "! must not carry a reference every session shares.
    CLASS-METHODS mapper_upper
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson_mapping.

    "! Whether the VALUE of a NUMBER node is a numeric zero in any of its
    "! spellings: ajson writes a packed field with decimals as `0.00` and a
    "! float as `0.0E+00` (both are |{ value }|), and a plain compare
    "! against `0` kept exactly the "price" column omit_initial is
    "! documented for. CO: every character is one of the set, i.e. there
    "! is no non-zero digit. The one predicate for this filter and for the
    "! row-preserving filters local to z2ui5_cl_ui5_client, which used to
    "! carry a copy of the line
    CLASS-METHODS check_number_initial
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! A JSON text with every raw control character below U+0020 other
    "! than tab, LF and CR written as a \u00XX escape. ajson's
    "! escape_string handles only those three plus the quote and the
    "! backslash, so a string value carrying U+0001 or a form feed (a legacy
    "! long text, a value out of a file) left the backend raw, and the
    "! browser's JSON.parse refuses the WHOLE response over one such byte.
    "! Correct on any compact ajson output: outside a string JSON allows no
    "! character of this set at all, so every one found is inside a string
    "! literal, and the escape stands for exactly that character there
    CLASS-METHODS escape_controls
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    " the bytes of the set, in the order gv_controls holds the characters
    CONSTANTS c_controls_hex TYPE string VALUE `0001020304050607080B0C0E0F101112131415161718191A1B1C1D1E1F`.

    CLASS-DATA gi_no_empty_values TYPE REF TO z2ui5_if_ajson_filter.
    CLASS-DATA gi_mapper_upper    TYPE REF TO z2ui5_if_ajson_mapping.
    CLASS-DATA gv_controls        TYPE string.
    CLASS-DATA gv_controls_built  TYPE abap_bool.
ENDCLASS.


CLASS z2ui5_cl_ui5_util_json_fl IMPLEMENTATION.

  METHOD create_no_empty_values.

    IF gi_no_empty_values IS NOT BOUND.
      gi_no_empty_values = NEW z2ui5_cl_ui5_util_json_fl( ).
    ENDIF.
    result = gi_no_empty_values.

  ENDMETHOD.

  METHOD mapper_upper.

    IF gi_mapper_upper IS NOT BOUND.
      gi_mapper_upper = NEW z2ui5_cl_ui5_util_json_fl( ).
    ENDIF.
    result = gi_mapper_upper.

  ENDMETHOD.

  METHOD z2ui5_if_ajson_mapping~to_json.

    " ajson hands the lower-cased component name in and writes what comes
    " back as the node name - the one call the upper-case mapping is
    rv_result = to_upper( iv_name ).

  ENDMETHOD.

  METHOD z2ui5_if_ajson_mapping~to_abap.

    " the reader upper-cases the answer and falls back to the node name
    " when it is empty, so the name itself is the same answer ajson's
    " empty field table gave
    rv_result = iv_name.

  ENDMETHOD.

  METHOD z2ui5_if_ajson_mapping~rename_node.

    " as ajson's own upper-case mapping renames: the node name upper-cased
    cv_name = to_upper( cv_name ).

  ENDMETHOD.

  METHOD check_number_initial.

    result = xsdbool( val CO `0.-+Ee` ).

  ENDMETHOD.

  METHOD escape_controls.

    IF gv_controls_built = abap_false.
      gv_controls_built = abap_true.
      TRY.
          gv_controls = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( CONV xstring( c_controls_hex ) ).
        CATCH z2ui5_cx_ui5_util_error.
          " no codepage API (UNSUPPORTED_CODEPAGE_API): degrade like
          " z2ui5_cl_ui5_view_builder=>xml_escape - the set stays empty and the
          " text leaves as before, rather than every response failing here
          CLEAR gv_controls.
      ENDTRY.
    ENDIF.

    result = val.
    " one CA scan: the common response carries none of these
    IF gv_controls IS INITIAL OR result NA gv_controls.
      RETURN.
    ENDIF.

    " one replace per character, no regex - see xml_escape for why
    DATA(lv_off) = 0.
    DATA(lv_len) = strlen( gv_controls ).
    WHILE lv_off < lv_len.
      IF result CA gv_controls+lv_off(1).
        DATA(lv_hex) = lv_off * 2.
        result = replace( val  = result
                          sub  = gv_controls+lv_off(1)
                          with = `\u00` && c_controls_hex+lv_hex(2)
                          occ  = 0 ).
      ENDIF.
      lv_off = lv_off + 1.
    ENDWHILE.

  ENDMETHOD.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            rv_keep = xsdbool( is_node-value <> `false` ).
          WHEN z2ui5_if_ajson_types=>node_type-number.
            rv_keep = xsdbool( check_number_initial( is_node-value ) = abap_false ).
          WHEN z2ui5_if_ajson_types=>node_type-string.
            rv_keep = xsdbool( is_node-value <> `` ).
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.
        rv_keep = xsdbool( is_node-children <> 0 ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
