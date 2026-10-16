INTERFACE zui5latest_if_ajson_iterator
  PUBLIC.

  METHODS has_next
    RETURNING
      VALUE(rv_yes) TYPE abap_bool.

  METHODS next
    RETURNING
      VALUE(ri_item) TYPE REF TO zui5latest_if_ajson.

ENDINTERFACE.
