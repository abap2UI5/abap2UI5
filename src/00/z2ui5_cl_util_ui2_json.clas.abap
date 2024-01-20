CLASS z2ui5_cl_util_ui2_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM /ui2/cl_json.

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS is_compressable REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_ui2_json IMPLEMENTATION.

  METHOD is_compressable.

    rv_compress = super->is_compressable(
        type_descr  = type_descr
        name        = name ).

    IF z2ui5_cl_util_func=>boolean_check_by_name( type_descr->get_relative_name( ) ).
      rv_compress = abap_false.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
