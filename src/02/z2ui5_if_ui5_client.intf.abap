INTERFACE z2ui5_if_ui5_client
  PUBLIC.

  INTERFACES z2ui5_if_client.

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

      "obsolete?
      image_editor_popup_close  TYPE string VALUE `IMAGE_EDITOR_POPUP_CLOSE`,
      nav_container_to          TYPE string VALUE `NAV_CONTAINER_TO`,
      nest_nav_container_to     TYPE string VALUE `NEST_NAV_CONTAINER_TO`,
      nest2_nav_container_to    TYPE string VALUE `NEST2_NAV_CONTAINER_TO`,
      popup_nav_container_to    TYPE string VALUE `POPUP_NAV_CONTAINER_TO`,
      popover_nav_container_to  TYPE string VALUE `POPOVER_NAV_CONTAINER_TO`,
      z2ui5                     TYPE string VALUE `Z2UI5`,

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

  " The client API under its new name. Every method is an ALIAS of the
  " z2ui5_if_client method it stands for - the interface adds a name, not a
  " second set of methods: a class implementing this one implements
  " z2ui5_if_client~<method> exactly as before, and a reference of either type
  " reaches the same implementation.
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
