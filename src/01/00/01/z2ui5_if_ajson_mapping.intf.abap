interface z2ui5_if_ajson_mapping
  public.

  types:
    begin of ty_mapping_field, " deprecated, will be removed
      abap type string,
      json type string,
    end of ty_mapping_field,
    ty_mapping_fields type standard table of ty_mapping_field
      with unique sorted key abap components abap
      with unique sorted key json components json.

  types:
    begin of ty_rename,
      from type string,
      to type string,
    end of ty_rename,
    tty_rename_map type standard table of ty_rename
      with unique sorted key by_name components from.

  types:
    ty_table_of type standard table of ref to z2ui5_if_ajson_mapping.

  methods to_abap " deprecated, will be removed
    importing
      !iv_path         type string
      !iv_name         type string
    returning
      value(rv_result) type string.

  methods to_json " deprecated, will be removed
    importing
      !iv_path         type string
      !iv_name         type string
    returning
      value(rv_result) type string.

  methods rename_node
    importing
      !is_node type z2ui5_if_ajson_types=>ty_node
    changing
      !cv_name type z2ui5_if_ajson_types=>ty_node-name.

endinterface.
