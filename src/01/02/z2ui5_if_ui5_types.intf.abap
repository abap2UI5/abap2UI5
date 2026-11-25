INTERFACE z2ui5_if_ui5_types
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_ui5,
      event_backend_function  TYPE string VALUE `.eB`,
      event_frontend_function TYPE string VALUE `.eF`,
      " same roundtrip as .eB, but cancels the control's built-in default
      " first - it takes the UI5 event object ($event) as first argument
      event_backend_prevent   TYPE string VALUE `.eBP`,
    END OF cs_ui5.

  CONSTANTS cs_event_nav_app_leave TYPE string VALUE `___ZZZ_NAL`.

  " The transport of a WINDOWED table's request (window_bind_tab( )): the
  " frontend's list binding wants more rows, or was sorted or filtered. The
  " handler turns it into the APP's event - the one window_bind_tab( ) named -
  " with the request as get( )-r_event_data (z2ui5_cl_ui5_srv_window=>request)
  " and calls main( ), which loads, sorts and filters. Spelled as the
  " frontend sends it - bundle/webapp/core/WindowModel.js, EVENT - so never a
  " literal. Arguments: the model path of the table, the app's event, the
  " reason (MORE / SORT / FILTER), skip, top - and for SORT the sorters,
  " for FILTER the filter groups, as JSON (z2ui5_cl_ui5_srv_window=>parse_sort
  " and parse_filter)
  CONSTANTS cs_event_window TYPE string VALUE `___ZZZ_WIN`.

  " The model key the window state of every windowed table travels under -
  " /__WINDOW/<NAME>/TOTAL, COUNT, SIZE and EVENT - read by the frontend's
  " list binding and bindable by the app (`{/__WINDOW/MT_ROWS/TOTAL}` rows)
  CONSTANTS cv_window_model_key TYPE string VALUE `__WINDOW`.

  " The VIEW_SLOTS system-action vocabulary, spelled as the frontend's
  " ViewSlots module dispatches it. Every backend-side call (the system
  " actions, the nav-app teardown, the popup_close mapping) uses these -
  " never a literal.
  CONSTANTS:
    BEGIN OF cs_slot_action,
      target       TYPE string VALUE `VIEW_SLOTS`,
      display      TYPE string VALUE `display`,
      destroy      TYPE string VALUE `destroy`,
    END OF cs_slot_action.

  " The other whitelisted global-call targets the backend queues actions
  " against, spelled as the keys of GLOBAL_TARGETS in the frontend's
  " bundle/webapp/core/actions/ControlCall.js dispatch - the same cross-repo
  " wire contract as cs_slot_action-target above, so never a literal.
  CONSTANTS:
    BEGIN OF cs_global_target,
      message_toast TYPE string VALUE `MESSAGE_TOAST`,
      message_box   TYPE string VALUE `MESSAGE_BOX`,
    END OF cs_global_target.

  TYPES:
    BEGIN OF ty_s_http_res,
      body          TYPE string,
      status_code   TYPE i,
      status_reason TYPE string,
      BEGIN OF s_stateful,
        active   TYPE i,
        switched TYPE abap_bool,
      END OF s_stateful,
    END OF ty_s_http_res.

  TYPES:
    BEGIN OF ty_s_bind_config,
      path_only            TYPE abap_bool,
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping,
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter,
      tab                  TYPE REF TO data,
      tab_index            TYPE i,
      switch_default_model TYPE abap_bool,
      check_json           TYPE abap_bool,
      " window_bind_tab( ): the rows the browser asks for at a time, the
      " rows there are in all - its value, and a reference to it to find the
      " attribute it is - and the app's event for the browser's requests
      window               TYPE i,
      window_total         TYPE i,
      window_total_ref     TYPE REF TO data,
      window_event         TYPE string,
    END OF ty_s_bind_config.


  TYPES:
    BEGIN OF ty_s_attri,
      name              TYPE string,
      name_client       TYPE string,
      name_parent       TYPE string,
      name_ref          TYPE string,
      bind              TYPE abap_bool,
      srtti_data        TYPE string,
      " the S-RTTI descriptor of srtti_data as a document of its own, so the
      " restore parses each once (z2ui5_cl_ui5_util_context=>xml_srtti_parse_pair)
      " instead of lexing one combined document twice. Added 2026-09: a draft
      " written before carries no element for it, deserializes with an empty
      " type, and is restored from the combined document as before
      srtti_type        TYPE string,
      check_dissolved   TYPE abap_bool,
      custom_filter     TYPE REF TO z2ui5_if_ajson_filter,
      custom_mapper     TYPE REF TO z2ui5_if_ajson_mapping,
      " the bound string carries JSON - serialize it as a node, not as text
      check_json        TYPE abap_bool,
      " live only: the draft stores the row without it
      " (z2ui5_cl_ui5_srv_model=>main_attri_db_rows), dissolve_run resolves
      " it again from the attribute when it needs one
      o_typedescr       TYPE REF TO cl_abap_typedescr,
      " the absolute type name as a STRING, next to the descriptor it is
      " taken from: the descriptor is an object reference and does not
      " survive the draft, the name does - so the binding search can
      " prefilter by type on a restored row without resolving it first
      " (z2ui5_cl_ui5_srv_model=>attri_search). Added 2026-09: a draft
      " written before carries no element for it and deserializes with an
      " empty name (asXML tolerates a MISSING component, never a surplus
      " one); the search then skips the prefilter for that row.
      " The same release DROPPED the custom_filter_back / custom_mapper_back
      " components nothing had set for a long time - the one deliberate
      " draft-format break: a draft written before it carries two surplus
      " elements and does not deserialize any more. Drafts expire within
      " hours (z2ui5_cl_ui5_srv_draft=>cleanup), so the window is the
      " upgrade itself; a roundtrip on such a draft answers with the
      " framework's error page once, the next start is a fresh app
      type_name         TYPE string,
      type_kind         TYPE string,
      kind              TYPE string,
      " window_bind_tab( ): the table is the rows the app has loaded, in the
      " order the browser shows them; window_total is how many there are in
      " all - read anew from the app's attribute window_total_name on every
      " response when the app passed one, so a window event that changes it
      " needs no new view - window_size how many the browser asks for at a
      " time, and window_event the app's event its requests arrive as. The framework
      " neither sorts nor filters nor keeps an order - the app does, in
      " main( ) (z2ui5_cl_ui5_srv_window=>request).
      " Replaced 2026-11-19 the seven components of the server-side window
      " (count, sort and filter with their owners) - a draft written with
      " those carries surplus elements and does not deserialize; drafts
      " expire within hours (z2ui5_cl_ui5_srv_draft=>cleanup), so the
      " window is the upgrade itself
      window_size       TYPE i,
      window_total      TYPE i,
      window_total_name TYPE string,
      window_event      TYPE string,
    END OF ty_s_attri.
  " the secondary key serves the two reads that walk a row's CHILDREN (the
  " save of a generic reference, the alias pass) - a sequential scan of
  " the whole table per parent otherwise. name_parent is written before a
  " row is inserted and never through a reference afterwards, which is
  " what a key component of a secondary key requires; name_ref, which the
  " alias pass rewrites through references, must never join a key
  TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name
    WITH NON-UNIQUE SORTED KEY parent COMPONENTS name_parent.

  " One view-lifecycle call, as the backend collects it: what the app's last
  " call for a slot decided (z2ui5_cl_ui5_frontend=>slot_reset keeps at most
  " one row per slot). main_end( ) derives the model decision from the list
  " and ships it as the response's VIEWS section.
  TYPES:
    BEGIN OF ty_s_system_action,
      slot    TYPE string,
      method  TYPE string,
      xml     TYPE string,
      " the slot-specific extras as a JSON object - the popover's anchor, a
      " nested view's insert/destroy methods, the MAIN view's model switch
      options TYPE REF TO z2ui5_if_ajson,
    END OF ty_s_system_action.
  TYPES ty_t_system_action TYPE STANDARD TABLE OF ty_s_system_action WITH EMPTY KEY.

  " One QUEUED frontend action, built as JSON right away (o_json, the
  " ["EVENT",...] array) and embedded into the response as-is - no string
  " round trip.
  TYPES:
    BEGIN OF ty_s_queued_action,
      o_json TYPE REF TO z2ui5_if_ajson,
    END OF ty_s_queued_action.
  TYPES ty_t_queued_action TYPE STANDARD TABLE OF ty_s_queued_action WITH EMPTY KEY.

  " What an app asked the frontend to DO - a focus, a toast, a control
  " method. The frontend runs the list last, once the views of the response
  " are in the DOM, so a render-dependent action like SET_FOCUS finds its
  " control. It leaves as the response's ACTIONS list.
  "
  " Until protocol 3 a second list rode next to it, t_system: the view
  " lifecycle and the URL intent spelled as actions (VIEW_SLOTS/display,
  " ROUTER/sync). Both are state, not commands - at most one entry per slot
  " and one navigation intent per response - and travel as the sections
  " VIEWS and NAV now (ty_s_response).
  TYPES:
    BEGIN OF ty_s_action,
      t_custom TYPE ty_t_queued_action,
    END OF ty_s_action.

  " The browser-history intent of one roundtrip. Router computes ONE outcome
  " from all of it - adopt the hash, push a route entry, replace it, or write
  " the app-state hash - so it travels as one call with one options object
  " rather than as separate fields the frontend would have to recombine.
  TYPES:
    BEGIN OF ty_s_nav,
      set_app_state_active  TYPE abap_bool,
      set_push_state        TYPE string,
      " HashChanger#replaceHash (client->hash_replace): the same write as
      " set_push_state minus the history entry - the router's replace-navTo.
      " Like set_push_state the WHOLE app hash, and written only for an app
      " that owns the hash - a hash_attach_changed listener, routing off.
      " When both are set in one roundtrip the push wins (the frontend
      " processes setPushState first)
      hash_replace          TYPE string,
      " Hash-based app routing (UI5 Router style): when active, the frontend
      " keeps the URL hash in sync with the running app as a bookmarkable route,
      " and the browser Back/Forward buttons navigate between apps via that hash
      " (see bundle/webapp/core/Router.js). Opt-in per APP via
      " follow_up_action( cs_event-hash_routing ) - the mode is remembered on the app,
      " travels in its draft and is re-sent whenever the frontend may not
      " still hold it (see z2ui5_cl_ui5_app_cont->mv_nav_mode and the
      " nav_mode_sent latch in main_end). The value carries the MODE (see
      " z2ui5_if_client=>cs_nav_mode): 'KEEP' syncs the class AND its draft id
      " '#/app/<CLASS>/<DRAFT>' so Back/Forward restore the exact preserved
      " state; 'FRESH' syncs the class only '#/app/<CLASS>' so they start the
      " app fresh; 'DEFAULT' turns routing off again; an empty value means 'no
      " change' (a session keeps the mode it already has).
      set_nav_routing       TYPE string,
      " App-owned hash routing (routing OFF, cs_event-hash_attach_changed): the
      " backend event name the frontend round-trips when the hash changes
      " under the app (browser Back/Forward, a manual edit). While registered,
      " set_push_state pushes its value as the whole app hash through the
      " HashChanger and the router's per-response hash cleanup stands down
      " (see bundle/webapp/core/Router.js applyHashEvent). Empty = no change; a
      " single space = unregister - the set_app_state_active encoding
      set_hash_listener     TYPE string,
      " Forward app navigation via a backend nav_app_call: tells the frontend to
      " PUSH a new route history entry ('#/app/<CLASS>' of the called app) so the
      " browser Back button returns to the calling app - the routing equivalent
      " of a UI5 navTo. A plain roundtrip only replaces the current route.
      check_nav_app_call    TYPE abap_bool,
      " The CALLING app of that nav_app_call, as class + the draft id it was
      " saved under right before the navigation. That draft carries every
      " client-side model change the user made since the caller last rendered
      " (switches, checkboxes, input) - its history entry, however, still points
      " at the older draft of that last render. The frontend therefore repoints
      " the caller's entry at this draft before pushing the called app's route,
      " so browser Back restores the caller exactly as the user left it (KEEP
      " mode only - a FRESH route carries no draft). Set for the FIRST hop of a
      " request only, so a chain of nav_app_calls keeps the entry of the app the
      " user actually navigated away from.
      nav_app_call_prev_app TYPE string,
      nav_app_call_prev_id  TYPE string,
    END OF ty_s_nav.


  " The declarative timer of ONE app (z2ui5_if_client~timer_set): the
  " repeating START_TIMER the framework arms whenever the app gets the
  " screen. Kept on the app container - and therefore in its draft - twice:
  " what the app declared (ms_timer) and what was last SENT to the browser
  " for it (ms_timer_sent), so an unchanged timer that runs is not sent
  " again (z2ui5_cl_ui5_handler=>main_end_timer). Initial = no timer.
  TYPES:
    BEGIN OF ty_s_timer,
      event    TYPE string,
      delay_ms TYPE i,
      no_busy  TYPE abap_bool,
    END OF ty_s_timer.

  TYPES:
    BEGIN OF ty_s_next,
      o_app_call      TYPE REF TO z2ui5_if_app,
      o_app_leave     TYPE REF TO z2ui5_if_app,
      next_event      TYPE string,
      " the two action queues of this roundtrip, as the response ships them
      s_action        TYPE ty_s_action,
      r_data          TYPE REF TO data,
      " BACKEND-ONLY, never serialized: the view-lifecycle calls of this
      " roundtrip, collected while the app runs and turned into the VIEWS
      " section by main_end( ).
      t_action_front  TYPE ty_t_system_action,
      " BACKEND-ONLY: what the browser history / URL has to reflect after this
      " roundtrip. main_end( ) turns it into the NAV section - the frontend
      " router reads its inputs from that one object, not from one response
      " field per component of ty_s_nav.
      s_nav           TYPE ty_s_nav,
      " BACKEND-ONLY: the stateful-session switch. It never was a frontend
      " concern - z2ui5_cl_ui5_http_handler reads it off the response record to
      " call set_session_stateful, and no frontend module ever looked at it.
      s_stateful      TYPE ty_s_http_res-s_stateful,
      " BACKEND-ONLY: nav_app_call( keep_messages ) / nav_app_leave(
      " keep_messages ) - the hop carries the message toasts and boxes this
      " app queued over to the app navigated to (z2ui5_cl_ui5_action
      " =>prepare_app_stack); every other queued action is dropped as before
      keep_messages   TYPE abap_bool,
      " BACKEND-ONLY: a hop of this request left an app whose declarative
      " timer runs in the browser (z2ui5_cl_ui5_action=>prepare_app_stack).
      " The response stops it unless the app answering declares one of its
      " own - another instance of the SAME class looks like the same app
      " to the browser, which ends a repeating timer only on a class change
      check_timer_end TYPE abap_bool,
    END OF ty_s_next.

  "! The WIRE protocol version, carried in every response as
  "! S_FRONT.PROTOCOL and compared by the frontend against the value it was
  "! built for.
  "!
  "! It is not the product version (z2ui5_if_app=&gt;version) and does not move
  "! with a release: it moves only when a response can no longer be read by a
  "! frontend written for the previous number - the S_ACTION envelope
  "! replacing S_FRONT.PARAMS was such a change, and the flattening of the
  "! two-way bindings out of MODEL.XX was another (both protocol 2).
  "!
  "! Protocol 3: the flags of an event wire travel as one object in slot [1]
  "! of the event array, .eB(['NAME',{queueLast:true}]), no longer as
  "! positions [3] to [5] (z2ui5_cl_ui5_srv_event=&gt;get_event) - a frontend
  "! of protocol 2 reads such a wire as one without a flag. And the response
  "! carries the view lifecycle and the URL intent as the sections VIEWS and
  "! NAV and the app's follow-up actions as ACTIONS, where S_ACTION carried
  "! the lists T_SYSTEM and T_CUSTOM (ty_s_response, ty_s_action). And a
  "! request that starts an app names what the hash asks it to restore as
  "! S_FRONT.ROUTE - the backend no longer parses the hash for it.
  "!
  "! Why it exists: backend and frontend ship together here, but they do not
  "! ship together everywhere. A port of this framework, a pinned webapp, a
  "! third-party shell - each can pair a backend and a frontend of different
  "! ages, and until this field existed the result was a page that rendered
  "! NOTHING, with no error anywhere: the frontend looked for a key the
  "! backend no longer wrote and read its absence as "no action to run".
  "! A number on the wire turns that into a message somebody can read.
  "!
  "! Raise it in the same change that breaks the wire, and raise the
  "! frontend's expectation with it (bundle/webapp/core/Server.js).
  CONSTANTS c_protocol TYPE i VALUE 3.

  TYPES:
    BEGIN OF ty_s_response,
      BEGIN OF s_front,
        s_action TYPE ty_s_action,
        id       TYPE string,
        app      TYPE string,
        " PROTOCOL has no field here: z2ui5_cl_ui5_handler
        " =>response_abap_to_json stamps c_protocol on every response
        " itself, so no caller can set - or forget - it
        " VIEWS: one entry per slot this roundtrip changes -
        "   "MAIN": { "XML": "<mvc:View ...>", "OPT": { ... } }   a display
        "   "POPUP": { "DESTROY": true }                          a teardown
        " The frontend applies them in ITS order (MAIN, NEST, NEST2, POPUP,
        " POPOVER - a nested view is inserted into the main control tree),
        " so nothing here is sorted. Unbound or empty: no slot changes
        " (z2ui5_cl_ui5_frontend=>slots_serialize)
        o_views  TYPE REF TO z2ui5_if_ajson,
        " NAV: the URL intent of this roundtrip, the options the frontend's
        " Router.sync takes. Unbound: none - the frontend still syncs the
        " URL once per response (z2ui5_cl_ui5_frontend=>nav_serialize)
        o_nav    TYPE REF TO z2ui5_if_ajson,
      END OF s_front,
      model TYPE string,
    END OF ty_s_response.

  " one scroll position per view slot (main / nest / nest2 / popup / popover)
  TYPES:
    BEGIN OF ty_s_scroll_pos,
      id TYPE string,
      x  TYPE i,
      y  TYPE i,
    END OF ty_s_scroll_pos.

  TYPES:
    BEGIN OF ty_s_request,
      " the parsed request tree the view model is read from, and the path
      " of its MODEL node in that tree (`/value/MODEL` standalone, `/MODEL`
      " behind a launchpad proxy - see z2ui5_cl_ui5_handler=>request_parse_body).
      " The model is NOT sliced out of the request: a slice walks and copies
      " every node, and on a mass edit the model IS most of the request. A
      " request without a MODEL node carries an empty tree and no path; a
      " tree that is the model itself (the shape the tests hand in) carries
      " no path either - the consumer prefixes what it reads with the path
      " (z2ui5_cl_ui5_srv_model=>main_json_to_attri)
      o_model    TYPE REF TO z2ui5_if_ajson,
      model_path TYPE string,
      BEGIN OF s_front,
        id             TYPE string,
        t_event_arg    TYPE string_table,
        event          TYPE string,
        " the launchpad ComponentData AS THE REQUEST CARRIED IT - bound on
        " the page load's first roundtrip only. On an event roundtrip it
        " stays unbound: the session keeps the data as a string
        " (ty_s_session-comp_data), and z2ui5_cl_ui5_client=>get( ) parses
        " that on demand instead of the handler parsing it per roundtrip
        o_comp_data    TYPE REF TO z2ui5_if_ajson,
        origin         TYPE string,
        pathname       TYPE string,
        search         TYPE string,
        hash           TYPE string,
        " what the hash asks an app START to restore, as the frontend parsed
        " it (core/Router.js startRoute): the class and draft of a route
        " '#/app/<CLASS>/<DRAFT>', or the draft of an app-state link
        " '#/z2ui5-xapp-state=<DRAFT>'. Filled on a request without a draft
        " id only, and not at all when the hash names neither
        BEGIN OF s_route,
          app       TYPE string,
          draft     TYPE string,
          app_state TYPE string,
        END OF s_route,
        " the previous roundtrip's duration as the browser measured it, in
        " ms (core/Server.js, MS_CLIENT_PREV) - for the roundtrip monitor
        " only (z2ui5_if_ui5_monitor=>ty_s_roundtrip-ms_client_prev); 0
        " when the request carries none or an unreadable one
        ms_client_prev TYPE i,
        " the request is a START_TIMER tick (core/actions/ViewOps.js, wire
        " S_FRONT.TIMER) - the one kind of roundtrip that may answer with
        " the draft it continued when main( ) changed nothing
        " (z2ui5_cl_ui5_handler=>main_end_reuse)
        check_timer    TYPE abap_bool,
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
          main    TYPE ty_s_scroll_pos,
          nest    TYPE ty_s_scroll_pos,
          nest2   TYPE ty_s_scroll_pos,
          popup   TYPE ty_s_scroll_pos,
          popover TYPE ty_s_scroll_pos,
        END OF s_scroll,
        BEGIN OF s_ui5,
          version         TYPE string,
          build_timestamp TYPE string,
          gav             TYPE string,
          theme           TYPE string,
        END OF s_ui5,
      END OF s_front,
      BEGIN OF s_control,
        check_launchpad TYPE abap_bool,
        app_start       TYPE string,
        app_start_draft TYPE string,
        " abap_true when app_start_draft came from the app-state bookmark
        " hash (#/z2ui5-xapp-state=<id>), abap_false when it came from a
        " route (#/app/<CLASS>/<id>) - only the former is the app's opt-in
        " to the app-state hash (z2ui5_cl_ui5_action=>factory_first_start)
        check_app_state TYPE abap_bool,
      END OF s_control,
    END OF ty_s_request.

  " What a browser tells the backend about ITSELF, once per page load instead
  " of on every roundtrip: the UI5 build, the device it runs on, the
  " launchpad's ComponentData, and the page location (origin, pathname and
  " query - the hash stays live, it carries the routing state). It is stored
  " on the app and therefore travels in the draft, so a follow-up roundtrip
  " needs to send none of it.
  "
  " Two parts of s_device are NOT session-constant and keep travelling with
  " every request - orientation and resize change while the app runs. They are
  " merged over the stored block, so client->get( )-s_device still answers with
  " a device record that is current in every field.
  TYPES:
    BEGIN OF ty_s_session,
      s_ui5         TYPE ty_s_request-s_front-s_ui5,
      s_device      TYPE ty_s_request-s_front-s_device,
      comp_data     TYPE string,
      origin        TYPE string,
      pathname      TYPE string,
      search        TYPE string,
      " the routing mode last SENT to the frontend for this app - a plain
      " event roundtrip repeats no mode (see z2ui5_cl_ui5_handler=>main_end)
      nav_mode_sent TYPE string,
    END OF ty_s_session.

  TYPES:
    BEGIN OF ty_s_actual,
      event              TYPE string,
      t_event_arg        TYPE string_table,
      check_on_navigated TYPE abap_bool,
      r_data             TYPE REF TO data,
      " The table cells the incoming delta could not convert, collected by
      " z2ui5_cl_ui5_srv_model while the model was parsed and handed on to
      " the app through client->get( )-t_model_skipped. It belongs to THIS
      " roundtrip only - the action is rebuilt per request and never
      " serialized into the draft, so a trace can never outlive the edit
      " that caused it
      t_model_skipped    TYPE z2ui5_if_client=>ty_t_model_skip,
      " The app was reached by going BACK: a nav_app_leave( ) returned to an
      " instance restored from the stack (z2ui5_cl_ui5_action=>
      " factory_stack_leave). view_display( ) sends it as the MAIN display's
      " navBack, so the page being left plays its arrival transition in
      " reverse - the sap.m.NavContainer rule. A leave to a FRESH instance is
      " a forward navigation that discards the current app and does not set
      " it
      check_nav_back     TYPE abap_bool,
    END OF ty_s_actual.

ENDINTERFACE.
