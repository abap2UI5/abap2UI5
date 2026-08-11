CLASS z2ui5_cl_core_srv_event DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    METHODS get_event
      IMPORTING
        val           TYPE clike                              OPTIONAL
        t_arg         TYPE string_table                       OPTIONAL
        s_cnt         TYPE z2ui5_if_types=>ty_s_event_control OPTIONAL
          PREFERRED PARAMETER val
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_event_client
      IMPORTING
        val           TYPE clike
        view          TYPE clike        DEFAULT z2ui5_if_client=>cs_view-main
        t_arg         TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    "! The JSON-array form of a frontend action, as the ajson it is built
    "! in - the response embeds it as a real nested array, so no string
    "! round trip happens on the way out.
    METHODS get_event_client_ajson
      IMPORTING
        val           TYPE clike
        view          TYPE clike        DEFAULT z2ui5_if_client=>cs_view-main
        t_arg         TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson.

    "! The same action stringified - for the places that need the action as
    "! TEXT rather than as part of the response JSON.
    METHODS get_event_client_json
      IMPORTING
        val           TYPE clike
        view          TYPE clike        DEFAULT z2ui5_if_client=>cs_view-main
        t_arg         TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    TYPES:
      BEGIN OF ty_s_client_event,
        val   TYPE string,
        t_arg TYPE string_table,
      END OF ty_s_client_event.

    METHODS map_client_event
      IMPORTING
        val           TYPE clike
        view          TYPE clike
        t_arg         TYPE string_table
      RETURNING
        VALUE(result) TYPE ty_s_client_event.

    METHODS get_t_arg
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
    " Escape a value so it is safe as the body of a single-quoted JS string
    " literal emitted into the view XML. Backslash MUST be escaped first (so
    " the escapes added afterwards are not themselves re-escaped); without it a
    " value ending in '\' or containing "\'" breaks out of the '...' wrapper
    " and the trailing text is evaluated as JS. CR/LF are escaped too - a raw
    " newline is a syntax error inside a single-quoted JS literal.
    CLASS-METHODS escape_js_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_core_srv_event IMPLEMENTATION.

  METHOD get_event.

    " preventDefault() only has an effect while the control's own handler is
    " running, so it cannot be a follow-up action from the response: the
    " event is bound to .eBP instead, which cancels the default and then
    " roundtrips like .eB. It needs the UI5 event object, which UI5 resolves
    " for the reserved $event argument in the handler expression.
    "
    " eBP's second argument is the veto CONDITION. The flag form sends the
    " constant `true`; prevent_default_expr sends an expression instead, which
    " UI5 resolves per firing like any other $-prefixed argument - so one wire
    " can veto one row/column and let the rest through.
    DATA lv_func TYPE string.
    DATA lv_event_arg TYPE string.
    IF s_cnt-prevent_default_expr IS NOT INITIAL.
      lv_func = z2ui5_if_core_types=>cs_ui5-event_backend_prevent.
      lv_event_arg = |$event,{ s_cnt-prevent_default_expr },|.
    ELSEIF s_cnt-check_prevent_default = abap_true.
      lv_func = z2ui5_if_core_types=>cs_ui5-event_backend_prevent.
      lv_event_arg = `$event,true,`.
    ELSE.
      lv_func = z2ui5_if_core_types=>cs_ui5-event_backend_function.
    ENDIF.

    result = |{ lv_func }({ lv_event_arg }['{ escape_js_string( CONV string( val ) ) }'|.

    IF s_cnt-check_allow_multi_req = abap_true.
      result = |{ result },false,true|.
    ENDIF.

    result = |{ result }]{ get_t_arg( t_arg ) }|.

  ENDMETHOD.

  METHOD get_event_client.

    DATA(ls_event) = map_client_event( val   = val
                                       view  = view
                                       t_arg = t_arg ).

    result = |{ z2ui5_if_core_types=>cs_ui5-event_frontend_function }('{ escape_js_string( ls_event-val ) }'{ get_t_arg( ls_event-t_arg ) }|.

  ENDMETHOD.

  METHOD map_client_event.

    DATA(lv_val) = CONV string( val ).
    DATA(lt_arg) = t_arg.

    " NavContainer navigation reuses the generic cs_event-control_by_id call
    " so the frontend needs only the one generic dispatcher. Both the backend
    " follow-up action and the XML-bound client event (_event_client) are
    " formatted here, so this is the single place the *_nav_container_to events
    " are remapped to `<container>, <slot>, to, <target>`. The public
    " cs_event-*_nav_container_to constant values stay unchanged.
    DATA(lv_slot) = SWITCH string( lv_val
                                   WHEN z2ui5_if_client=>cs_event-nav_container_to         THEN z2ui5_if_client=>cs_view-main
                                   WHEN z2ui5_if_client=>cs_event-nest_nav_container_to    THEN z2ui5_if_client=>cs_view-nested
                                   WHEN z2ui5_if_client=>cs_event-nest2_nav_container_to   THEN z2ui5_if_client=>cs_view-nested2
                                   WHEN z2ui5_if_client=>cs_event-popup_nav_container_to   THEN z2ui5_if_client=>cs_view-popup
                                   WHEN z2ui5_if_client=>cs_event-popover_nav_container_to THEN z2ui5_if_client=>cs_view-popover
                                   ELSE `` ).
    IF lv_slot IS NOT INITIAL.
      " read from t_arg (the unchanged importing parameter), never from lt_arg
      " which is the assignment target here - referencing the target inside its
      " own VALUE constructor reads it while it is being rebuilt in place
      lt_arg = VALUE #( ( VALUE #( t_arg[ 1 ] OPTIONAL ) )
                        ( lv_slot )
                        ( `to` )
                        ( VALUE #( t_arg[ 2 ] OPTIONAL ) ) ).
      lv_val = z2ui5_if_client=>cs_event-control_by_id.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-popup_close
        OR lv_val = z2ui5_if_client=>cs_event-popover_close.
      " Closing a popup IS tearing its slot down - the same call the framework
      " itself queues for a popup_destroy( ) or an app switch. The two public
      " constants stay ( an app closes its dialog with _event_client(
      " cs_event-popup_close ), round-trip free, and that is the whole point
      " of them ), but they are formatted as the one VIEW_SLOTS call here, so
      " the frontend has a single teardown path rather than a second handler
      " that happens to do the same thing.
      lt_arg = VALUE #( ( z2ui5_if_core_types=>cs_slot_action-target )
                        ( z2ui5_if_core_types=>cs_slot_action-destroy )
                        ( COND #( WHEN lv_val = z2ui5_if_client=>cs_event-popup_close
                                  THEN z2ui5_if_client=>cs_view-popup
                                  ELSE z2ui5_if_client=>cs_view-popover ) ) ).
      lv_val = z2ui5_if_client=>cs_event-control_global.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-control_by_id.
      " the view is passed as its own parameter now, not as a positional
      " t_arg slot; inject it at position 2 so the frontend still reads
      " args = id, view, method, ... . cs_view-main maps to the empty slot,
      " keeping the unchanged default where the id resolves across all open
      " views (resolveById); a concrete view scopes the lookup to that slot.
      DATA(lv_view_slot) = COND string( WHEN view = z2ui5_if_client=>cs_view-main THEN ``
                                        ELSE CONV string( view ) ).
      INSERT lv_view_slot INTO lt_arg INDEX 2.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-bind_element.
      " element-bind a whole view slot to a table row: args = slot, index,
      " path. The path comes from client->_bind( table ); _bind returns the
      " binding with braces ({/MT_TAB}), which would be an invalid raw JS
      " argument, so strip the braces here to a plain path ('/MT_TAB') that
      " get_t_arg then quotes. The slot is the follow_up_action view parameter.
      DATA(lv_bind_path) = VALUE string( t_arg[ 2 ] OPTIONAL ).
      REPLACE ALL OCCURRENCES OF `{` IN lv_bind_path WITH ``.
      REPLACE ALL OCCURRENCES OF `}` IN lv_bind_path WITH ``.
      lt_arg = VALUE #( ( CONV string( view ) )
                        ( VALUE #( t_arg[ 1 ] OPTIONAL ) )
                        ( lv_bind_path ) ).
    ENDIF.

    result-val   = lv_val.
    result-t_arg = lt_arg.

  ENDMETHOD.

  METHOD get_event_client_json.

    TRY.
        result = get_event_client_ajson( val   = val
                                         view  = view
                                         t_arg = t_arg )->stringify( ).
      CATCH z2ui5_cx_ajson_error INTO DATA(lx_error).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.


  METHOD get_event_client_ajson.

    " Serialize a framework follow-up action as DATA - a JSON array
    " ["EVENT", arg1, ...] - instead of an executable eF( ) JS snippet. The
    " backend owns the whole serialization including the escaping (via AJSON);
    " the frontend only dispatches the array (FrontendAction.runCustom /
    " runSystem), so no code is built here or parsed there on this path. The
    " XML-bound handler strings (get_event_client) keep the JS form - they
    " live inside view XML, where UI5 itself parses the handler expression.
    DATA(ls_event) = map_client_event( val   = val
                                       view  = view
                                       t_arg = t_arg ).

    " same contract as get_t_arg: an empty argument between filled ones keeps
    " its position, trailing empties are dropped - the frontend only casts the
    " args that were sent, so a trailing `` would turn open() into open('')
    DATA(lv_index) = lines( ls_event-t_arg ).
    WHILE lv_index > 0.
      IF ls_event-t_arg[ lv_index ] IS NOT INITIAL.
        EXIT.
      ENDIF.
      DELETE ls_event-t_arg INDEX lv_index.
      lv_index = lv_index - 1.
    ENDWHILE.

    TRY.
        DATA(li_json) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        li_json->touch_array( `/` ).
        li_json->push( iv_path = `/`
                       iv_val  = ls_event-val ).

        LOOP AT ls_event-t_arg INTO DATA(lv_arg).
          DATA(lv_is_embedded) = abap_false.
          IF lv_arg IS NOT INITIAL AND ( lv_arg(1) = `{` OR lv_arg(1) = `[` ).
            " a JSON object/array argument (the STORE_DATA payload, the
            " compound filter groups, ...) is embedded as real JSON so the
            " frontend receives a ready-to-use object - the counterpart of
            " the raw (unquoted) branch in get_t_arg. Values that only look
            " like JSON ({0} message placeholders, {/PATH} bindings) fail to
            " parse and stay plain strings, exactly what the frontend's own
            " JSON.parse fallback produced for them before.
            TRY.
                li_json->push( iv_path = `/`
                               iv_val  = z2ui5_cl_ajson=>parse( lv_arg ) ).
                lv_is_embedded = abap_true.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
          IF lv_is_embedded = abap_false.
            li_json->push( iv_path = `/`
                           iv_val  = lv_arg ).
          ENDIF.
        ENDLOOP.

        result = li_json.
      CATCH cx_root INTO DATA(lx_error).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.

  METHOD escape_js_string.

    result = val.
    REPLACE ALL OCCURRENCES OF `\` IN result WITH `\\`.
    REPLACE ALL OCCURRENCES OF `'` IN result WITH `\'`.
    " read the newline constants from the context class, not cl_abap_char_
    " utilities directly (the SAP-standard dependency is abstracted there for
    " non-ABAP runtimes - see z2ui5_cl_a2ui5_context)
    REPLACE ALL OCCURRENCES OF z2ui5_cl_a2ui5_context=>cv_char_util_cr_lf IN result WITH `\n`.
    REPLACE ALL OCCURRENCES OF z2ui5_cl_a2ui5_context=>cv_char_util_newline IN result WITH `\n`.
    " a standalone CR (not part of CR+LF, already collapsed above) is a JS
    " line terminator too and would break the '...' literal
    DATA(lv_cr) = substring( val = z2ui5_cl_a2ui5_context=>cv_char_util_cr_lf
                             off = 0
                             len = 1 ).
    REPLACE ALL OCCURRENCES OF lv_cr IN result WITH `\r`.

  ENDMETHOD.

  METHOD get_t_arg.

    DATA lv_new TYPE string.
    DATA lv_pending TYPE string.
    LOOP AT val REFERENCE INTO DATA(lr_arg).

      lv_new = lr_arg->*.
      IF lv_new IS INITIAL.
        " an empty argument between filled ones must keep its position -
        " dropping it would shift every following argument into the wrong
        " slot (a CONTROL_BY_ID action without a view lost its method name
        " this way). Buffer it and only flush when a later non-empty
        " argument follows, so trailing empties still disappear.
        lv_pending = |{ lv_pending }, ''|.
        CONTINUE.
      ENDIF.
      " a message template that starts with a bare positional placeholder
      " ({0}, {1}, ... - either immediately closed {0} or a conditional
      " {0?a:b}) is a plain string, not a binding or object literal, so it must
      " still be quoted - the `{`-raw exception below is only for real
      " bindings/object literals like {/PATH} or {..}. {0/field} (relative
      " binding) keeps a `/` after the digits and is therefore not matched, so
      " it stays raw as before.
      FIND REGEX `^\{[0-9]+[?}]` IN lv_new ##REGEX_POSIX.
      DATA(lv_is_placeholder) = xsdbool( sy-subrc = 0 ).
      IF (     lv_new(1) <> `$`
           AND lv_new(1) <> `{`
           AND lv_new NP `.eB(*`
           AND lv_new NP `.eBP(*`
           AND lv_new NP `.eF(*` ) OR lv_is_placeholder = abap_true.
        " a quoted arg becomes a single-quoted JS string literal; escape it in
        " full (backslash, quote, CR/LF) so no value - including one carrying a
        " literal backslash or ending in '\' - can close the '...' wrapper and
        " inject JS. The raw-binding branch above (values starting with { $ or
        " an .eB/.eBP/.eF event expression) stays unescaped by design, since
        " those are real bindings/expressions, not string data.
        lv_new = |'{ escape_js_string( lv_new ) }'|.
      ENDIF.
      result = |{ result }{ lv_pending }, { lv_new }|.
      lv_pending = ``.
    ENDLOOP.

    result = |{ result })|.

  ENDMETHOD.

ENDCLASS.
