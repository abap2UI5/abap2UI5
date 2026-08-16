CLASS z2ui5_cx_ui5_util_error DEFINITION
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

    " The text this exception carries itself, WITHOUT the `previous` chain -
    " the counterpart of get_text( ), which renders the whole chain. Used to
    " render each cause exactly once.
    METHODS get_text_own
      RETURNING
        VALUE(result) TYPE string.

    " Same for any exception: the own text of a z2ui5 error, the plain
    " get_text( ) of every other exception class (cx_root=>get_text never
    " walks the chain).
    CLASS-METHODS get_text_own_by_x
      IMPORTING
        !val          TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    " The full diagnostic dump of an exception: the concise message chain
    " first, then one block per link of the `previous` chain with the
    " exception class, its own text, the source position it was raised at,
    " the kernel error id and every public attribute that carries a value
    " (e.g. source/target type of a CX_SY_MOVE_CAST_ERROR), followed by the
    " system context. This is what a 500 response body carries, so a report
    " of "it dumped" contains everything needed to locate the cause without
    " reproducing it on the system.
    " Works for ANY exception, not only for this class - the top-level catch
    " sees whatever was raised.
    CLASS-METHODS get_text_full
      IMPORTING
        !val          TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

    " Chain walks are bounded: a `previous` chain that points back into
    " itself (an exception passed as its own cause) would otherwise loop
    " forever inside the error renderer - the one place that must never hang.
    CONSTANTS cv_chain_max TYPE i VALUE 20.

    CLASS-METHODS get_text_full_entry
      IMPORTING
        !val          TYPE REF TO cx_root
        !index        TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_text_full_context
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cx_ui5_util_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    DATA lo_root TYPE REF TO cx_root.
    DATA lv_text TYPE string.
    DATA temp1 TYPE REF TO cx_root.

    TRY.
        lo_root ?= val.
      CATCH cx_root.
        lv_text = val.
    ENDTRY.

    " Keep the cause chain. The framework's dominant raise pattern hands the
    " caught exception over as `val` without a `previous` (see AGENTS.md,
    " "Exception handling"); without this fallback everything below it - the
    " actual root cause of a MOVE_CAST or a failed dynamic call, and with it
    " the source position of the method that really failed - is dropped and
    " only the outermost message ever reaches the client.

    IF previous IS BOUND.
      temp1 = previous.
    ELSE.
      temp1 = lo_root.
    ENDIF.
    super->constructor( previous = temp1 ).
    CLEAR textid.

    ms_error-x_root = lo_root.
    ms_error-text   = lv_text.
    ms_error-uuid   = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

  ENDMETHOD.

  METHOD get_text_own.

    IF ms_error-text IS NOT INITIAL.
      result = ms_error-text.
      RETURN.
    ENDIF.

    " an exception handed over as `val` is normally also the `previous` (see
    " constructor) and is rendered as its own chain entry - repeating it here
    " would print every such cause twice. Only when the caller passed a
    " DIFFERENT previous does x_root still need a voice of its own.
    IF ms_error-x_root IS BOUND AND ms_error-x_root <> previous.
      result = ms_error-x_root->get_text( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_text_own_by_x.
        DATA temp2 TYPE REF TO z2ui5_cx_ui5_util_error.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.

        temp2 ?= val.
        result = temp2->get_text_own( ).
      CATCH cx_sy_move_cast_error.
        result = val->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD if_message~get_text.

    DATA lv_count TYPE i.
    DATA lv_text  TYPE string.
    DATA lv_last LIKE result.
    DATA lo_x LIKE previous.
        DATA temp3 TYPE string.
    DATA temp4 TYPE string.

    result = get_text_own( ).

    lv_last = result.


    lo_x = previous.
    WHILE lo_x IS BOUND AND lv_count < cv_chain_max.
      lv_count = lv_count + 1.
      lv_text = get_text_own_by_x( lo_x ).
      " a wrapper that only re-raises repeats the text of its cause - print
      " it once instead of the same line N times
      IF lv_text IS NOT INITIAL AND lv_text <> lv_last.

        IF result IS INITIAL.
          temp3 = lv_text.
        ELSE.
          temp3 = result && z2ui5_cl_ui5_util_context=>cv_char_util_newline && lv_text.
        ENDIF.
        result = temp3.
        lv_last = lv_text.
      ENDIF.
      lo_x = lo_x->previous.
    ENDWHILE.

    " never answer with an empty text - a raise without val/previous would
    " otherwise produce a blank 500 body downstream

    IF result IS INITIAL.
      temp4 = `UNKNOWN_ERROR`.
    ELSE.
      temp4 = result.
    ENDIF.
    result = temp4.

  ENDMETHOD.

  METHOD get_text_full.

    DATA lv_count TYPE i.
    DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    DATA lv_message TYPE string.
    DATA temp5 TYPE string.
    DATA lo_x LIKE val.

    IF val IS NOT BOUND.
      result = `UNKNOWN_ERROR`.
      RETURN.
    ENDIF.


    lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.

    " The messages first, one per line: this section is what the frontend
    " lifts out for the error popup (app/webapp/core/ErrorView.js reads it by
    " its `--- error ---` header, everything after the next `--- ` header
    " stays behind Details) - keep the header spelling in sync with it.
    " get_text( ) on a z2ui5 error already renders the whole concise chain,
    " every other exception class has only its own text.

    lv_message = val->get_text( ).

    IF lv_message IS INITIAL.
      temp5 = `UNKNOWN_ERROR`.
    ELSE.
      temp5 = lv_message.
    ENDIF.
    lv_message = temp5.

    result = `--- error ---` && lv_nl && lv_message &&
             lv_nl && lv_nl && `--- exception chain ---`.


    lo_x = val.
    WHILE lo_x IS BOUND AND lv_count < cv_chain_max.
      lv_count = lv_count + 1.
      result = result && lv_nl && get_text_full_entry( val   = lo_x
                                                       index = lv_count ).
      lo_x = lo_x->previous.
    ENDWHILE.

    IF lo_x IS BOUND.
      result = result && lv_nl && |[...] chain truncated after { cv_chain_max } entries|.
    ENDIF.

    result = result && lv_nl && lv_nl && get_text_full_context( ).

  ENDMETHOD.

  METHOD get_text_full_entry.

    DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    DATA lv_text TYPE string.
    DATA lv_position TYPE string.
        DATA temp6 TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA lx_own LIKE temp6.
    DATA lt_attri TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp7 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp7.
    lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.

    result = |[{ index }] { z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( val ) }|.


    lv_text = get_text_own_by_x( val ).
    IF lv_text IS NOT INITIAL.
      result = result && lv_nl && |    text     : { lv_text }|.
    ENDIF.

    " the position is the answer to "which method failed?" - for a
    " CX_SY_MOVE_CAST_ERROR the text names the two types, only the position
    " names the class include and line that tried the cast

    lv_position = z2ui5_cl_ui5_util_context=>error_get_source_position( val ).
    IF lv_position IS NOT INITIAL.
      result = result && lv_nl && |    position : { lv_position }|.
    ENDIF.

    IF val->kernel_errid IS NOT INITIAL.
      result = result && lv_nl && |    kernel   : { val->kernel_errid }|.
    ENDIF.

    TRY.

        temp6 ?= val.

        lx_own = temp6.
        result = result && lv_nl && |    id       : { lx_own->ms_error-uuid }|.
      CATCH cx_sy_move_cast_error ##NO_HANDLER.
    ENDTRY.


    lt_attri = z2ui5_cl_ui5_util_context=>error_get_attributes( val ).


    LOOP AT lt_attri REFERENCE INTO lr_attri.
      result = result && lv_nl && |    { lr_attri->n } = { lr_attri->v }|.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_text_full_context.

    DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.

    " the runtime context of the failing request - what an issue report
    " otherwise has to ask back for
    result = `--- context ---` && lv_nl &&
             |    system   : { sy-sysid } / client { sy-mandt } / host { sy-host } / release { sy-saprl }| && lv_nl &&
             |    user     : { sy-uname } / language { sy-langu }| && lv_nl &&
             |    time     : { sy-datum } { sy-uzeit }|.

  ENDMETHOD.
ENDCLASS.
