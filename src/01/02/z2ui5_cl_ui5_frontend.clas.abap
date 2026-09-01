" Everything the backend asks the FRONTEND to do, in one place: it builds
" the action payloads, queues them, and serializes the collected queues
" into the response's action lists. z2ui5_cl_ui5_client keeps only the
" public API surface and hands straight through to here.
"
" The two queues differ in phase, not in format. SYSTEM carries the view
" lifecycle and runs first, before the view is rendered; APP carries what an
" app asked for and runs last, once the DOM exists.
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

    "! Queue a raw JS snippet an app passed to follow_up_action - the legacy
    "! formats. It travels as a STRING entry of the action list, which is
    "! exactly the marker the frontend's legacy path keys on.
    METHODS queue_app_js
      IMPORTING
        val TYPE clike.

    "! Tear a view slot down. Everything queued for that slot so far is
    "! dropped: whatever it was, this call decides the slot's state.
    METHODS slot_destroy
      IMPORTING
        slot TYPE clike.

    "! Display a view in a slot. The frontend tears the slot down implicitly
    "! before it builds (actions/Slots) - a display REPLACES the slot, so no
    "! separate destroy action travels with it. Displaying a slot twice
    "! queues ONE display, with the last XML.
    METHODS slot_display
      IMPORTING
        slot                          TYPE clike
        xml                           TYPE clike
        id                            TYPE clike OPTIONAL
        method_insert                 TYPE clike OPTIONAL
        method_destroy                TYPE clike OPTIONAL
        open_by_id                    TYPE clike OPTIONAL
        switch_default_model_path     TYPE clike OPTIONAL
        switch_default_model_anno_uri TYPE clike OPTIONAL.

    "! Turn the collected view-lifecycle calls into SYSTEM actions - in slot
    "! order, so the frontend only has to run what it receives: a nested view
    "! is inserted into the MAIN control tree, so MAIN has to be built before
    "! NEST and NEST2 whichever way round the app called them.
    METHODS slots_serialize.

    "! Turn the roundtrip's browser-history intent into the ROUTER/sync
    "! SYSTEM action. Router computes ONE outcome from the whole options
    "! object - adopt the hash, push a route entry, replace it, or write the
    "! app-state hash - so it travels as one call with one options object.
    "! Queue it LAST, after the slots and the model push, so the route
    "! reflects what was actually rendered. The COMMON roundtrip carries no
    "! nav intent at all - then nothing is queued: the frontend syncs the
    "! URL once per response anyway (View1), with the response's own id.
    METHODS nav_serialize.

    "! Queue a message toast for the APP phase.
    "! `MESSAGE_TOAST`, `show`, the text, and the options object. Only the
    "! options the app actually set end up in that object, and when it would
    "! be empty it is left off entirely - the control then applies its own
    "! defaults for everything.
    METHODS msg_toast
      IMPORTING
        text                     TYPE clike
        duration                 TYPE clike     OPTIONAL
        width                    TYPE clike     OPTIONAL
        my                       TYPE clike     OPTIONAL
        at                       TYPE clike     OPTIONAL
        of                       TYPE clike     OPTIONAL
        offset                   TYPE clike     OPTIONAL
        collision                TYPE clike     OPTIONAL
        onclose                  TYPE clike     OPTIONAL
        autoclose                TYPE abap_bool DEFAULT abap_true
        animationtimingfunction  TYPE clike     OPTIONAL
        animationduration        TYPE clike     OPTIONAL
        closeonbrowsernavigation TYPE abap_bool DEFAULT abap_true
        class                    TYPE clike     OPTIONAL.

    "! The same for a message box. text is TYPE any: a message table (
    "! BAPIRET2 and friends ) is run through the formatter first, and a
    "! formatter that finds nothing worth showing queues nothing at all.
    METHODS msg_box
      IMPORTING
        text              TYPE any
        type              TYPE clike        DEFAULT `information`
        title             TYPE clike        OPTIONAL
        styleclass        TYPE clike        OPTIONAL
        onclose           TYPE clike        OPTIONAL
        actions           TYPE string_table OPTIONAL
        emphasizedaction  TYPE clike        OPTIONAL
        initialfocus      TYPE clike        OPTIONAL
        textdirection     TYPE clike        OPTIONAL
        icon              TYPE clike        OPTIONAL
        details           TYPE clike        OPTIONAL
        closeonnavigation TYPE abap_bool    DEFAULT abap_true
        dependenton       TYPE clike        OPTIONAL
        contentwidth      TYPE clike        OPTIONAL.

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
        opt           TYPE REF TO z2ui5_if_ajson OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson.

    "! Queue one APP-phase framework action.
    METHODS queue_app
      IMPORTING
        t_arg TYPE string_table
        opt   TYPE REF TO z2ui5_if_ajson OPTIONAL.

    "! Queue one SYSTEM-phase framework action.
    METHODS queue_system
      IMPORTING
        t_arg TYPE string_table
        opt   TYPE REF TO z2ui5_if_ajson OPTIONAL.

    "! The sap.m.MessageBox display methods, i.e. the box types the
    "! whitelisted global call accepts. Filled lazily in box_resolve - a
    "! class_constructor would have to be PUBLIC, widening the API for an
    "! internal list.
    CLASS-DATA ct_box_type TYPE string_table.

    "! Resolve what the message box actually shows. The result carries the
    "! MessageBox display method in `type`, lowercased and guaranteed to be
    "! one of ct_box_type.
    METHODS box_resolve
      IMPORTING
        text          TYPE any
        type          TYPE clike
        title         TYPE clike
        details       TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_ui5_util_context=>ty_s_msg_box.

    "! Drop everything queued for a slot so far - see the method body.
    METHODS slot_reset
      IMPORTING
        slot TYPE clike.

    "! Add an option to the payload, but only when the app set it - an option
    "! that is absent lets the control apply its own default.
    METHODS set_opt_string
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

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
    "! out of nothing but string options, and written call by call each one
    "! was four lines of marshalling per option - 28 of the 31 calls in this
    "! class, in which the only thing worth reading is the pairing of a name
    "! with a value. A table of pairs puts the pairs on one line each and
    "! leaves the one behaviour ( absent when unset ) in set_opt_string( ),
    "! where it is stated once.
    METHODS set_opt_strings
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        opt  TYPE ty_t_opt
      RAISING
        z2ui5_cx_ajson_error.

    METHODS set_opt_int
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

    "! Add a boolean option only when it differs from the receiver's own
    "! default - the default value carries no information.
    METHODS set_opt_bool
      IMPORTING
        json        TYPE REF TO z2ui5_if_ajson
        name        TYPE string
        val         TYPE abap_bool
        default_val TYPE abap_bool DEFAULT abap_false
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_ui5_frontend IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_event = NEW #( ).

  ENDMETHOD.


  METHOD build_global_call.

    TRY.
        result = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
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
      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
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


  METHOD queue_system.

    INSERT VALUE #( o_json = build_global_call( t_arg = t_arg
                                                opt   = opt ) )
           INTO TABLE mo_action->ms_next-s_action-t_system.

  ENDMETHOD.


  METHOD queue_app_event.

    INSERT VALUE #( o_json = mo_srv_event->get_event_client_ajson(
                                 val   = val
                                 view  = view
                                 t_arg = t_arg ) )
           INTO TABLE mo_action->ms_next-s_action-t_custom.

  ENDMETHOD.


  METHOD queue_app_js.

    INSERT VALUE #( js = val )
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
        " model switch. An option the caller left alone is absent, never
        " sent as an empty value.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        set_opt_strings(
            json = li_opt
            opt  = VALUE #( ( name = `id`                        val = id )
                            ( name = `methodInsert`              val = method_insert )
                            ( name = `methodDestroy`             val = method_destroy )
                            ( name = `openById`                  val = open_by_id )
                            ( name = `switchDefaultModelPath`    val = switch_default_model_path )
                            ( name = `switchDefaultModelAnnoUri` val = switch_default_model_anno_uri ) ) ).

        INSERT VALUE #( slot    = slot
                        method  = z2ui5_if_ui5_types=>cs_slot_action-display
                        xml     = xml
                        options = li_opt )
               INTO TABLE mo_action->ms_next-t_action_front.

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `SLOT_DISPLAY_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD slots_serialize.

    " A new MAIN view is a new screen, and the frontend takes the two
    " STANDALONE slots down with it (actions/Slots displayMain) - they live
    " outside the MAIN control tree and would otherwise float on top of a
    " page they no longer belong to. So a destroy for them next to a MAIN
    " display describes something that has already happened by the time it
    " would run: it is dropped here instead of travelling with every
    " roundtrip that rebuilds the view. Their DISPLAYS are untouched - the
    " slot order below puts them behind MAIN, and each action is awaited
    " before the next runs, so a popup this roundtrip opens still opens.
    DATA(lv_main_displayed) = xsdbool( line_exists(
        mo_action->ms_next-t_action_front[ slot   = z2ui5_if_client=>cs_view-main
                                           method = z2ui5_if_ui5_types=>cs_slot_action-display ] ) ). "#EC CI_SORTSEQ
    IF lv_main_displayed = abap_true.
      DELETE mo_action->ms_next-t_action_front
             WHERE method = z2ui5_if_ui5_types=>cs_slot_action-destroy
               AND ( slot = z2ui5_if_client=>cs_view-popup
                  OR slot = z2ui5_if_client=>cs_view-popover ).
    ENDIF.

    " The view-lifecycle calls leave in SLOT order, never in the order the
    " app happened to make them - see the ABAP Doc.
    LOOP AT VALUE string_table( ( z2ui5_if_client=>cs_view-main )
                                ( z2ui5_if_client=>cs_view-nested )
                                ( z2ui5_if_client=>cs_view-nested2 )
                                ( z2ui5_if_client=>cs_view-popup )
                                ( z2ui5_if_client=>cs_view-popover ) )
         INTO DATA(lv_slot).
      " REFERENCE INTO - a row carries the whole view XML, which a copying
      " LOOP would duplicate once per slot action
      LOOP AT mo_action->ms_next-t_action_front REFERENCE INTO DATA(lr_action) "#EC CI_SORTSEQ
           WHERE slot = lv_slot.
        DATA(lt_arg) = VALUE string_table( ( z2ui5_if_ui5_types=>cs_slot_action-target )
                                           ( lr_action->method )
                                           ( lr_action->slot ) ).
        IF lr_action->method = z2ui5_if_ui5_types=>cs_slot_action-display.
          INSERT lr_action->xml INTO TABLE lt_arg.
        ENDIF.
        queue_system( t_arg = lt_arg
                      opt   = lr_action->options ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD nav_serialize.

    DATA(ls_nav) = mo_action->ms_next-s_nav.

    TRY.
        " only what is actually set travels - an absent option reads exactly
        " like the empty value it would otherwise carry
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
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

        " no nav intent this roundtrip - queue nothing, the frontend's own
        " per-response sync covers the plain case (it injects the id itself)
        IF li_opt->is_empty( ) = abap_true.
          RETURN.
        ENDIF.

        queue_system( t_arg = VALUE #( ( z2ui5_if_ui5_types=>cs_global_target-router )
                                       ( `sync` ) )
                      opt   = li_opt ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `NAV_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD msg_toast.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        " Only what the app actually set travels. sap.m.MessageToast owns a
        " default for every option, and it applies its vertical lift ONLY
        " while none of my/at/of/offset is passed ( its hasDefaultPosition
        " check ) - so mirroring a UI5 default here would both suppress that
        " lift and silently freeze the value if UI5 ever changes it.
        set_opt_int( json = li_opt
                     name = `duration`
                     val  = duration ).
        set_opt_int( json = li_opt
                     name = `animationDuration`
                     val  = animationduration ).
        set_opt_strings(
            json = li_opt
            " `class` is NOT a MessageToast option - the frontend puts the
            " classes on the DOM node of the toast, which carries no id to
            " address it by
            opt  = VALUE #( ( name = `width`                   val = width )
                            ( name = `my`                      val = my )
                            ( name = `at`                      val = at )
                            ( name = `of`                      val = of )
                            ( name = `offset`                  val = offset )
                            ( name = `collision`               val = collision )
                            ( name = `onClose`                 val = onclose )
                            ( name = `animationTimingFunction` val = animationtimingfunction )
                            ( name = `class`                   val = class ) ) ).

        " abap_true is UI5's own default for both, so only the opt-out is
        " worth sending
        set_opt_bool( json        = li_opt
                      name        = `autoClose`
                      val         = autoclose
                      default_val = abap_true ).
        set_opt_bool( json        = li_opt
                      name        = `closeOnBrowserNavigation`
                      val         = closeonbrowsernavigation
                      default_val = abap_true ).

        " sap.m.MessageToast is a global object, so the toast rides the
        " generic whitelisted global call
        queue_app( t_arg = VALUE #( ( z2ui5_if_ui5_types=>cs_global_target-message_toast )
                                    ( `show` )
                                    ( CONV string( text ) ) )
                   opt   = li_opt ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `MESSAGE_TOAST_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


  METHOD msg_box.

    DATA(ls_msg) = box_resolve( text    = text
                                type    = type
                                title   = title
                                details = details ).
    IF ls_msg-skip = abap_true.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        " only what the app actually set travels - every MessageBox method
        " carries its OWN defaults ( confirm's [OK, CANCEL], error's [CLOSE],
        " the emphasized action derived from them ), so sending a value for an
        " option the app left alone would override those
        set_opt_strings(
            json = li_opt
            opt  = VALUE #( ( name = `title`            val = ls_msg-title )
                            ( name = `styleClass`       val = styleclass )
                            ( name = `onClose`          val = onclose )
                            ( name = `emphasizedAction` val = emphasizedaction )
                            ( name = `initialFocus`     val = initialfocus )
                            ( name = `textDirection`    val = textdirection )
                            ( name = `details`          val = ls_msg-details )
                            ( name = `dependentOn`      val = dependenton )
                            ( name = `contentWidth`     val = contentwidth ) ) ).

        " MessageBox.Icon.NONE is a valid UI5 value, but passing it would
        " defeat the icon the chosen method sets for itself ( error -> the
        " error icon ), so it is dropped like an unset icon
        IF icon <> `NONE`.
          set_opt_string( json = li_opt
                          name = `icon`
                          val  = icon ).
        ENDIF.

        IF actions IS NOT INITIAL.
          li_opt->touch_array( `/actions` ).
          LOOP AT actions INTO DATA(lv_action).
            li_opt->push( iv_path = `/actions`
                          iv_val  = lv_action ).
          ENDLOOP.
        ENDIF.

        " abap_true is UI5's own default, so only the opt-out is worth sending
        set_opt_bool( json        = li_opt
                      name        = `closeOnNavigation`
                      val         = closeonnavigation
                      default_val = abap_true ).

        " sap.m.MessageBox is a global too - and its display methods are the
        " box types, so the type IS the method of the global call
        queue_app( t_arg = VALUE #( ( z2ui5_if_ui5_types=>cs_global_target-message_box )
                                    ( ls_msg-type )
                                    ( ls_msg-text ) )
                   opt   = li_opt ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `MESSAGE_BOX_OPTIONS_INVALID`
            previous = lx_json.
    ENDTRY.

  ENDMETHOD.


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

    IF z2ui5_cl_ui5_util_context=>rtti_check_clike( text ) = abap_false.
      result = z2ui5_cl_ui5_util_context=>ui5_msg_box_format( text ).
      IF result-skip = abap_true.
        RETURN.
      ENDIF.
      IF title IS NOT INITIAL.
        result-title = title.
      ENDIF.
    ELSE.
      " lowercased right here, so `Information` gets the same show-mapping
      " and default title as `information`
      result = VALUE #( text    = text
                        type    = to_lower( type )
                        title   = title
                        details = details ).

      IF result-type = `information`.
        result-type = `show`.
        IF result-title IS INITIAL.
          result-title = `Information`.
        ENDIF.
      ENDIF.
    ENDIF.

    " MessageBox display methods are lowercase (show, error, warning, ...) but
    " the type arrives capitalized from ui5_msg_box_format ( `Error` for a
    " multi-message box ) or however an app spelled it
    result-type = to_lower( result-type ).

    " the type travels as the method of the whitelisted global call, so a type
    " that is no MessageBox display method would be rejected there and the box
    " would not appear at all - a requested box is never dropped silently, it
    " falls back to a plain show( ) like the frontend used to do
    IF NOT line_exists( ct_box_type[ table_line = result-type ] ). "#EC CI_SORTSEQ
      result-type = `show`.
    ENDIF.

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
    " Condense first: `1 000` would pass a check that allows blanks and then
    " dump in CONV, and a blanks-only value must count as left-alone.
    DATA(lv_val) = condense( CONV string( val ) ).
    IF lv_val IS NOT INITIAL AND lv_val CO `0123456789`.
      json->set_integer( iv_path = |/{ name }|
                         iv_val  = CONV i( lv_val ) ).
    ENDIF.

  ENDMETHOD.


  METHOD set_opt_bool.

    IF val <> default_val.
      json->set_boolean( iv_path = |/{ name }|
                         iv_val  = val ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
