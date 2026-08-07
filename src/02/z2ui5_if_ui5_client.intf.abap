INTERFACE z2ui5_if_ui5_client
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_event,

      "Framework
      popup_close               TYPE string VALUE `POPUP_CLOSE`,
      popover_close             TYPE string VALUE `POPOVER_CLOSE`,

      set_size_limit            TYPE string VALUE `SET_SIZE_LIMIT`,
      set_odata_model           TYPE string VALUE `SET_ODATA_MODEL`,

      cross_app_nav_to_ext      TYPE string VALUE `CROSS_APP_NAV_TO_EXT`,
      cross_app_nav_to_prev_app TYPE string VALUE `CROSS_APP_NAV_TO_PREV_APP`,


      "Actions base
      clipboard_copy            TYPE string VALUE `CLIPBOARD_COPY`,
      set_title                 TYPE string VALUE `SET_TITLE`,
      set_favicon               TYPE string VALUE `SET_FAVICON`,
      set_focus                 TYPE string VALUE `SET_FOCUS`,
      scroll_to                 TYPE string VALUE `SCROLL_TO`,
      scroll_into_view          TYPE string VALUE `SCROLL_INTO_VIEW`,
      start_timer               TYPE string VALUE `START_TIMER`,
      system_logout             TYPE string VALUE `SYSTEM_LOGOUT`,
      keyboard_set_mode         TYPE string VALUE `KEYBOARD_SET_MODE`,
      keyboard_shortcut         TYPE string VALUE `KEYBOARD_SHORTCUT`,
      open_new_tab              TYPE string VALUE `OPEN_NEW_TAB`,
      location_reload           TYPE string VALUE `LOCATION_RELOAD`,
      nav_to_route              TYPE string VALUE `NAV_TO_ROUTE`,

      "Actions more
      set_title_launchpad       TYPE string VALUE `SET_TITLE_LAUNCHPAD`,

      "Control Action
      wizard_set_next_step      TYPE string VALUE `WIZARD_SET_NEXT_STEP`,

      download_b64_file         TYPE string VALUE `DOWNLOAD_B64_FILE`,
      urlhelper                 TYPE string VALUE `URLHELPER`,
      history_back              TYPE string VALUE `HISTORY_BACK`,
      clipboard_app_state       TYPE string VALUE `CLIPBOARD_APP_STATE`,

      store_data                TYPE string VALUE `STORE_DATA`,
      play_audio                TYPE string VALUE `PLAY_AUDIO`,

      "Control
      control_by_id             TYPE string VALUE `CONTROL_BY_ID`,
      control_global            TYPE string VALUE `CONTROL_GLOBAL`,
      binding_call              TYPE string VALUE `BINDING_CALL`,
      bind_element              TYPE string VALUE `BIND_ELEMENT`,
      smart_variant_init        TYPE string VALUE `SMART_VARIANT_INIT`,
      filter_bar_variant_init   TYPE string VALUE `FILTER_BAR_VARIANT_INIT`,

    END OF cs_event.

  CONSTANTS:
    BEGIN OF cs_view,
      main    TYPE string VALUE `MAIN`,
      nested  TYPE string VALUE `NEST`,
      nested2 TYPE string VALUE `NEST2`,
      popup   TYPE string VALUE `POPUP`,
      popover TYPE string VALUE `POPOVER`,
    END OF cs_view.

  CONSTANTS:
    "! Hash-based app routing modes (see set_nav_routing). The mode decides how
    "! much of the running app the URL hash carries, and therefore what the
    "! browser Back/Forward buttons (and a reload / bookmark) restore:
    "!  default - no routing: the hash is left untouched, exactly as before this
    "!            feature. Back/Forward leave the abap2UI5 page (framework default).
    "!  fresh   - route '#/app/&lt;CLASS&gt;' (class only): Back/Forward/reload/bookmark
    "!            start the app FRESH (a clean instance, no preserved input).
    "!  keep    - route '#/app/&lt;CLASS&gt;/&lt;DRAFT&gt;' (class + server draft): the exact
    "!            preserved state is restored (all user input), falling back to a
    "!            fresh start once the draft has expired.
    BEGIN OF cs_nav_mode,
      default TYPE string VALUE `DEFAULT`,
      fresh   TYPE string VALUE `FRESH`,
      keep    TYPE string VALUE `KEEP`,
    END OF cs_nav_mode.

  CONSTANTS:
    BEGIN OF cs_device,
      BEGIN OF system,
        phone   TYPE string VALUE `phone`,
        tablet  TYPE string VALUE `tablet`,
        desktop TYPE string VALUE `desktop`,
        combi   TYPE string VALUE `combi`,
      END OF system,
      BEGIN OF browser,
        chrome  TYPE string VALUE `cr`,
        firefox TYPE string VALUE `ff`,
        safari  TYPE string VALUE `sf`,
        edge    TYPE string VALUE `ed`,
      END OF browser,
      BEGIN OF os,
        windows   TYPE string VALUE `win`,
        macintosh TYPE string VALUE `mac`,
        linux     TYPE string VALUE `linux`,
        ios       TYPE string VALUE `ios`,
        android   TYPE string VALUE `android`,
      END OF os,
      BEGIN OF orientation,
        portrait  TYPE string VALUE `portrait`,
        landscape TYPE string VALUE `landscape`,
      END OF orientation,
    END OF cs_device.

  TYPES:
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_http_context,
      path      TYPE string,
      app_start TYPE string,
      t_params  TYPE ty_t_name_value,
    END OF ty_s_http_context.

  TYPES:
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
    END OF ty_s_draft.

  TYPES:
    BEGIN OF ty_s_http_config,
      src                     TYPE string,
      theme                   TYPE string,
      content_security_policy TYPE string,
      styles_css              TYPE string,
      title                   TYPE string,
      t_add_config            TYPE ty_t_name_value,
      custom_js               TYPE string,
      t_security_header       TYPE ty_t_name_value,
    END OF ty_s_http_config.

  TYPES:
    BEGIN OF ty_s_http_config_post,
      draft_exp_time_in_hours  TYPE i,
      " when set via the exit, framework errors answer with a generic 500
      " message instead of the raw exception text (avoids leaking internal
      " details to the client in hardened installations)
      check_hide_error_details TYPE abap_bool,
      " a state-changing POST whose Origin/Referer header names a different
      " site than the app's own host is rejected with 403 (CSRF defense).
      " On by default: z2ui5_cl_exit=>set_config_http_post seeds abap_true
      " before the user exit runs, so an app that must accept cross-origin
      " POSTs opts out by setting it back to abap_false in its own exit.
      " Lenient: a request without an Origin/Referer header (older clients,
      " some proxies) is allowed, so only an explicit cross-origin marker is
      " blocked - the app's own roundtrips are always same-origin (the SPA
      " fetches its own backend).
      check_csrf_active        TYPE abap_bool,
    END OF ty_s_http_config_post.

  TYPES:
    BEGIN OF ty_s_config,
      origin   TYPE string,
      pathname TYPE string,
      search   TYPE string,
      hash     TYPE string,
    END OF ty_s_config.

  TYPES:
    BEGIN OF ty_s_get,
      event                  TYPE string,
      t_event_arg            TYPE string_table,
      check_launchpad_active TYPE abap_bool,
      check_on_navigated     TYPE abap_bool,
      s_draft                TYPE ty_s_draft,
      s_config               TYPE ty_s_config,
      t_comp_params          TYPE ty_t_name_value,
      r_event_data           TYPE REF TO data,
      BEGIN OF s_device,
        system      TYPE string,
        orientation TYPE string,
        BEGIN OF browser,
          name    TYPE string,
          version TYPE string,
        END OF browser,
        BEGIN OF os,
          name    TYPE string,
          version TYPE string,
        END OF os,
        BEGIN OF resize,
          width  TYPE i,
          height TYPE i,
        END OF resize,
        BEGIN OF support,
          touch   TYPE abap_bool,
          pointer TYPE abap_bool,
          retina  TYPE abap_bool,
        END OF support,
      END OF s_device,
      BEGIN OF s_focus,
        id              TYPE string,
        selection_start TYPE i,
        selection_end   TYPE i,
      END OF s_focus,
      BEGIN OF s_scroll,
        BEGIN OF main,
          id TYPE string,
          x  TYPE i,
          y  TYPE i,
        END OF main,
        BEGIN OF nest,
          id TYPE string,
          x  TYPE i,
          y  TYPE i,
        END OF nest,
        BEGIN OF nest2,
          id TYPE string,
          x  TYPE i,
          y  TYPE i,
        END OF nest2,
        BEGIN OF popup,
          id TYPE string,
          x  TYPE i,
          y  TYPE i,
        END OF popup,
        BEGIN OF popover,
          id TYPE string,
          x  TYPE i,
          y  TYPE i,
        END OF popover,
      END OF s_scroll,
      BEGIN OF s_ui5,
        version         TYPE string,
        build_timestamp TYPE string,
        gav             TYPE string,
        theme           TYPE string,
      END OF s_ui5,
      BEGIN OF _s_nav,
        check_leave TYPE abap_bool,
        check_call  TYPE abap_bool,
      END OF _s_nav,
    END OF ty_s_get.

  TYPES:
    BEGIN OF ty_s_event_control,
      check_allow_multi_req TYPE abap_bool,
      " cancel the control's built-in default for this event before the
      " roundtrip (oEvent.preventDefault(), e.g. sap.tnt NavigationListItem
      " press without the automatic item selection); the event itself is
      " still sent, so the backend decides what happens instead
      check_prevent_default TYPE abap_bool,
      " the same veto, but decided PER FIRING instead of per wire: a client
      " expression that is evaluated when the event fires and cancels the
      " default only when it is truthy, e.g.
      "   `${$parameters>/column}.getId() CS 'COL_DATE'` in UI5 terms:
      "   `${$parameters>/column}.getId().indexOf('COL_DATE') >= 0`
      " so ONE wire can protect one row/column and let the rest through.
      " Wins over check_prevent_default when both are set; the event is sent
      " in either case, exactly as with the flag
      prevent_default_expr  TYPE string,
    END OF ty_s_event_control.

  INTERFACES z2ui5_if_client.

  ALIASES view_destroy            FOR z2ui5_if_client~view_destroy.
  ALIASES view_display            FOR z2ui5_if_client~view_display.
  ALIASES view_model_update       FOR z2ui5_if_client~view_model_update.
  ALIASES set_session_stateful    FOR z2ui5_if_client~set_session_stateful.
  ALIASES set_app_state_active    FOR z2ui5_if_client~set_app_state_active.
  ALIASES set_push_state          FOR z2ui5_if_client~set_push_state.
  ALIASES set_nav_back            FOR z2ui5_if_client~set_nav_back.
  ALIASES set_nav_routing         FOR z2ui5_if_client~set_nav_routing.
  ALIASES nest_view_display       FOR z2ui5_if_client~nest_view_display.
  ALIASES nest_view_destroy       FOR z2ui5_if_client~nest_view_destroy.
  ALIASES nest_view_model_update  FOR z2ui5_if_client~nest_view_model_update.
  ALIASES nest2_view_display      FOR z2ui5_if_client~nest2_view_display.
  ALIASES nest2_view_destroy      FOR z2ui5_if_client~nest2_view_destroy.
  ALIASES nest2_view_model_update FOR z2ui5_if_client~nest2_view_model_update.
  ALIASES popup_display           FOR z2ui5_if_client~popup_display.
  ALIASES popup_model_update      FOR z2ui5_if_client~popup_model_update.
  ALIASES popup_destroy           FOR z2ui5_if_client~popup_destroy.
  ALIASES popover_model_update    FOR z2ui5_if_client~popover_model_update.
  ALIASES popover_display         FOR z2ui5_if_client~popover_display.
  ALIASES popover_destroy         FOR z2ui5_if_client~popover_destroy.
  ALIASES get                     FOR z2ui5_if_client~get.
  ALIASES get_event_arg           FOR z2ui5_if_client~get_event_arg.
  ALIASES get_app                 FOR z2ui5_if_client~get_app.
  ALIASES _event_nav_app_leave    FOR z2ui5_if_client~_event_nav_app_leave.
  ALIASES nav_app_leave           FOR z2ui5_if_client~nav_app_leave.
  ALIASES nav_app_call            FOR z2ui5_if_client~nav_app_call.
  ALIASES message_box_display     FOR z2ui5_if_client~message_box_display.
  ALIASES message_toast_display   FOR z2ui5_if_client~message_toast_display.
  ALIASES _event                  FOR z2ui5_if_client~_event.
  ALIASES _event_client           FOR z2ui5_if_client~_event_client.
  ALIASES _bind                   FOR z2ui5_if_client~_bind.
  ALIASES _bind_edit              FOR z2ui5_if_client~_bind_edit.
  ALIASES follow_up_action        FOR z2ui5_if_client~follow_up_action.
  ALIASES check_on_event          FOR z2ui5_if_client~check_on_event.
  ALIASES check_on_init           FOR z2ui5_if_client~check_on_init.
  ALIASES check_app_prev_stack    FOR z2ui5_if_client~check_app_prev_stack.
  ALIASES check_on_navigated      FOR z2ui5_if_client~check_on_navigated.
  ALIASES get_app_prev            FOR z2ui5_if_client~get_app_prev.

ENDINTERFACE.
