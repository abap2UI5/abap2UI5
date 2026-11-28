CLASS z2ui5_cl_ui5_ajs_rilib DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS create_path_refs_init
      IMPORTING
        !it_data_refs       TYPE z2ui5_if_ui5_ajs_rinit=>tty_data_refs
      RETURNING
        VALUE(ri_refs_init) TYPE REF TO z2ui5_if_ui5_ajs_rinit
      RAISING
        z2ui5_cx_ui5_ajs_error.

ENDCLASS.



CLASS z2ui5_cl_ui5_ajs_rilib IMPLEMENTATION.


  METHOD create_path_refs_init.
    CREATE OBJECT ri_refs_init TYPE lcl_path_refs_init
      EXPORTING
        it_data_refs = it_data_refs.
  ENDMETHOD.
ENDCLASS.
