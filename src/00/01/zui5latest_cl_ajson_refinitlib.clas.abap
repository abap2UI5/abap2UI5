CLASS zui5latest_cl_ajson_refinitlib DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS create_path_refs_init
      IMPORTING
        !it_data_refs       TYPE zui5latest_if_ajson_refinit=>tty_data_refs
      RETURNING
        VALUE(ri_refs_init) TYPE REF TO zui5latest_if_ajson_refinit
      RAISING
        zui5latest_cx_ajson_error.

ENDCLASS.



CLASS zui5latest_cl_ajson_refinitlib IMPLEMENTATION.


  METHOD create_path_refs_init.
    CREATE OBJECT ri_refs_init TYPE lcl_path_refs_init
      EXPORTING
        it_data_refs = it_data_refs.
  ENDMETHOD.
ENDCLASS.
