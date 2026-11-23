CLASS z2ui5_cl_ui5_util_json_fl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

    CLASS-METHODS create_no_empty_values
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson_filter.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_util_json_fl IMPLEMENTATION.

  METHOD create_no_empty_values.

    result = NEW z2ui5_cl_ui5_util_json_fl( ).

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
            " lcl_empty_filter_keep_rows in z2ui5_cl_ui5_client
            rv_keep = xsdbool( is_node-value CN `0.-+Ee` ).
          WHEN z2ui5_if_ajson_types=>node_type-string.
            rv_keep = xsdbool( is_node-value <> `` ).
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.
        rv_keep = xsdbool( is_node-children <> 0 ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
