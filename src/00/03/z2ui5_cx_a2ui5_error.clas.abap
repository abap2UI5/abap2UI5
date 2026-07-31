CLASS z2ui5_cx_a2ui5_error DEFINITION
  PUBLIC
  INHERITING FROM cx_no_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        text   TYPE string,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val       TYPE any            OPTIONAL
        !previous TYPE REF TO cx_root OPTIONAL
          PREFERRED PARAMETER val.

    METHODS if_message~get_text REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cx_a2ui5_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root.
        ms_error-text = val.
    ENDTRY.
    ms_error-uuid = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).

  ENDMETHOD.

  METHOD if_message~get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text( ).
    ELSEIF ms_error-text IS NOT INITIAL.
      result = ms_error-text.
    ENDIF.

    IF previous IS BOUND.
      DATA(lo_x) = previous.
      WHILE lo_x IS BOUND.
        result = result && z2ui5_cl_a2ui5_context=>cv_char_util_newline && lo_x->get_text( ).
        " a nested z2ui5 error just rendered its own previous-chain -
        " walking it again here would duplicate every deeper cause
        TRY.
            DATA(lo_dummy) = CAST z2ui5_cx_a2ui5_error( lo_x ) ##NEEDED.
            EXIT.
          CATCH cx_sy_move_cast_error.
            lo_x = lo_x->previous.
        ENDTRY.
      ENDWHILE.
    ENDIF.

    " never answer with an empty text - a raise without val/previous would
    " otherwise produce a blank 500 body downstream
    result = COND #( WHEN result IS INITIAL THEN `UNKNOWN_ERROR` ELSE result ).

  ENDMETHOD.
ENDCLASS.
