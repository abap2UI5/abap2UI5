INTERFACE z2ui5_if_config
  PUBLIC.

  METHODS get_event_method
    IMPORTING
      event_object  TYPE string
    RETURNING
      VALUE(result) TYPE string.

  METHODS get_attr_name_by_ref
    IMPORTING
      ref           TYPE data
    RETURNING
      VALUE(result) TYPE string.

  DATA mo_view_model TYPE REF TO z2ui5_cl_hlp_tree_json.

ENDINTERFACE.
