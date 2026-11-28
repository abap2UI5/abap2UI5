" Everything the backend asks the FRONTEND to do, in one place: it collects
" the view-lifecycle calls and the URL intent of a roundtrip and hands them
" over as the response's sections VIEWS and NAV, and it builds and queues
" the actions an app asked for, the response's ACTIONS list.
" z2ui5_cl_ui5_client keeps only the public API surface and hands straight
" through to here.
"
" The sections say what the screen IS after this roundtrip - which slot
" shows what, where the URL stands. The actions say what to DO, and run
" last, once the DOM exists.
"
" Plain comments, not ABAP Doc: SE24 regenerates the CLASS statement from
" the class metadata, which detaches a leading "! block from it and turns
" it into an "ABAP Doc comment is in the wrong position" warning.
CLASS z2ui5_cl_ui5_frontend DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_ui5_action.

    "! Queue an APP-phase action for a client event, exactly as
    "! follow_up_action ships it: mapped and argument-embedded by
    "! z2ui5_cl_ui5_srv_event.
    METHODS queue_app_event
      IMPORTING
        val   TYPE clike
        view  TYPE clike        DEFAULT z2ui5_if_client=>cs_view-main
        t_arg TYPE string_table OPTIONAL.

    "! Tear a view slot down. Everything queued for that slot so far is
    "! dropped: whatever it was, this call decides the slot's state.
    METHODS slot_destroy
      IMPORTING
        slot TYPE clike.

    "! Display a view in a slot. The frontend tears the slot down implicitly
    "! before it builds (actions/Slots) - a display REPLACES the slot, so no
    "! separate destroy action travels with it. Displaying a slot twice
    "! queues ONE display, with the last XML. The transition options are the
    "! MAIN view's only: the page change the root sap.m.App animates.
    METHODS slot_display
      IMPORTING
        slot                          TYPE clike
        xml                           TYPE clike
        id                            TYPE clike     OPTIONAL
        method_insert                 TYPE clike     OPTIONAL
        method_destroy                TYPE clike     OPTIONAL
        open_by_id                    TYPE clike     OPTIONAL
        switch_default_model_path     TYPE clike     OPTIONAL
        switch_default_model_anno_uri TYPE clike     OPTIONAL
        transition                    TYPE clike     OPTIONAL
        transition_back               TYPE abap_bool DEFAULT abap_false
        nav_back                      TYPE abap_bool DEFAULT abap_false
        app_instance                  TYPE clike     OPTIONAL.

    "! The collected view-lifecycle calls as the response's VIEWS section:
    "! one entry per slot, a display with its XML and options or a teardown.
    "! Nothing is sorted - the frontend applies the slots in its own order
    "! (MAIN first: a nested view is inserted into the main control tree).
    "! Empty when the roundtrip touches no slot.
    METHODS slots_serialize
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_ajs.

    "! The roundtrip's browser-history intent as the response's NAV section -
    "! the options Router.sync takes, which computes ONE outcome from the
    "! whole object: adopt the hash, push a route entry, replace it, or write
    "! the app-state hash. Unbound when the roundtrip carries no intent, the
    "! COMMON case: the frontend syncs the URL once per response anyway, with
    "! the response's own id.
    METHODS nav_serialize
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_ajs.

    "! Queue a message toast for the APP phase. The call carries
    "! `MESSAGE_TOAST`, `show`, the text, and the options object. Only the
    "! options the app actually set end up in that object, and when it would
    "! be empty it is left off entirely - the control then applies its own
    "! defaults for everything.
    METHODS msg_toast
      IMPORTING
        text     TYPE clike
        duration TYPE clike OPTIONAL
        onclose  TYPE clike OPTIONAL.

    "! The same for a message box. text is TYPE any: a message table (
    "! BAPIRET2 and friends ) is run through the formatter first, and a
    "! formatter that finds nothing worth showing queues nothing at all.
    METHODS msg_box
      IMPORTING
        text             TYPE any
        type             TYPE clike        DEFAULT `information`
        title            TYPE clike        OPTIONAL
        styleclass       TYPE clike        OPTIONAL
        onclose          TYPE clike        OPTIONAL
        actions          TYPE string_table OPTIONAL
        emphasizedaction TYPE clike        OPTIONAL
        initialfocus     TYPE clike        OPTIONAL
        details          TYPE clike        OPTIONAL
        icon             TYPE clike        OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_action    TYPE REF TO z2ui5_cl_ui5_action.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_ui5_srv_event.

    "! Build one framework action as its JSON array: [ t_arg..., opt? ].
    "! The first argument is the whitelisted global target (VIEW_SLOTS,
    "! MESSAGE_TOAST, ROUTER, ...), which the frontend dispatches directly -
    "! the CONTROL_GLOBAL prefix of the eF( ) form is a dispatch constant,
    "! not information, so it does not travel. The options ride as the last
    "! argument and only when one was set at all - an absent object lets the
    "! frontend apply the control's own defaults for everything.
    METHODS build_global_call
      IMPORTING
        t_arg         TYPE string_table
        opt           TYPE REF TO z2ui5_if_ui5_ajs OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_ajs.

    "! Queue one APP-phase framework action.
    METHODS queue_app
      IMPORTING
        t_arg TYPE string_table
        opt   TYPE REF TO z2ui5_if_ui5_ajs OPTIONAL.

    "! Drop everything queued for a slot so far - see the method body.
    METHODS slot_reset
      IMPORTING
        slot TYPE clike.

    "! Add an option to the payload, but only when the app set it - an option
    "! that is absent lets the control apply its own default.
    METHODS set_opt_string
      IMPORTING
        json TYPE REF TO z2ui5_if_ui5_ajs
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ui5_ajs_error.

    " One option of a payload: the name it travels under, and the value the
    " app set. `val` is a string because that is what the option becomes -
    " `set_string( )` assigns its `clike` into one before it writes it, so a
    " trailing blank is cut at exactly the same point either way.
    TYPES:
      BEGIN OF ty_s_opt,
        name TYPE string,
        val  TYPE string,
      END OF ty_s_opt.
    TYPES ty_t_opt TYPE STANDARD TABLE OF ty_s_opt WITH EMPTY KEY.

    "! The same for a whole set of options at once: four payloads are built
    "! mostly out of string options, and written call by call each one
    "! was four lines of marshalling per option - most of the option calls in
    "! this class, in which the only thing worth reading is the pairing of a name
    "! with a value. A table of pairs puts the pairs on one line each and
    "! leaves the one behaviour ( absent when unset ) in set_opt_string( ),
    "! where it is stated once.
    METHODS set_opt_strings
      IMPORTING
        json TYPE REF TO z2ui5_if_ui5_ajs
        opt  TYPE ty_t_opt
      RAISING
        z2ui5_cx_ui5_ajs_error.

    METHODS set_opt_int
      IMPORTING
        json TYPE REF TO z2ui5_if_ui5_ajs
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ui5_ajs_error.

    "! Add a boolean option only when it is set - an unset flag carries no
    "! information, the receiver's own default covers it.
    METHODS set_opt_bool
      IMPORTING
        json TYPE REF TO z2ui5_if_ui5_ajs
        name TYPE string
        val  TYPE abap_bool
      RAISING
        z2ui5_cx_ui5_ajs_error.

