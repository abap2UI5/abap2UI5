INTERFACE z2ui5_if_client
  PUBLIC.

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

  CONSTANTS:
    BEGIN OF cs_event,

      popup_close               TYPE string VALUE `POPUP_CLOSE`,
      popover_close             TYPE string VALUE `POPOVER_CLOSE`,

      set_size_limit            TYPE string VALUE `SET_SIZE_LIMIT`,
      set_odata_model           TYPE string VALUE `SET_ODATA_MODEL`,

      cross_app_nav_to_ext      TYPE string VALUE `CROSS_APP_NAV_TO_EXT`,
      cross_app_nav_to_prev_app TYPE string VALUE `CROSS_APP_NAV_TO_PREV_APP`,

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
      set_title_launchpad       TYPE string VALUE `SET_TITLE_LAUNCHPAD`,
      download_b64_file         TYPE string VALUE `DOWNLOAD_B64_FILE`,
      urlhelper                 TYPE string VALUE `URLHELPER`,
      store_data                TYPE string VALUE `STORE_DATA`,
      play_audio                TYPE string VALUE `PLAY_AUDIO`,

      smart_variant_init        TYPE string VALUE `SMART_VARIANT_INIT`,
      filter_bar_variant_init   TYPE string VALUE `FILTER_BAR_VARIANT_INIT`,

      "Control
      control_by_id             TYPE string VALUE `CONTROL_BY_ID`,
      control_global            TYPE string VALUE `CONTROL_GLOBAL`,
      binding_call              TYPE string VALUE `BINDING_CALL`,
      bind_element              TYPE string VALUE `BIND_ELEMENT`,

      "experimental
      " the hash_* family - everything that reads, writes or observes the URL
      " fragment, named after its UI5 original (sap/ui/core/routing/HashChanger):
      " hash_set = setHash (a PUSHED history entry), hash_replace = replaceHash
      " (no new entry), hash_back = one consumed step back with an optional
      " fallback hash (the UI5 onNavBack pattern), hash_attach_changed =
      " attachHashChanged (registers a backend event for foreign hash changes),
      " hash_routing = the hash-based app routing modes (cs_nav_mode).
      " app_state_set_active keeps the id of the CURRENT app state in the URL.
      " hash_set / hash_routing / app_state_set_active share their wire value
      " with their obsolete spellings below - both names reach the same branch
      hash_set                  TYPE string VALUE `SET_PUSH_STATE`,
      hash_replace              TYPE string VALUE `HASH_REPLACE`,
      hash_back                 TYPE string VALUE `HASH_BACK`,
      hash_attach_changed       TYPE string VALUE `HASH_ATTACH_CHANGED`,
      hash_routing              TYPE string VALUE `SET_NAV_ROUTING`,
      app_state_set_active      TYPE string VALUE `SET_APP_STATE_ACTIVE`,

      "obsolet
      set_app_state_active      TYPE string VALUE `SET_APP_STATE_ACTIVE`,
      set_push_state            TYPE string VALUE `SET_PUSH_STATE`,
      set_nav_routing           TYPE string VALUE `SET_NAV_ROUTING`,
      " superseded by app_state_get_href( ) + cs_event-clipboard_copy: the
      " backend composes the same link itself now (the browser location and
      " the live hash ride with the requests), so the app can also SHOW it
      clipboard_app_state       TYPE string VALUE `CLIPBOARD_APP_STATE`,
      image_editor_popup_close  TYPE string VALUE `IMAGE_EDITOR_POPUP_CLOSE`,
      nav_container_to          TYPE string VALUE `NAV_CONTAINER_TO`,
      nest_nav_container_to     TYPE string VALUE `NEST_NAV_CONTAINER_TO`,
      nest2_nav_container_to    TYPE string VALUE `NEST2_NAV_CONTAINER_TO`,
      popup_nav_container_to    TYPE string VALUE `POPUP_NAV_CONTAINER_TO`,
      popover_nav_container_to  TYPE string VALUE `POPOVER_NAV_CONTAINER_TO`,
      z2ui5                     TYPE string VALUE `Z2UI5`,
      wizard_set_next_step      TYPE string VALUE `WIZARD_SET_NEXT_STEP`,

    END OF cs_event.

  CONSTANTS:
    BEGIN OF cs_view,
      main    TYPE string VALUE `MAIN`,
      nested  TYPE string VALUE `NEST`,
      nested2 TYPE string VALUE `NEST2`,
      popup   TYPE string VALUE `POPUP`,
      popover TYPE string VALUE `POPOVER`,
    END OF cs_view.

  TYPES:
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    "! One table cell of this roundtrip's delta that could NOT be applied. The
    "! value DID arrive from the client, it just would not convert into the
    "! ABAP component behind the cell - `1,250.00` or `12.50 EUR` into a
    "! packed price, text into an integer. Such a cell is SKIPPED, never
    "! raised on: one unconvertible cell must not kill a delta that carries
    "! many good ones. This is the trace of that skip, and the only way an app
    "! can find out it happened - the browser still shows what the user typed,
    "! because the client model was updated before the roundtrip.
    "! Read it unconditionally at the top of main( ), NOT inside a Save
    "! branch: the delta travels with whatever roundtrip follows the edit,
    "! which need not be the press the app is interested in. The list is
    "! per-roundtrip - the next request sees an empty one.
    "!
    "! The entry names the cell but does NOT carry the value that was
    "! refused, so an app can say which field was not accepted and not what
    "! the user typed. And reading the trace alone pushes no model, so the
    "! browser goes on showing the refused text until the app writes
    "! something.
    "! See z2ui5_cl_ui5_srv_model=>delta_apply_field, which fills it.
    BEGIN OF ty_s_model_skip,
      " the bound attribute that holds the table, spelled as the app declared
      " it (`MT_PRODUCTS`). A cell of a NESTED table names the path to it,
      " parent first (`MT_TREE-NODES`).
      "
      " NOT the path _bind( ) hands the view: that is `{/MT_PRODUCTS}`, and
      " nothing public converts one spelling into the other. A consumer
      " matching on this has to carry the ABAP attribute name as a literal,
      " which a rename breaks silently
      name  TYPE string,
      " 1-based ABAP row index in the table `name` ends at. For a NESTED cell
      " that is the index of the INNER table - the parent row is not recorded,
      " so the field is named but the record owning it cannot be identified
      row   TYPE i,
      " the component inside the row (`PRICE`) - the ABAP name, not a label
      field TYPE string,
    END OF ty_s_model_skip.
  TYPES ty_t_model_skip TYPE STANDARD TABLE OF ty_s_model_skip WITH EMPTY KEY.

  TYPES:
    "! Everything the frontend sent with this roundtrip - the return type of
    "! get( ). s_draft and s_config are written out here rather than named
    "! separately, the way s_device, s_focus, s_scroll and s_ui5 already are:
    "! nothing outside this structure has ever used them as a type.
    BEGIN OF ty_s_get,
      event                  TYPE string,
      t_event_arg            TYPE string_table,
      check_launchpad_active TYPE abap_bool,
      check_on_navigated     TYPE abap_bool,
      BEGIN OF s_draft,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,
      END OF s_draft,
      BEGIN OF s_config,
        origin   TYPE string,
        pathname TYPE string,
        search   TYPE string,
        hash     TYPE string,
      END OF s_config,
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
      " The table cells this roundtrip's delta could not apply - empty in
      " the normal case. Only a value that actually ARRIVED and failed to
      " convert is listed; a field the client never sent is not an error.
      " An app that writes back what the user edited reads this to tell the
      " user which cell was refused (and to stay in edit mode) instead of
      " reporting a success the model does not carry. The scalar-attribute
      " path is unaffected - a value that will not convert into a non-table
      " attribute still raises JSON_PARSING_ERROR, as it always has.
      " It sits AFTER the internal _s_nav block rather than next to the other
      " t_* members because the API gate only accepts a component APPENDED at
      " the end of a public structure as compatible (api-snapshot.mjs,
      " isAdditiveTypeComponents) - an insertion in the middle is a rule-5
      " violation
      t_model_skipped        TYPE ty_t_model_skip,
    END OF ty_s_get.

  TYPES:
    "! The per-wire options of _event( ) - see the documentation on the method
    "! for what each one decides.
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

  CONSTANTS:
    "! Hash-based app routing modes, switched on with
    "! follow_up_action( cs_event-set_nav_routing ) - the set_nav_routing( )
    "! METHOD this used to name was removed in 1.143.0. The mode decides how
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
  "! view slot (see z2ui5_cl_ui5_handler=>main_end). A handler can therefore
  "! no longer render stale by forgetting a call, and there is nothing left
  "! for this method to do. It stays in the interface so existing apps keep
  "! compiling - remove the calls at your leisure.
  METHODS view_model_update.

  METHODS set_session_stateful
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  "! The app-state hash: while active, the URL carries the id of the CURRENT
  "! app state (`#/z2ui5-xapp-state=&lt;id&gt;`), advanced on every roundtrip - a
  "! reload, a bookmark or a shared link restores the exact state (the draft
  "! the framework persists anyway is the state container, nothing extra is
  "! stored). abap_false switches the URL tracking off again. Mutually
  "! exclusive with hash_routing and hash_attach_changed - each claims the
  "! whole app hash.
  METHODS app_state_set_active
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  "! The absolute URL of the CURRENT app state - the link that restores
  "! exactly this roundtrip's state, FLP-safe: the shell hash of the page
  "! survives in the link, so the recipient lands in this app instead of on
  "! the launchpad home page. Composed from the browser's own location
  "! (origin/pathname/search ride with the requests) plus this response's
  "! draft id. The app owns the string: copy it with
  "! cs_event-clipboard_copy, show it in an Input, mail it, render it as a
  "! QR code. Supersedes the obsolete cs_event-clipboard_app_state.
  METHODS app_state_get_href
    RETURNING
      VALUE(result) TYPE string.

  "! HashChanger#setHash: write VAL as the app's URL hash - a PUSHED history
  "! entry, so the browser Back button has a step to take. The 1:1
  "! counterpart of a UI5 router's navTo. With cs_event-hash_attach_changed
  "! registered the value is the WHOLE app hash (`/Page2`); without a
  "! listener the legacy suffix behavior applies (see the obsolete
  "! set_push_state, which this renames).
  METHODS hash_set
    IMPORTING
      val TYPE string OPTIONAL.

  "! HashChanger#replaceHash: write VAL as the app's URL hash WITHOUT a new
  "! history entry - the UI5 router's navTo( ..., true ). What
  "! FlexibleColumnLayout apps do when a NAVIGATION ARROW changes the
  "! layout: the URL follows, but Back does not step through arrow drags.
  METHODS hash_replace
    IMPORTING
      val TYPE string OPTIONAL.

  "! obsolete spelling of app_state_set_active( ) - same behavior. It stays
  "! in the interface so existing apps keep compiling.
  METHODS set_app_state_active
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  "! obsolete spelling of hash_set( ) - same behavior ('push state' described
  "! the old history.pushState implementation, which the HashChanger-backed
  "! write replaced). It stays in the interface so existing apps keep
  "! compiling.
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
      VALUE(result) TYPE ty_s_get.

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
  "!
  "! @parameter arg | the ONE-VALUE spelling of t_arg: `arg = x` is exactly
  "!                  `t_arg = VALUE #( ( x ) )`, byte for byte, and the
  "!                  handler reads it back with the same `get_event_arg( )`.
  "!                  It exists because the single argument is what most
  "!                  wires carry - a row key, a `${$source>/...}`, one event
  "!                  parameter - and there the table constructor is longer
  "!                  than the value inside it. From two values on, t_arg is
  "!                  the right parameter and stays it; arg deliberately does
  "!                  not grow into arg2/arg3, which would only put the
  "!                  positional numbering the table already spells out back
  "!                  into the parameter names.
  "!                  Passing both APPENDS arg behind the t_arg rows - a
  "!                  defined composition, not a guess between two readings.
  METHODS _event
    IMPORTING
      val           TYPE clike                              OPTIONAL
      t_arg         TYPE string_table                       OPTIONAL
      s_ctrl        TYPE ty_s_event_control                  OPTIONAL
      " appended rather than slotted next to t_arg, where it would read
      " better: rule 5 allows a new optional parameter at the END of the
      " list - inserting one reorders a public signature
      arg           TYPE clike                              OPTIONAL
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
  "! cs_event-hash_routing / hash_set / hash_replace / hash_attach_changed /
  "! app_state_set_active (and their obsolete set_* spellings) before that
  "! branch. Those are backend-side navigation options rather than frontend
  "! handlers, so wiring one into a view attribute never dispatched anything
  "! here either.
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

  "! @parameter tab               | bind ONE CELL of an internal table instead
  "!                                of a whole attribute: pass the table here
  "!                                and the row number in tab_index, and the
  "!                                bound value as val - the row component
  "!                                itself, e.g.
  "!                                `_bind( val       = mt_emp[ 1 ]-name
  "!                                        tab       = mt_emp
  "!                                        tab_index = 1 )` -> `{/MT_EMP/0/NAME}`.
  "!                                The cell is identified by REFERENCE: val
  "!                                has to BE the component of that row, not a
  "!                                copy of its value (a helper variable holding
  "!                                the same string is refused with
  "!                                BINDING_ERROR_TAB_CELL_LEVEL).
  "!                                One toolchain caveat, not an ABAP one: a
  "!                                STOCK abaplint downport lowers a table
  "!                                expression read at COMPONENT level to
  "!                                `READ TABLE ... INTO <wa>` - a copy - and
  "!                                the cell is then refused on code that is
  "!                                correct at the v750 target. This repository
  "!                                patches that lowering to `ASSIGNING`
  "!                                (node/setup/patch-abaplint-downport.mjs,
  "!                                filed upstream), so `tab[ n ]-comp` works
  "!                                through every build here. An app downported
  "!                                by an UNPATCHED abaplint has to assign the
  "!                                row first - `ASSIGN tab[ n ] TO <row>`, then
  "!                                `val = <row>-comp` - which the same rule
  "!                                already lowers with ASSIGNING and which is
  "!                                7.02-native. Measured, not assumed: the
  "!                                transpiler resolves every form correctly;
  "!                                only the downport loses the reference.
  "!                                What travels
  "!                                is still the whole table - this only writes
  "!                                a row-qualified path into the view, so the
  "!                                model keeps the ARRAY shape while the view
  "!                                addresses single rows. Use it where the
  "!                                original model is an array but the view
  "!                                repeats controls instead of binding an
  "!                                aggregation (six statically written panels
  "!                                over /Employee/0..5), which is otherwise
  "!                                written as a series of flat attributes
  "!                                (emp1_name, emp2_name, ...) and loses that
  "!                                shape. For a REPEATING aggregation bind the
  "!                                table itself (`items = _bind( mt_emp )`) and
  "!                                keep the template's fields relative.
  "! @parameter tab_index         | the row of tab to address, counted the ABAP
  "!                                way from 1 - the client path is 0-based, so
  "!                                tab_index = 1 renders as `/0/`. A row that
  "!                                does not exist raises
  "!                                BINDING_ERROR_TAB_CELL_LEVEL instead of
  "!                                dumping, but note that writing the val
  "!                                argument as `tab[ n ]` already dumps on the
  "!                                ABAP side when row n is missing - seed the
  "!                                table before building the view.
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
  "!                                z2ui5_cl_ui5_srv_model.
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

  "! obsolete - alias of _bind with identical behaviour, please use _bind.
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

  "! The PATH form of _bind( ) under a name of its own: returns the model
  "! PATH of val instead of its value - what a bound aggregation, a
  "! binding_call filter/sorter and bindElement need. Identical to
  "! `_bind( val = ... path = abap_true )`, byte for byte; it delegates
  "! rather than repeat the call, so the two can never drift apart.
  "!
  "! It exists because the two forms of _bind( ) read nothing alike:
  "! `_bind( t_products )` says what it does, `_bind( val = t_products
  "! path = abap_true )` needs a named val and a boolean whose name and
  "! value mean nothing to a reader who does not already know the method -
  "! and path being the FIRST optional parameter is what forces `val =`
  "! along with it.
  "!
  "! Deliberately ONE parameter. The moment a second is needed - tab /
  "! tab_index for a row path, omit_initial, json, switch_default_model -
  "! _bind( ) is the right call and path stays on it, undeprecated.
  METHODS _bind_path
    IMPORTING
      val           TYPE data
    RETURNING
      VALUE(result) TYPE string.

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
  "! INVISIBLE_MESSAGE, FORMATTING, ICON_POOL): t_arg = object, method, params.
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
  "! (sap/base/i18n/Formatting, needs UI5 &gt;= 1.120):
  "! t_arg = JSON object, e.g. \{"BGN4":\{"digits":4\}\}. It REPLACES the whole
  "! registration - addCustomCurrencies MERGES codes into it instead
  "! (t_arg = the same map). Reaching for the wrong one is silent: an
  "! app that registers currencies as it loads more data and calls
  "! setCustomCurrencies drops what it registered before, and the symptom is
  "! a wrong digit count in a table, never an error.
  "! What this reaches is the FORMATTING configuration, not a control that has
  "! already formatted: a control caching its NumberFormat at init( ) - among
  "! them sap.ui.unified.Currency - keeps the digit count it was built with,
  "! because it implements no localization-change hook. A BOUND
  "! sap.ui.model.type.Currency does implement one and re-formats.
  "! ICON_POOL-registerFont makes an icon collection outside the default
  "! SAP-icons font resolvable - sap.tnt&apos;s SAP-icons-TNT is the common one:
  "! t_arg = fontFamily, fontURI, e.g. `SAP-icons-TNT` /
  "! `sap/tnt/themes/base/fonts/`. A normal UI5 app does this in its
  "! Component&apos;s init; an abap2UI5 app has no Component of its own, and
  "! IconPool is a module SINGLETON rather than a control, so no other wire
  "! reaches it. Without the registration a sap-icon://SAP-icons-TNT/... URI
  "! renders NO GLYPH and logs nothing. The fontURI is a module path in every
  "! real use and is resolved through sap.ui.require.toUrl, so the registration
  "! survives a different mount point; an absolute URL is passed through. Issue
  "! it from the init branch - the same collection is registered only once per
  "! session, so a repeat call costs nothing.
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
  "! restored values reach the backend through the binding of the
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
  "! cs_event-hash_attach_changed - APP-OWNED hash routing
  "! (HashChanger#attachHashChanged), the 1:1 counterpart of a UI5 router's
  "! own hash (`#/Page2`) for an app that does NOT use hash_routing:
  "! t_arg = a backend event name. From then on hash_set( `/Page2` ) writes
  "! that value as the whole app hash (a pushed history entry),
  "! hash_replace( ) the same without a new entry, and a hash change the app
  "! did not write itself - browser Back/Forward, a manual URL edit - fires
  "! the registered event; the hash the browser now stands on arrives with
  "! that request (and with every other one, a fresh deep-link start
  "! included) in get( )-s_config-hash, so the app decides what to show.
  "! While registered, the framework leaves the hash entirely alone. Calling
  "! it without t_arg unregisters. The registration dies with an app switch -
  "! register it in view_display( ), so every render (a draft restore
  "! included) re-asserts it. Mutually exclusive with hash_routing (a routed
  "! app's hash belongs to the router) and with app_state_set_active (both
  "! claim the whole hash).
  "! cs_event-hash_back - the UI5 onNavBack pattern: without t_arg one real
  "! step back in the browser history (`window.history.go(-1)` - the step is
  "! CONSUMED, and the resulting hash change fires the registered event).
  "! With t_arg = a fallback hash it guards the cold deep link the way UI5's
  "! recommended onNavBack does: when this page load never pushed an app
  "! hash, there is no in-app step to take, so the fallback is written as a
  "! REPLACE instead of falling out of the app - and the change fires the
  "! registered event, which shows the fallback route.
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

  "! TRUE on the first roundtrip of THIS app instance, and only that one -
  "! the framework flips the flag after the first response, so an app that
  "! runs for an hour sees it once.
  "!
  "! It is NOT "the app starts": an app reached again through the app stack,
  "! a value help handing control back or a restored bookmark are all
  "! roundtrips of an EXISTING instance, and check_on_init( ) is false on
  "! every one of them. Gating the view on it alone is the most common way
  "! to end up with a screen that does not refresh - see
  "! check_on_navigated( ), which is true on all of those AND on the first
  "! roundtrip, and is therefore the branch to display in.
  METHODS check_on_init
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_app_prev_stack
    RETURNING
      VALUE(result) TYPE abap_bool.

  "! TRUE whenever this roundtrip has to put the app on screen: the first
  "! start of a new instance, a called app returning through the app stack,
  "! one of the built-in value-help popups closing, and a bookmarked draft
  "! being restored.
  "!
  "! The first start is included ON PURPOSE and is part of the contract, not
  "! an accident of the current factory: z2ui5_cl_ui5_action=>factory_first_start
  "! sets the flag for a fresh CREATE OBJECT as well as for a draft restore.
  "! So `check_on_init( )` being true implies this is true, which makes
  "!
  "!     IF client->check_on_navigated( ).
  "!       view_display( ).
  "!     ENDIF.
  "!
  "! the complete display condition on its own - no OR with check_on_init( )
  "! is needed, and the samples and documentation are written that way.
  "! Whoever changes the factory keeps this true, or 530 apps stop rendering
  "! on their first start with nothing raised anywhere.
  METHODS check_on_navigated
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS get_app_prev
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

ENDINTERFACE.
