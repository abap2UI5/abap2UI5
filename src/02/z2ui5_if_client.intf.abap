INTERFACE z2ui5_if_client
  PUBLIC.

  CONSTANTS:
    "! The values get( )-s_device carries, as constants to compare against:
    "! what system, browser, os and orientation say about the client, e.g.
    "! `IF client->get( )-s_device-system = client->cs_device-system-phone.`
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
    "! Every frontend event a wire or follow_up_action( ) can name: what the
    "! browser does when the response arrives (set_title, scroll_to,
    "! download_b64_file, clipboard_copy, ...) or when the wired control fires
    "! (the control_by_id / control_global / binding_call family), the
    "! smart-control handshakes, the hash family, and - at the end - obsolete
    "! spellings kept so old apps compile. follow_up_action( ) documents the
    "! families that take structured arguments; the rest take the argument
    "! their name suggests, one sample each in the cookbook.
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

      " the hash_* family - everything that reads, writes or observes the URL
      " fragment, named after its UI5 original (sap/ui/core/routing/HashChanger):
      " hash_set = setHash (a PUSHED history entry), hash_replace = replaceHash
      " (no new entry), hash_back = one consumed step back with an optional
      " fallback hash (the UI5 onNavBack pattern), hash_attach_changed =
      " attachHashChanged (registers a backend event for foreign hash changes),
      " hash_routing = the hash-based app routing modes (cs_nav_mode).
      " app_state_set_active keeps the id of the CURRENT app state in the URL.
      " hash_set / hash_routing / app_state_set_active share their wire value
      " with their obsolete spellings below - both names reach the same branch.
      " The one-word comment right before the run is its LABEL on the
      " documentation site (docs, scripts/lib/client-interface.mjs reads the
      " first line of a comment run): keep it one line, keep it last.

      "experimental
      hash_set                  TYPE string VALUE `SET_PUSH_STATE`,
      hash_replace              TYPE string VALUE `HASH_REPLACE`,
      hash_back                 TYPE string VALUE `HASH_BACK`,
      hash_attach_changed       TYPE string VALUE `HASH_ATTACH_CHANGED`,
      hash_routing              TYPE string VALUE `SET_NAV_ROUTING`,
      app_state_set_active      TYPE string VALUE `SET_APP_STATE_ACTIVE`,

      " everything from here to END OF is kept for compatibility only and is
      " NOT on the documentation site (its deprecations page names each one
      " with its successor): the site's generator drops every member under a
      " label that opens with "obsolete", so a run added here needs one

      "obsolete - the hash_* / app_state_* spellings above replace these
      set_app_state_active      TYPE string VALUE `SET_APP_STATE_ACTIVE`,
      set_push_state            TYPE string VALUE `SET_PUSH_STATE`,
      set_nav_routing           TYPE string VALUE `SET_NAV_ROUTING`,
      "obsolete - superseded by app_state_get_href( ) + cs_event-clipboard_copy:
      " the backend composes the same link itself now (the browser location
      " and the live hash ride with the requests), so the app can also SHOW it
      clipboard_app_state       TYPE string VALUE `CLIPBOARD_APP_STATE`,
      "obsolete
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
    "! The five slots the frontend renders into: the main view, the two nested
    "! views, the popup and the popover. The `view` parameter of
    "! follow_up_action( ) and _event_client( ) names the slot a control id is
    "! resolved in, and a keyboard shortcut can be scoped to one.
    BEGIN OF cs_view,
      main    TYPE string VALUE `MAIN`,
      nested  TYPE string VALUE `NEST`,
      nested2 TYPE string VALUE `NEST2`,
      popup   TYPE string VALUE `POPUP`,
      popover TYPE string VALUE `POPOVER`,
    END OF cs_view.

  TYPES:
    "! A name-value pair, both strings - the shape of a launchpad startup
    "! parameter in get( )-t_comp_params (n = the parameter name the tile
    "! passed, v = its first value).
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  "! The table of name-value pairs get( )-t_comp_params carries.
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
    "! Reading the trace alone pushes no model, so the browser goes on
    "! showing the refused text until the app writes something.
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
      name       TYPE string,
      " 1-based ABAP row index in the table `name` ends at. For a NESTED cell
      " that is the index of the INNER table - the record owning it is in
      " row_parent below
      row        TYPE i,
      " the component inside the row (`PRICE`) - the ABAP name, not a label
      field      TYPE string,
      " for a NESTED cell the 1-based row index of the IMMEDIATE parent in
      " the outer table (`MT_TREE[row_parent]-NODES[row]-FIELD`); 0 for a
      " top-level cell. Appended at the end - the API gate only accepts an
      " APPENDED component as compatible (api-snapshot.mjs,
      " isAdditiveTypeComponents)
      row_parent TYPE i,
      " the refused raw value exactly as it arrived from the client, so the
      " app can quote what the user typed (`'1,250.00' is not a valid
      " price`). Empty when even reading the raw text failed (a structured
      " value that would not convert, a broken node)
      value      TYPE string,
    END OF ty_s_model_skip.
  "! The table of skipped cells get( )-t_model_skipped carries, one
  "! ty_s_model_skip row per cell this roundtrip's delta could not apply.
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
      " quote EVERY argument of this wire as a string. An argument that
      " starts with `$` or `{` (or an .eB( expression) is otherwise written
      " raw, as live UI5 expression syntax - which is how `${$source>/KEY}`
      " reaches the handler as the row's value. Data that may start with
      " those characters (text a user typed, a key from a foreign system)
      " would be EVALUATED by the client, so a wire that carries data rather
      " than bindings sets this and gives up expressions for its arguments
      check_arg_literal     TYPE abap_bool,
      " while a roundtrip is in flight, the LAST event fired on this wire is
      " kept and dispatched once the response has landed, instead of being
      " dropped - one roundtrip in flight at a time, order preserved, the
      " backend ends on the control's current value. For per-keystroke wires
      " (liveChange, liveSearch, sliderChange): without it every keystroke
      " typed while a roundtrip runs is lost, the last one included, and the
      " backend stays at the value of the last COMPLETED roundtrip until the
      " user pauses and types again. Appended at the END of the structure
      " (rule 5, see the note on ty_s_get-t_model_skipped)
      check_queue_last      TYPE abap_bool,
    END OF ty_s_event_control.

  CONSTANTS:
    "! Hash-based app routing modes, switched on with
    "! follow_up_action( cs_event-hash_routing ), the mode as its t_arg. The
    "! mode decides how much of the running app the URL hash carries, and
    "! therefore what the
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

  "! Empty the MAIN view slot on this response - the screen goes blank until
  "! the next view_display( ). Rarely needed: a new view_display( ) replaces
  "! the view anyway. It is for the app that wants the page cleared without
  "! drawing another view, e.g. right before it hands over to a called app.
  METHODS view_destroy.

  "! Display the MAIN view. A new main view is a new screen, so an open
  "! popup and popover go with it - re-open one in the same roundtrip if it
  "! is meant to survive ( the frontend builds MAIN first, then the popup ).
  "!
  "! @parameter val | the view XML - what z2ui5_cl_ui5_view_builder=>stringify( )
  "!                  returns, a sap.ui.core.mvc.View with everything inside it.
  "! @parameter switch_default_model_anno_uri | the annotation file URI of the
  "!                  OData service named in switch_default_model_path, for the
  "!                  smart controls that read annotations (optional).
  "! @parameter switch_default_model_path | the service URL of an OData V2
  "!                  service to install as the view's DEFAULT model, for smart
  "!                  controls that bind against OData metadata
  "!                  (`/sap/opu/odata/IWBEP/GWSAMPLE_BASIC/`). abap2UI5's own
  "!                  data then lives in the named `http` model, reached with
  "!                  `_bind( val = ... switch_default_model = abap_true )`.
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

  "! Switch the ABAP session of this app to STATEFUL from this roundtrip on -
  "! the work process and the session context (enqueue locks, open RFC
  "! connections, everything the app does not serialise) survive between
  "! roundtrips - or back to stateless with abap_false. The price is one pinned
  "! work process per active user, so it is for the few internal, low-traffic
  "! apps that need GUI-like locking; see the Statefulness chapter. Two calls
  "! in one roundtrip cancel out - the state at the END of the roundtrip is what
  "! the server gets. Pair every switch on with a switch off on every exit path.
  "!
  "! @parameter val | abap_true (the default) makes the session stateful,
  "!                  abap_false makes it stateless again.
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
  "!
  "! @parameter val | abap_true (the default) switches the tracking on,
  "!                  abap_false switches it off.
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
  "! QR code.
  METHODS app_state_get_href
    RETURNING
      VALUE(result) TYPE string.

  "! HashChanger#setHash: write VAL as the app's URL hash - a PUSHED history
  "! entry, so the browser Back button has a step to take. The 1:1
  "! counterpart of a UI5 router's navTo. With cs_event-hash_attach_changed
  "! registered the value is the WHOLE app hash (`/Page2`); without a
  "! listener VAL is APPENDED to the hash the page already has - a suffix
  "! such as `&amp;my-app-state=detail`, written with history.pushState.
  "!
  "! @parameter val | the hash to write - the whole app hash (`/Page2`) with a
  "!                  hash_attach_changed listener registered, otherwise the
  "!                  suffix appended to the hash the page already has.
  METHODS hash_set
    IMPORTING
      val TYPE string OPTIONAL.

  "! HashChanger#replaceHash: write VAL as the app's URL hash WITHOUT a new
  "! history entry - the UI5 router's navTo( ..., true ). What
  "! FlexibleColumnLayout apps do when a NAVIGATION ARROW changes the
  "! layout: the URL follows, but Back does not step through arrow drags.
  "!
  "! @parameter val | the hash to write, spelled as for hash_set( ).
  METHODS hash_replace
    IMPORTING
      val TYPE string OPTIONAL.

  "! obsolete spelling of app_state_set_active( ) - same behavior. It stays
  "! in the interface so existing apps keep compiling.
  "!
  "! @parameter val | as app_state_set_active( ).
  METHODS set_app_state_active
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  "! obsolete spelling of hash_set( ) - same behavior ('push state' described
  "! the old history.pushState implementation, which the HashChanger-backed
  "! write replaced). It stays in the interface so existing apps keep
  "! compiling.
  "!
  "! @parameter val | as hash_set( ).
  METHODS set_push_state
    IMPORTING
      val TYPE string OPTIONAL.

  "! Render a NESTED view into a control of the main view: the fragment in
  "! val is inserted into the control with the given id through the UI5
  "! mutator named in method_insert, after method_destroy has cleared what
  "! was there. The main view stays as it is - only the fragment is rendered
  "! again on the next call, which is what a nested view is for. It shares
  "! the main view's model, so _bind( ) and _event( ) work in it like anywhere
  "! else; see the Nested Views chapter.
  "!
  "! @parameter val | the XML of the nested view - a sap.ui.core.mvc.View
  "!                  built like the main one, its root element (a Page, a
  "!                  VBox) is what the anchor receives.
  "! @parameter id | the id of the control in the main view that receives the
  "!                  fragment - any control with an aggregation to insert into.
  "! @parameter method_insert | the UI5 mutator called on that control to add
  "!                  the fragment (`addContent` for a Page or a VBox,
  "!                  `addItem` for a List, `addPage` for a NavContainer).
  "! @parameter method_destroy | the mutator that removes the previous content
  "!                  first (`removeAllContent`, `removeAllItems`); without it
  "!                  every call adds one more fragment.
  METHODS nest_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  "! Remove the nested view (the NEST slot) from its anchor control on this
  "! response.
  METHODS nest_view_destroy.
  "! obsolete - does NOTHING, see view_model_update. A nested view inherits
  "! the MAIN view's model anyway, and that model is pushed automatically
  METHODS nest_view_model_update.

  "! A second nested slot with exactly the contract of nest_view_display( ) -
  "! for a fragment inside the nested fragment, or two independent fragments
  "! on one page that are re-rendered separately.
  "!
  "! @parameter val | as nest_view_display( ).
  "! @parameter id | as nest_view_display( ) - a control of the main view or
  "!                  of the first nested view.
  "! @parameter method_insert | as nest_view_display( ).
  "! @parameter method_destroy | as nest_view_display( ).
  METHODS nest2_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  "! Remove the second nested view (the NEST2 slot) from its anchor control on
  "! this response.
  METHODS nest2_view_destroy.
  "! obsolete - does NOTHING, see view_model_update. A nested view inherits
  "! the MAIN view's model anyway, and that model is pushed automatically
  METHODS nest2_view_model_update.

  "! Open the XML in val as the POPUP slot - a sap.m.Dialog that lies over the
  "! main view, which stays as it is. One popup at a time: a second
  "! popup_display( ) replaces the first. The popup shares the app's model, so
  "! _bind( ) and _event( ) work in it as in the view; close it with
  "! popup_destroy( ) in the handler of the event that ends it. See the Popup
  "! chapter.
  "!
  "! @parameter val | the popup XML: a core:FragmentDefinition with the Dialog
  "!                  inside it, as z2ui5_cl_ui5_view_builder=>factory( )->ele(
  "!                  n = `FragmentDefinition` ns = `core` ) ... ->stringify( )
  "!                  produces it.
  METHODS popup_display
    IMPORTING
      val TYPE clike.

  "! obsolete - does NOTHING, see view_model_update. The automatic push
  "! reaches the POPUP slot too, so an open popup refreshes on its own
  METHODS popup_model_update.

  "! Close the popup: the POPUP slot is emptied on this response and the main
  "! view underneath is untouched. Call it in the handler of the event that
  "! ends the dialog - Save, Cancel, the close button.
  METHODS popup_destroy.

  "! obsolete - does NOTHING, see view_model_update. The automatic push
  "! reaches the POPOVER slot too, so an open popover refreshes on its own
  METHODS popover_model_update.

  "! Open the XML as a POPOVER anchored to the control whose id is by_id
  "! (sap.m.Popover openBy) - the usual shape for a menu, a quick view or a
  "! confirmation next to the button that was pressed. One popover at a time;
  "! it shares the app's model like a popup does, and popover_destroy( )
  "! closes it. See the Popover chapter.
  "!
  "! @parameter xml | the popover XML: a core:FragmentDefinition with the
  "!                  Popover inside it, from the view builder.
  "! @parameter by_id | the id of the control the popover opens by - usually
  "!                  the button whose press event this roundtrip handles.
  METHODS popover_display
    IMPORTING
      xml   TYPE clike
      by_id TYPE clike.

  "! Close the popover: the POPOVER slot is emptied on this response.
  METHODS popover_destroy.

  "! Everything the frontend sent with this roundtrip, as one structure
  "! (ty_s_get): the event and its arguments, the device, focus, scroll and
  "! UI5 runtime information, the browser location (s_config), the launchpad
  "! startup parameters (t_comp_params), the draft ids, data a returning app
  "! handed over (r_event_data) and the table cells this roundtrip's delta
  "! could not apply (t_model_skipped). Cheap to call more than once - the
  "! launchpad parameters are parsed once per roundtrip and remembered.
  METHODS get
    RETURNING
      VALUE(result) TYPE ty_s_get.

  "! The name of the event that triggered this roundtrip - empty when no
  "! event is being handled (e.g. on the initial call). Shortcut for
  "! get( )-event, made for the dispatcher idiom CASE client->get_event( ).
  METHODS get_event
    RETURNING
      VALUE(result) TYPE string.

  "! One argument of the event that triggered this roundtrip, in the order
  "! the wire's t_arg listed them - the way to read the row key or the event
  "! parameter a wire carried (`t_arg = VALUE #( ( `$\{$source>/KEY\}` ) )`, or
  "! the same with `arg =`). Empty when the position does not exist; the whole
  "! list is get( )-t_event_arg.
  "!
  "! @parameter v | the 1-based position in t_arg. The default 1 is the first
  "!                  argument - the only one a wire written with `arg =`
  "!                  carries.
  METHODS get_event_arg
    IMPORTING
      v             TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE string.

  "! The app instance behind a draft id. Without id the running app itself -
  "! the object main( ) was called on, for a helper that only holds the
  "! client. With an id, the instance that draft holds, loaded from the
  "! database: that is how the previous app on the stack is reached
  "! (get( )-s_draft-id_prev_app, which get_app_prev( ) does for you).
  "!
  "! @parameter id | the draft id of the instance to load (get( )-s_draft-id,
  "!                  -id_prev_app, -id_prev_app_stack); empty for the
  "!                  running app.
  METHODS get_app
    IMPORTING
      id            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  "! The handler expression for a view attribute that LEAVES this app on
  "! press - a Page's navButtonPress, a Cancel button:
  "! `)->a( n = `navButtonPress` v = client->_event_nav_app_leave( ) )`. The
  "! press does what nav_app_leave( ) does in a handler, without a branch in
  "! main( ): the previous app on the stack takes the screen back. Pair it
  "! with `showNavButton` bound to check_app_prev_stack( ), so the button is
  "! only there when it has somewhere to go.
  METHODS _event_nav_app_leave
    RETURNING
      VALUE(result) TYPE string.

  "! Hand the screen back to the previous app on the stack - the one that
  "! called this app with nav_app_call( ) - or, with app supplied, to that
  "! instance instead, WITHOUT pushing the current app onto the stack: a
  "! forward navigation that discards this app. The target's main( ) runs
  "! next with check_on_navigated( ) true, so it re-displays its view (the
  "! browser still shows this app's view until it does); event and r_data let
  "! the leaving app hand a result over. Scheduled for the end of the
  "! roundtrip, so it is usually the last statement of a handler branch.
  "!
  "! @parameter app | the app to show next; not supplied, the app this one was
  "!                  called from - with nothing to return to, the user lands
  "!                  on the start page, so guard the call with
  "!                  check_app_prev_stack( ).
  "! @parameter event | an event name the target finds in check_on_event( ) on
  "!                  arrival, so a return WITH a result can be told from a
  "!                  plain return.
  "! @parameter r_data | data handed to the target, read there as
  "!                  get( )-r_event_data (a reference to a copy of it). An
  "!                  intentionally empty value still arrives.
  METHODS nav_app_leave
    IMPORTING
      VALUE(app)    TYPE REF TO z2ui5_if_app OPTIONAL
      event         TYPE clike                OPTIONAL
      r_data        TYPE data                 OPTIONAL
        PREFERRED PARAMETER app
    RETURNING
      VALUE(result) TYPE string.

  "! Show another app on top of this one. The instance in app takes the
  "! screen with the next response and its main( ) runs, check_on_init( ) and
  "! check_on_navigated( ) both true; this app is pushed onto the stack and
  "! gets the screen back when the called app calls nav_app_leave( ) - then
  "! this main( ) runs again with check_on_navigated( ) true, and
  "! get_app_prev( ) is the called instance, its public attributes readable as
  "! the result. Scheduled for the end of the roundtrip, so it is usually the
  "! last statement of a handler branch. See the Navigation chapter.
  "!
  "! @parameter app | a bound instance of the app to call - NEW zcl_other_app( )
  "!                  with whatever it needs set on it before the call; an
  "!                  unbound reference raises NAV_APP_TARGET_NOT_BOUND.
  METHODS nav_app_call
    IMPORTING
      app           TYPE REF TO z2ui5_if_app
    RETURNING
      VALUE(result) TYPE string.

  "! Show a sap.m.MessageBox. `text` is TYPE any and takes whatever the app
  "! has: a text, a message structure or table (BAPIRET2, T100, RAP,
  "! symsg, a log object, an exception), an HTML string, a business table, a
  "! nested structure or tree, an object, a number. Messages are recognized
  "! first and set the box's severity and title themselves; everything else
  "! is rendered - a headline in the box, the data itself in the details.
  "! The one case that shows nothing at all is complex data that is initial
  "! (an empty message table stays as silent as it always was).
  "!
  "! Every option below is the sap.m.MessageBox option of the same name,
  "! passed through when set; onclose is the one abap2UI5-shaped exception.
  "!
  "! @parameter text | what to show - a text, or any of the shapes above.
  "! @parameter type | the kind of box, which decides icon and default title:
  "!                  `information` (the default), `warning`, `error`,
  "!                  `success`, `confirm`, `alert` or `show`.
  "! @parameter title | the title bar text; the type's own title when empty.
  "! @parameter styleclass | one or more CSS classes added to the box.
  "! @parameter onclose | a BACKEND event name raised when the box closes; the
  "!                  action the user pressed arrives as the first event
  "!                  argument (get_event_arg( )), so one handler tells
  "!                  DELETE from CANCEL.
  "! @parameter actions | the buttons, as sap.m.MessageBox.Action names (`OK`,
  "!                  `CANCEL`, `YES`, `NO`, `ABORT`, `RETRY`, `IGNORE`,
  "!                  `CLOSE`, `DELETE`) or as free texts; `OK` alone when
  "!                  not supplied.
  "! @parameter emphasizedaction | the one of the actions rendered as the
  "!                  emphasized button.
  "! @parameter initialfocus | the action (or control id) that has the focus
  "!                  when the box opens.
  "! @parameter textdirection | `LTR`, `RTL` or `Inherit` for the text.
  "! @parameter icon | an icon of sap.m.MessageBox.Icon (`NONE`,
  "!                  `INFORMATION`, `WARNING`, `ERROR`, `SUCCESS`,
  "!                  `QUESTION`) instead of the one the type implies.
  "! @parameter details | a further text (or JSON) shown behind the box's
  "!                  "Show details" link.
  "! @parameter closeonnavigation | close the box when the page navigates
  "!                  (the default); abap_false keeps it open.
  "! @parameter dependenton | the id of a control the box becomes a dependent
  "!                  of, so it is destroyed with that control (UI5 1.124 on).
  "! @parameter contentwidth | a CSS width for the box's content.
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

  "! Show a sap.m.MessageToast with text - the fire-and-forget notification
  "! for a saved record or a copied link, gone again after a few seconds.
  "! Every other parameter is the option of the same name of
  "! sap.m.MessageToast.show( ), passed through only when set, so UI5 owns
  "! every default; onclose and class are abap2UI5-shaped.
  "!
  "! @parameter text | the text shown.
  "! @parameter duration | milliseconds the toast stays (UI5 default 3000).
  "! @parameter width | the toast's CSS width (UI5 default 15em).
  "! @parameter my | the toast's own docking point, a sap.ui.core.Popup.Dock
  "!                  value (UI5 default `center bottom`).
  "! @parameter at | the docking point of `of` the toast is placed at (UI5
  "!                  default `center bottom`).
  "! @parameter of | the control id or DOM reference the toast is positioned
  "!                  relative to (UI5 default: the window).
  "! @parameter offset | the offset from that position as `x y` in pixels.
  "! @parameter collision | how a toast that would leave the window is moved
  "!                  (`fit`, `flip`, `none`, one value per axis; UI5 default
  "!                  `fit fit`).
  "! @parameter onclose | a BACKEND event name raised when the toast closes.
  "! @parameter autoclose | close after duration (the default) or stay until
  "!                  the user clicks elsewhere.
  "! @parameter animationtimingfunction | the CSS timing function of the fade
  "!                  (UI5 default `ease`).
  "! @parameter animationduration | the fade duration in milliseconds (UI5
  "!                  default 1000).
  "! @parameter closeonbrowsernavigation | close on browser navigation (the
  "!                  default).
  "! @parameter class | one or more CSS classes added to the toast.
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

  " arg is appended rather than slotted next to t_arg, where it would read
  " better: rule 5 allows a new optional parameter at the END of the list -
  " inserting one reorders a public signature. (A plain comment here, above
  " the ABAP Doc, so the documentation site's parser does not print it into
  " the parameter table the way it prints a comment inside the list.)
  "! Register a backend event and return the handler expression for a view
  "! attribute (press = client->_event( `SAVE` )). s_ctrl carries the optional
  "! event flags: check_prevent_default cancels the control's built-in
  "! default for this event (oEvent.preventDefault(), e.g. a sap.tnt
  "! NavigationListItem press that must not select the item) before the
  "! roundtrip - the event is still sent, so the backend stays in charge of
  "! what happens instead. That flag is baked per WIRE at render time;
  "! prevent_default_expr is the same veto decided per FIRING - a client
  "! expression evaluated when the event fires, so one wire can protect one
  "! row/column and let the rest through
  "! (`$\{$parameters>/column\}.getId().indexOf('COL_DATE') >= 0`). It wins
  "! over the flag when both are set. check_queue_last keeps the LAST event
  "! fired on the wire while a roundtrip is in flight and dispatches it once
  "! the response has landed, instead of dropping it - one roundtrip in
  "! flight at a time, order preserved, the backend ends on the control's
  "! current value; it is the flag for a per-keystroke wire (liveChange,
  "! liveSearch, sliderChange), which without it loses every keystroke typed
  "! while a roundtrip runs, the last one included.
  "!
  "! @parameter val | the event name the handler checks with
  "!                  check_on_event( `SAVE` ) - upper case by convention,
  "!                  unique within the app.
  "! @parameter t_arg | arguments sent with the event and read back with
  "!                  get_event_arg( n ) in the same order: a literal, a
  "!                  `$\{$source>/...\}` or `$\{$parameters>/...\}` client
  "!                  expression evaluated when the event fires, or
  "!                  `$event>...` for a field of the UI5 event itself.
  "! @parameter s_ctrl | the per-wire options (ty_s_event_control): keep the
  "!                  last firing until the running roundtrip has landed,
  "!                  cancel the control's default, quote every argument as
  "!                  a literal.
  "! @parameter arg | the ONE-VALUE spelling of t_arg: `arg = x` is exactly
  "!                  `t_arg = VALUE #( ( x ) )`, byte for byte, and the
  "!                  handler reads it back with the same `get_event_arg( )`.
  "!                  It exists because the single argument is what most
  "!                  wires carry - a row key, a `$\{$source>/...\}`, one event
  "!                  parameter - and there the table constructor is longer
  "!                  than the value inside it. From two values on, t_arg is
  "!                  the right parameter and stays it; arg deliberately does
  "!                  not grow into arg2/arg3, which would only put the
  "!                  positional numbering the table already spells out back
  "!                  into the parameter names.
  "!                  Passing both APPENDS arg behind the t_arg rows - a
  "!                  defined composition, not a guess between two readings.
  "!                  An argument that starts with `$` or `\{` (or an .eB(
  "!                  expression) is written RAW, as live UI5 expression
  "!                  syntax - that is how `$\{$source>/KEY\}` reaches the
  "!                  handler as the row's value. Data that may start with
  "!                  those characters (text a user typed, a key from a
  "!                  foreign system) is therefore evaluated, not passed:
  "!                  set s_ctrl-check_arg_literal to have every argument of
  "!                  the wire quoted as a string instead.
  METHODS _event
    IMPORTING
      val           TYPE clike                              OPTIONAL
      t_arg         TYPE string_table                       OPTIONAL
      s_ctrl        TYPE ty_s_event_control                  OPTIONAL
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
  "!
  "! @parameter val | the frontend event, as follow_up_action( ) takes it.
  "! @parameter view | the view slot the event's control id is resolved in
  "!                  (cs_view).
  "! @parameter t_arg | the positional arguments of the event.
  METHODS _event_client
    IMPORTING
      val           TYPE clike
      view          TYPE clike        DEFAULT cs_view-main
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  "! Bind a public attribute of the app to the view. Returns the binding
  "! expression for a view attribute - `\{/NAME\}` - and registers val, so its
  "! value travels to the client with the response and what the user edits
  "! travels back before the next main( ), without a line of code for the
  "! transport. A table binds as a whole (`items = _bind( mt_items )`) and
  "! the rows become the template's context, so the template's own bindings
  "! stay relative (`\{NAME\}`). See the Binding chapter.
  "!
  "! @parameter val | the attribute to bind - a PUBLIC attribute of the app
  "!                  (or a component of one), passed by reference: the
  "!                  framework reaches it by name on the next roundtrip, so
  "!                  a local variable, a copy or a protected attribute cannot
  "!                  be bound (BINDING_ERROR).
  "! @parameter path | abap_true returns the model PATH of val instead of the
  "!                  value binding - what a bound aggregation, a binding_call
  "!                  filter or sorter and bindElement need; _bind_path( ) is
  "!                  the readable spelling of it.
  "! @parameter switch_default_model | abap_true writes the binding against
  "!                  the named `http` model - where abap2UI5's own data lives
  "!                  once view_display( switch_default_model_path = ... ) has
  "!                  made an OData service the view's default model.
  "! @parameter tab               | bind ONE CELL of an internal table instead
  "!                                of a whole attribute: pass the table here
  "!                                and the row number in tab_index, and the
  "!                                bound value as val - the row component
  "!                                itself, e.g.
  "!                                `_bind( val       = mt_emp[ 1 ]-name
  "!                                        tab       = mt_emp
  "!                                        tab_index = 1 )` -> `\{/MT_EMP/0/NAME\}`.
  "!                                The cell is identified by REFERENCE: val
  "!                                has to BE the component of that row, not a
  "!                                copy of its value (a helper variable holding
  "!                                the same string is refused with
  "!                                BINDING_ERROR_TAB_CELL_LEVEL).
  "!                                One toolchain caveat, not an ABAP one, and
  "!                                only for an app that DOWNPORTS with
  "!                                abaplint older than 2.120.51: that downport
  "!                                lowered a table expression read at
  "!                                COMPONENT level to
  "!                                `READ TABLE ... INTO &lt;wa&gt;` - a copy - so
  "!                                the cell was refused on code correct at the
  "!                                v750 target. Fixed upstream
  "!                                (abaplint/abaplint#4276): the outline is
  "!                                `ASSIGNING` from 2.120.51 on, which is what
  "!                                the write path of the same rule always
  "!                                emitted. On an older abaplint, assign the
  "!                                row first - `ASSIGN tab[ n ] TO &lt;row&gt;`,
  "!                                then `val = &lt;row&gt;-comp` - which that rule
  "!                                already lowered with ASSIGNING and which is
  "!                                7.02-native. Measured, not assumed: the
  "!                                transpiler resolves every form correctly;
  "!                                only the old downport lost the reference.
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
  "!                                z2ui5_cl_ui5_srv_model. Ignored for a
  "!                                CELL (tab supplied): whether a value is
  "!                                JSON is decided on the table's bind.
  "!                                custom_mapper, custom_filter and the
  "!                                omit_initial pair are passed on to the
  "!                                table there, like a _bind( ) of the
  "!                                table itself would store them.
  METHODS _bind
    IMPORTING
      val                  TYPE data
      path                 TYPE abap_bool                     DEFAULT abap_false
      "obsolete - inactive, not passed on internally
      view                 TYPE clike                         DEFAULT cs_view-main
      "obsolete - still evaluated, but NO AJSON TYPE BELONGS IN A BIND CALL
      "any more. Both hand an app a reference to the bundled AJSON library
      "(src/00/01), which is a MIRRORED copy of an external project, not a
      "contract this framework owns: an app implementing
      "z2ui5_if_ajson_mapping / _filter binds itself to whatever that mirror
      "looks like today, and a resync of the mirror is free to break it.
      "Everything they were ever reached for is declarative on this method
      "now, and each replacement has a sample that proves it:
      "  drop initial fields   -> omit_initial / omit_initial_paths
      "                           (z2ui5_cl_smp_app_507)
      "  a model NODE instead
      "  of a quoted string,
      "  under keys no ABAP
      "  component can carry   -> json = abap_true
      "                           (z2ui5_cl_smp_app_509)
      "  anything else         -> shape the value in ABAP before binding it
      "The one thing _bind( ) deliberately cannot do is a mapping that
      "differs per direction - see the _back pair on _bind_edit( ), which is
      "dead there. Measured 2026-09-13 across samples, samples-controls and
      "samples-stack: not one app class passes either parameter or
      "implements either interface, and none ever did in their git history -
      "so nothing has to be migrated, only nothing new written. AJSON itself
      "stays: it is the model engine (z2ui5_cl_ui5_srv_model), and json =
      "abap_true is implemented with it. What goes is the LEAK of the
      "mirrored library into the app-facing interface.
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      "obsolete - the filter half of custom_mapper, see there. This is the
      "half that had the one real use - do not send initial fields, i.e.
      "z2ui5_cl_ajson_filter_lib=>create_empty_filter - and that use is
      "exactly what omit_initial replaced: it is wired into this very slot
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
  "!
  "! All four AJSON parameters here are dead ends: this is the only place
  "! that ever offered a per-direction mapping, and the two _back halves
  "! that made it one are inert. Do not reach for any of them in new code -
  "! bind with _bind( ) and say what you mean with omit_initial /
  "! omit_initial_paths or json = abap_true, whose notes on _bind( ) carry
  "! the full reasoning and a sample each.
  "!
  "! @parameter val | as _bind( ).
  "! @parameter path | as _bind( ).
  "! @parameter custom_mapper | as _bind( ) - obsolete there too.
  "! @parameter custom_mapper_back | accepted, no longer evaluated.
  "! @parameter custom_filter | as _bind( ) - obsolete there too.
  "! @parameter custom_filter_back | accepted, no longer evaluated.
  "! @parameter tab | as _bind( ).
  "! @parameter tab_index | as _bind( ).
  "! @parameter switch_default_model | as _bind( ).
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
  "! _bind( ) is the right call and path stays on it.
  "!
  "! @parameter val | the public attribute whose model path is returned - the
  "!                  same reference rule as _bind( ).
  METHODS _bind_path
    IMPORTING
      val           TYPE data
    RETURNING
      VALUE(result) TYPE string.

  "! Schedule a frontend action to run after the backend response has been
  "! processed. Two ways to call it: pass a frontend event as val (a
  "! cs_event-* constant, e.g. cs_event-set_title) with its arguments in
  "! t_arg and the framework builds the event call; or pass a raw JavaScript
  "! expression as val, without t_arg, to run it as it is. The families below
  "! take structured arguments; t_arg is POSITIONAL, and an empty argument
  "! between filled ones keeps its slot as ``.
  "!
  "! Every one of them also works roundtrip-free when WIRED IN THE VIEW: write
  "! the same call where its result is consumed -
  "! `)->a( n = `press` v = client->follow_up_action( val = ... t_arg = ... ) )` -
  "! and the action runs in the browser without a server call.
  "!
  "! **cs_event-control_by_id** - call a method on a control resolved by id,
  "! t_arg = id, method, params: ``client->follow_up_action( val = client->cs_event-control_by_id t_arg = VALUE #( ( `tab` ) ( `setSelectedIndex` ) ( `0` ) ) )``.
  "! Any public control method works unless it is on the frontend denylist
  "! (methods that would break framework invariants). The named
  "! per-aggregation mutators are on the allowed side of that line - addItem,
  "! removeItem, removeAllItems, destroyContent - and only the GENERIC
  "! reflection variants that take the member name as an argument are denied
  "! (addAggregation, removeAllAggregation, setAssociation, ...). The view is
  "! passed as the separate view parameter (default cs_view-main resolves the
  "! id across all open views; pass cs_view-popup/popover/... to scope the
  "! lookup to that view). Two entries are NOT UI5 methods but frontend
  "! capabilities in method form: `css` sets ONE whitelisted CSS declaration
  "! on the control's own DOM node (t_arg = id, `css`, property, value) - for
  "! a value the control has no property for at all, e.g. the width of a
  "! sap.m.Page; prefer a bound property wherever one exists. `toggleBy`
  "! opens/closes a popup anchored to a control (t_arg = id, `toggleBy`,
  "! anchor id). An association setter (setSelectedSection, setSelectedItem)
  "! clears the association when its argument is EMPTY. Wherever an argument
  "! takes a CONTROL ID, it also takes an aggregation ITEM, addressed
  "! positionally as `&lt;id&gt;/&lt;aggregation&gt;/&lt;index&gt;` (`carousel/pages/2`,
  "! 0-based). A control cloned from an aggregation template has no id the
  "! backend can spell - UI5 mints it from the template id, the parent id and
  "! the index, and the parent id carries the view prefix assigned at runtime -
  "! so this is the only way to reach one. It is the equivalent of the UI5
  "! controller idiom `oCarousel.setActivePage( oCarousel.getPages()[ i ] )`.
  "! A plain id (no slashes) resolves exactly as before.
  "!
  "! **cs_event-control_global** - call a whitelisted method on a global
  "! object (MESSAGE_TOAST, MESSAGE_BOX, BUSY_INDICATOR, THEMING, POPUP,
  "! INVISIBLE_MESSAGE, FORMATTING, ICON_POOL), t_arg = object, method,
  "! params: ``client->follow_up_action( val = client->cs_event-control_global t_arg = VALUE #( ( `BUSY_INDICATOR` ) ( `show` ) ( `0` ) ) )``.
  "! POPUP-setWithinArea confines every popup to the control whose id is
  "! passed (sap.ui.core.Popup.setWithinArea, needs UI5 &gt;= 1.89) instead of
  "! to the window; an EMPTY argument releases the restriction again.
  "! INVISIBLE_MESSAGE-announce reads a text out to a screen reader without
  "! rendering it (sap.ui.core.InvisibleMessage, needs UI5 &gt;= 1.78): t_arg =
  "! text, mode (Polite, default, or Assertive). It is a singleton, so there
  "! is no control id - this is the only way to announce a change the backend
  "! made. FORMATTING-setCustomCurrencies registers currency codes the
  "! standard sap.ui.model.type.Currency does not know, or overrides their
  "! digit count (sap/base/i18n/Formatting, needs UI5 &gt;= 1.120): t_arg = JSON
  "! object, e.g. \{"BGN4":\{"digits":4\}\}. It REPLACES the whole registration -
  "! addCustomCurrencies MERGES codes into it instead (t_arg = the same map).
  "! Reaching for the wrong one is silent: an app that registers currencies
  "! as it loads more data and calls setCustomCurrencies drops what it
  "! registered before, and the symptom is a wrong digit count in a table,
  "! never an error. What this reaches is the FORMATTING configuration, not a
  "! control that has already formatted: a control caching its NumberFormat
  "! at init( ) - among them sap.ui.unified.Currency - keeps the digit count
  "! it was built with, because it implements no localization-change hook. A
  "! BOUND sap.ui.model.type.Currency does implement one and re-formats.
  "! ICON_POOL-registerFont makes an icon collection outside the default
  "! SAP-icons font resolvable - sap.tnt's SAP-icons-TNT is the common one:
  "! t_arg = fontFamily, fontURI, e.g. `SAP-icons-TNT` /
  "! `sap/tnt/themes/base/fonts/`. A normal UI5 app does this in its
  "! Component's init; an abap2UI5 app has no Component of its own, and
  "! IconPool is a module SINGLETON rather than a control, so no other wire
  "! reaches it. Without the registration a sap-icon://SAP-icons-TNT/... URI
  "! renders NO GLYPH and logs nothing. The fontURI is a module path in every
  "! real use and is resolved through sap.ui.require.toUrl, so the
  "! registration survives a different mount point; an absolute URL is passed
  "! through. Issue it from the init branch - the same collection is
  "! registered only once per session, so a repeat call costs nothing.
  "!
  "! **cs_event-smart_variant_init** - run the initialise( ) handshake
  "! sap.ui.comp variant management needs (a controller would call
  "! oSmartVariantManagement.initialise( fnCallback, oPersonalizableControl )),
  "! t_arg = SmartVariantManagement id, personalizable control id (optional,
  "! default: the first control that registered itself):
  "! ``client->follow_up_action( val = client->cs_event-smart_variant_init t_arg = VALUE #( ( `pageVariant` ) ) )``.
  "! Without it the control keeps no personalizable control, saving a view
  "! fails inside sap.ui.fl and stored variants are never loaded. The action
  "! waits for that registration, which the smart controls do once their
  "! OData metadata has loaded.
  "!
  "! **cs_event-filter_bar_variant_init** - wire a classic
  "! sap.ui.comp.filterbar.FilterBar to a SmartVariantManagement, t_arg =
  "! SmartVariantManagement id, FilterBar id:
  "! ``client->follow_up_action( val = client->cs_event-filter_bar_variant_init t_arg = VALUE #( ( `variant` ) ( `filterbar` ) ) )``.
  "! A SmartFilterBar knows its own fields and registers itself (see
  "! smart_variant_init above); a classic FilterBar does not, so a list
  "! report normally hand-writes the same controller boilerplate -
  "! registerFetchData / registerApplyData / registerGetFiltersWithValues,
  "! addPersonalizableControl( ) with a PersonalizableInfo, and a change
  "! handler per filter field that marks the variant as modified. This action
  "! does all of it, so saving, selecting and restoring a variant works
  "! without a single line of JavaScript. The restored values reach the
  "! backend through the binding of the filter fields, no extra roundtrip
  "! needed.
  "!
  "! **cs_event-keyboard_shortcut** - bind a key combination to a named
  "! backend event, the declarative equivalent of a sap.ui.core.CommandExecution
  "! shortcut, t_arg = combination, event name:
  "! ``client->follow_up_action( val = client->cs_event-keyboard_shortcut t_arg = VALUE #( ( `Ctrl+S` ) ( `SAVE` ) ) )``.
  "! The combination is spelled like the UI5 one (`Ctrl+S`, `Ctrl+Shift+D`,
  "! `F2`; ctrl/shift/alt/meta in any order, cmd/command/option/control
  "! accepted as aliases). Pressing it fires the event exactly like a button
  "! press and suppresses the browser's own default for the combination.
  "! Registering the same combination again rebinds it; an empty event name
  "! removes it. The registrations belong to the running app and are dropped
  "! when another app takes over. An optional THIRD t_arg SCOPES the
  "! shortcut: the scoped registration wins while its scope is OPEN and the
  "! unscoped one applies otherwise, which is how a UI5 CommandExecution in a
  "! Popover's dependents shadows the page-level one for the same command. A
  "! scope is either a view slot (cs_view-popover/popup/nested/nested2/main)
  "! or the ID OF A CONTROL that can be open or closed - a Popover/Dialog
  "! declared in the view and opened with control_by_id openBy, which never
  "! enters a framework slot. A control scope beats a slot scope (it is the
  "! more specific statement), then the innermost open slot wins. An empty
  "! event name removes the registration of THAT scope only.
  "!
  "! **cs_event-hash_attach_changed** - APP-OWNED hash routing
  "! (HashChanger#attachHashChanged), the 1:1 counterpart of a UI5 router's
  "! own hash (`#/Page2`) for an app that does NOT use hash_routing, t_arg = a
  "! backend event name:
  "! ``client->follow_up_action( val = client->cs_event-hash_attach_changed t_arg = VALUE #( ( `HASH_CHANGED` ) ) )``.
  "! From then on hash_set( `/Page2` ) writes that value as the whole app hash
  "! (a pushed history entry), hash_replace( ) the same without a new entry,
  "! and a hash change the app did not write itself - browser Back/Forward, a
  "! manual URL edit - fires the registered event; the hash the browser now
  "! stands on arrives with that request (and with every other one, a fresh
  "! deep-link start included) in get( )-s_config-hash, so the app decides
  "! what to show. While registered, the framework leaves the hash entirely
  "! alone. Calling it without t_arg unregisters. The registration dies with
  "! an app switch - register it in view_display( ), so every render (a draft
  "! restore included) re-asserts it. Mutually exclusive with hash_routing (a
  "! routed app's hash belongs to the router) and with app_state_set_active
  "! (both claim the whole hash).
  "!
  "! **cs_event-hash_back** - the UI5 onNavBack pattern: without t_arg one
  "! real step back in the browser history (`window.history.go(-1)` - the step
  "! is CONSUMED, and the resulting hash change fires the registered event).
  "! With t_arg = a fallback hash it guards the cold deep link the way UI5's
  "! recommended onNavBack does: when this page load never pushed an app
  "! hash, there is no in-app step to take, so the fallback is written as a
  "! REPLACE instead of falling out of the app - and the change fires the
  "! registered event, which shows the fallback route:
  "! ``client->follow_up_action( val = client->cs_event-hash_back t_arg = VALUE #( ( `/` ) ) )``.
  "!
  "! **cs_event-binding_call** - apply a declarative filter or sorter to an
  "! aggregation binding, the client-side equivalent of the UI5 controller
  "! pattern getBinding('items').filter(...); the model data stays untouched.
  "! t_arg = id, aggregation, method, params. Method `filter`: params = path,
  "! operator, value1, value2 (empty values clear the filter); method `sort`:
  "! params = path, descending, group (abap_bool as `X`/``):
  "! ``client->follow_up_action( val = client->cs_event-binding_call t_arg = VALUE #( ( `tab` ) ( `items` ) ( `filter` ) ( `NAME` ) ( `Contains` ) ( `ab` ) ) )``.
  "!
  "! @parameter val | the frontend event - a cs_event-* constant - or a raw
  "!                  JavaScript expression when t_arg is not supplied.
  "! @parameter view | the view slot the action's control id is resolved in:
  "!                  cs_view-main, the default, searches every open view;
  "!                  cs_view-popup, -popover, -nested, -nested2 scope the
  "!                  lookup to that slot.
  "! @parameter t_arg | the positional arguments of the event - each family
  "!                  above says what they are; an empty argument between
  "!                  filled ones keeps its slot as ``.
  METHODS follow_up_action
    IMPORTING
      val           TYPE string
      view          TYPE clike        DEFAULT cs_view-main
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  "! TRUE when this roundtrip was triggered by the event named val - the
  "! check a handler branch opens with (ELSEIF client->check_on_event( `SAVE` )).
  "! Without val, TRUE when any event is being handled at all. The name is
  "! what the wire registered with _event( `SAVE` ); the same name is in
  "! get_event( ), for a CASE-shaped dispatcher.
  "!
  "! @parameter val | the event name to compare with, or empty for "any event".
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

  "! TRUE when there is an app to return to - this app was reached through
  "! nav_app_call( ), so nav_app_leave( ) lands somewhere. What a Page's
  "! showNavButton binds to (`b = client->check_app_prev_stack( )`), so the
  "! back button is only there where it has somewhere to go.
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
  " Whoever changes the factory keeps this true, or every sample in the three
  " catalogues stops rendering on its first start with nothing raised
  " anywhere. (A plain comment, not ABAP Doc: it is a note to whoever edits
  " the framework, and the documentation site prints the ABAP Doc.)
  METHODS check_on_navigated
    RETURNING
      VALUE(result) TYPE abap_bool.

  "! The app instance on the other side of the last navigation: inside a
  "! called app, the caller; back in the caller after the called app's
  "! nav_app_leave( ), the instance that just returned - cast it to its class
  "! and read its public attributes for the result it produced.
  METHODS get_app_prev
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

ENDINTERFACE.
