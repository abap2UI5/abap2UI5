" The framework's own STATELESS ajson helpers - the upper-case field
" mapping this class implements, and two static predicates on JSON text.
" The mapping carries no state, so ONE instance serves the whole roll area
" instead of an object per serialization: response_abap_to_json built one
" on every single response, main_json_stringify one per model.
"
" The class used to implement a second thing, the no-empty-values filter
" (create_no_empty_values, z2ui5_if_ajson_filter~keep_node), for the
" generic conversion of the response structure. Since protocol 3 the
" response is written field by field (z2ui5_cl_ui5_handler
" =>response_abap_to_json) and nothing asked for the filter any more; it
" went on 2026-11-23. What _bind( omit_initial ) filters by are the
" row-preserving filters local to z2ui5_cl_ui5_client, which share
" check_number_initial below.
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
" 20 names, and the road z2ui5_cl_ui5_view_builder=>gv_name_chars and
" z2ui5_cl_ui5_user_exit=>gv_csp_default take for the same reason.
"
" Plain comments, not ABAP Doc: SE24 regenerates the CLASS statement from
" the class metadata and would detach a leading "! block from it (see
" z2ui5_cl_ui5_frontend).
CLASS z2ui5_cl_ui5_util_json_fl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_mapping.

    "! The upper-case field mapping every model and response serialization
    "! attaches - the shared, unconfigurable instance. It is attached to an
    "! ajson instance, never stored on mt_attri (the attribute row carries
    "! no mapper since 2026-11-28), so no draft carries a reference every
    "! session shares.
    CLASS-METHODS mapper_upper
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson_mapping.

    "! Whether the VALUE of a NUMBER node is a numeric zero in any of its
    "! spellings: ajson writes a packed field with decimals as `0.00` and a
    "! float as `0.0E+00` (both are |{ value }|), and a plain compare
    "! against `0` kept exactly the "price" column omit_initial is
    "! documented for. CO: every character is one of the set, i.e. there
    "! is no non-zero digit. The one predicate of the row-preserving
    "! filters local to z2ui5_cl_ui5_client, which used to carry a copy of
    "! the line each
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

    CLASS-DATA gi_mapper_upper    TYPE REF TO z2ui5_if_ajson_mapping.
    CLASS-DATA gv_controls        TYPE string.
    CLASS-DATA gv_controls_built  TYPE abap_bool.
ENDCLASS.


CLASS z2ui5_cl_ui5_util_json_fl IMPLEMENTATION.

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
          " z2ui5_cl_ui5_util_context=>c_escape_xml - the set stays empty and the
          " text leaves as before, rather than every response failing here
          CLEAR gv_controls.
      ENDTRY.
    ENDIF.

    result = val.
    " one CA scan: the common response carries none of these
    IF gv_controls IS INITIAL OR result NA gv_controls.
      RETURN.
    ENDIF.

    " one replace per character, no regex - see c_escape_xml of the context class for why
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

ENDCLASS.
