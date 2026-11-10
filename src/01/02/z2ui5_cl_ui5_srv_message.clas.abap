"! What a message box shows. Everything message_box_display( ) decides
"! about its `text` is decided here: whether the value is a message (a
"! BAPIRET2 table, a RAP response, a log, an exception), which box type and
"! title follow from it, what an error without a text says instead of
"! nothing, and when the box falls back to rendering the data.
"! The READERS stay in z2ui5_cl_ui5_util_context (msg_get_t and the RAP
"! walk behind it, the data renderer ui5_data_box_format) - they are
"! generic and shared with abap-util. This class is the framework's
"! policy on top of them, and z2ui5_cl_ui5_frontend only queues what it
"! answers.
CLASS z2ui5_cl_ui5_srv_message DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      "! The texts a box shows when an error carries none of its own.
      "! English like every other text the framework composes (the RAP
      "! fail causes in z2ui5_cl_ui5_util_context=>msg_get_rap_fail_text).
      BEGIN OF cs_text,
        "! nothing to show at all, and the app asked for an error box
        failed        TYPE string VALUE `The operation failed, no further details available`,
        "! one error message without a text and without a T100 key
        error_no_text TYPE string VALUE `Error without message text`,
      END OF cs_text.

    "! Resolve what the message box actually shows. The result carries the
    "! MessageBox display method in `type`, lowercased and guaranteed to be
    "! one the whitelisted global call accepts. `skip` is the one answer
    "! that shows no box: complex data that is initial, handed over with a
    "! type other than `error`.
    CLASS-METHODS box_resolve
      IMPORTING
        text          TYPE any
        type          TYPE clike
        title         TYPE clike
        details       TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    "! The MESSAGES in val as one box: type and title from the most severe
    "! one, a single text as it is, several as a counting headline plus a
    "! list in the details. Answers `skip` when nothing in val is a
    "! message - the caller renders the data then.
    CLASS-METHODS box_format_msg
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    "! The standard text of an error message that carries none, or empty
    "! when msg is not such a message - see the method body for what
    "! counts as one.
    CLASS-METHODS text_default
      IMPORTING
        msg           TYPE z2ui5_cl_ui5_util_context=>ty_s_msg
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! The sap.m.MessageBox display methods, i.e. the box types the
    "! whitelisted global call accepts. Filled lazily in box_resolve - a
    "! class_constructor would have to be PUBLIC, widening the API for an
    "! internal list.
    CLASS-DATA ct_box_type TYPE string_table.

ENDCLASS.


