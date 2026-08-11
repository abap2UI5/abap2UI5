INTERFACE z2ui5_if_core_types
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

  TYPES:
    BEGIN OF ty_s_http_res,
      body          TYPE string,
      status_code   TYPE i,
      status_reason TYPE string,
      t_header      TYPE z2ui5_if_types=>ty_t_name_value,
      BEGIN OF s_stateful,
        active   TYPE i,
        switched TYPE abap_bool,
      END OF s_stateful,
    END OF ty_s_http_res.

  TYPES:
    BEGIN OF ty_s_bind_config,
      path_only            TYPE abap_bool,
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping,
      custom_mapper_back   TYPE REF TO z2ui5_if_ajson_mapping,
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter,
      custom_filter_back   TYPE REF TO z2ui5_if_ajson_filter,
      tab                  TYPE REF TO data,
      tab_index            TYPE i,
      switch_default_model TYPE abap_bool,
      check_json           TYPE abap_bool,
    END OF ty_s_bind_config.

  TYPES:
    BEGIN OF ty_s_attri,
      name               TYPE string,
      name_client        TYPE string,
      name_parent        TYPE string,
      name_ref           TYPE string,
      bind               TYPE abap_bool,
      srtti_data         TYPE string,
      check_dissolved    TYPE abap_bool,
      custom_filter      TYPE REF TO z2ui5_if_ajson_filter,
      custom_filter_back TYPE REF TO z2ui5_if_ajson_filter,
      custom_mapper      TYPE REF TO z2ui5_if_ajson_mapping,
      custom_mapper_back TYPE REF TO z2ui5_if_ajson_mapping,
      " the bound string carries JSON - serialize it as a node, not as text
      check_json         TYPE abap_bool,
      o_typedescr        TYPE REF TO cl_abap_typedescr,
      type_kind          TYPE string,
      kind               TYPE string,
    END OF ty_s_attri.
  TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

  " One view-lifecycle call, as the backend collects it. It is kept typed
  " until main_end( ) rather than serialized on the spot, because two things
  " can only be decided once the app has run: a slot may be displayed twice
  " and only the last call counts, and the calls have to leave in slot order,
  " never in call order (see cs_slot_rank).
  TYPES:
    BEGIN OF ty_s_system_action,
      slot    TYPE string,
      method  TYPE string,
      xml     TYPE string,
      " the slot-specific extras as a JSON object - the popover's anchor, a
      " nested view's insert/destroy methods, the MAIN view's model switch
      options TYPE string,
    END OF ty_s_system_action.
  TYPES ty_t_system_action TYPE STANDARD TABLE OF ty_s_system_action WITH EMPTY KEY.

  " The order the slots are served in, whatever order the app called them in.
  " MAIN goes first because a NESTed view is inserted INTO its control tree -
  " a nested view built before the page it belongs to would find no parent.
  " The two fragment slots are standalone and come last.
  CONSTANTS:
    BEGIN OF cs_slot_rank,
      main    TYPE i VALUE 1,
      nest    TYPE i VALUE 2,
      nest2   TYPE i VALUE 3,
      popup   TYPE i VALUE 4,
      popover TYPE i VALUE 5,
    END OF cs_slot_rank.

  TYPES:
    BEGIN OF ty_s_next_frontend,
      BEGIN OF s_action,
        " SYSTEM actions run FIRST, in the display phase, before the view is
        " rendered - they are the framework's own view-lifecycle calls
        " (destroy a slot, display one, push the model into it), which every
        " later action depends on having happened. APP actions run last, once
        " the view is in the DOM, so a render-dependent one like SET_FOCUS
        " finds its target control. Same payload format and same dispatcher
        " for both, only the phase differs.
        t_system TYPE string_table,
        t_custom TYPE string_table,
      END OF s_action,
      set_app_state_active  TYPE abap_bool,
      set_push_state        TYPE string,
      set_nav_back          TYPE abap_bool,
      " Hash-based app routing (UI5 Router style): when active, the frontend
      " keeps the URL hash in sync with the running app as a bookmarkable route,
      " and the browser Back/Forward buttons navigate between apps via that hash
      " (see app/webapp/core/Router.js). Opt-in per APP via
      " client->set_nav_routing( ) - the mode is remembered on the app and
      " travels in its draft, so it is re-sent with every response of that app
      " (see z2ui5_cl_core_app=>mv_nav_mode). The value carries the MODE (see
      " z2ui5_if_client=>cs_nav_mode): 'KEEP' syncs the class AND its draft id
      " '#/app/<CLASS>/<DRAFT>' so Back/Forward restore the exact preserved
      " state; 'FRESH' syncs the class only '#/app/<CLASS>' so they start the
      " app fresh; 'DEFAULT' turns routing off again; an empty value means 'no
      " change' (a session keeps the mode it already has).
      set_nav_routing       TYPE string,
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
      s_stateful            TYPE ty_s_http_res-s_stateful,
    END OF ty_s_next_frontend.

  TYPES:
    BEGIN OF ty_s_next,
      o_app_call         TYPE REF TO z2ui5_if_app,
      o_app_leave        TYPE REF TO z2ui5_if_app,
      next_event         TYPE string,
      s_set              TYPE ty_s_next_frontend,
      r_data             TYPE REF TO data,
      " BACKEND-ONLY, never serialized: the view-lifecycle calls of this
      " roundtrip, collected while the app runs and turned into the SYSTEM
      " action list by main_end( ).
      t_action_front     TYPE ty_t_system_action,
      " BACKEND-ONLY: did this roundtrip ship a view into any slot? The model
      " has to travel with new XML, and the decision used to be made by
      " reading the response's own s_*-xml fields back.
      check_view_shipped TYPE abap_bool,
    END OF ty_s_next.

  TYPES:
    BEGIN OF ty_s_response,
      BEGIN OF s_front,
        params TYPE ty_s_next_frontend,
        id     TYPE string,
        app    TYPE string,
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
      o_model TYPE REF TO z2ui5_if_ajson,
      BEGIN OF s_front,
        id          TYPE string,
        t_event_arg TYPE string_table,
        event       TYPE string,
        o_comp_data TYPE REF TO z2ui5_if_ajson,
        origin      TYPE string,
        pathname    TYPE string,
        search      TYPE string,
        hash        TYPE string,
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
      END OF s_control,
    END OF ty_s_request.

  TYPES:
    BEGIN OF ty_s_actual,
      event              TYPE string,
      t_event_arg        TYPE string_table,
      check_on_navigated TYPE abap_bool,
      r_data             TYPE REF TO data,
    END OF ty_s_actual.

ENDINTERFACE.
