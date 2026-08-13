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

      "Actions more
      set_title_launchpad       TYPE string VALUE `SET_TITLE_LAUNCHPAD`,

      "Control Action
      "! obsolete - a Wizard is a control like any other, so drive it through
      "! the generic control call instead. This event bundles the two calls
      "! a UI5 controller makes (oWizard.discardProgress( oStep ) and
      "! oStep.setNextStep( oNext )) into one fixed pair; the same flow is
      "! two follow_up_action( cs_event-control_by_id ) calls, which the
      "! CONTROL_METHODS whitelist already carries - together with
      "! goToStep, which this event cannot reach at all. The constant stays
      "! in the public API and keeps working
      wizard_set_next_step      TYPE string VALUE `WIZARD_SET_NEXT_STEP`,

      download_b64_file         TYPE string VALUE `DOWNLOAD_B64_FILE`,
      urlhelper                 TYPE string VALUE `URLHELPER`,
      clipboard_app_state       TYPE string VALUE `CLIPBOARD_APP_STATE`,

      store_data                TYPE string VALUE `STORE_DATA`,
      play_audio                TYPE string VALUE `PLAY_AUDIO`,

      "! Enable hash-based app routing for this app (UI5 Router style):
      "! follow_up_action( val = cs_event-set_nav_routing t_arg = ( mode ) ).
      "! Once enabled, the URL hash mirrors the running app as a bookmarkable
      "! route, and the browser Back/Forward buttons navigate between apps via
      "! that hash. A forward navigation to another app (nav_app_call) pushes a
      "! new route history entry, so Back returns to the calling app - the
      "! routing equivalent of a UI5 navTo.
      "!
      "! Queue it ONCE, in check_on_init - the way a UI5 app configures routing
      "! once in its manifest. The mode is remembered on the app (it travels in
      "! the draft) and re-sent whenever the frontend may not still hold it -
      "! page load, Back/Forward restore, a navigation hop, a mode change - so
      "! it does not have to be re-asserted; an app called via nav_app_call inherits
      "! it, and an app the user navigates back to keeps its own mode even when
      "! the app in between ran with a different one.
      "!
      "! Works inside the SAP Fiori Launchpad as well: the route is written as
      "! the app (inner) hash behind the shell hash, so the FLP back button
      "! returns to the previous app instead of the launchpad home page.
      "!
      "! The mode (see cs_nav_mode) decides what Back/Forward/reload/bookmark
      "! restore: keep restores the exact preserved state via a draft id in the
      "! route '#/app/&lt;CLASS&gt;/&lt;DRAFT&gt;'; fresh routes by class only
      "! '#/app/&lt;CLASS&gt;' and always starts the app fresh; default disables
      "! routing. An empty t_arg means keep.
      set_nav_routing           TYPE string VALUE `SET_NAV_ROUTING`,

      "! Push an app-owned hash suffix onto the browser URL:
      "! follow_up_action( val = cs_event-set_push_state t_arg = ( suffix ) ).
      "! client->set_push_state( ) is the same call.
      set_push_state            TYPE string VALUE `SET_PUSH_STATE`,

      "! Carry the app-state id in the URL so the state can be bookmarked and
      "! restored: follow_up_action( cs_event-set_app_state_active ). An empty
      "! t_arg switches it on; pass a single space to switch it off again.
      "! client->set_app_state_active( ) is the same call.
      set_app_state_active      TYPE string VALUE `SET_APP_STATE_ACTIVE`,

      "Control
      control_by_id             TYPE string VALUE `CONTROL_BY_ID`,
      control_global            TYPE string VALUE `CONTROL_GLOBAL`,
      binding_call              TYPE string VALUE `BINDING_CALL`,
      bind_element              TYPE string VALUE `BIND_ELEMENT`,
      smart_variant_init        TYPE string VALUE `SMART_VARIANT_INIT`,
      filter_bar_variant_init   TYPE string VALUE `FILTER_BAR_VARIANT_INIT`,

      " legacy event names - still supported: the *nav_container_to variants
      " are remapped to the generic control_by_id call (z2ui5_cl_core_srv_event),
      " the others have dedicated frontend handlers
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

  METHODS view_destroy.

  "! Display the MAIN view. A new main view is a new screen, so an open
  "! popup and popover go with it - re-open one in the same roundtrip if it
  "! is meant to survive ( the frontend builds MAIN first, then the popup ).
  METHODS view_display
    IMPORTING
      val                           TYPE clike
      switch_default_model_anno_uri TYPE clike OPTIONAL
      switch_default_model_path     TYPE clike OPTIONAL.

  "! obsolete - does NOTHING. An event round-trip that changes bound data
  "! pushes the model AUTOMATICALLY: the framework compares the model state
  "! before and after main( ) and, when it differs, sends it to every open
  "! view slot (see z2ui5_cl_core_handler=>main_end). A handler can therefore
  "! no longer render stale by forgetting a call, and there is nothing left
  "! for this method to do. It stays in the interface so existing apps keep
  "! compiling - remove the calls at your leisure.
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


  METHODS nest_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest_view_destroy.
  "! obsolete - does NOTHING, see view_model_update. A nested view inherits
  "! the MAIN view's model anyway, and that model is pushed automatically
  METHODS nest_view_model_update.

  METHODS nest2_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest2_view_destroy.
  "! obsolete - does NOTHING, see view_model_update. A nested view inherits
  "! the MAIN view's model anyway, and that model is pushed automatically
  METHODS nest2_view_model_update.

  METHODS popup_display
    IMPORTING
      val TYPE clike.

  "! obsolete - does NOTHING, see view_model_update. The automatic push
  "! reaches the POPUP slot too, so an open popup refreshes on its own
  METHODS popup_model_update.

  METHODS popup_destroy.

  "! obsolete - does NOTHING, see view_model_update. The automatic push
  "! reaches the POPOVER slot too, so an open popover refreshes on its own
  METHODS popover_model_update.

  METHODS popover_display
    IMPORTING
      xml   TYPE clike
      by_id TYPE clike.

  METHODS popover_destroy.

  METHODS get
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_get.

  "! The name of the event that triggered this roundtrip - empty when no
  "! event is being handled (e.g. on the initial call). Shortcut for
  "! get( )-event, made for the dispatcher idiom CASE client->get_event( ).
  METHODS get_event
    RETURNING
      VALUE(result) TYPE string.

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
  "! of what happens instead. That flag is baked per WIRE at render time;
  "! prevent_default_expr is the same veto decided per FIRING - a client
  "! expression evaluated when the event fires, so one wire can protect one
  "! row/column and let the rest through
  "! (`${$parameters>/column}.getId().indexOf('COL_DATE') >= 0`). It wins
  "! over the flag when both are set.
  METHODS _event
    IMPORTING
      val           TYPE clike                              OPTIONAL
      t_arg         TYPE string_table                       OPTIONAL
      s_ctrl        TYPE z2ui5_if_types=>ty_s_event_control OPTIONAL
        PREFERRED PARAMETER val
    RETURNING
      VALUE(result) TYPE string.

  "! obsolete - use follow_up_action( ), which is the same call in the same
  "! position now. Since follow_up_action( ) has a RETURNING parameter, a call
  "! whose result is CONSUMED - the view-attribute form
  "! `v = client->follow_up_action( val = ... t_arg = ... )` - takes its
  "! IF result IS SUPPLIED branch straight to get_event_client( ), which is
  "! this method's entire body: the identical roundtrip-free wire, byte for
  "! byte. One method therefore both schedules a frontend action and wires
  "! one, and this one is a second name for half of it.
  "!
  "! The one difference is follow_up_action( )'s leading CASE, which claims
  "! cs_event-set_nav_routing / set_push_state / set_app_state_active before
  "! that branch. Those three are backend-side navigation options rather than
  "! frontend handlers, so wiring one into a view attribute never dispatched
  "! anything here either.
  "!
  "! It stays in the interface so existing apps keep compiling - rename the
  "! calls at your leisure.
  METHODS _event_client
    IMPORTING
      val           TYPE clike
      view          TYPE clike        DEFAULT cs_view-main
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  "! @parameter omit_initial       | keep INITIAL fields out of the serialized
  "!                                model instead of sending them as `` / 0. An
  "!                                ABAP field is never absent - it is initial -
  "!                                so by default every field reaches the client
  "!                                as an explicit value, which overrides the UI5
  "!                                property default the original view relies on
  "!                                (and an enum-typed property rejects the empty
  "!                                string outright). Set it when a bound
  "!                                template's rows fill different subsets of the
  "!                                same properties.
  "! @parameter omit_initial_paths | the same omission SCOPED to the listed
  "!                                fields (upper-cased column names, the last
  "!                                path segment). Use it when the blanket flag
  "!                                is too coarse: an abap_false that MUST reach
  "!                                the client is itself initial, so omit_initial
  "!                                would drop it and the control would fall back
  "!                                to its own default - list the numeric/enum
  "!                                columns instead and leave the booleans.
  "! @parameter json               | the bound string already CONTAINS JSON -
  "!                                splice it into the model as a JSON node
  "!                                instead of sending it as a quoted string.
  "!                                For a control property that must receive an
  "!                                OBJECT, which no typed ABAP value can be
  "!                                (a sap.ui.integration Card manifest: its
  "!                                keys `sap.app`/`sap.card` are not valid ABAP
  "!                                field names, and a string is read as a
  "!                                manifest URL). Outbound only - see
  "!                                z2ui5_cl_core_srv_model.
  METHODS _bind
    IMPORTING
      val                  TYPE data
      path                 TYPE abap_bool                     DEFAULT abap_false
      "obsolete - inactive, not passed on internally
      view                 TYPE clike                         DEFAULT cs_view-main
      "obsolete - still evaluated, but do not use in new code. Both hand an
      "app a reference to the bundled AJSON library (src/00/01), which is a
      "MIRRORED copy of an external project, not a contract this framework
      "owns: an app implementing z2ui5_if_ajson_mapping / _filter binds
      "itself to whatever that mirror looks like today. Everything they were
      "reached for has a declarative counterpart on this method now -
      "omit_initial / omit_initial_paths drop initial fields, json splices a
      "JSON node - and the ABAP side can shape the value before it is bound
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      tab                  TYPE data                          OPTIONAL
      tab_index            TYPE i                             OPTIONAL
      switch_default_model TYPE abap_bool                     DEFAULT abap_false
      omit_initial         TYPE abap_bool                     DEFAULT abap_false
      omit_initial_paths   TYPE string_table                  OPTIONAL
      json                 TYPE abap_bool                     DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  "! obsolete - delegates to _bind (both two-way), please use _bind.
  "! custom_mapper_back / custom_filter_back are still accepted for source
  "! compatibility but are no longer evaluated.
  METHODS _bind_edit
    IMPORTING
      val                  TYPE data
      path                 TYPE abap_bool                     DEFAULT abap_false
      "obsolete - inactive, not passed on internally
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
  "! The control/binding calls are frontend events too; their t_arg
  "! is positional (an empty argument between filled ones keeps its slot as ``):
  "! cs_event-control_by_id - call a method on a control resolved by id:
  "! t_arg = id, method, params. Any public control method works unless it is
  "! on the frontend denylist (methods that would break framework invariants).
  "! The named per-aggregation mutators are on the allowed side of that line -
  "! addItem, removeItem, removeAllItems, destroyContent - and only the GENERIC
  "! reflection variants that take the member name as an argument are denied
  "! (addAggregation, removeAllAggregation, setAssociation, ...).
  "! The view is passed as the separate
  "! view parameter (default cs_view-main resolves the id across all open
  "! views; pass cs_view-popup/popover/... to scope the lookup to that view).
  "! Two entries are NOT UI5 methods but frontend capabilities in method form:
  "! `css` sets ONE whitelisted CSS declaration on the control's own DOM node
  "! (t_arg = id, `css`, property, value) - for a value the control has no
  "! property for at all, e.g. the width of a sap.m.Page; prefer a bound
  "! property wherever one exists. `toggleBy` opens/closes a popup anchored to
  "! a control (t_arg = id, `toggleBy`, anchor id).
  "! An association setter (setSelectedSection, setSelectedItem) clears the
  "! association when its argument is EMPTY.
  "! Wherever an argument takes a CONTROL ID, it also takes an aggregation
  "! ITEM, addressed positionally as `&lt;id&gt;/&lt;aggregation&gt;/&lt;index&gt;`
  "! (`carousel/pages/2`, 0-based). A control cloned from an aggregation
  "! template has no id the backend can spell - UI5 mints it from the template
  "! id, the parent id and the index, and the parent id carries the view prefix
  "! assigned at runtime - so this is the only way to reach one. It is the
  "! equivalent of the UI5 controller idiom
  "! `oCarousel.setActivePage( oCarousel.getPages()[ i ] )`. A plain id (no
  "! slashes) resolves exactly as before.
  "! cs_event-control_global - call a whitelisted method on a global object
  "! (MESSAGE_TOAST, MESSAGE_BOX, BUSY_INDICATOR, THEMING, POPUP,
  "! INVISIBLE_MESSAGE, FORMATTING): t_arg = object, method, params.
  "! POPUP-setWithinArea confines every popup to the control whose id is
  "! passed (sap.ui.core.Popup.setWithinArea, needs UI5 &gt;= 1.89) instead of
  "! to the window; an EMPTY argument releases the restriction again.
  "! INVISIBLE_MESSAGE-announce reads a text out to a screen reader without
  "! rendering it (sap.ui.core.InvisibleMessage, needs UI5 &gt;= 1.78):
  "! t_arg = text, mode (Polite, default, or Assertive). It is a singleton, so
  "! there is no control id - this is the only way to announce a change the
  "! backend made.
  "! FORMATTING-setCustomCurrencies registers currency codes the standard
  "! sap.ui.model.type.Currency does not know, or overrides their digit count
  "! (sap.ui.core.Formatting, needs UI5 &gt;= 1.120):
  "! t_arg = JSON object, e.g. \{"BGN4":\{"digits":4\}\}. It REPLACES the whole
  "! registration - addCustomCurrency ADDS a single code to it instead
  "! (t_arg = code, JSON object). Reaching for the wrong one is silent: an
  "! app that registers currencies as it loads more data and calls
  "! setCustomCurrencies drops what it registered before, and the symptom is
  "! a wrong digit count in a table, never an error.
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
  "! An optional THIRD t_arg SCOPES the shortcut: the scoped registration wins
  "! while its scope is OPEN and the unscoped one applies otherwise, which is
  "! how a UI5 CommandExecution in a Popover's dependents shadows the
  "! page-level one for the same command. A scope is either a view slot
  "! (cs_view-popover/popup/nested/nested2/main) or the ID OF A CONTROL that
  "! can be open or closed - a Popover/Dialog declared in the view and opened
  "! with control_by_id openBy, which never enters a framework slot. A control
  "! scope beats a slot scope (it is the more specific statement), then the
  "! innermost open slot wins. An empty event name removes the registration of
  "! THAT scope only.
  "! cs_event-binding_call - apply a declarative filter/sorter to an
  "! aggregation binding, the client-side equivalent of the UI5 controller
  "! pattern getBinding('items').filter(...); the model data stays untouched:
  "! t_arg = id, aggregation, method, params. method `filter`: params = path,
  "! operator, value1, value2 (empty values clear the filter); method `sort`:
  "! params = path, descending, group (abap_bool as `X`/``).
  "! Each of these events also works roundtrip-free when WIRED IN THE VIEW:
  "! write the same call where its result is consumed
  "! (`)->a( n = `press` v = client->follow_up_action( val = ... t_arg = ... ) )`)
  "! and the action runs in the browser without a server call. That is what
  "! the obsolete _event_client( ) did, and the only thing it did.
  METHODS follow_up_action
    IMPORTING
      val           TYPE string
      view          TYPE clike        DEFAULT cs_view-main
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

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
