"! <p class="shorttext synchronized" lang="en">Serializable RTTI table</p>
CLASS z2ui5_cl_srt_tabledescr DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_srt_complexdescr
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA key            LIKE cl_abap_tabledescr=>key.
    DATA initial_size   LIKE cl_abap_tabledescr=>initial_size.
    DATA key_defkind    LIKE cl_abap_tabledescr=>key_defkind.
    DATA has_unique_key LIKE cl_abap_tabledescr=>has_unique_key.
    DATA table_kind     LIKE cl_abap_tabledescr=>table_kind.
    DATA line_type      TYPE REF TO z2ui5_cl_srt_datadescr.

    METHODS constructor
      IMPORTING
        !rtti TYPE REF TO cl_abap_tabledescr.

    METHODS get_rtti
      REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_srt_tabledescr IMPLEMENTATION.
  METHOD constructor.
    super->constructor( rtti ).
    key            = rtti->key.
    initial_size   = rtti->initial_size.
    key_defkind    = rtti->key_defkind.
    has_unique_key = rtti->has_unique_key.
    table_kind     = rtti->table_kind.

    line_type ?= z2ui5_cl_srt_typedescr=>create_by_rtti( rtti->get_table_line_type( ) ).
    IF line_type->not_serializable = abap_true.
      not_serializable = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_rtti.
    DATA lt_empty_key TYPE abap_keydescr_tab.
    DATA lo_data_rtti TYPE REF TO cl_abap_datadescr.
    DATA lo_error     TYPE REF TO cx_sy_table_creation.

    FIELD-SYMBOLS <lt_key> TYPE abap_keydescr_tab.

    CLEAR lt_empty_key.
    CASE key_defkind.
      WHEN cl_abap_tabledescr=>keydefkind_user.
        ASSIGN key TO <lt_key>.
      WHEN OTHERS.
        ASSIGN lt_empty_key TO <lt_key>.
    ENDCASE.
    TRY.

        lo_data_rtti ?= line_type->get_rtti( ).
        rtti = cl_abap_tabledescr=>create( p_line_type  = lo_data_rtti
                                           p_table_kind = table_kind
                                           p_unique     = has_unique_key
                                           p_key        = <lt_key>
                                           p_key_kind   = key_defkind ).

      CATCH cx_sy_table_creation INTO lo_error.
        RAISE EXCEPTION TYPE z2ui5_cx_srt
          EXPORTING previous = lo_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
