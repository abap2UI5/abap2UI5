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

    DATA temp19 TYPE string.
    DATA lv_val LIKE temp19.
    DATA lt_arg LIKE t_arg.
    DATA temp20 TYPE string.
    DATA lv_slot LIKE temp20.
      DATA temp21 TYPE string_table.
      DATA temp1 TYPE string.
      DATA temp2 TYPE string.
      DATA temp3 TYPE string.
      DATA temp4 TYPE string.
      DATA temp23 TYPE string.
      DATA temp5 TYPE string.
      DATA lv_view_slot LIKE temp5.
      DATA temp24 TYPE string.
      DATA temp25 TYPE string.
      DATA temp6 TYPE string.
      DATA lv_bind_path LIKE temp6.
      DATA temp26 TYPE string_table.
      DATA temp7 TYPE string.
      DATA temp8 TYPE string.
      DATA temp9 TYPE string.
    temp19 = val.

    lv_val = temp19.

    lt_arg = t_arg.

    " NavContainer navigation reuses the generic cs_event-control_by_id call
    " so the frontend needs only the one generic dispatcher. Both the backend
    " follow-up action and the XML-bound client event (_event_client) are
    " formatted here, so this is the single place the *_nav_container_to events
    " are remapped to `<container>, <slot>, to, <target>`. The public
    " cs_event-*_nav_container_to constant values stay unchanged.

    CASE lv_val.
      WHEN z2ui5_if_client=>cs_event-nav_container_to.
        temp20 = `MAIN`.
      WHEN z2ui5_if_client=>cs_event-nest_nav_container_to.
        temp20 = `NEST`.
      WHEN z2ui5_if_client=>cs_event-nest2_nav_container_to.
        temp20 = `NEST2`.
      WHEN z2ui5_if_client=>cs_event-popup_nav_container_to.
        temp20 = `POPUP`.
      WHEN z2ui5_if_client=>cs_event-popover_nav_container_to.
        temp20 = `POPOVER`.
      WHEN OTHERS.
        temp20 = ``.
    ENDCASE.

    lv_slot = temp20.
    IF lv_slot IS NOT INITIAL.
      " read from t_arg (the unchanged importing parameter), never from lt_arg
      " which is the assignment target here - referencing the target inside its
      " own VALUE constructor reads it while it is being rebuilt in place

      CLEAR temp21.

      CLEAR temp1.

      READ TABLE t_arg INTO temp2 INDEX 1.
      IF sy-subrc = 0.
        temp1 = temp2.
      ENDIF.
      INSERT temp1 INTO TABLE temp21.
      INSERT lv_slot INTO TABLE temp21.
      INSERT `to` INTO TABLE temp21.

      CLEAR temp3.

      READ TABLE t_arg INTO temp4 INDEX 2.
      IF sy-subrc = 0.
        temp3 = temp4.
      ENDIF.
      INSERT temp3 INTO TABLE temp21.
      lt_arg = temp21.
      lv_val = z2ui5_if_client=>cs_event-control_by_id.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-control_by_id.
      " the view is passed as its own parameter now, not as a positional
      " t_arg slot; inject it at position 2 so the frontend still reads
      " args = id, view, method, ... . cs_view-main maps to the empty slot,
      " keeping the unchanged default where the id resolves across all open
      " views (resolveById); a concrete view scopes the lookup to that slot.

      temp23 = view.

      IF view = z2ui5_if_client=>cs_view-main.
        temp5 = ``.
      ELSE.
        temp5 = temp23.
      ENDIF.

      lv_view_slot = temp5.
      " lt_arg already equals t_arg (set at the top); this branch did not
      " touch it, so inject the view slot directly.
      INSERT lv_view_slot INTO lt_arg INDEX 2.
    ELSEIF lv_val = z2ui5_if_client=>cs_event-bind_element.
      " element-bind a whole view slot to a table row: args = slot, index,
      " path. The path comes from client->_bind( table ); _bind returns the
      " binding with braces ({/MT_TAB}), which would be an invalid raw JS
      " argument, so strip the braces here to a plain path ('/MT_TAB') that
      " get_t_arg then quotes. The slot is the follow_up_action view parameter.

      CLEAR temp24.

      READ TABLE t_arg INTO temp25 INDEX 2.
      IF sy-subrc = 0.
        temp24 = temp25.
      ENDIF.

      temp6 = temp24.

      lv_bind_path = temp6.
      REPLACE ALL OCCURRENCES OF `{` IN lv_bind_path WITH ``.
      REPLACE ALL OCCURRENCES OF `}` IN lv_bind_path WITH ``.

      CLEAR temp26.

      temp7 = view.
      INSERT temp7 INTO TABLE temp26.

      CLEAR temp8.

      READ TABLE t_arg INTO temp9 INDEX 1.
      IF sy-subrc = 0.
        temp8 = temp9.
      ENDIF.
      INSERT temp8 INTO TABLE temp26.
      INSERT lv_bind_path INTO TABLE temp26.
      lt_arg = temp26.
    ENDIF.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_frontend_function }('{ lv_val }'{ get_t_arg( lt_arg ) }|.

  ENDMETHOD.

  METHOD get_t_arg.

    DATA lv_new TYPE string.
    DATA lv_pending TYPE string.
    DATA temp28 LIKE LINE OF val.
    DATA lr_arg LIKE REF TO temp28.
      DATA lv_is_placeholder TYPE abap_bool.
      DATA temp1 TYPE xsdboolean.
    LOOP AT val REFERENCE INTO lr_arg.

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


      temp1 = boolc( sy-subrc = 0 ).
      lv_is_placeholder = temp1.
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
