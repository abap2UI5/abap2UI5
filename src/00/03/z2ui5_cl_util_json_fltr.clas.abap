CLASS z2ui5_cl_util_json_fltr DEFINITION
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


CLASS z2ui5_cl_util_json_fltr IMPLEMENTATION.

  METHOD create_no_empty_values.

    CREATE OBJECT result TYPE z2ui5_cl_util_json_fltr.

  ENDMETHOD.

  METHOD z2ui5_if_ajson_filter~keep_node.
            DATA temp1 TYPE xsdboolean.
            DATA temp2 TYPE xsdboolean.
            DATA temp3 TYPE xsdboolean.
        DATA temp4 TYPE xsdboolean.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            
            temp1 = boolc( is_node-value <> `false` ).
            rv_keep = temp1.
          WHEN z2ui5_if_ajson_types=>node_type-number.
            
            temp2 = boolc( is_node-value <> `0` ).
            rv_keep = temp2.
          WHEN z2ui5_if_ajson_types=>node_type-string.
            
            temp3 = boolc( is_node-value <> `` ).
            rv_keep = temp3.
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.
        
        temp4 = boolc( is_node-children <> 0 ).
        rv_keep = temp4.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
