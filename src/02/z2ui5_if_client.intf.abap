INTERFACE z2ui5_if_client
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

      "obsolet?
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

  "! Hash-based app routing modes (see set_nav_routing). The mode decides how
  "! much of the running app the URL hash carries, and therefore what the
  "! browser Back/Forward buttons (and a reload / bookmark) restore:
  "!  default - no routing: the hash is left untouched, exactly as before this
  "!            feature. Back/Forward leave the abap2UI5 page (framework default).
  "!  fresh   - route '#/app/<CLASS>' (class only): Back/Forward/reload/bookmark
  "!            start the app FRESH (a clean instance, no preserved input).
  "!  keep    - route '#/app/<CLASS>/<DRAFT>' (class + server draft): the exact
  "!            preserved state is restored (all user input), falling back to a
  "!            fresh start once the draft has expired.
  CONSTANTS:
    BEGIN OF cs_nav_mode,
      default TYPE string VALUE `DEFAULT`,
      fresh   TYPE string VALUE `FRESH`,
      keep    TYPE string VALUE `KEEP`,
    END OF cs_nav_mode.

  METHODS view_destroy.

  METHODS view_display
    IMPORTING
      val                           TYPE clike
      switch_default_model_anno_uri TYPE clike OPTIONAL
      switch_default_model_path     TYPE clike OPTIONAL.

  METHODS view_model_update.

  METHODS set_session_stateful
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  METHODS set_app_state_active
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  METHODS set_push_state
    IMPORTING
      val TYPE string OPTIONAL.

  METHODS set_nav_back
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  "! Enable hash-based app routing for this session (UI5 Router style). Once
  "! enabled, the URL hash mirrors the running app as a bookmarkable route, and
  "! the browser Back/Forward buttons navigate between apps via that hash. A
  "! forward navigation to another app (client->nav_app_call) pushes a new route
  "! history entry, so the browser Back button returns to the calling app - the
  "! routing equivalent of a UI5 navTo. Call once (e.g. in the launcher app's
  "! check_on_init).
  "!
  "! The mode (see cs_nav_mode) decides what Back/Forward/reload/bookmark
  "! restore: keep (default) restores the exact preserved state via a draft id
  "! in the route '#/app/<CLASS>/<DRAFT>'; fresh routes by class only
  "! '#/app/<CLASS>' and always starts the app fresh; default disables routing
  "! (framework behaviour as before this feature).
  "!
  "! In keep mode the calling app's route entry is advanced to the draft saved
  "! for it during the nav_app_call, so Back restores it as the user LEFT it -
  "! including everything two-way bound that changed on the client since it
  "! last rendered and travelled to the backend with the triggering event.
  METHODS set_nav_routing
    IMPORTING
      mode TYPE string DEFAULT cs_nav_mode-keep.

  METHODS nest_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest_view_destroy.
  "! obsolete - main and nested views share one model now, use view_model_update instead
  METHODS nest_view_model_update.

  METHODS nest2_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest2_view_destroy.
  "! obsolete - main and nested views share one model now, use view_model_update instead
  METHODS nest2_view_model_update.

  METHODS popup_display
    IMPORTING
      val TYPE clike.

  METHODS popup_model_update.

  METHODS popup_destroy.

  METHODS popover_model_update.

  METHODS popover_display
    IMPORTING
      xml   TYPE clike
      by_id TYPE clike.

  METHODS popover_destroy.

  METHODS get
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_get.

  METHODS get_event_arg
    IMPORTING
      v             TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE string.

  METHODS get_app
    IMPORTING
      id            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS _event_nav_app_leave
    RETURNING
      VALUE(result) TYPE string.

  METHODS nav_app_leave
    IMPORTING
      VALUE(app)    TYPE REF TO z2ui5_if_app OPTIONAL
      event         TYPE clike                OPTIONAL
      r_data        TYPE data                 OPTIONAL
        PREFERRED PARAMETER app
    RETURNING
      VALUE(result) TYPE string.

  METHODS nav_app_call
    IMPORTING
      app           TYPE REF TO z2ui5_if_app
    RETURNING
      VALUE(result) TYPE string.

  METHODS message_box_display
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

  METHODS message_toast_display
    IMPORTING
      text                     TYPE clike
      duration                 TYPE clike     OPTIONAL
      width                    TYPE clike     OPTIONAL
      my                       TYPE clike     OPTIONAL
      at                       TYPE clike     OPTIONAL
      of                       TYPE clike     OPTIONAL
      offset                   TYPE clike     OPTIONAL
      collision                TYPE clike     OPTIONAL
      onclose                  TYPE clike     DEFAULT ``
      autoclose                TYPE abap_bool DEFAULT abap_true
      animationtimingfunction  TYPE clike     OPTIONAL
      animationduration        TYPE clike     OPTIONAL
      closeonbrowsernavigation TYPE abap_bool DEFAULT abap_true
      class                    TYPE clike     OPTIONAL.

  "! Register a backend event and return the handler expression for a view
  "! attribute (press = client->_event( `SAVE` )). s_ctrl carries the optional
  "! event flags: check_allow_multi_req sends the event while another
  "! roundtrip is still running, check_prevent_default cancels the control's
  "! built-in default for this event (oEvent.preventDefault(), e.g. a
  "! sap.tnt NavigationListItem press that must not select the item) before
  "! the roundtrip - the event is still sent, so the backend stays in charge
  "! of what happens instead.
  METHODS _event
    IMPORTING
      val           TYPE clike                              OPTIONAL
      t_arg         TYPE string_table                       OPTIONAL
      s_ctrl        TYPE z2ui5_if_types=>ty_s_event_control OPTIONAL
      r_data        TYPE data                               OPTIONAL
        PREFERRED PARAMETER val
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_client
    IMPORTING
      val           TYPE clike
      view          TYPE clike        DEFAULT cs_view-main
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind
    IMPORTING
      val                  TYPE data
      path                 TYPE abap_bool                     DEFAULT abap_false
      "obsolet - inaktiv, wird intern nicht weitergegeben
      view                 TYPE clike                         DEFAULT cs_view-main
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
*      custom_mapper_back   TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
*      custom_filter_back   TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      tab                  TYPE data                          OPTIONAL
      tab_index            TYPE i                             OPTIONAL
      switch_default_model TYPE abap_bool                     DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  "! obsolet - identisch zu _bind (beide two-way), bitte _bind verwenden
  METHODS _bind_edit
    IMPORTING
      val                  TYPE data
      path                 TYPE abap_bool                     DEFAULT abap_false
      "obsolet - inaktiv, wird intern nicht weitergegeben
      view                 TYPE clike                         DEFAULT cs_view-main
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_mapper_back   TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      custom_filter_back   TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      tab                  TYPE data                          OPTIONAL
      tab_index            TYPE i                             OPTIONAL
      switch_default_model TYPE abap_bool                     DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  "! Schedule a frontend action to run after the backend response is processed.
  "! Two ways to call it: pass a frontend event as val (e.g. cs_event-set_title)
  "! with its arguments in t_arg and the framework builds the event call; or pass
  "! a raw JavaScript expression as val (without t_arg) to run it as-is.
  "! The whitelisted control/binding calls are frontend events too; their t_arg
  "! is positional (an empty argument between filled ones keeps its slot as ``):
  "! cs_event-control_by_id - call a whitelisted method on a control resolved
  "! by id: t_arg = id, method, params. The view is passed as the separate
  "! view parameter (default cs_view-main resolves the id across all open
  "! views; pass cs_view-popup/popover/... to scope the lookup to that view).
  "! cs_event-control_global - call a whitelisted method on a global object
  "! (MESSAGE_TOAST, MESSAGE_BOX, BUSY_INDICATOR, THEMING):
  "! t_arg = object, method, params.
  "! cs_event-smart_variant_init - run the initialise( ) handshake sap.ui.comp
  "! variant management needs (a controller would call
  "! oSmartVariantManagement.initialise( fnCallback, oPersonalizableControl )).
  "! Without it the control keeps no personalizable control, saving a view fails
  "! inside sap.ui.fl and stored variants are never loaded:
  "! t_arg = SmartVariantManagement id, personalizable control id (optional,
  "! default: the first control that registered itself). The action waits for
  "! that registration, which the smart controls do once their OData metadata
  "! has loaded.
  "! cs_event-filter_bar_variant_init - wire a classic
  "! sap.ui.comp.filterbar.FilterBar to a SmartVariantManagement:
  "! t_arg = SmartVariantManagement id, FilterBar id. A SmartFilterBar knows
  "! its own fields and registers itself (see smart_variant_init above); a
  "! classic FilterBar does not, so a list report normally hand-writes the
  "! same controller boilerplate - registerFetchData / registerApplyData /
  "! registerGetFiltersWithValues, addPersonalizableControl( ) with a
  "! PersonalizableInfo, and a change handler per filter field that marks the
  "! variant as modified. This action does all of it, so saving, selecting and
  "! restoring a variant works without a single line of JavaScript. The
  "! restored values reach the backend through the two-way binding of the
  "! filter fields, no extra roundtrip needed.
  "! cs_event-keyboard_shortcut - bind a key combination to a named backend
  "! event, the declarative equivalent of a sap.ui.core.CommandExecution
  "! shortcut: t_arg = combination, event name. The combination is spelled
  "! like the UI5 one (`Ctrl+S`, `Ctrl+Shift+D`, `F2`; ctrl/shift/alt/meta in
  "! any order, cmd/command/option/control accepted as aliases). Pressing it
  "! fires the event exactly like a button press and suppresses the browser's
  "! own default for the combination. Registering the same combination again
  "! rebinds it; an empty event name removes it. The registrations belong to
  "! the running app and are dropped when another app takes over.
  "! cs_event-binding_call - apply a declarative filter/sorter to an
  "! aggregation binding, the client-side equivalent of the UI5 controller
  "! pattern getBinding('items').filter(...); the model data stays untouched:
  "! t_arg = id, aggregation, method, params. method `filter`: params = path,
  "! operator, value1, value2 (empty values clear the filter); method `sort`:
  "! params = path, descending, group (abap_bool as `X`/``).
  "! Each of these events also works roundtrip-free when wired in the view via
  "! _event_client with the same t_arg (and view).
  METHODS follow_up_action
    IMPORTING
      val   TYPE string
      view  TYPE clike        DEFAULT cs_view-main
      t_arg TYPE string_table OPTIONAL.

  METHODS check_on_event
    IMPORTING
      val           TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_on_init
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_app_prev_stack
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_on_navigated
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS get_app_prev
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

ENDINTERFACE.
