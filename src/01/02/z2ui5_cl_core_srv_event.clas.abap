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

  PROTECTED SECTION.
    METHODS get_t_arg
      IMPORTING
        val           TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_event IMPLEMENTATION.

  METHOD get_event.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_backend_function }(['{ val }'|.

    IF s_cnt-check_allow_multi_req = abap_true.
      result = |{ result },false,true|.
    ENDIF.

    result = |{ result }]{ get_t_arg( t_arg ) }|.

  ENDMETHOD.

  METHOD get_event_client.

    DATA(lv_val) = CONV string( val ).
    DATA(lt_arg) = t_arg.

    " NavContainer navigation reuses the generic cs_event-control_by_id call
    " so the frontend needs only the one generic dispatcher. Both the backend
    " follow-up action and the XML-bound client event (_event_client) are
    " formatted here, so this is the single place the *_nav_container_to events
    " are remapped to `<container>, <slot>, to, <target>`. The public
    " cs_event-*_nav_container_to constant values stay unchanged.
    DATA(lv_slot) = SWITCH string( lv_val
                                   WHEN z2ui5_if_client=>cs_event-nav_container_to         THEN `MAIN`
                                   WHEN z2ui5_if_client=>cs_event-nest_nav_container_to    THEN `NEST`
                                   WHEN z2ui5_if_client=>cs_event-nest2_nav_container_to   THEN `NEST2`
                                   WHEN z2ui5_if_client=>cs_event-popup_nav_container_to   THEN `POPUP`
                                   WHEN z2ui5_if_client=>cs_event-popover_nav_container_to THEN `POPOVER`
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
    ELSEIF lv_val = z2ui5_if_client=>cs_event-control_by_id.
      " the view is passed as its own parameter now, not as a positional
      " t_arg slot; inject it at position 2 so the frontend still reads
      " args = id, view, method, ... . cs_view-main maps to the empty slot,
      " keeping the unchanged default where the id resolves across all open
      " views (resolveById); a concrete view scopes the lookup to that slot.
      DATA(lv_view_slot) = COND string( WHEN view = z2ui5_if_client=>cs_view-main THEN ``
                                        ELSE CONV string( view ) ).
      " lt_arg already equals t_arg (set at the top); this branch did not
      " touch it, so inject the view slot directly.
      INSERT lv_view_slot INTO lt_arg INDEX 2.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-bind_element.
      " element-bind a whole view slot to a table row: args = slot, index,
      " path. The path comes from client->_bind( table ); _bind returns the
      " binding with braces ({/MT_TAB}), which would be an invalid raw JS
      " argument, so strip the braces here to a plain path ('/MT_TAB') that
      " get_t_arg then quotes. The slot is the follow_up_action view parameter.
      DATA(lv_bind_path) = CONV string( VALUE #( t_arg[ 2 ] OPTIONAL ) ).
      REPLACE ALL OCCURRENCES OF `{` IN lv_bind_path WITH ``.
      REPLACE ALL OCCURRENCES OF `}` IN lv_bind_path WITH ``.
      lt_arg = VALUE #( ( CONV string( view ) )
                        ( VALUE #( t_arg[ 1 ] OPTIONAL ) )
                        ( lv_bind_path ) ).
    ENDIF.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_frontend_function }('{ lv_val }'{ get_t_arg( lt_arg ) }|.

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
      FIND REGEX `^\{[0-9]+[?}]` IN lv_new.
      DATA(lv_is_placeholder) = xsdbool( sy-subrc = 0 ).
      IF ( lv_new(1) <> `$` AND lv_new(1) <> `{` AND lv_new NP `.eB(*` ) OR lv_is_placeholder = abap_true.
        " a quoted arg is JS string source (a backslash escape like \n stays a
        " newline); escape only an embedded ' so it cannot close the '...'
        " wrapper - otherwise a template like Value changed to '{0}' emits
        " broken JS.
        REPLACE ALL OCCURRENCES OF `'` IN lv_new WITH `\'`.
        lv_new = |'{ lv_new }'|.
      ENDIF.
      result = |{ result }{ lv_pending }, { lv_new }|.
      lv_pending = ``.
    ENDLOOP.

    result = |{ result })|.

  ENDMETHOD.

ENDCLASS.
