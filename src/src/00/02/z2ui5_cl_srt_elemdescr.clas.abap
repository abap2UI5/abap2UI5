"! <p class="shorttext synchronized" lang="en">Serializable RTTI elementary type</p>
CLASS z2ui5_cl_srt_elemdescr DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_srt_datadescr
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA edit_mask     LIKE cl_abap_elemdescr=>edit_mask.
    DATA help_id       LIKE cl_abap_elemdescr=>help_id.
    DATA output_length LIKE cl_abap_elemdescr=>output_length.

    METHODS constructor
      IMPORTING
        !rtti TYPE REF TO cl_abap_elemdescr.

    METHODS get_rtti
      REDEFINITION.
  PROTECTED SECTION.
    METHODS get_rtti_by_type_kind
      IMPORTING
        i_type_kind LIKE cl_abap_typedescr=>type_kind
      RETURNING
        VALUE(rtti) TYPE REF TO cl_abap_typedescr.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_srt_elemdescr IMPLEMENTATION.


  METHOD constructor.
    super->constructor( rtti ).

    edit_mask     = rtti->edit_mask.
    help_id       = rtti->help_id.
    output_length = rtti->output_length.
  ENDMETHOD.


  METHOD get_rtti.
    rtti = super->get_rtti( ).
    IF rtti IS BOUND.
      RETURN.
    ENDIF.

    IF     is_ddic_type   = abap_true
       AND technical_type = abap_false.
      " If XML transformations are used, they may be based on
      " the data element, for instance XSDBOOLEAN will convert "true"
      " into "X" during deserialization.
      rtti = cl_abap_typedescr=>describe_by_name( absolute_name ).
    ELSE.
      rtti = get_rtti_by_type_kind( type_kind ).
    ENDIF.
  ENDMETHOD.


  METHOD get_rtti_by_type_kind.
    DATA l_length TYPE i.

    CASE i_type_kind.
      WHEN cl_abap_typedescr=>typekind_num.
        l_length = length / cl_abap_char_utilities=>charsize.
        rtti = cl_abap_elemdescr=>get_n( l_length ).
      WHEN cl_abap_typedescr=>typekind_char.
        l_length = length / cl_abap_char_utilities=>charsize.
        rtti = cl_abap_elemdescr=>get_c( l_length ).
      WHEN cl_abap_typedescr=>typekind_string.
        rtti = cl_abap_elemdescr=>get_string( ).
      WHEN cl_abap_typedescr=>typekind_xstring.
        rtti = cl_abap_elemdescr=>get_xstring( ).
      WHEN cl_abap_typedescr=>typekind_int.
        rtti = cl_abap_elemdescr=>get_i( ).
      WHEN cl_abap_typedescr=>typekind_float.
        rtti = cl_abap_elemdescr=>get_f( ).
      WHEN cl_abap_typedescr=>typekind_date.
        rtti = cl_abap_elemdescr=>get_d( ).
      WHEN cl_abap_typedescr=>typekind_time.
        rtti = cl_abap_elemdescr=>get_t( ).
      WHEN cl_abap_typedescr=>typekind_hex.
        rtti = cl_abap_elemdescr=>get_x( length ).
      WHEN cl_abap_typedescr=>typekind_packed.
        rtti = cl_abap_elemdescr=>get_p( p_length   = length
                                         p_decimals = decimals ).
      WHEN cl_abap_typedescr=>typekind_decfloat16.
        rtti = cl_abap_elemdescr=>get_decfloat16( ).
      WHEN cl_abap_typedescr=>typekind_decfloat34.
        rtti = cl_abap_elemdescr=>get_decfloat34( ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE z2ui5_cx_srt.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
