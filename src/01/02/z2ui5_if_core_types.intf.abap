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
      o_typedescr        TYPE REF TO cl_abap_typedescr,
      type_kind          TYPE string,
      kind               TYPE string,
    END OF ty_s_attri.
  TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

  " the two nested-view slots share the exact same shape. No
  " check_update_model here - a nested view inherits the MAIN view's model
  TYPES:
    BEGIN OF ty_s_view_nest,
      xml            TYPE string,
      id             TYPE string,
      method_insert  TYPE string,
      method_destroy TYPE string,
      check_destroy  TYPE abap_bool,
    END OF ty_s_view_nest.

  TYPES:
    BEGIN OF ty_s_next_frontend,
      BEGIN OF s_view,
        xml                       TYPE string,
        switchdefaultmodelannouri TYPE string,
        switch_default_model_path TYPE string,
        check_destroy             TYPE abap_bool,
        check_update_model        TYPE abap_bool,
      END OF s_view,
      s_view_nest           TYPE ty_s_view_nest,
      s_view_nest2          TYPE ty_s_view_nest,
      BEGIN OF s_popup,
        xml                TYPE string,
        id                 TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_popup,
      BEGIN OF s_popover,
        xml                TYPE string,
        id                 TYPE string,
        open_by_id         TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_popover,
      BEGIN OF s_msg_box,
        type              TYPE string,
        text              TYPE string,
        title             TYPE string,
        styleclass        TYPE string,
        onclose           TYPE string,
        actions           TYPE string_table,
        emphasizedaction  TYPE string,
        initialfocus      TYPE string,
        textdirection     TYPE string,
        icon              TYPE string,
        details           TYPE string,
        closeonnavigation TYPE string,
        dependenton       TYPE string,
        contentwidth      TYPE string,
      END OF s_msg_box,
      BEGIN OF s_msg_toast,
        class                    TYPE string,
        text                     TYPE string,
        duration                 TYPE string,
        width                    TYPE string,
        my                       TYPE string,
        at                       TYPE string,
        of                       TYPE string,
        offset                   TYPE string,
        collision                TYPE string,
        onclose                  TYPE string,
        autoclose                TYPE string,
        animationtimingfunction  TYPE string,
        animationduration        TYPE string,
        closeonbrowsernavigation TYPE string,
      END OF s_msg_toast,
      BEGIN OF s_follow_up_action,
        custom_js TYPE string_table,
      END OF s_follow_up_action,
      set_app_state_active  TYPE abap_bool,
      set_push_state        TYPE string,
      set_nav_back          TYPE abap_bool,
      " Hash-based app routing (UI5 Router style): when active, the frontend
      " keeps the URL hash in sync with the running app as a bookmarkable route,
      " and the browser Back/Forward buttons navigate between apps via that hash
      " (see app/webapp Component.js HashChanger listener). Opt-in per session
      " via client->set_nav_routing( ). The value carries the routing MODE (see
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
      o_app_call  TYPE REF TO z2ui5_if_app,
      o_app_leave TYPE REF TO z2ui5_if_app,
      next_event  TYPE string,
      s_set       TYPE ty_s_next_frontend,
      r_data      TYPE REF TO data,
    END OF ty_s_next.

  TYPES:
    BEGIN OF ty_s_response,
      BEGIN OF s_front,
        params    TYPE ty_s_next_frontend,
        id        TYPE string,
        app_start TYPE string,
        app       TYPE string,
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
