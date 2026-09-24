"! <p class="shorttext synchronized">abap2UI5 - user exit</p>
"!
"! The framework's extension point: implement this interface in a class of
"! your own, in a package of your own, and abap2UI5 finds it and calls it -
"! set_config_http_get on the initial page request - and once more per
"! response for its t_security_header, which every response of the handler
"! carries - set_config_http_post on every roundtrip after it.
"!
"! Supersedes z2ui5_if_exit, which carries the same two methods under the old
"! name and is still found and still called. Nothing has to change today; new
"! code implements this interface.
INTERFACE z2ui5_if_ui5_exit
  PUBLIC.

  TYPES:
    "! What the request the exit is answering for is - path, the app named by
    "! the URL, and the URL parameters. app_start is the app_start query
    "! parameter of THIS request, trimmed, upper-cased and with a
    "! percent-encoded namespace unpacked - the way the framework reads it.
    "! It is empty on every POST (the SPA posts to the manifest URI) and when
    "! the app is named by the hash route, which never reaches the server: a
    "! hint for the page request, not the authority on which app runs.
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
      " the CSP meta tag of the page, pre-filled with the default before the
      " exit runs. The default carries no 'unsafe-eval'. Only on UI5 1.71 to
      " 1.82 can a popup still need it - one whose XML names a module in a
      " binding type or a core:require that is not loaded yet. Such an
      " installation switches it on here -
      "   REPLACE `script-src 'self'` IN cs_config-content_security_policy
      "           WITH `script-src 'self' 'unsafe-eval'`.
      " - or the exit replaces the whole tag.
      " Its script-src carries no 'unsafe-inline' either: after the exit ran,
      " the framework appends the hash of the page's one inline script to
      " every script-src (and script-src-elem) - here and in a policy sent
      " through t_security_header - so nothing else inline runs. A script-src
      " that names 'unsafe-inline' itself is left without the hash, which is
      " how an installation that needs inline script of its own opts back in
      "   REPLACE `script-src 'self'` IN cs_config-content_security_policy
      "           WITH `script-src 'self' 'unsafe-inline'`.
      content_security_policy TYPE string,
      " CSS of the installation's own, written into the page head as a
      " <style> element of its own (a < is escaped as \3c )
      styles_css              TYPE string,
      t_add_config            TYPE z2ui5_if_client=>ty_t_name_value,
      t_security_header       TYPE z2ui5_if_client=>ty_t_name_value,
    END OF ty_s_http_config.

  TYPES:
    "! What the backend decides per roundtrip - the changing parameter of
    "! set_config_http_post.
    BEGIN OF ty_s_http_config_post,
      draft_exp_time_in_hours    TYPE i,
      " when set via the exit, framework errors answer with a generic 500
      " message instead of the raw exception text (avoids leaking internal
      " details to the client in hardened installations)
      check_hide_error_details   TYPE abap_bool,
      " a state-changing POST whose Origin/Referer header names a different
      " site than the app's own host is rejected with 403 (CSRF defense).
      " On by default: z2ui5_cl_ui5_user_exit=>set_config_http_post seeds abap_true
      " before the user exit runs, so an app that must accept cross-origin
      " POSTs opts out by setting it back to abap_false in its own exit.
      " Lenient: a request without an Origin/Referer header (older clients,
      " some proxies) is allowed, so only an explicit cross-origin marker is
      " blocked - the app's own roundtrips are always same-origin (the SPA
      " fetches its own backend).
      check_csrf_active          TYPE abap_bool,
      " the CSRF gate compares Origin/Referer against the app's own host,
      " and behind a reverse proxy / web dispatcher that host is the
      " X-Forwarded-Host the proxy wrote - so it is trusted by default
      " (seeded abap_true like check_csrf_active), or every request behind a
      " proxy would 403 against the internal Host. The header is client-
      " suppliable, though: an installation that is NOT behind a proxy that
      " sets it hardens the gate by switching this to abap_false in its
      " exit, so only the transport-level Host header is compared.
      " Of a comma-separated list the FIRST entry is compared, on purpose:
      " that is the header's meaning (each proxy appends the Host it saw,
      " so the first is the one the browser sent, which is what Origin
      " carries), and the last entry behind two proxies is an internal
      " name. A proxy that APPENDS instead of replacing lets a client put
      " its own entry first - a non-browser client, since a browser cannot
      " send the header without a CORS preflight the ICF node answers 405,
      " and a non-browser client is not a CSRF victim. Do not "fix" this by
      " taking the last entry; the switch above is the hardening.
      check_trust_forwarded_host TYPE abap_bool,
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