ENDCLASS.


CLASS z2ui5_cl_ui5_frontend IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_event = NEW #( ).

  ENDMETHOD.


  METHOD build_global_call.

    TRY.
        result = z2ui5_cl_ui5_ajs=>create_empty( ).
        result->touch_array( `/` ).
        " REFERENCE INTO - an argument can be a whole view XML
        LOOP AT t_arg REFERENCE INTO DATA(lr_arg).
          result->push( iv_path = `/`
                        iv_val  = lr_arg->* ).
        ENDLOOP.
        IF opt IS BOUND AND opt->is_empty( ) = abap_false.
          result->push( iv_path = `/`
                        iv_val  = opt ).
        ENDIF.
      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `ACTION_BUILD_FAILED`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD queue_app.

    INSERT VALUE #( o_json = build_global_call( t_arg = t_arg
                                                opt   = opt ) )
           INTO TABLE mo_action->ms_next-s_action-t_custom.

  ENDMETHOD.


  METHOD queue_app_event.

    INSERT VALUE #( o_json = mo_srv_event->get_event_client_ajson(
                                 val   = val
                                 view  = view
                                 t_arg = t_arg ) )
           INTO TABLE mo_action->ms_next-s_action-t_custom.

  ENDMETHOD.


  METHOD slot_destroy.

    slot_reset( slot ).
    INSERT VALUE #( slot   = slot
                    method = z2ui5_if_ui5_types=>cs_slot_action-destroy )
           INTO TABLE mo_action->ms_next-t_action_front.

  ENDMETHOD.


  METHOD slot_reset.

    " Everything queued for this slot so far is void: whatever it was, the
    " call being queued now decides the slot's state. That is what made the
    " old slot STRUCT behave the way it did - a second popup_display( )
    " overwrote the first, a destroy after a display wiped it - only here it
    " is explicit, so the frontend receives at most ONE action per slot and
    " needs no such rule of its own.
    DELETE mo_action->ms_next-t_action_front WHERE slot = slot.

  ENDMETHOD.


  METHOD slot_display.

    " Whatever was queued for this slot so far is void - the last call
    " decides the slot's state. The teardown of what the slot currently
    " HOLDS is implicit on the frontend (a display replaces the slot), so
    " no destroy action is queued here.
    slot_reset( slot ).

    TRY.
        " The options carry what is specific to a slot - the popover's
        " anchor, a nested view's insert/destroy methods, the MAIN view's
        " model switch and page transition. An option the caller left alone
        " is absent, never sent as an empty value - so a frontend that knows
        " no transition reads a display exactly as before.
        DATA(li_opt) = CAST z2ui5_if_ui5_ajs( z2ui5_cl_ui5_ajs=>create_empty( ) ).
        set_opt_strings(
            json = li_opt
            opt  = VALUE #( ( name = `id`                        val = id )
                            ( name = `methodInsert`              val = method_insert )
                            ( name = `methodDestroy`             val = method_destroy )
                            ( name = `openById`                  val = open_by_id )
                            ( name = `switchDefaultModelPath`    val = switch_default_model_path )
                            ( name = `switchDefaultModelAnnoUri` val = switch_default_model_anno_uri )
                            ( name = `transition`                val = transition )
                            ( name = `appInstance`               val = app_instance ) ) ).
        set_opt_bool( json = li_opt
                      name = `transitionBack`
                      val  = transition_back ).
        set_opt_bool( json = li_opt
                      name = `navBack`
                      val  = nav_back ).

        INSERT VALUE #( slot    = slot
                        method  = z2ui5_if_ui5_types=>cs_slot_action-display
                        xml     = xml
                        options = li_opt )
               INTO TABLE mo_action->ms_next-t_action_front.

      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `SLOT_DISPLAY_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD slots_serialize.

    " One entry per slot: slot_reset( ) keeps at most one call per slot, so
    " the collected list IS the state of the slots after this roundtrip.
    " The order they are built in is the frontend's knowledge (View1), and
    " so is what a new MAIN view takes down with it - nothing is sorted or
    " dropped here.
    TRY.
        result = z2ui5_cl_ui5_ajs=>create_empty( ).
        " REFERENCE INTO - a row carries the whole view XML
        LOOP AT mo_action->ms_next-t_action_front REFERENCE INTO DATA(lr_action).
          IF lr_action->method = z2ui5_if_ui5_types=>cs_slot_action-destroy.
            result->set_boolean( iv_path = |/{ lr_action->slot }/DESTROY|
                                 iv_val  = abap_true ).
            CONTINUE.
          ENDIF.
          " an empty view is still a display - the key says so
          result->set( iv_ignore_empty = abap_false
                       iv_path         = |/{ lr_action->slot }/XML|
                       iv_val          = lr_action->xml ).
          IF lr_action->options IS BOUND AND lr_action->options->is_empty( ) = abap_false.
            result->set( iv_path = |/{ lr_action->slot }/OPT|
                         iv_val  = lr_action->options ).
          ENDIF.
        ENDLOOP.
      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `VIEWS_SECTION_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD nav_serialize.

    DATA(ls_nav) = mo_action->ms_next-s_nav.

    TRY.
        " only what is actually set travels - an absent option reads exactly
        " like the empty value it would otherwise carry
        DATA(li_opt) = CAST z2ui5_if_ui5_ajs( z2ui5_cl_ui5_ajs=>create_empty( ) ).
        set_opt_bool( json = li_opt
                      name = `setAppStateActive`
                      val  = ls_nav-set_app_state_active ).
        set_opt_bool( json = li_opt
                      name = `checkNavAppCall`
                      val  = ls_nav-check_nav_app_call ).
        set_opt_strings(
            json = li_opt
            opt  = VALUE #( ( name = `setPushState`      val = ls_nav-set_push_state )
                            ( name = `setHashReplace`    val = ls_nav-hash_replace )
                            ( name = `setNavRouting`     val = ls_nav-set_nav_routing )
                            ( name = `setHashEvent`      val = ls_nav-set_hash_listener )
                            ( name = `navAppCallPrevApp` val = ls_nav-nav_app_call_prev_app )
                            ( name = `navAppCallPrevId`  val = ls_nav-nav_app_call_prev_id ) ) ).

        " no nav intent this roundtrip - no section, the frontend's own
        " per-response sync covers the plain case (it injects the id itself)
        IF li_opt->is_empty( ) = abap_false.
          result = li_opt.
        ENDIF.

      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `NAV_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD msg_toast.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ui5_ajs( z2ui5_cl_ui5_ajs=>create_empty( ) ).

        " Only what the app actually set travels. sap.m.MessageToast owns a
        " default for every option, and it applies its vertical lift ONLY
        " while none of my/at/of/offset is passed ( its hasDefaultPosition
        " check ) - so mirroring a UI5 default here would both suppress that
        " lift and silently freeze the value if UI5 ever changes it. Those
        " four, and every other pure MessageToast option, are no parameter of
        " this method anymore ( 2026-09 ): they are set on the control, as the
        " option object of a CONTROL_GLOBAL MESSAGE_TOAST call - which is the
        " very object built here, so both ways meet in showToast( ).
        set_opt_int( json = li_opt
                     name = `duration`
                     val  = duration ).
        set_opt_string( json = li_opt
                        name = `onClose`
                        val  = onclose ).

        " sap.m.MessageToast is a global object, so the toast rides the
        " generic whitelisted global call
        queue_app( t_arg = VALUE #( ( z2ui5_if_ui5_types=>cs_global_target-message_toast )
                                    ( `show` )
                                    ( CONV string( text ) ) )
                   opt   = li_opt ).

      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `MESSAGE_TOAST_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD msg_box.

    DATA(ls_msg) = z2ui5_cl_ui5_srv_message=>box_resolve( text    = text
                                                          type    = type
                                                          title   = title
                                                          details = details ).
    IF ls_msg-skip = abap_true.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ui5_ajs( z2ui5_cl_ui5_ajs=>create_empty( ) ).

        " only what the app actually set travels - every MessageBox method
        " carries its OWN defaults ( confirm's [OK, CANCEL], error's [CLOSE],
        " the emphasized action derived from them ), so sending a value for an
        " option the app left alone would override those. What is left here is
        " what an ABAP app decides; a pure pass-through option ( textDirection,
        " closeOnNavigation, dependentOn, contentWidth ) is no parameter of
        " this method anymore ( 2026-09 ) and is set on the control, as the
        " option object of a CONTROL_GLOBAL MESSAGE_BOX call - which is the
        " very object built here, so both ways meet in showBox( ). The icon
        " left with them by mistake and is a parameter again ( 2026-11 )
        set_opt_strings(
            json = li_opt
            opt  = VALUE #( ( name = `title`            val = ls_msg-title )
                            ( name = `styleClass`       val = styleclass )
                            ( name = `onClose`          val = onclose )
                            ( name = `emphasizedAction` val = emphasizedaction )
                            ( name = `initialFocus`     val = initialfocus )
                            ( name = `details`          val = ls_msg-details )
                            ( name = `icon`             val = icon ) ) ).

        IF actions IS NOT INITIAL.
          li_opt->set( iv_path = `/actions`
                       iv_val  = actions ).
        ENDIF.

        " sap.m.MessageBox is a global too - and its display methods are the
        " box types, so the type IS the method of the global call
        queue_app( t_arg = VALUE #( ( z2ui5_if_ui5_types=>cs_global_target-message_box )
                                    ( ls_msg-type )
                                    ( ls_msg-text ) )
                   opt   = li_opt ).

      CATCH z2ui5_cx_ui5_ajs_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `MESSAGE_BOX_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD set_opt_string.

    " an option the app left alone must not appear in the payload at all -
    " the control's own default has to win, and an empty string is a value
    IF val IS NOT INITIAL.
      json->set_string( iv_path = |/{ name }|
                        iv_val  = val ).
    ENDIF.

  ENDMETHOD.


  METHOD set_opt_strings.

    LOOP AT opt INTO DATA(ls_opt).
      set_opt_string( json = json
                      name = ls_opt-name
                      val  = ls_opt-val ).
    ENDLOOP.

  ENDMETHOD.


  METHOD set_opt_int.

    " a duration the app left alone must not appear in the payload - UI5's
    " own default has to win. A non-numeric value is dropped rather than
    " converted, so a stray string can never reach MessageToast as NaN.
    " A blanks-only value counts as left-alone, and a digit string past the
    " integer range is dropped like a non-numeric value: CONV raised
    " CX_SY_CONVERSION_OVERFLOW out of a method whose only CATCH is the
    " ajson one (check_int_digits)
    IF z2ui5_cl_ui5_util_context=>check_int_digits( val ) = abap_true.
      json->set_integer( iv_path = |/{ name }|
                         iv_val  = CONV i( condense( val ) ) ).
    ENDIF.

  ENDMETHOD.


  METHOD set_opt_bool.

    IF val = abap_true.
      json->set_boolean( iv_path = |/{ name }|
                         iv_val  = val ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
