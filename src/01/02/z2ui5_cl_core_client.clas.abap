CLASS z2ui5_cl_core_client DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_client.

    DATA mo_action TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        action TYPE REF TO z2ui5_cl_core_action.

    DATA mo_srv_bind  TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA mo_srv_event TYPE REF TO z2ui5_cl_core_srv_event.

    METHODS nav_app_set_id
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! Resolve what the message box actually shows. text is TYPE any: a
    "! message table ( BAPIRET2 and friends ) is run through the formatter,
    "! a plain text is taken as it stands. The result carries the MessageBox
    "! display method in `type`, already lowercased.
    METHODS msg_box_resolve
      IMPORTING
        text          TYPE any
        type          TYPE clike
        title         TYPE clike
        details       TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_a2ui5_context=>ty_s_msg_box.

    "! Add a message option to the payload, but only when the app set it -
    "! an option that is absent lets the control apply its own default.
    METHODS set_opt_string
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

    METHODS set_opt_int
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_core_client IMPLEMENTATION.


  METHOD constructor.

    mo_action = action.
    mo_srv_bind = NEW #( mo_action->mo_app ).
    mo_srv_event = NEW #( ).

  ENDMETHOD.


  METHOD z2ui5_if_client~follow_up_action.

    DATA(lv_js) = val.

    IF val IS NOT INITIAL
        AND val CO `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_`.
      " a framework event travels as pure data - a JSON array serialized and
      " escaped entirely in ABAP (get_event_client_json); only a raw JS
      " expression passed by the app keeps the code form
      lv_js = mo_srv_event->get_event_client_json( val   = val
                                                   view  = view
                                                   t_arg = t_arg ).
    ENDIF.

    INSERT lv_js INTO TABLE mo_action->ms_next-s_set-s_follow_up_action-custom_js.

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_event.

    IF val IS NOT INITIAL.
      result = xsdbool( mo_action->ms_actual-event = val ).
    ELSE.
      result = xsdbool( mo_action->ms_actual-event IS NOT INITIAL ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    result = VALUE #( event                  = mo_action->ms_actual-event
                      check_launchpad_active = mo_action->mo_http_post->ms_request-s_control-check_launchpad
                      t_event_arg            = mo_action->ms_actual-t_event_arg
                      s_draft                = CORRESPONDING #( mo_action->mo_app->ms_draft )
                      check_on_navigated     = mo_action->ms_actual-check_on_navigated
                      s_config               = CORRESPONDING #( mo_action->mo_http_post->ms_request-s_front )
                      s_device               = mo_action->mo_http_post->ms_request-s_front-s_device
                      s_focus                = mo_action->mo_http_post->ms_request-s_front-s_focus
                      s_scroll               = mo_action->mo_http_post->ms_request-s_front-s_scroll
                      s_ui5                  = mo_action->mo_http_post->ms_request-s_front-s_ui5
                      r_event_data           = mo_action->ms_actual-r_data
                      _s_nav-check_call      = xsdbool( mo_action->ms_next-o_app_call IS NOT INITIAL )
                      _s_nav-check_leave     = xsdbool( mo_action->ms_next-o_app_leave IS NOT INITIAL ) ).

    TRY.

        DATA(lo_comp) = mo_action->mo_http_post->ms_request-s_front-o_comp_data.
        IF lo_comp IS NOT BOUND.
          RETURN.
        ENDIF.
        DATA(lo_params) = lo_comp->slice( `/startupParameters/` ).

        IF lo_params IS NOT BOUND.
          RETURN.
        ENDIF.
        LOOP AT lo_params->mt_json_tree                 "#EC CI_SORTSEQ
             REFERENCE INTO DATA(lr_comp)
             WHERE name = `1`.

          INSERT VALUE #( n = shift_left( val = shift_right( val = lr_comp->path
                                                             sub = `/` )
                                          sub = `/` )
                          v = lr_comp->value ) INTO TABLE result-t_comp_params.
        ENDLOOP.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_event_arg.

    TRY.
        result = mo_action->ms_actual-t_event_arg[ v ].
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app.

    IF id IS NOT INITIAL.
      DATA(lo_app) = z2ui5_cl_core_app=>db_load( id ).
      result = CAST #( lo_app->mo_app ).
    ELSE.
      result = get_if_app( ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_box_display.

    DATA(ls_msg) = msg_box_resolve( text    = text
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
        set_opt_string( json = li_opt
                        name = `title`
                        val  = ls_msg-title ).
        set_opt_string( json = li_opt
                        name = `styleClass`
                        val  = styleclass ).
        set_opt_string( json = li_opt
                        name = `onClose`
                        val  = onclose ).
        set_opt_string( json = li_opt
                        name = `emphasizedAction`
                        val  = emphasizedaction ).
        set_opt_string( json = li_opt
                        name = `initialFocus`
                        val  = initialfocus ).
        set_opt_string( json = li_opt
                        name = `textDirection`
                        val  = textdirection ).
        set_opt_string( json = li_opt
                        name = `details`
                        val  = ls_msg-details ).
        set_opt_string( json = li_opt
                        name = `dependentOn`
                        val  = dependenton ).
        set_opt_string( json = li_opt
                        name = `contentWidth`
                        val  = contentwidth ).

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
        IF closeonnavigation = abap_false.
          li_opt->set_boolean( iv_path = `/closeOnNavigation`
                               iv_val  = abap_false ).
        ENDIF.

        z2ui5_if_client~follow_up_action(
            val   = z2ui5_if_client=>cs_event-message_box
            t_arg = VALUE #( ( ls_msg-type )
                             ( ls_msg-text )
                             ( li_opt->stringify( ) ) ) ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |MESSAGE_BOX_OPTIONS_INVALID - { lx_json->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD msg_box_resolve.

    IF z2ui5_cl_a2ui5_context=>rtti_check_clike( text ) = abap_false.
      result = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( text ).
      IF result-skip = abap_true.
        RETURN.
      ENDIF.
      IF title IS NOT INITIAL.
        result-title = title.
      ENDIF.
    ELSE.
      result = VALUE #( text    = text
                        type    = type
                        title   = title
                        details = details ).

      IF result-type = `information`.
        result-type = `show`.
        IF result-title IS INITIAL.
          result-title = `Information`.
        ENDIF.
      ENDIF.
    ENDIF.

    IF result-type IS INITIAL.
      result-type = `show`.
    ENDIF.

    " MessageBox display methods are lowercase (show, error, warning, ...) but
    " the type arrives capitalized from ui5_msg_box_format ( `Error` for a
    " multi-message box ) or however an app spelled it
    result-type = to_lower( result-type ).

  ENDMETHOD.


  METHOD set_opt_string.

    " an option the app left alone must not appear in the payload at all -
    " the control's own default has to win, and an empty string is a value
    IF val IS NOT INITIAL.
      json->set_string( iv_path = |/{ name }|
                        iv_val  = val ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~message_toast_display.

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
        set_opt_string( json = li_opt
                        name = `width`
                        val  = width ).
        set_opt_string( json = li_opt
                        name = `my`
                        val  = my ).
        set_opt_string( json = li_opt
                        name = `at`
                        val  = at ).
        set_opt_string( json = li_opt
                        name = `of`
                        val  = of ).
        set_opt_string( json = li_opt
                        name = `offset`
                        val  = offset ).
        set_opt_string( json = li_opt
                        name = `collision`
                        val  = collision ).
        set_opt_string( json = li_opt
                        name = `onClose`
                        val  = onclose ).
        set_opt_string( json = li_opt
                        name = `animationTimingFunction`
                        val  = animationtimingfunction ).
        " not a MessageToast option - the frontend puts the classes on the
        " DOM node of the toast, which carries no id to address it by
        set_opt_string( json = li_opt
                        name = `class`
                        val  = class ).

        " abap_true is UI5's own default for both, so only the opt-out is
        " worth sending
        IF autoclose = abap_false.
          li_opt->set_boolean( iv_path = `/autoClose`
                               iv_val  = abap_false ).
        ENDIF.
        IF closeonbrowsernavigation = abap_false.
          li_opt->set_boolean( iv_path = `/closeOnBrowserNavigation`
                               iv_val  = abap_false ).
        ENDIF.

        z2ui5_if_client~follow_up_action(
            val   = z2ui5_if_client=>cs_event-message_toast
            t_arg = VALUE #( ( CONV string( text ) )
                             ( li_opt->stringify( ) ) ) ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |MESSAGE_TOAST_OPTIONS_INVALID - { lx_json->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD set_opt_int.

    " a duration the app left alone must not appear in the payload - UI5's
    " own default has to win. A non-numeric value is dropped rather than
    " converted, so a stray string can never reach MessageToast as NaN.
    IF val IS NOT INITIAL AND val CO ` 0123456789`.
      json->set_integer( iv_path = |/{ name }|
                         iv_val  = CONV i( val ) ).
    ENDIF.

  ENDMETHOD.


  METHOD nav_app_set_id.

    IF app IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `NAV_APP_TARGET_NOT_BOUND - the app passed to nav_app_call/nav_app_leave is not bound`.
    ENDIF.

    IF app->id_app IS INITIAL.
      app->id_app = z2ui5_cl_a2ui5_context=>uuid_get_c32( ).
    ENDIF.
    result = app->id_app.

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_call.

    mo_action->ms_next-o_app_call = app.
    result = nav_app_set_id( app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_leave.

    IF app IS NOT SUPPLIED.
      app = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app_stack ).
    ENDIF.

    mo_action->ms_next-o_app_leave = app.
    mo_action->ms_next-next_event  = event.

    " IS SUPPLIED (not IS NOT INITIAL) so an intentionally empty return
    " value still reaches the previous app (https://github.com/abap2UI5/abap2UI5/issues/2404)
    IF r_data IS SUPPLIED.
      mo_action->ms_next-r_data = z2ui5_cl_a2ui5_context=>conv_copy_ref_data( r_data ).
    ENDIF.

    result = nav_app_set_id( app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_destroy.

    " see popover_destroy for why the whole slot is wiped instead of setting a flag
    mo_action->ms_next-s_set-s_view_nest2 = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_display.

    mo_action->ms_next-s_set-s_view_nest2-check_destroy  = abap_false.
    mo_action->ms_next-s_set-s_view_nest2-xml            = val.
    mo_action->ms_next-s_set-s_view_nest2-id             = id.
    mo_action->ms_next-s_set-s_view_nest2-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest2-method_insert  = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest2_view_model_update.

    " deliberately EMPTY - see view_model_update. A nested view owns no model
    " anyway: it inherits the MAIN view's by UI5 model propagation, so the
    " automatic push of the root model already covers it

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_destroy.

    " see popover_destroy for why the whole slot is wiped instead of setting a flag
    mo_action->ms_next-s_set-s_view_nest = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_display.

    mo_action->ms_next-s_set-s_view_nest-check_destroy  = abap_false.
    mo_action->ms_next-s_set-s_view_nest-xml            = val.
    mo_action->ms_next-s_set-s_view_nest-id             = id.
    mo_action->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_action->ms_next-s_set-s_view_nest-method_insert  = method_insert.

  ENDMETHOD.


  METHOD z2ui5_if_client~nest_view_model_update.

    " deliberately EMPTY - see nest2_view_model_update

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_destroy.

    " wipe the whole slot (like popup_destroy) - a plain flag would leave the
    " xml of a popover_display( ) from the same roundtrip in place and the
    " frontend would destroy and then re-open the popover
    mo_action->ms_next-s_set-s_popover = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_display.

    mo_action->ms_next-s_set-s_popover-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_popover-xml           = xml.
    mo_action->ms_next-s_set-s_popover-open_by_id    = by_id.

  ENDMETHOD.


  METHOD z2ui5_if_client~popover_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPOVER slot too, so an open popover refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_destroy.

    mo_action->ms_next-s_set-s_popup = VALUE #( check_destroy = abap_true ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_action->ms_next-s_set-s_popup-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_popup-xml           = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_model_update.

    " deliberately EMPTY - see view_model_update. The automatic push flags
    " the POPUP slot too, so an open popup refreshes without this call

  ENDMETHOD.


  METHOD z2ui5_if_client~view_destroy.

    mo_action->ms_next-s_set-s_view-check_destroy = abap_true.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_display.

    " like popup_display/popover_display: displaying cancels a destroy
    " queued earlier in the same roundtrip
    mo_action->ms_next-s_set-s_view-check_destroy = abap_false.
    mo_action->ms_next-s_set-s_view-xml = val.
    mo_action->ms_next-s_set-s_view-switchdefaultmodelannouri = switch_default_model_anno_uri.
    mo_action->ms_next-s_set-s_view-switch_default_model_path = switch_default_model_path.

  ENDMETHOD.


  METHOD z2ui5_if_client~view_model_update.

    " deliberately EMPTY - the handler pushes the model by itself whenever
    " main( ) changed it (z2ui5_cl_core_handler=>main_end compares the model
    " before and after main( ) and flags every model-owning slot). The method
    " stays in the interface so existing apps keep compiling and their calls
    " keep being harmless; there is nothing left for it to do

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind.

    DATA(li_filter) = custom_filter.

    " omit_initial wires ajson's empty filter into the slot the serializer
    " already evaluates (z2ui5_cl_core_srv_model->main_json_stringify), so an
    " initial field stays ABSENT from the model and the control keeps its own
    " default. A caller-supplied filter is kept: both have to pass.
    IF omit_initial = abap_true OR omit_initial_paths IS NOT INITIAL.
      TRY.
          DATA li_omit TYPE REF TO z2ui5_if_ajson_filter.
          IF omit_initial_paths IS NOT INITIAL.
            " scoped: only the listed columns are dropped when initial, so a
            " boolean that must send abap_false survives
            li_omit = NEW lcl_initial_paths_filter( omit_initial_paths ).
          ELSE.
            li_omit = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ).
          ENDIF.
          IF li_filter IS BOUND.
            li_filter = z2ui5_cl_ajson_filter_lib=>create_and_filter(
                            VALUE #( ( li_filter ) ( li_omit ) ) ).
          ELSE.
            li_filter = li_omit.
          ENDIF.
        CATCH cx_root.
          " a filter that cannot be built must not kill the roundtrip - the
          " model is then serialized as before (initial fields included)
          li_filter = custom_filter.
      ENDTRY.
    ENDIF.

    result = mo_srv_bind->main( val    = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( val )
                                config = VALUE #(
                                    path_only            = path
                                    custom_filter        = li_filter
                                    custom_mapper        = custom_mapper
                                    tab                  = z2ui5_cl_a2ui5_context=>conv_get_as_data_ref( tab )
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model
                                    check_json           = json ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_bind_edit.

    " compatibility alias of _bind - delegate instead of repeating the call so
    " both can never drift apart. custom_mapper_back / custom_filter_back exist
    " only on this signature and are deliberately no longer evaluated (_bind
    " has no counterpart for them).
    result = z2ui5_if_client~_bind( val                  = val
                                    path                 = path
                                    view                 = view
                                    custom_mapper        = custom_mapper
                                    custom_filter        = custom_filter
                                    tab                  = tab
                                    tab_index            = tab_index
                                    switch_default_model = switch_default_model ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event.

    result = mo_srv_event->get_event( val   = val
                                      t_arg = t_arg
                                      s_cnt = s_ctrl ).

    IF r_data IS NOT INITIAL.
      mo_action->ms_next-r_data = z2ui5_cl_a2ui5_context=>conv_copy_ref_data( r_data ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_client.

    result = mo_srv_event->get_event_client( val   = val
                                             view  = view
                                             t_arg = t_arg ).

  ENDMETHOD.


  METHOD z2ui5_if_client~set_nav_back.

    mo_action->ms_next-s_set-set_nav_back = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_push_state.

    mo_action->ms_next-s_set-set_push_state = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_nav_routing.

    mo_action->ms_next-s_set-set_nav_routing = mode.
    " remember the mode on the app so every later response of this app carries
    " it again - see z2ui5_cl_core_app=>mv_nav_mode
    mo_action->mo_app->mv_nav_mode = mode.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_app_state_active.

    mo_action->ms_next-s_set-set_app_state_active = val.

  ENDMETHOD.


  METHOD z2ui5_if_client~set_session_stateful.

    DATA(li_app) = get_if_app( ).
    IF li_app->check_sticky = val.
      RETURN.
    ENDIF.
    mo_action->ms_next-s_set-s_stateful-active = COND #( WHEN val = abap_true THEN 1 ELSE 0 ).
    li_app->check_sticky = val.

    mo_action->ms_next-s_set-s_stateful-switched = xsdbool( mo_action->ms_next-s_set-s_stateful-switched = abap_false ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_app_prev_stack.

    result = xsdbool( mo_action->mo_app->ms_draft-id_prev_app_stack IS NOT INITIAL ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_init.

    " keep the interface access on a typed variable - reading the attribute
    " directly on the method-call chain breaks in the abaplint transpiler
    " runtime (plain property access misses the interface attribute alias)
    DATA(li_app) = get_if_app( ).
    result = xsdbool( li_app->check_initialized = abap_false ).

  ENDMETHOD.


  METHOD z2ui5_if_client~check_on_navigated.

    result = mo_action->ms_actual-check_on_navigated.

  ENDMETHOD.


  METHOD z2ui5_if_client~get_app_prev.

    result = z2ui5_if_client~get_app( mo_action->mo_app->ms_draft-id_prev_app ).

  ENDMETHOD.


  METHOD z2ui5_if_client~_event_nav_app_leave.

    result = z2ui5_if_client~_event( z2ui5_if_core_types=>cs_event_nav_app_leave ).

  ENDMETHOD.


  METHOD get_if_app.

    result = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

  ENDMETHOD.

ENDCLASS.
