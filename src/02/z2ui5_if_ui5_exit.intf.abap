"! <p class="shorttext synchronized">abap2UI5 - user exit</p>
"!
"! The framework's extension point: implement this interface in a class of
"! your own, in a package of your own, and abap2UI5 finds it and calls it -
"! set_config_http_get on the initial page request - and once more per
"! response for its t_security_header, which every response of the handler
"! carries - set_config_http_post on every roundtrip after it. The
"! framework asks set_config_http_post once per request and hands the
"! answer to everything that reads it (the CSRF gate, the monitor switch,
"! the draft cleanup, the error response) - but an exit that raised is
"! asked again, and a reader outside an HTTP request asks every time. So
"! neither is promised to run exactly once, and both must be cheap and
"! idempotent - read configuration, do not write state.
"!
"! The one exit interface. Its former name z2ui5_if_exit, with the same two
"! methods and types, was deleted on 2026-11-17: an exit class written against
"! it implements this interface instead.
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
      " It does carry 'wasm-unsafe-eval' in script-src, which lets a script
      " compile WebAssembly and nothing else: the camera scanner of sap.ndc and
      " the BarcodeScanner of the custom controls need it. A tag an exit
      " writes itself keeps it for them.
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
      " the roundtrip monitor (z2ui5_if_ui5_monitor) is called only when this
      " is abap_true - off by default, nothing seeds it. A monitor is code of
      " another package running inside every roundtrip of every app, and a
      " syntax error in it or in anything it uses is the runtime error
      " SYNTAX_ERROR, which no CATCH stops: installing a monitor must not be
      " able to break abap2UI5. An installation switches it on here, once the
      " monitor's package is active and checked:
      "   cs_config-check_monitor_active = abap_true.
      " Read on every roundtrip, so switching it off again takes effect on
      " the next one.
      check_monitor_active       TYPE abap_bool,
      " how many drafts of a chain survive each save, the one just saved
      " included. Seeded with 2 before the exit runs; 0 switches the pruning
      " off and keeps every draft until draft_exp_time_in_hours takes it by
      " age. N > 0 deletes, on
      " every save, the one draft at depth N + 1 of the chain the roundtrips
      " of one app build (z2ui5_if_ui5_draft_store=>prune_chain) - so a
      " polling app keeps N drafts instead of one per tick for hours.
      " Values below 2 are raised to 2: the retry of a lost response
      " continues the draft before the newest one
      " (z2ui5_cl_ui5_srv_draft=>c_min_keep_per_chain), more than 50 are cut
      " to 50. Never deleted: the drafts of the app stack (Back, popups),
      " the draft of an app state link and of a route restore. An app whose
      " app state hash is active (app_state_set_active) is not pruned - its
      " URL names every draft. To keep every draft (the behaviour before
      " 2026-11):
      "   cs_config-draft_keep_per_chain = 0.
      draft_keep_per_chain       TYPE i,
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
