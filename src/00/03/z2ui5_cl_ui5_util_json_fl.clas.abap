" The framework's own STATELESS ajson helpers - the no-empty-values filter
" this class implements, and the upper-case field mapping next to it. Both
" carry no state at all (the filter has no attribute, the mapping an empty
" field table), so ONE instance of each serves the whole roll area instead
" of a pair of objects per serialization: response_abap_to_json built both
" on every single response, main_json_stringify one per model.
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

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gi_no_empty_values TYPE REF TO z2ui5_if_ajson_filter.
    CLASS-DATA gi_mapper_upper    TYPE REF TO z2ui5_if_ajson_mapping.
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
      gi_mapper_upper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
    ENDIF.
    result = gi_mapper_upper.

  ENDMETHOD.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            rv_keep = xsdbool( is_node-value <> `false` ).
          WHEN z2ui5_if_ajson_types=>node_type-number.
            " every spelling of zero (`0`, `0.00`, `0.0E+00`) is empty - see
            " lcl_node_value=>check_initial in z2ui5_cl_ui5_client
            rv_keep = xsdbool( is_node-value CN `0.-+Ee` ).
          WHEN z2ui5_if_ajson_types=>node_type-string.
            rv_keep = xsdbool( is_node-value <> `` ).
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.
        rv_keep = xsdbool( is_node-children <> 0 ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
