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

    DATA temp9 TYPE string.
    DATA lv_val LIKE temp9.
    DATA lt_arg LIKE t_arg.
    DATA temp10 TYPE string.
    DATA lv_slot LIKE temp10.
      DATA temp11 TYPE string_table.
      DATA temp1 TYPE string.
      DATA temp2 TYPE string.
      DATA temp3 TYPE string.
      DATA temp4 TYPE string.
    temp9 = val.

    lv_val = temp9.

    lt_arg = t_arg.

    " NavContainer navigation reuses the generic cs_event-control_by_id call
    " so the frontend needs only the one generic dispatcher. Both the backend
    " follow-up action and the XML-bound client event (_event_client) are
    " formatted here, so this is the single place the *_nav_container_to events
    " are remapped to `<container>, <slot>, to, <target>`. The public
    " cs_event-*_nav_container_to constant values stay unchanged.

    CASE lv_val.
      WHEN z2ui5_if_client=>cs_event-nav_container_to.
        temp10 = `MAIN`.
      WHEN z2ui5_if_client=>cs_event-nest_nav_container_to.
        temp10 = `NEST`.
      WHEN z2ui5_if_client=>cs_event-nest2_nav_container_to.
        temp10 = `NEST2`.
      WHEN z2ui5_if_client=>cs_event-popup_nav_container_to.
        temp10 = `POPUP`.
      WHEN z2ui5_if_client=>cs_event-popover_nav_container_to.
        temp10 = `POPOVER`.
      WHEN OTHERS.
        temp10 = ``.
    ENDCASE.

    lv_slot = temp10.
    IF lv_slot IS NOT INITIAL.
      " read from t_arg (the unchanged importing parameter), never from lt_arg
      " which is the assignment target here - referencing the target inside its
      " own VALUE constructor reads it while it is being rebuilt in place

      CLEAR temp11.

      CLEAR temp1.

      READ TABLE t_arg INTO temp2 INDEX 1.
      IF sy-subrc = 0.
        temp1 = temp2.
      ENDIF.
      INSERT temp1 INTO TABLE temp11.
      INSERT lv_slot INTO TABLE temp11.
      INSERT `to` INTO TABLE temp11.

      CLEAR temp3.

      READ TABLE t_arg INTO temp4 INDEX 2.
      IF sy-subrc = 0.
        temp3 = temp4.
      ENDIF.
      INSERT temp3 INTO TABLE temp11.
      lt_arg = temp11.
      lv_val = z2ui5_if_client=>cs_event-control_by_id.
    ENDIF.

    result = |{ z2ui5_if_core_types=>cs_ui5-event_frontend_function }('{ lv_val }'{ get_t_arg( lt_arg ) }|.

  ENDMETHOD.

  METHOD get_t_arg.

    DATA lv_new TYPE string.
    DATA lv_pending TYPE string.
    DATA temp13 LIKE LINE OF val.
    DATA lr_arg LIKE REF TO temp13.
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
      IF lv_new(1) <> `$` AND lv_new(1) <> `{` AND lv_new NP `.eB(*`.
        lv_new = |'{ lv_new }'|.
      ENDIF.
      result = |{ result }{ lv_pending }, { lv_new }|.
      lv_pending = ``.
    ENDLOOP.

    result = |{ result })|.

  ENDMETHOD.

ENDCLASS.
