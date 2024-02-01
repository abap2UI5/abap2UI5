interface z2ui5_if_ajson
  public.

  constants version type string value 'v1.1.9'. "#EC NOTEXT
  constants origin type string value 'https://github.com/sbcgua/ajson'. "#EC NOTEXT
  constants license type string value 'MIT'. "#EC NOTEXT

  types:
    begin of ty_opts,
      read_only type abap_bool,
      keep_item_order type abap_bool,
      format_datetime type abap_bool,
      to_abap_corresponding_only type abap_bool,
    end of ty_opts.

  " DATA

  data mt_json_tree type z2ui5_if_ajson_types=>ty_nodes_ts read-only.

  " CLONING

  methods clone
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.
  methods filter
    importing
      ii_filter type ref to z2ui5_if_ajson_filter
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.
  methods map
    importing
      ii_mapper type ref to z2ui5_if_ajson_mapping
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  " METHODS

  methods freeze.
  methods keep_item_order
    returning
      value(ri_json) type ref to z2ui5_if_ajson.
  methods format_datetime
    importing
      iv_use_iso type abap_bool default abap_true
    returning
      value(ri_json) type ref to z2ui5_if_ajson.
  methods to_abap_corresponding_only
    importing
      iv_enable type abap_bool default abap_true
    returning
      value(ri_json) type ref to z2ui5_if_ajson.
  methods opts
    returning
      value(rs_opts) type ty_opts.

  " METHODS ex.reader

  methods is_empty
    returning
      value(rv_yes) type abap_bool.

  methods exists
    importing
      iv_path type string
    returning
      value(rv_exists) type abap_bool.

  methods members
    importing
      iv_path type string
    returning
      value(rt_members) type string_table.

  methods get
    importing
      iv_path type string
    returning
      value(rv_value) type string.

  methods get_node_type
    importing
      iv_path type string
    returning
      value(rv_node_type) type z2ui5_if_ajson_types=>ty_node_type.

  methods get_boolean
    importing
      iv_path type string
    returning
      value(rv_value) type abap_bool.

  methods get_integer
    importing
      iv_path type string
    returning
      value(rv_value) type i.

  methods get_number
    importing
      iv_path type string
    returning
      value(rv_value) type f.

  methods get_date
    importing
      iv_path type string
    returning
      value(rv_value) type d.

  methods get_timestamp
    importing
      iv_path type string
    returning
      value(rv_value) type timestamp.

  methods get_string
    importing
      iv_path type string
    returning
      value(rv_value) type string.

  methods slice
    importing
      iv_path type string
    returning
      value(ri_json) type ref to z2ui5_if_ajson.

  methods to_abap
    importing
      iv_corresponding type abap_bool default abap_false
    exporting
      ev_container type any
    raising
      z2UI5_cx_ajson_error.

  methods array_to_string_table
    importing
      iv_path type string
    returning
      value(rt_string_table) type string_table
    raising
      z2UI5_cx_ajson_error.

  " METHODS ex.writer

  methods clear
    raising
      z2UI5_cx_ajson_error.

  methods set
    importing
      iv_path type string
      iv_val type any
      iv_ignore_empty type abap_bool default abap_true
      iv_node_type type z2ui5_if_ajson_types=>ty_node_type optional
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods setx
    importing
      iv_param type string
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_boolean
    importing
      iv_path type string
      iv_val type any
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_string
    importing
      iv_path type string
      iv_val type clike
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_integer
    importing
      iv_path type string
      iv_val type i
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_date
    importing
      iv_path type string
      iv_val type d
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_timestamp
    importing
      iv_path type string
      iv_val type timestamp
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods set_null
    importing
      iv_path type string
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods delete
    importing
      iv_path type string
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods touch_array
    importing
      iv_path type string
      iv_clear type abap_bool default abap_false
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods push
    importing
      iv_path type string
      iv_val type any
    returning
      value(ri_json) type ref to z2ui5_if_ajson
    raising
      z2UI5_cx_ajson_error.

  methods stringify
    importing
      iv_indent type i default 0
    returning
      value(rv_json) type string
    raising
      z2UI5_cx_ajson_error.

endinterface.
