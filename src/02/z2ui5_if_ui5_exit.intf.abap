"! <p class="shorttext synchronized">abap2UI5 - user exit</p>
"!
"! The framework's extension point: implement this interface in a class of
"! your own, in a package of your own, and abap2UI5 finds it and calls it -
"! set_config_http_get on the initial page request, set_config_http_post on
"! every roundtrip after it.
"!
"! Supersedes z2ui5_if_exit, which carries the same two methods under the old
"! name and is still found and still called. Nothing has to change today; new
"! code implements this interface.
INTERFACE z2ui5_if_ui5_exit
  PUBLIC.

  TYPES:
    "! What the request the exit is answering for is - path, the app named by
    "! the URL, and the URL parameters.
    BEGIN OF ty_s_http_context,
      path      TYPE string,
      app_start TYPE string,
      t_params  TYPE z2ui5_if_client=>ty_t_name_value,
    END OF ty_s_http_context.

  TYPES:
    "! Everything the generated page is built from - the changing parameter of
    "! set_config_http_get.
    BEGIN OF ty_s_http_config,
      src                     TYPE string,
      theme                   TYPE string,
      content_security_policy TYPE string,
      styles_css              TYPE string,
      " NO LONGER READ: the generated page carries a constant
      " <title>abap2UI5</title>, and the tab title is set by the running app
      " with cs_event-set_title. The component stays because it is part of the
      " public contract (rule 5) - an exit that still assigns it compiles and
      " runs, the assignment just has no effect on the page
      title                   TYPE string,
      t_add_config            TYPE z2ui5_if_client=>ty_t_name_value,
      custom_js               TYPE string,
      t_security_header       TYPE z2ui5_if_client=>ty_t_name_value,
    END OF ty_s_http_config.

  TYPES:
    "! What the backend decides per roundtrip - the changing parameter of
    "! set_config_http_post.
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

  METHODS set_config_http_get
    IMPORTING
      is_context TYPE ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE ty_s_http_config.

  METHODS set_config_http_post
    IMPORTING
      is_context TYPE ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE ty_s_http_config_post.

ENDINTERFACE.
