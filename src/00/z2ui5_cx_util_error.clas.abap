class Z2UI5_CX_UTIL_ERROR definition
  public
  inheriting from CX_NO_CHECK
  final
  create public .

public section.

  data:
    BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        text   TYPE string,
      END OF ms_error .

  methods CONSTRUCTOR
    importing
      !VAL type ANY optional
      !PREVIOUS type ref to CX_ROOT optional
    preferred parameter VAL .

  methods IF_MESSAGE~GET_TEXT
    redefinition .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CX_UTIL_ERROR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root.
        ms_error-text = val.
    ENDTRY.
    ms_error-uuid = z2ui5_cl_util_func=>func_get_uuid_32( ).

  ENDMETHOD.


  METHOD IF_MESSAGE~get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text( ).
      DATA(error) = abap_true.
    ELSEIF ms_error-text IS NOT INITIAL.
      result = ms_error-text.
      error = abap_true.
    ENDIF.

    result = COND #( WHEN error = abap_true AND result IS INITIAL THEN `unknown error` else result ).

  ENDMETHOD.
ENDCLASS.
