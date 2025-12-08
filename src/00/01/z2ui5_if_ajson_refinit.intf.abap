INTERFACE z2ui5_if_ajson_refinit PUBLIC.

  TYPES:
    BEGIN OF ty_data_ref,
      path TYPE string,
      name TYPE string,
      dref TYPE REF TO data,
    END OF ty_data_ref.
  TYPES:
    tty_data_refs TYPE STANDARD TABLE OF ty_data_ref
      WITH UNIQUE SORTED KEY by_path COMPONENTS path name.

  METHODS get_data_ref
    IMPORTING
      !is_node      TYPE z2ui5_if_ajson_types=>ty_node
    RETURNING
      VALUE(ro_ref) TYPE REF TO data.

ENDINTERFACE.