CLASS z2ui5_cl_ui5_srv_message IMPLEMENTATION.

  METHOD box_resolve.

    IF ct_box_type IS INITIAL.
      ct_box_type = VALUE #( ( `show` )
                             ( `alert` )
                             ( `confirm` )
                             ( `information` )
                             ( `warning` )
                             ( `error` )
                             ( `success` ) ).
    ENDIF.

    " MESSAGES FIRST. A BAPIRET2 table, a RAP response, a log object, an
    " exception, a plain message structure - that is what most apps hand
    " over, and the formatter is the one place that knows all of their
    " shapes, their severity and their titles. Only when NOTHING in there is
    " a message does the generic renderer below get a turn, so nothing about
    " the message path changes for an app that was already using it
    DATA(lv_is_msg) = abap_false.
    IF z2ui5_cl_ui5_util_context=>rtti_check_clike( text ) = abap_false.
      result = box_format_msg( text ).
      lv_is_msg = xsdbool( result-skip = abap_false ).
    ENDIF.

    IF lv_is_msg = abap_true.
      IF title IS NOT INITIAL.
        result-title = title.
      ENDIF.
    ELSE.
      " no messages in there, or a character value, which is its own text:
      " show the DATA. A table, a nested structure, a tree, an object, an
      " HTML string, a number - the app throws in what it has and the box
      " renders it rather than staying empty or not appearing at all
      result = z2ui5_cl_ui5_util_context=>ui5_data_box_format( text ).

      " MessageBox display methods are lowercase (show, error, warning, ...)
      " and the type arrives however an app spelled it, so it is lowercased
      " right here - `Information` gets the same show-mapping and default
      " title as `information` (box_format_msg lower-cases its own)
      DATA(lv_type) = to_lower( type ).

      IF result-skip = abap_true.
        " nothing to show: complex data that is initial - an empty message
        " table, an empty RAP response, an unbound reference. An app that
        " asks for an ERROR box has an error to report all the same (the
        " EML statement failed and REPORTED came back empty), so the box
        " says so with the standard text instead of not appearing. Every
        " other type stays as silent as it always was: a BAPI return table
        " without messages is the normal case, not an event
        IF lv_type <> `error`.
          RETURN.
        ENDIF.
        result = VALUE #( text = cs_text-failed ).
      ENDIF.

      result-type  = lv_type.
      result-title = title.

      IF result-type = `information`.
        result-type = `show`.
        IF result-title IS INITIAL.
          result-title = `Information`.
        ENDIF.
      ENDIF.
    ENDIF.

    " the details the app passed fill the slot the resolver left empty -
    " they never overwrite a rendering, which IS the data the app asked to
    " see
    IF result-details IS INITIAL.
      result-details = details.
    ENDIF.

    " the type travels as the method of the whitelisted global call, so a type
    " that is no MessageBox display method would be rejected there and the box
    " would not appear at all - a requested box is never dropped silently, it
    " falls back to a plain show( ) like the frontend used to do
    IF NOT line_exists( ct_box_type[ table_line = result-type ] ). "#EC CI_SORTSEQ
      result-type = `show`.
    ENDIF.

  ENDMETHOD.

  METHOD box_format_msg.

    DATA(lt_msg) = z2ui5_cl_ui5_util_context=>msg_get_t( val ).

    " an error that names itself as a message and still has no text gets
    " the standard one - before the entries without a text are dropped
    LOOP AT lt_msg REFERENCE INTO DATA(lr_text) WHERE text IS INITIAL. "#EC CI_SORTSEQ
      lr_text->text = text_default( lr_text->* ).
    ENDLOOP.

    " a structure that carries none of the message components maps to an
    " entry with no text at all - that is not a message, it is data, and it
    " used to reach the box as a popup with a blank line in it. Dropping it
    " here is what lets `skip` mean "nothing in here is a message" and lets
    " the caller fall back to ui5_data_box_format( )
    DELETE lt_msg WHERE text IS INITIAL.

    DATA(lv_lines) = lines( lt_msg ).

    IF lv_lines = 0.
      result-skip = abap_true.
      RETURN.
    ENDIF.

    " the box takes its type/title from the MOST SEVERE message, also when
    " several are collapsed into one box below: a warning followed by an
    " error is an error box (it took the first message's type until
    " 2026-10, which opened [W, E] as a warning). Error over warning over
    " success and information, which rank the same - the first of them wins
    DATA(lv_type) = ``.
    DATA(lv_rank) = -1.
    LOOP AT lt_msg REFERENCE INTO DATA(lr_type).
      DATA(lv_type_row) = z2ui5_cl_ui5_util_context=>ui5_get_msg_type( lr_type->type ).
      DATA(lv_rank_row) = COND i( WHEN lv_type_row = z2ui5_cl_ui5_util_context=>cs_ui5_msg_type-e THEN 2
                                  WHEN lv_type_row = z2ui5_cl_ui5_util_context=>cs_ui5_msg_type-w THEN 1
                                  ELSE 0 ).
      IF lv_rank_row > lv_rank.
        lv_rank = lv_rank_row.
        lv_type = lv_type_row.
      ENDIF.
    ENDLOOP.
    result-title = lv_type.
    result-type  = to_lower( lv_type ).

    IF lv_lines = 1.
      result-text = lt_msg[ 1 ]-text.
      RETURN.
    ENDIF.

    " several messages: a counting headline plus every text as a bullet. No
    " blank around it - the box shows the text as written, and the template
    " used to carry one on either side
    result-text = |{ lv_lines } Messages found:|.
    DATA lt_detail_items TYPE string_table.
    " the texts are data inside markup, escaped like every sibling renderer
    " escapes its values: unescaped, `Enter a value for <MATNR>` lost its
    " token to the frontend sanitizer, which drops an unknown element
    LOOP AT lt_msg REFERENCE INTO DATA(lr_msg).
      INSERT |<li>{ z2ui5_cl_ui5_util_context=>c_escape_html( lr_msg->text ) }</li>| INTO TABLE lt_detail_items.
    ENDLOOP.
    result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.

  ENDMETHOD.

  METHOD text_default.

    " only an ERROR - a text-less success or information is nothing a user
    " has to hear about, and it is dropped like any other empty entry
    IF z2ui5_cl_ui5_util_context=>ui5_get_msg_type( msg-type ) <> z2ui5_cl_ui5_util_context=>cs_ui5_msg_type-e.
      RETURN.
    ENDIF.

    " ... and only one that IDENTIFIES itself as a message. A type alone
    " does not: msg_get_t maps every component of whatever the app handed
    " over BY NAME, so a business row with a column called TYPE holding `E`
    " looks exactly like a message without a text - and is data, which the
    " caller renders. Two things make an entry a message beyond doubt:
    "   a T100 key  - class AND number, the pair msg_get_internal asks for
    "                 before it reads a text. The text is named by its key,
    "                 so whoever reads the box can look the message up
    "   a RAP row   - t_meta is filled by msg_get_rap_row and nowhere else
    IF msg-id IS NOT INITIAL AND msg-no IS NOT INITIAL.
      result = |Error { to_upper( msg-id ) } { msg-no } (no message text available)|.
    ELSEIF msg-t_meta IS NOT INITIAL.
      result = cs_text-error_no_text.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
