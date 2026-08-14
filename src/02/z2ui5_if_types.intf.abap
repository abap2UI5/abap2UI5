INTERFACE z2ui5_if_types
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
      " On by default: z2ui5_cl_ui5_user_exit=>set_config_http_post seeds abap_true
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

ENDINTERFACE.
