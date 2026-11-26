"! <p class="shorttext synchronized">abap2UI5 - test harness for apps</p>
"!
"! Drives a z2ui5_if_app class from an ABAP Unit test through the REAL
"! framework - the handler, the client, _bind( ) and _event( ), the draft -
"! the way the browser drives it, one roundtrip per call, and answers what
"! the browser would then show. No test double of z2ui5_if_client, no
"! framework internals in the test:
"!
"!     DATA(test) = z2ui5_cl_ui5_test=&gt;start( NEW zcl_my_app( ) ).
"!     test-&gt;set_model( path = `/NAME` val = `World` )-&gt;event( `POST` ).
"!     DATA(messages) = test-&gt;messages( ).
"!     cl_abap_unit_assert=&gt;assert_equals( exp = `Hello World`
"!                                         act = messages[ 1 ]-text ).
"!
"! What happens is what happens in production: start( ) is the first
"! roundtrip of the app (check_on_init( ) and check_on_navigated( ) are true),
"! set_model( ) is what the user types into a bound control - it travels as
"! the model delta of the next request, the framework writes it into the
"! bound attribute before main( ) runs - and event( ) is a press of a control
"! wired with client-&gt;_event( ). Every roundtrip saves the app as a draft and
"! the next one restores it from there, so an attribute the draft cannot carry
"! fails here as it fails in a browser. The drafts live in memory, in the
"! harness - no row reaches Z2UI5_T_01 - and the store a system has
"! installed is put back after every roundtrip.
"!
"! Consequence of the draft: app( ) answers the instance that ran the LAST
"! roundtrip. The next roundtrip runs a new instance restored from the
"! draft - read app( ) again after every step, and change a value through
"! set_model( ) (a bound value) rather than on an old reference. An app that
"! switched to a stateful session (set_session_stateful) keeps its instance
"! across roundtrips, as on a system.
"!
"! Readers: view_xml( ), nest_xml( ), nest2_xml( ), popup_xml( ) and
"! popover_xml( ) answer what each view slot shows NOW - a slot keeps its
"! view until a roundtrip displays another or destroys it, like the
"! browser. model( ) is the view model the browser holds, set_model( ) edits
"! included. actions( ) and messages( ) are what the LAST roundtrip asked
"! the browser to do. nav_called( ) and nav_left( ) say whether the last
"! roundtrip navigated. Model paths are written as in a view binding:
"! `/NAME`, `/MS_ROW/CITY`, table rows counted from 0 - `/MT_TAB/0/NAME`
"! is the first row.
"!
"! FOR TESTING: usable from test classes only, it never ships into a
"! production call path. Not covered: what only the browser does - a
"! frontend event (_event_client), a popup closed in the browser alone,
"! rendering. Those need the browser, or the abap2UI5 linter's render check.
CLASS z2ui5_cl_ui5_test DEFINITION PUBLIC FINAL CREATE PRIVATE FOR TESTING.

  PUBLIC SECTION.

    " One follow-up action of the last response - what the app queued with
    " follow_up_action( ), message_toast_display( ), message_box_display( )
    " and friends. name is the first element of the wire array (MESSAGE_TOAST,
    " MESSAGE_BOX, SET_FOCUS, START_TIMER, CONTROL_GLOBAL, ...), t_arg the
    " further elements as text - an object or array argument as its JSON -
    " and json the whole entry.
    TYPES:
      BEGIN OF ty_s_action,
        name  TYPE string,
        t_arg TYPE string_table,
        json  TYPE string,
      END OF ty_s_action.
    TYPES ty_t_action TYPE STANDARD TABLE OF ty_s_action WITH DEFAULT KEY.

    " One message the last response shows. type is `toast` for a message
    " toast, else the sap.m.MessageBox method of the box - `information`,
    " `success`, `warning`, `error`, `confirm`, `alert` or `show`.
    TYPES:
      BEGIN OF ty_s_message,
        type  TYPE string,
        text  TYPE string,
        title TYPE string,
      END OF ty_s_message.
    TYPES ty_t_message TYPE STANDARD TABLE OF ty_s_message WITH DEFAULT KEY.

    "! The first roundtrip of an app - a page load that starts the given
    "! instance. Prepare the instance before (a constructor parameter, an
    "! attribute): it is the one main( ) runs.
    CLASS-METHODS start
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! The app as the TARGET of a nav_app_call( ) - how a popup app, a value
    "! help or a confirmation is reached. A caller of the harness's own
    "! calls it on its first start; its nav_app_leave( ) then goes back there,
    "! and nav_left( ) answers the instance that left, with its result.
    CLASS-METHODS start_called
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! A roundtrip for the event - what a press of a control wired with
    "! client-&gt;_event( val ) sends, with the model edits of set_model( ) since
    "! the last roundtrip. t_arg are the event arguments, as get_event_arg( )
    "! hands them to the app.
    METHODS event
      IMPORTING
        val           TYPE clike
        t_arg         TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! What the user types into the control bound to the model path - the
    "! value goes into the browser's model now and to the backend with the
    "! next roundtrip, as the delta the browser sends. path as in a binding,
    "! rows from 0: `/NAME`, `/MS_ROW/CITY`, `/MT_TAB/0/NAME`. val is any
    "! elementary value - a string, a number, abap_true / abap_false.
    METHODS set_model
      IMPORTING
        path          TYPE clike
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! A press of a control wired with client-&gt;_event_nav_app_leave( ).
    METHODS leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! The tick of the timer the app runs - declared with client->timer_set( )
    "! or armed with cs_event-start_timer: a roundtrip for its event, flagged
    "! as a tick. Raises when no timer runs: a one-shot timer is spent by
    "! every roundtrip that does not arm it again, timer_stop( ),
    "! cs_event-stop_timer and a navigation end any timer.
    METHODS timer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! A page reload that restores the running app from its last draft - the
    "! browser's reload or Back/Forward under hash routing. The app runs with
    "! check_on_navigated( ) and not check_on_init( ); the screen and the
    "! model start empty, as in a new page. Raises when the last roundtrip
    "! saved no draft (a stateful app that asked for no KEEP routing).
    METHODS restore
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_test.

    "! The app instance that answered the last roundtrip.
    METHODS app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

    "! The XML of the main view on screen - empty when none is.
    METHODS view_xml
      RETURNING
        VALUE(result) TYPE string.

    "! The XML of the nested view on screen (nest_view_display).
    METHODS nest_xml
      RETURNING
        VALUE(result) TYPE string.

    "! The XML of the second nested view on screen (nest2_view_display).
    METHODS nest2_xml
      RETURNING
        VALUE(result) TYPE string.

    "! The XML of the popup on screen - empty when none is open.
    METHODS popup_xml
      RETURNING
        VALUE(result) TYPE string.

    "! The XML of the popover on screen - empty when none is open.
    METHODS popover_xml
      RETURNING
        VALUE(result) TYPE string.

    "! The view model the browser holds: without path the whole model as
    "! JSON; with one the value at that path - a string for a value, the
    "! JSON of an object or array, empty when the path is not there.
    METHODS model
      IMPORTING
        path          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    "! The follow-up actions of the last response, in their order.
    METHODS actions
      RETURNING
        VALUE(result) TYPE ty_t_action.

    "! The message toasts and boxes of the last response, in their order.
    METHODS messages
      RETURNING
        VALUE(result) TYPE ty_t_message.

    "! The app the last roundtrip navigated FORWARD to - the target of a
    "! nav_app_call( ), or of a nav_app_leave( ) to a new instance. Unbound
    "! when it did not; app( ) is the same instance when it did.
    METHODS nav_called
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

    "! The app that LEFT in the last roundtrip - its nav_app_leave( )
    "! returned to app( ), which ran with check_on_nav_back( ). Read its
    "! result from it. Unbound when the last roundtrip went back to nobody.
    METHODS nav_left
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

    "! The event of the armed timer - empty when none is armed.
    METHODS timer_event
      RETURNING
        VALUE(result) TYPE string.

    "! The last response as the browser received it (JSON).
    METHODS response
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_slot,
        slot TYPE string,
        xml  TYPE string,
      END OF ty_s_slot.
    TYPES ty_t_slot TYPE STANDARD TABLE OF ty_s_slot WITH DEFAULT KEY.

    " the page origin every start request names
    CONSTANTS c_origin   TYPE string VALUE `https://localhost`.
    CONSTANTS c_pathname TYPE string VALUE `/sap/bc/z2ui5`.

    " the drafts of this test (the local lcl_store)
    DATA mi_store       TYPE REF TO z2ui5_if_ui5_draft_store.
    " the handler of a stateful session - kept across requests like
    " z2ui5_cl_ui5_http_handler keeps it, unbound for a stateless app
    DATA mo_handler     TYPE REF TO z2ui5_cl_ui5_handler.
    DATA mv_id          TYPE string.
    DATA mv_response    TYPE string.
    DATA mv_model       TYPE string.
    DATA mt_edit        TYPE string_table.
    DATA mt_slot        TYPE ty_t_slot.
    DATA mt_action      TYPE ty_t_action.
    DATA mi_app         TYPE REF TO z2ui5_if_app.
    DATA mi_called      TYPE REF TO z2ui5_if_app.
    DATA mi_left        TYPE REF TO z2ui5_if_app.
    DATA mv_timer       TYPE string.
    DATA mv_timer_again TYPE abap_bool.

    METHODS roundtrip
      IMPORTING
        iv_request TYPE string
        io_app     TYPE REF TO z2ui5_if_app OPTIONAL.

    METHODS roundtrip_nav
      IMPORTING
        io_handler TYPE REF TO z2ui5_cl_ui5_handler
        iv_count   TYPE i.

    METHODS request_event
      IMPORTING
        iv_event      TYPE string
        t_arg         TYPE string_table OPTIONAL
        check_timer   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

    METHODS request_delta
      IMPORTING
        ii_request TYPE REF TO z2ui5_if_ajson
      RAISING
        z2ui5_cx_ajson_error.

    METHODS response_read
      IMPORTING
        iv_body TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    METHODS response_views
      IMPORTING
        ii_json TYPE REF TO z2ui5_if_ajson.

    METHODS response_actions
      IMPORTING
        ii_json TYPE REF TO z2ui5_if_ajson
      RAISING
        z2ui5_cx_ajson_error.

    METHODS timer_read.

    METHODS slot_get
      IMPORTING
        iv_slot       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    "! a model path as the browser writes it (rows from 0) as the ajson
    "! path of the same node (array items from 1)
    CLASS-METHODS path_to_json
      IMPORTING
        iv_path       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS node_text
      IMPORTING
        ii_json       TYPE REF TO z2ui5_if_ajson
        iv_path       TYPE string
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_ui5_test IMPLEMENTATION.

  METHOD start.
        DATA temp5 TYPE REF TO z2ui5_if_ajson.
        DATA li_request LIKE temp5.
        DATA lv_request TYPE string.
        DATA x TYPE REF TO cx_root.

    CREATE OBJECT result.
    CREATE OBJECT result->mi_store TYPE lcl_store.

    TRY.

        temp5 ?= z2ui5_cl_ajson=>create_empty( ).

        li_request = temp5.
        li_request->set( iv_path = `/value/S_FRONT/ORIGIN`
                         iv_val  = c_origin ).
        li_request->set( iv_path = `/value/S_FRONT/PATHNAME`
                         iv_val  = c_pathname ).

        lv_request = li_request->stringify( ).

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.

    " the request names no app - the handler starts the instance itself
    " (z2ui5_cl_ui5_handler->mo_app_start)
    result->roundtrip( iv_request = lv_request
                       io_app     = app ).

  ENDMETHOD.

  METHOD start_called.

    DATA temp6 TYPE REF TO lcl_caller.
    CREATE OBJECT temp6 TYPE lcl_caller EXPORTING APP = app.
    result = start( temp6 ).

  ENDMETHOD.

  METHOD event.

    DATA temp7 TYPE string.
    temp7 = val.
    roundtrip( request_event( iv_event = temp7
                              t_arg    = t_arg ) ).
    result = me.

  ENDMETHOD.

  METHOD leave.

    roundtrip( request_event( z2ui5_if_ui5_types=>cs_event_nav_app_leave ) ).
    result = me.

  ENDMETHOD.

  METHOD timer.

    IF mv_timer IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `timer( ) - no timer is armed (cs_event-start_timer)`.
    ENDIF.
    roundtrip( request_event( iv_event    = mv_timer
                              check_timer = abap_true ) ).
    result = me.

  ENDMETHOD.

  METHOD restore.
        DATA temp8 TYPE REF TO z2ui5_if_ajson.
        DATA li_request LIKE temp8.
        DATA lv_request TYPE string.
        DATA x TYPE REF TO cx_root.

    IF mv_id IS INITIAL OR mi_store->check_exists( mv_id ) = abap_false.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `restore( ) - the last roundtrip saved no draft (a stateful app without KEEP routing)`.
    ENDIF.

    TRY.

        temp8 ?= z2ui5_cl_ajson=>create_empty( ).

        li_request = temp8.
        li_request->set( iv_path = `/value/S_FRONT/ORIGIN`
                         iv_val  = c_origin ).
        li_request->set( iv_path = `/value/S_FRONT/PATHNAME`
                         iv_val  = c_pathname ).
        " a route restore, '#/app/<CLASS>/<DRAFT>' as the router parses it
        li_request->set( iv_path = `/value/S_FRONT/ROUTE/APP`
                         iv_val  = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mi_app ) ).
        li_request->set( iv_path = `/value/S_FRONT/ROUTE/DRAFT`
                         iv_val  = mv_id ).

        lv_request = li_request->stringify( ).

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.

    " a new page: nothing on screen, no model, no session kept
    CLEAR: mt_slot, mv_model, mt_edit, mo_handler, mv_timer, mv_timer_again.
    roundtrip( lv_request ).
    result = me.

  ENDMETHOD.

  METHOD set_model.

    DATA temp9 TYPE string.
    DATA lv_path LIKE temp9.
        DATA temp10 TYPE REF TO z2ui5_if_ajson.
        DATA temp1 TYPE string.
        DATA li_model LIKE temp10.
        DATA x TYPE REF TO cx_root.
    DATA temp11 LIKE sy-subrc.
    temp9 = path.

    lv_path = temp9.
    IF lv_path IS INITIAL OR lv_path(1) <> `/`.
      lv_path = `/` && lv_path.
    ENDIF.

    TRY.


        IF mv_model IS INITIAL.
          temp1 = `{}`.
        ELSE.
          temp1 = mv_model.
        ENDIF.
        temp10 ?= z2ui5_cl_ajson=>parse( temp1 ).

        li_model = temp10.
        li_model->set( iv_path         = path_to_json( lv_path )
                       iv_val          = val
                       iv_ignore_empty = abap_false ).
        mv_model = li_model->stringify( ).

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.


    READ TABLE mt_edit WITH KEY table_line = lv_path TRANSPORTING NO FIELDS.
    temp11 = sy-subrc.
    IF NOT temp11 = 0. "#EC CI_SORTSEQ
      INSERT lv_path INTO TABLE mt_edit.
    ENDIF.
    result = me.

  ENDMETHOD.

  METHOD request_event.
        DATA temp12 TYPE REF TO z2ui5_if_ajson.
        DATA li_request LIKE temp12.
          DATA lv_arg LIKE LINE OF t_arg.
        DATA x TYPE REF TO cx_root.

    TRY.

        temp12 ?= z2ui5_cl_ajson=>create_empty( ).

        li_request = temp12.
        li_request->set( iv_path = `/value/S_FRONT/ID`
                         iv_val  = mv_id ).
        li_request->set( iv_path = `/value/S_FRONT/EVENT`
                         iv_val  = iv_event ).
        IF t_arg IS NOT INITIAL.
          li_request->touch_array( `/value/S_FRONT/T_EVENT_ARG` ).

          LOOP AT t_arg INTO lv_arg.
            li_request->push( iv_path = `/value/S_FRONT/T_EVENT_ARG`
                              iv_val  = lv_arg ).
          ENDLOOP.
        ENDIF.
        IF check_timer = abap_true.
          li_request->set_boolean( iv_path = `/value/S_FRONT/TIMER`
                                   iv_val  = abap_true ).
        ENDIF.
        request_delta( li_request ).
        result = li_request->stringify( ).

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.
    CLEAR mt_edit.

  ENDMETHOD.

  METHOD request_delta.
    DATA temp13 TYPE REF TO z2ui5_if_ajson.
    DATA li_model LIKE temp13.
    DATA lt_whole TYPE string_table.
    DATA lv_path LIKE LINE OF mt_edit.
      TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_part TYPE temp1.
      DATA lv_attr TYPE string.
      FIELD-SYMBOLS <temp2> LIKE LINE OF lt_part.
      DATA temp3 LIKE sy-tabix.
      DATA temp14 LIKE sy-subrc.
      FIELD-SYMBOLS <temp15> LIKE LINE OF lt_part.
      DATA temp16 LIKE sy-tabix.
      FIELD-SYMBOLS <temp4> LIKE LINE OF lt_part.
      DATA temp5 LIKE sy-tabix.
        DATA lv_cell TYPE string.
        FIELD-SYMBOLS <temp6> LIKE LINE OF lt_part.
        DATA temp7 LIKE sy-tabix.
        FIELD-SYMBOLS <temp1> LIKE LINE OF lt_part.
        DATA temp2 LIKE sy-tabix.

    " The delta the browser builds from the edited paths (core/Lib.js,
    " buildDeltaFromPaths): a table cell - /TAB/<row>/<field> - travels as
    " TAB.__delta.<row>.<field>, anything else as the whole attribute, which
    " also covers every cell edit of it
    IF mt_edit IS INITIAL OR mv_model IS INITIAL.
      RETURN.
    ENDIF.

    temp13 ?= z2ui5_cl_ajson=>parse( mv_model ).

    li_model = temp13.



    LOOP AT mt_edit INTO lv_path.


      SPLIT substring( val = lv_path
                       off = 1 ) AT `/` INTO TABLE lt_part.



      temp3 = sy-tabix.
      READ TABLE lt_part INDEX 1 ASSIGNING <temp2>.
      sy-tabix = temp3.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_attr = `/` && <temp2>.

      READ TABLE lt_whole WITH KEY table_line = lv_attr TRANSPORTING NO FIELDS.
      temp14 = sy-subrc.
      IF temp14 = 0. "#EC CI_SORTSEQ
        CONTINUE.
      ENDIF.
      " one level of rows: <attr>/<row>/<field>, the row a number and the
      " field a name - a deeper edit ships the field of the row whole


      IF lines( lt_part ) >= 3.
        temp16 = sy-tabix.
        READ TABLE lt_part INDEX 2 ASSIGNING <temp15>.
        sy-tabix = temp16.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
      ENDIF.


      IF lines( lt_part ) >= 3 AND <temp15> CO `0123456789`.
        temp5 = sy-tabix.
        READ TABLE lt_part INDEX 3 ASSIGNING <temp4>.
        sy-tabix = temp5.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
      ENDIF.
      IF lines( lt_part ) >= 3 AND <temp15> CO `0123456789` AND <temp4> CN `0123456789`.



        temp7 = sy-tabix.
        READ TABLE lt_part INDEX 2 ASSIGNING <temp6>.
        sy-tabix = temp7.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.


        temp2 = sy-tabix.
        READ TABLE lt_part INDEX 3 ASSIGNING <temp1>.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_cell = |/{ <temp6> }/{ <temp1> }|.
        ii_request->set( iv_path         = |/value/MODEL{ lv_attr }/__delta{ lv_cell }|
                         iv_val          = li_model->slice( path_to_json( lv_attr && lv_cell ) )
                         iv_ignore_empty = abap_false ).
      ELSE.
        ii_request->delete( |/value/MODEL{ lv_attr }| ).
        ii_request->set( iv_path         = |/value/MODEL{ lv_attr }|
                         iv_val          = li_model->slice( lv_attr )
                         iv_ignore_empty = abap_false ).
        INSERT lv_attr INTO TABLE lt_whole.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD roundtrip.

    " the in-memory store for exactly this roundtrip; get_instance( ) answers
    " a fresh shipped store when none is installed, which is what putting
    " that answer back restores
    DATA li_store_before TYPE REF TO z2ui5_if_ui5_draft_store.
        DATA lv_count TYPE i.
        DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
        DATA temp1 TYPE xsdboolean.
        DATA ls_result TYPE z2ui5_if_ui5_types=>ty_s_http_res.
        DATA temp17 TYPE REF TO z2ui5_if_app.
        DATA lx_json TYPE REF TO z2ui5_cx_ajson_error.
    li_store_before = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    z2ui5_cl_ui5_srv_draft=>set_instance( mi_store ).

    TRY.

        lv_count = mi_store->count_entries_total( ).

        " a stateful session answers from the handler it kept, exactly as
        " z2ui5_cl_ui5_http_handler=>_http_post does

        IF mo_handler IS BOUND.
          lo_handler = mo_handler.
          lo_handler->mv_request_json = iv_request.
        ELSE.
          CREATE OBJECT lo_handler EXPORTING VAL = iv_request.
          " a stateless request starts in a new internal session: no
          " container of an earlier roundtrip is buffered there, the app
          " comes back from the draft store
          z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
        ENDIF.

        temp1 = boolc( mo_handler IS BOUND ).
        lo_handler->mv_session_sticky = temp1.
        lo_handler->mo_app_start = io_app.


        ls_result = lo_handler->main( ).
        CLEAR lo_handler->mo_app_start.


        temp17 ?= lo_handler->mo_action->mo_app->mo_app.
        mi_app = temp17.
        " the navigation first: it ends the timer the response of the app
        " navigated to may arm again
        roundtrip_nav( io_handler = lo_handler
                       iv_count   = lv_count ).
        response_read( ls_result-body ).

        IF lo_handler->mo_action->mo_app->mv_check_sticky = abap_true.
          mo_handler = lo_handler.
        ELSE.
          CLEAR mo_handler.
        ENDIF.


      CATCH z2ui5_cx_ajson_error INTO lx_json.
        z2ui5_cl_ui5_srv_draft=>set_instance( li_store_before ).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = lx_json.
      CLEANUP.
        z2ui5_cl_ui5_srv_draft=>set_instance( li_store_before ).
    ENDTRY.

    z2ui5_cl_ui5_srv_draft=>set_instance( li_store_before ).

  ENDMETHOD.

  METHOD roundtrip_nav.
    DATA lo_cont LIKE io_handler->mo_action->mo_app.
    DATA temp18 TYPE REF TO lcl_store.
      DATA temp19 TYPE REF TO z2ui5_if_app.

    CLEAR: mi_called, mi_left.

    " a navigation hop saves the app it leaves (z2ui5_cl_ui5_action=>
    " prepare_app_stack) and the app it reaches names that draft as its
    " previous app - a previous app saved in THIS roundtrip is the hop

    lo_cont = io_handler->mo_action->mo_app.

    temp18 ?= mi_store.
    IF lo_cont->ms_draft-id_prev_app IS INITIAL
        OR temp18->check_written_since( id    = lo_cont->ms_draft-id_prev_app
                                                            count = iv_count ) = abap_false.
      RETURN.
    ENDIF.

    IF io_handler->mo_action->ms_actual-check_nav_back = abap_true.
      " what client->get_app_prev( ) answers on that roundtrip

      temp19 ?= z2ui5_cl_ui5_app_cont=>db_load( lo_cont->ms_draft-id_prev_app )->mo_app.
      mi_left = temp19.
    ELSE.
      mi_called = mi_app.
    ENDIF.
    " a navigation ends every timer - the response of the app navigated to
    " arms its own (timer_set( ) declares one, a STOP_TIMER says so)
    CLEAR: mv_timer, mv_timer_again.

  ENDMETHOD.

  METHOD response_read.

    DATA temp20 TYPE REF TO z2ui5_if_ajson.
    DATA li_json LIKE temp20.
    temp20 ?= z2ui5_cl_ajson=>parse( iv_body ).

    li_json = temp20.
    mv_response = iv_body.
    mv_id = li_json->get_string( `/S_FRONT/ID` ).

    response_views( li_json ).

    " a MODEL key IS the push: the browser takes it over whole; without one
    " it keeps what it has, the user's edits included
    IF li_json->exists( `/MODEL` ) = abap_true.
      mv_model = li_json->slice( `/MODEL` )->stringify( ).
    ENDIF.

    response_actions( li_json ).
    timer_read( ).

  ENDMETHOD.

  METHOD response_views.

    " the frontend's order (View1): MAIN first - a new main view takes the
    " nested views with it, they live inside it - then the others
    DATA temp21 TYPE string_table.
    DATA lt_order LIKE temp21.
    DATA lv_slot LIKE LINE OF lt_order.
      DATA lv_path TYPE string.
        DATA temp23 TYPE z2ui5_cl_ui5_test=>ty_s_slot.
    CLEAR temp21.
    INSERT z2ui5_if_client=>cs_view-main INTO TABLE temp21.
    INSERT z2ui5_if_client=>cs_view-nested INTO TABLE temp21.
    INSERT z2ui5_if_client=>cs_view-nested2 INTO TABLE temp21.
    INSERT z2ui5_if_client=>cs_view-popup INTO TABLE temp21.
    INSERT z2ui5_if_client=>cs_view-popover INTO TABLE temp21.

    lt_order = temp21.

    LOOP AT lt_order INTO lv_slot.

      lv_path = |/S_FRONT/VIEWS/{ lv_slot }|.
      IF ii_json->exists( lv_path ) = abap_false.
        CONTINUE.
      ENDIF.
      DELETE mt_slot WHERE slot = lv_slot.
      IF lv_slot = z2ui5_if_client=>cs_view-main.
        DELETE mt_slot WHERE slot = z2ui5_if_client=>cs_view-nested OR slot = z2ui5_if_client=>cs_view-nested2.
      ENDIF.
      IF ii_json->get_boolean( lv_path && `/DESTROY` ) = abap_false.

        CLEAR temp23.
        temp23-slot = lv_slot.
        temp23-xml = ii_json->get_string( lv_path && `/XML` ).
        INSERT temp23 INTO TABLE mt_slot.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD response_actions.
    DATA temp24 TYPE string_table.
    DATA lv_index LIKE LINE OF temp24.
      DATA lv_entry TYPE string.
      DATA temp25 TYPE ty_s_action.
      DATA ls_action LIKE temp25.
      DATA lv_arg TYPE i.

    CLEAR mt_action.
    IF ii_json->exists( `/S_FRONT/ACTIONS` ) = abap_false.
      RETURN.
    ENDIF.


    temp24 = ii_json->members( `/S_FRONT/ACTIONS` ).

    LOOP AT temp24 INTO lv_index.

      lv_entry = |/S_FRONT/ACTIONS/{ lv_index }|.

      CLEAR temp25.
      temp25-name = ii_json->get_string( lv_entry && `/1` ).
      temp25-json = ii_json->slice( lv_entry )->stringify( ).

      ls_action = temp25.

      lv_arg = 2.
      WHILE ii_json->exists( |{ lv_entry }/{ lv_arg }| ) = abap_true.
        INSERT node_text( ii_json = ii_json
                          iv_path = |{ lv_entry }/{ lv_arg }| ) INTO TABLE ls_action-t_arg.
        lv_arg = lv_arg + 1.
      ENDWHILE.
      INSERT ls_action INTO TABLE mt_action.
    ENDLOOP.

  ENDMETHOD.

  METHOD timer_read.
    DATA ls_action LIKE LINE OF mt_action.
          DATA temp26 TYPE string.
          DATA temp27 TYPE string.
          DATA temp28 TYPE string.
          DATA temp29 TYPE string.
          DATA temp2 TYPE xsdboolean.

    " one timer per app: a START_TIMER arms it (its fourth argument `X`
    " repeats it), STOP_TIMER ends it, and a one-shot timer is spent by
    " every roundtrip that does not arm it again
    IF mv_timer_again = abap_false.
      CLEAR mv_timer.
    ENDIF.

    LOOP AT mt_action INTO ls_action.
      CASE ls_action-name.
        WHEN z2ui5_if_client=>cs_event-start_timer.

          CLEAR temp26.

          READ TABLE ls_action-t_arg INTO temp27 INDEX 1.
          IF sy-subrc = 0.
            temp26 = temp27.
          ENDIF.
          mv_timer       = temp26.

          CLEAR temp28.

          READ TABLE ls_action-t_arg INTO temp29 INDEX 4.
          IF sy-subrc = 0.
            temp28 = temp29.
          ENDIF.

          temp2 = boolc( temp28 = abap_true ).
          mv_timer_again = temp2.
        WHEN z2ui5_if_client=>cs_event-stop_timer.
          CLEAR: mv_timer, mv_timer_again.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD node_text.

    DATA lv_type TYPE z2ui5_if_ajson_types=>ty_node_type.
    lv_type = ii_json->get_node_type( iv_path ).
    IF lv_type = z2ui5_if_ajson_types=>node_type-object OR lv_type = z2ui5_if_ajson_types=>node_type-array.
      result = ii_json->slice( iv_path )->stringify( ).
    ELSE.
      result = ii_json->get_string( iv_path ).
    ENDIF.

  ENDMETHOD.

  METHOD path_to_json.

    " a segment of digits is a row of a table - from 0 in the model the
    " browser binds, from 1 in an ajson path
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_part TYPE temp2.
    DATA lv_part LIKE LINE OF lt_part.
        DATA temp30 TYPE i.
    SPLIT iv_path AT `/` INTO TABLE lt_part.

    LOOP AT lt_part INTO lv_part.
      IF lv_part IS INITIAL.
        CONTINUE.
      ENDIF.
      IF lv_part CO `0123456789`.

        temp30 = lv_part.
        lv_part = |{ temp30 + 1 }|.
      ENDIF.
      result = |{ result }/{ lv_part }|.
    ENDLOOP.
    IF result IS INITIAL.
      result = `/`.
    ENDIF.

  ENDMETHOD.

  METHOD slot_get.

    DATA ls_slot LIKE LINE OF mt_slot.
    LOOP AT mt_slot INTO ls_slot WHERE slot = iv_slot. "#EC CI_SORTSEQ
      result = ls_slot-xml.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

  METHOD app.

    result = mi_app.

  ENDMETHOD.

  METHOD view_xml.

    result = slot_get( z2ui5_if_client=>cs_view-main ).

  ENDMETHOD.

  METHOD nest_xml.

    result = slot_get( z2ui5_if_client=>cs_view-nested ).

  ENDMETHOD.

  METHOD nest2_xml.

    result = slot_get( z2ui5_if_client=>cs_view-nested2 ).

  ENDMETHOD.

  METHOD popup_xml.

    result = slot_get( z2ui5_if_client=>cs_view-popup ).

  ENDMETHOD.

  METHOD popover_xml.

    result = slot_get( z2ui5_if_client=>cs_view-popover ).

  ENDMETHOD.

  METHOD model.
      DATA temp31 TYPE string.
        DATA temp32 TYPE REF TO z2ui5_if_ajson.
        DATA li_model LIKE temp32.
        DATA temp33 TYPE string.
        DATA lv_path TYPE string.
        DATA x TYPE REF TO cx_root.

    IF path IS INITIAL.

      IF mv_model IS INITIAL.
        temp31 = `{}`.
      ELSE.
        temp31 = mv_model.
      ENDIF.
      result = temp31.
      RETURN.
    ENDIF.
    IF mv_model IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        temp32 ?= z2ui5_cl_ajson=>parse( mv_model ).

        li_model = temp32.

        temp33 = path.

        lv_path = path_to_json( temp33 ).
        IF li_model->exists( lv_path ) = abap_true.
          result = node_text( ii_json = li_model
                              iv_path = lv_path ).
        ENDIF.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD actions.

    result = mt_action.

  ENDMETHOD.

  METHOD messages.

    " ["MESSAGE_TOAST","show",text,{...}] and ["MESSAGE_BOX",type,text,
    " {title,...}] as the client queues them, the same behind
    " ["CONTROL_GLOBAL",...] when the app called follow_up_action( )
    DATA ls_action LIKE LINE OF mt_action.
      DATA lt_arg LIKE ls_action-t_arg.
      DATA lv_name LIKE ls_action-name.
        DATA temp34 TYPE z2ui5_cl_ui5_test=>ty_s_action-name.
        DATA temp35 TYPE string.
      DATA temp36 TYPE ty_s_message.
      DATA temp8 TYPE z2ui5_cl_ui5_test=>ty_s_message-type.
      DATA temp9 TYPE string.
      DATA temp10 TYPE z2ui5_cl_ui5_test=>ty_s_message-text.
      DATA temp11 TYPE string.
      DATA ls_message LIKE temp36.
      DATA temp37 TYPE string.
      DATA temp38 TYPE string.
      DATA lv_opt LIKE temp37.
    LOOP AT mt_action INTO ls_action.

      lt_arg = ls_action-t_arg.

      lv_name = ls_action-name.
      IF lv_name = z2ui5_if_client=>cs_event-control_global.

        CLEAR temp34.

        READ TABLE lt_arg INTO temp35 INDEX 1.
        IF sy-subrc = 0.
          temp34 = temp35.
        ENDIF.
        lv_name = temp34.
        DELETE lt_arg INDEX 1.
      ENDIF.
      IF lv_name <> z2ui5_if_ui5_types=>cs_global_target-message_toast
          AND lv_name <> z2ui5_if_ui5_types=>cs_global_target-message_box.
        CONTINUE.
      ENDIF.


      CLEAR temp36.

      CLEAR temp8.

      READ TABLE lt_arg INTO temp9 INDEX 1.
      IF sy-subrc = 0.
        temp8 = temp9.
      ENDIF.
      temp36-type = temp8.

      CLEAR temp10.

      READ TABLE lt_arg INTO temp11 INDEX 2.
      IF sy-subrc = 0.
        temp10 = temp11.
      ENDIF.
      temp36-text = temp10.

      ls_message = temp36.
      IF lv_name = z2ui5_if_ui5_types=>cs_global_target-message_toast.
        ls_message-type = `toast`.
      ENDIF.

      CLEAR temp37.

      READ TABLE lt_arg INTO temp38 INDEX 3.
      IF sy-subrc = 0.
        temp37 = temp38.
      ENDIF.

      lv_opt = temp37.
      IF lv_opt IS NOT INITIAL AND lv_opt(1) = `{`.
        TRY.
            ls_message-title = z2ui5_cl_ajson=>parse( lv_opt )->z2ui5_if_ajson~get_string( `/title` ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
      INSERT ls_message INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD nav_called.

    result = mi_called.

  ENDMETHOD.

  METHOD nav_left.

    result = mi_left.

  ENDMETHOD.

  METHOD timer_event.

    result = mv_timer.

  ENDMETHOD.

  METHOD response.

    result = mv_response.

  ENDMETHOD.

ENDCLASS.
