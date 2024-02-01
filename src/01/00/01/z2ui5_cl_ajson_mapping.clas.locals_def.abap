class lcl_mapping_fields definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_mapping_fields type z2ui5_if_ajson_mapping~ty_mapping_fields optional.

  protected section.

  private section.
    data mt_mapping_fields type z2ui5_if_ajson_mapping~ty_mapping_fields.

endclass.

class lcl_rename definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_rename_map type z2ui5_if_ajson_mapping~tty_rename_map
        iv_rename_by type i.

  protected section.

  private section.
    data mt_rename_map type z2ui5_if_ajson_mapping~tty_rename_map.
    data mv_rename_by type i.

endclass.

class lcl_mapping_to_upper definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_mapping_fields type z2ui5_if_ajson_mapping~ty_mapping_fields optional.

  protected section.

  private section.
    data mi_mapping_fields type ref to z2ui5_if_ajson_mapping.

endclass.


class lcl_mapping_to_lower definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_mapping_fields type z2ui5_if_ajson_mapping~ty_mapping_fields optional.

  protected section.

  private section.
    data mi_mapping_fields type ref to z2ui5_if_ajson_mapping.

endclass.


class lcl_mapping_camel definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_mapping_fields   type z2ui5_if_ajson_mapping~ty_mapping_fields optional
        iv_first_json_upper type abap_bool default abap_true.

  protected section.

  private section.
    data mv_first_json_upper type abap_bool.
    data mi_mapping_fields type ref to z2ui5_if_ajson_mapping.

endclass.

class lcl_compound_mapper definition.

  public section.
    interfaces z2ui5_if_ajson_mapping.

    methods constructor
      importing
        it_queue type z2ui5_if_ajson_mapping=>ty_table_of.

  protected section.

  private section.
    data mt_queue type z2ui5_if_ajson_mapping=>ty_table_of.

endclass.

class lcl_to_snake definition.
  public section.
    interfaces z2ui5_if_ajson_mapping.
endclass.

class lcl_to_camel definition.
  public section.
    interfaces z2ui5_if_ajson_mapping.
    methods constructor
      importing
        iv_first_json_upper type abap_bool.
  private section.
    data mv_first_json_upper type abap_bool.
endclass.
