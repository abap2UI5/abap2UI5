"! <p class="shorttext synchronized">abap2UI5 - local rule-based provider</p>
"! z2ui5_if_ui5_llm without a model and without HTTP: the first rule whose
"! text the last user message contains (case-insensitive) is the answer,
"! the fallback when none does, the question itself when there is no
"! fallback. Deterministic and offline, so it runs on NW 7.02, on a system
"! without network, in a unit test and in the transpiled playground, and an
"! app written against z2ui5_if_ui5_llm can be shown before anyone has a key.
"! Token usage is counted in words - a stand-in that is stable, not a
"! tokenizer. s_options-max_tokens cuts the answer after that many words,
"! with stop_reason max_tokens, the way a real provider does.
CLASS z2ui5_cl_ui5_llm_local DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm.

    "! the model name the result reports
    CONSTANTS cv_model TYPE string VALUE `local`.

    METHODS constructor
      IMPORTING
        t_rule   TYPE z2ui5_cl_ui5_llm=>ty_t_rule OPTIONAL
        fallback TYPE clike OPTIONAL.

    "! the number of blank-separated words of a text
    CLASS-METHODS count_words
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE i.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA mt_rule TYPE z2ui5_cl_ui5_llm=>ty_t_rule.
    DATA mv_fallback TYPE string.

    CLASS-METHODS words
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    METHODS answer
      IMPORTING
        question      TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm_local IMPLEMENTATION.

  METHOD constructor.

    mt_rule     = t_rule.
    mv_fallback = fallback.

  ENDMETHOD.

  METHOD words.

    DATA lv_text TYPE string.

    lv_text = val.
    REPLACE ALL OCCURRENCES OF z2ui5_cl_ui5_util_context=>cv_char_util_newline IN lv_text WITH ` `.
    REPLACE ALL OCCURRENCES OF z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab IN lv_text WITH ` `.
    lv_text = condense( lv_text ).
    IF lv_text = ``.
      RETURN.
    ENDIF.
    SPLIT lv_text AT ` ` INTO TABLE result.

  ENDMETHOD.

  METHOD count_words.

    result = lines( words( val ) ).

  ENDMETHOD.

  METHOD answer.

    DATA lv_question TYPE string.
    DATA lv_key TYPE string.

    lv_question = to_upper( question ).
    LOOP AT mt_rule INTO DATA(ls_rule).
      IF ls_rule-contains = ``.
        CONTINUE.
      ENDIF.
      lv_key = to_upper( ls_rule-contains ).
      IF lv_question CS lv_key.
        result = ls_rule-answer.
        RETURN.
      ENDIF.
    ENDLOOP.

    result = COND #( WHEN mv_fallback IS INITIAL THEN question ELSE mv_fallback ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_llm~chat.

    DATA lv_question TYPE string.
    DATA lv_input TYPE string.
    DATA lv_word TYPE string.

    LOOP AT t_message INTO DATA(ls_message).
      lv_input = |{ lv_input } { ls_message-content }|.
      IF ls_message-role = z2ui5_if_ui5_llm=>cs_role-user.
        lv_question = ls_message-content.
      ENDIF.
    ENDLOOP.
    IF lv_question IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = `a chat call needs a user message with content`.
    ENDIF.
    lv_input = |{ system } { lv_input }|.

    result-model                = cv_model.
    result-stop_reason          = z2ui5_if_ui5_llm=>cs_stop-end_turn.
    result-text                 = answer( lv_question ).
    result-s_usage-input_tokens = count_words( lv_input ).

    DATA(lt_word) = words( result-text ).
    IF s_options-max_tokens > 0 AND lines( lt_word ) > s_options-max_tokens.
      CLEAR result-text.
      LOOP AT lt_word INTO lv_word TO s_options-max_tokens.
        result-text = COND #( WHEN result-text IS INITIAL THEN lv_word ELSE |{ result-text } { lv_word }| ).
      ENDLOOP.
      result-stop_reason = z2ui5_if_ui5_llm=>cs_stop-max_tokens.
    ENDIF.
    result-s_usage-output_tokens = count_words( result-text ).

  ENDMETHOD.

ENDCLASS.
