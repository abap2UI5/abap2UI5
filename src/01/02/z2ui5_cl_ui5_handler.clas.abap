CLASS z2ui5_cl_ui5_handler DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_action       TYPE REF TO z2ui5_cl_ui5_action.
    DATA mv_request_json TYPE string.
    DATA ms_request      TYPE z2ui5_if_ui5_types=>ty_s_request.
    DATA ms_response     TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA mv_response     TYPE string.

    METHODS constructor
      IMPORTING
        val TYPE string.

    METHODS main
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_http_res.

    METHODS request_json_to_abap
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_request.

    " The two halves of the FLP hash split (see the method bodies) - public
    " because z2ui5_cl_ui5_client->app_state_get_href needs the shell part;
    " together with Router.splitHash they are the only owners of the rule.
    CLASS-METHODS hash_get_app_part
      IMPORTING
        iv_hash       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    " check_bare_is_shell decides the one ambiguous shape: a hash with
    " neither a leading '/' nor a '&/' separator. Coming from the FLP's
    " HashChanger the shell was already stripped, so the bare form is an app
    " hash and the canonical Router.splitHash answer is 'no shell' - the
    " default. Coming from the RAW browser location (s_front-hash) the bare
    " form is a launchpad intent, i.e. ALL shell - those callers pass
    " abap_true. The caller knows its input's provenance; this parameter is
    " what keeps that knowledge from becoming a second split implementation
    CLASS-METHODS hash_get_shell_part
      IMPORTING
        iv_hash             TYPE string
        check_bare_is_shell TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)       TYPE string.

    " The absolute URL that starts the given app class via ?app_start=,
    " composed from the browser's own location parts. Lives HERE, next to
    " the hash owners, because its one subtle decision is a hash split:
    " the app-owned part (route/app-state) must be dropped - the backend
    " prefers it over app_start, so appending it verbatim would re-open the
    " CURRENT app instead of the requested one - while the launchpad shell
    " part has to survive, or the link lands on the FLP home page.
    " (Moved out of z2ui5_cl_ui5_util_context: it knows app_start and FLP
    " hash anatomy, which is framework vocabulary the generic utility
    " catalog must not carry - see "Utilities" in AGENTS.md.)
    CLASS-METHODS app_get_url
      IMPORTING
        !classname    TYPE clike
        !origin       TYPE clike
        !pathname     TYPE clike
        !search       TYPE clike
        !hash         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    " Everything about the failing roundtrip that only this class knows:
    " the running app, the event that was dispatched, the draft ids and the
    " request origin. Rendered as the outermost entry of the error chain.
    " Must never raise itself - it runs while an exception is being handled.
    METHODS request_context_info
      RETURNING
        VALUE(result) TYPE string.

    METHODS main_begin.

    METHODS main_loop.

    METHODS main_process
      RETURNING
        VALUE(check_go_client) TYPE abap_bool.

    METHODS main_end.

    "! the draft save at the end of main_end - a sticky app saves only when
    "! a route or app-state link carries its draft id
    METHODS main_end_save.

    METHODS response_abap_to_json
      IMPORTING
        val           TYPE z2ui5_if_ui5_types=>ty_s_response
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
    " upper bound for nav_app_call/nav_app_leave hops within a single
    " request - an app that navigates unconditionally in main( ) would
    " otherwise loop the work process forever
    DATA mv_dispatch_limit TYPE i VALUE 1000.

    " automatic model update: the model snapshot taken in main_process BEFORE
    " main( ) ran, compared in main_end. The taken flag exists because the
    " snapshot string cannot distinguish "not taken" from an empty model, and
    " a snapshot is only comparable when it was taken in the SAME dispatch
    " iteration main_end responds for (a nav_app_call/leave hop re-snapshots
    " for the app that then answers).
    DATA mv_model_before       TYPE string.
    DATA mv_model_before_taken TYPE abap_bool.

    "! Reconcile what this request says about the browser with what the draft
    "! already knows - see the method body.
    METHODS session_merge.

    "! Derive the launchpad flag from the request's CURRENT location fields -
    "! called from session_merge, after the draft-stored location was merged
    "! back (pathname/search only travel on app-start-shaped requests).
    METHODS launchpad_derive.

    "! Write one action queue into the response JSON - each framework action
    "! as the real nested array it was built as, each legacy raw-JS snippet
    "! as the string entry the frontend's legacy path keys on.
    METHODS actions_serialize
      IMPORTING
        ajson    TYPE REF TO z2ui5_if_ajson
        path     TYPE string
        t_action TYPE z2ui5_if_ui5_types=>ty_t_queued_action
      RAISING
        z2ui5_cx_ajson_error.

    METHODS request_parse_body
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_request
      RAISING
        z2ui5_cx_ajson_error.

    METHODS slice_to_abap
      IMPORTING
        io_json TYPE REF TO z2ui5_if_ajson
        iv_path TYPE string
      CHANGING
        cs_data TYPE any
      RAISING
        z2ui5_cx_ajson_error.

    METHODS request_parse_event_args
      IMPORTING
        io_front          TYPE REF TO z2ui5_if_ajson
      EXPORTING
        ev_check_override TYPE abap_bool
        et_event_arg      TYPE string_table
      RAISING
        z2ui5_cx_ajson_error.

    METHODS request_app_start
      IMPORTING
        iv_search     TYPE string
        io_comp_data  TYPE REF TO z2ui5_if_ajson
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    METHODS request_app_start_draft
      IMPORTING
        iv_hash       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS request_app_start_route
      IMPORTING
        iv_hash       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS request_app_start_route_draft
      IMPORTING
        iv_hash       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS parse_app_route_rest
      IMPORTING
        iv_hash       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    " the part of iv_val before the first iv_sub, or iv_val when it does not
    " occur - cuts a route token off at the next separator
    METHODS cut_at
      IMPORTING
        iv_val        TYPE string
        iv_sub        TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_handler IMPLEMENTATION.

  METHOD request_json_to_abap.
    TRY.
        result = request_parse_body( val ).

        IF result-s_front-id IS NOT INITIAL.
          RETURN.
        ENDIF.

        " Hash-based app routing (UI5 Router style) takes precedence: once a
        " session runs with routing on, the live hash '#/app/<CLASS>/<DRAFTID>'
        " is the navigation state (browser Back/Forward, bookmark, reload),
        " while the '?app_start=' query is only the initial boot value and would
        " otherwise always win over it. The route's <DRAFTID> segment restores
        " the exact preserved app state; when it is absent or expired the app
        " starts fresh from <CLASS>. Fall back to the query / legacy app-state
        " hash when the hash carries no app route (normal boot / non-routing).
        DATA(lv_route_class) = request_app_start_route( result-s_front-hash ).
        IF lv_route_class IS NOT INITIAL.
          result-s_control-app_start       = lv_route_class.
          result-s_control-app_start_draft = request_app_start_route_draft( result-s_front-hash ).
        ELSE.
          result-s_control-app_start       =
            request_app_start( iv_search    = result-s_front-search
                               io_comp_data = result-s_front-o_comp_data ).
          result-s_control-app_start_draft = request_app_start_draft( result-s_front-hash ).
        ENDIF.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD request_parse_body.
    DATA(lo_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( val ) ).

    " standalone requests arrive wrapped as { "value": <payload> } (see
    " app/webapp/core/Server.js), launchpad/gateway proxies may strip the
    " envelope - a keyed lookup detects it, slicing the whole tree only to
    " unwrap it would walk and copy every node of the request
    DATA(lv_root) = COND string( WHEN lo_ajson->exists( `/value` ) = abap_true
                                 THEN `/value` ).

    " the whole view model is transported back under the MODEL container
    " (symmetric to the response); the frontend ships only the edited delta.
    " The container is not sliced off: slice( ) walks every node of the
    " parsed request (a CP compare per node - the sorted key is no help)
    " and copies the whole subtree, and on a mass edit the model IS most of
    " the request, so the delta was materialized twice. The root tree
    " travels with the path of its MODEL node instead, and the model service
    " reads the attributes below that path (z2ui5_if_ui5_types names the
    " contract). The S_FRONT slice below still walks the tree once
    DATA(lv_model_path) = lv_root && `/MODEL`.
    IF lo_ajson->exists( lv_model_path ) = abap_true.
      result-o_model    = lo_ajson.
      result-model_path = lv_model_path.
    ELSE.
      result-o_model = z2ui5_cl_ajson=>create_empty( ).
    ENDIF.

    lo_ajson = lo_ajson->slice( lv_root && `/S_FRONT` ).
    " valid JSON without an S_FRONT container (health-check POST, rewrapping
    " proxy) - return the empty result so main_begin takes its system-startup
    " branch instead of dumping on the unbound slice below
    IF lo_ajson IS NOT BOUND.
      RETURN.
    ENDIF.

    request_parse_event_args( EXPORTING io_front          = lo_ajson
                              IMPORTING ev_check_override = DATA(lv_check_arg_object)
                                        et_event_arg      = DATA(lt_event_arg) ).

    lo_ajson->to_abap( EXPORTING iv_corresponding = abap_true
                       IMPORTING ev_container     = result-s_front ).

    IF lv_check_arg_object = abap_true.
      result-s_front-t_event_arg = lt_event_arg.
    ENDIF.

    " slice the small CONFIG subtree once - every slice walks the whole
    " node table of its tree, so the per-section slices below only pay
    " for the CONFIG nodes instead of the full S_FRONT tree each time
    DATA(lo_config) = lo_ajson->slice( `/CONFIG` ).
    IF lo_config IS BOUND.

      result-s_front-o_comp_data = lo_config->slice( `/ComponentData` ).

      slice_to_abap( EXPORTING io_json = lo_config
                               iv_path = `/S_DEVICE`
                     CHANGING  cs_data = result-s_front-s_device ).
      slice_to_abap( EXPORTING io_json = lo_config
                               iv_path = `/S_FOCUS`
                     CHANGING  cs_data = result-s_front-s_focus ).
      slice_to_abap( EXPORTING io_json = lo_config
                               iv_path = `/S_SCROLL`
                     CHANGING  cs_data = result-s_front-s_scroll ).

      result-s_front-s_ui5-version         = lo_config->get_string( `/S_UI5/VERSION` ).
      result-s_front-s_ui5-build_timestamp = lo_config->get_string( `/S_UI5/BUILDTIMESTAMP` ).
      result-s_front-s_ui5-gav             = lo_config->get_string( `/S_UI5/GAV` ).
      result-s_front-s_ui5-theme           = lo_config->get_string( `/S_UI5/THEME` ).

    ENDIF.

    " check_launchpad is NOT derived here: pathname/search only travel on
    " app-start-shaped requests - an event roundtrip restores them from the
    " draft, so the flag is computed in session_merge, from the MERGED values
  ENDMETHOD.

  METHOD slice_to_abap.
    " Slice one optional sub-container out of a parsed JSON node and write it
    " into the ABAP target. A missing node leaves the target untouched. Shared
    " by request_parse_body for the S_DEVICE / S_FOCUS / S_SCROLL sub-structures.
    DATA(lo_slice) = io_json->slice( iv_path ).
    IF lo_slice IS BOUND.
      lo_slice->to_abap( EXPORTING iv_corresponding = abap_true
                         IMPORTING ev_container     = cs_data ).
    ENDIF.
  ENDMETHOD.

  METHOD request_parse_event_args.

    " object event arguments arrive as raw JSON - the frontend sends them
    " unserialized so the request body is only encoded once - and to_abap
    " cannot place them in a string table, so they are serialized here and
    " apps keep receiving every argument as a string
    CLEAR: et_event_arg,
           ev_check_override.

    DATA(lv_arg_index) = 1.
    DO.
      DATA(lv_arg_path) = |/T_EVENT_ARG/{ lv_arg_index }|.
      CASE io_front->get_node_type( lv_arg_path ).
        WHEN ``.
          EXIT.
        WHEN z2ui5_if_ajson_types=>node_type-object OR z2ui5_if_ajson_types=>node_type-array.
          ev_check_override = abap_true.
          APPEND io_front->slice( lv_arg_path )->stringify( ) TO et_event_arg.
        WHEN z2ui5_if_ajson_types=>node_type-boolean.
          " same result as the to_abap conversion of a boolean node
          APPEND CONV string( io_front->get_boolean( lv_arg_path ) ) TO et_event_arg.
        WHEN OTHERS.
          APPEND io_front->get_string( lv_arg_path ) TO et_event_arg.
      ENDCASE.
      lv_arg_index = lv_arg_index + 1.
    ENDDO.

    IF ev_check_override = abap_true.
      " to_abap raises on non-scalar members of a string table
      io_front->delete( `/T_EVENT_ARG` ).
    ENDIF.

  ENDMETHOD.

  METHOD request_app_start.
    TRY.
        IF io_comp_data IS BOUND.
          result = z2ui5_cl_ui5_util_context=>c_trim_upper(
              io_comp_data->get( `/startupParameters/app_start/1` ) ).
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    IF result IS NOT INITIAL.
      IF result(1) = `-`.
        REPLACE FIRST OCCURRENCE OF `-` IN result WITH `/`.
        REPLACE FIRST OCCURRENCE OF `-` IN result WITH `/`.
      ENDIF.
      RETURN.
    ENDIF.

    result = z2ui5_cl_ui5_util_context=>c_trim_upper(
        z2ui5_cl_ui5_util_context=>url_param_get( val = `app_start`
                                               url    = iv_search ) ).
    " a namespaced class name carries slashes, and a client that
    " percent-encodes the value (%2Fns%2Fclass) is well within the URL
    " rules; url_param_get leaves values encoded, so the one encoding a
    " class name can carry is unpacked here
    result = replace( val  = result
                      sub  = `%2F`
                      with = `/`
                      occ  = 0 ).
  ENDMETHOD.

  METHOD hash_get_app_part.
    " Reduce a browser hash to the part that belongs to the running app - the
    " "app hash". Inside the SAP Fiori Launchpad the shell owns everything
    " before '&/' ('#<SemanticObject>-<action>&/<app hash>'), standalone the
    " whole hash is the app hash. This mirrors Router.splitHash in the
    " frontend and is the single place the backend knows about the shell hash;
    " without it every launchpad hash looks like "no route" and Back / reload /
    " a bookmark fall back to the '?app_start=' query.
    result = iv_hash.

    IF result IS INITIAL.
      RETURN.
    ENDIF.

    IF result(1) = `#`.
      result = substring( val = result
                          off = 1 ).
      IF result IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    " An app hash starts with '/', a shell hash never does. Checking this
    " first matters: an app hash may itself contain '&/' in a parameter, and
    " splitting on that would truncate it.
    IF result(1) = `/`.
      RETURN.
    ENDIF.

    DATA(lv_off) = find( val = result
                         sub = `&/` ).
    IF lv_off < 0.
      RETURN.
    ENDIF.

    result = substring( val = result
                        off = lv_off + 2 ).
  ENDMETHOD.

  METHOD hash_get_shell_part.
    " The complement of hash_get_app_part: the part of a browser hash the
    " launchpad SHELL owns - everything in front of '&/'
    " ('#<SemanticObject>-<action>&/<app hash>'). Standalone, or when the
    " hash is all app, there is no shell part and the result is empty.
    " Same guard order as above, for the same reason: the leading-'/' check
    " runs BEFORE the '&/' search, because an app hash may itself contain
    " '&/' in a parameter and splitting on that would fabricate a shell part
    " out of an app-owned prefix. Mirrors the shell half of Router.splitHash;
    " z2ui5_cl_ui5_client->app_state_get_href keeps the shell part in the
    " link it composes, so the recipient lands in this app instead of on the
    " launchpad home page.
    DATA(lv_hash) = iv_hash.

    IF lv_hash IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_hash(1) = `#`.
      lv_hash = substring( val = lv_hash
                           off = 1 ).
      IF lv_hash IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_hash(1) = `/`.
      RETURN.
    ENDIF.

    DATA(lv_off) = find( val = lv_hash
                         sub = `&/` ).
    IF lv_off < 0.
      " no separator: an inner hash reads as app (canonical, the default),
      " a raw location hash as a bare launchpad intent - all shell. See the
      " parameter's comment in the class definition
      IF check_bare_is_shell = abap_true.
        result = lv_hash.
      ENDIF.
      RETURN.
    ENDIF.

    result = substring( val = lv_hash
                        len = lv_off ).
  ENDMETHOD.

  METHOD app_get_url.

    DATA(lt_param) = z2ui5_cl_ui5_util_context=>url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start`
                    v = to_lower( classname ) ) INTO TABLE lt_param.

    " only the launchpad shell part of the hash survives into the link; the
    " raw location hash is this caller's input, so a bare intent counts as
    " shell (see hash_get_shell_part's parameter comment)
    DATA(lv_shell) = hash_get_shell_part( iv_hash             = CONV string( hash )
                                          check_bare_is_shell = abap_true ).
    DATA(lv_hash) = COND string( WHEN lv_shell IS NOT INITIAL
                                 THEN |#{ lv_shell }| ).

    result = |{ origin }{ pathname }?| && z2ui5_cl_ui5_util_context=>url_param_create_url( lt_param ) && lv_hash.

  ENDMETHOD.

  METHOD request_app_start_draft.
    TRY.
        DATA(lv_hash) = hash_get_app_part( iv_hash ).
        " strip the leading slashes (see parse_app_route_rest for why they
        " stack); url_param_get matches parameter names verbatim
        SHIFT lv_hash LEFT DELETING LEADING `/`.
        result = z2ui5_cl_ui5_util_context=>c_trim_upper(
            z2ui5_cl_ui5_util_context=>url_param_get( val = `z2ui5-xapp-state`
                                                   url    = lv_hash ) ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD parse_app_route_rest.
    " Shared prologue for request_app_start_route / _route_draft: return the
    " route remainder after 'app/' when the hash carries a real app route, or
    " empty when it does not (normal boot, an app-owned hash, an 'app/'
    " occurring mid-hash). The route must be the START of the APP hash - the
    " launchpad shell hash in front of it is stripped by hash_get_app_part, so
    " '#/app/X' and '#Z2UI5-display&/app/X' resolve identically.
    DATA(lv_hash) = hash_get_app_part( iv_hash ).

    " leading slashes are optional AND may stack: the launchpad convention
    " writes the app hash without one ('&/app/X'), our own routes carry one
    " ('#/app/X'), and URLs written through the UI5 HashChanger before navTo
    " stripped its slash carry two ('#//app/X' - hasher prepends a '/' of its
    " own); those live on in bookmarks and browser history, so strip them all
    SHIFT lv_hash LEFT DELETING LEADING `/`.

    IF strlen( lv_hash ) < 4 OR lv_hash(4) <> `app/`.
      RETURN.
    ENDIF.

    result = substring( val = lv_hash
                        off = 4 ).
  ENDMETHOD.

  METHOD cut_at.
    result = iv_val.
    DATA(lv_off) = find( val = iv_val
                         sub = iv_sub ).
    IF lv_off >= 0.
      result = substring( val = iv_val
                          len = lv_off ).
    ENDIF.
  ENDMETHOD.

  METHOD request_app_start_route.
    " Parse the app class from a hash route '#/app/<CLASS>' (UI5 Router style).
    " Returns empty when the hash carries no app route, so a normal boot or an
    " app that manages its own hash falls through to the '?app_start=' query.
    TRY.
        DATA(lv_rest) = parse_app_route_rest( iv_hash ).
        IF lv_rest IS INITIAL.
          RETURN.
        ENDIF.
        " the class token ends at the next route / query separator
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `/` ).
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `&` ).
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `?` ).
        result = z2ui5_cl_ui5_util_context=>c_trim_upper( lv_rest ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD request_app_start_route_draft.
    " Parse the draft id (app state) from a hash route
    " '#/app/<CLASS>/<DRAFTID>'. Returns empty when the route carries no draft
    " segment (fresh navigation / bookmark without state), so the app starts
    " fresh from <CLASS>.
    TRY.
        DATA(lv_rest) = parse_app_route_rest( iv_hash ).
        IF lv_rest IS INITIAL.
          RETURN.
        ENDIF.
        " cut off a trailing query / fragment, then take the 2nd path segment -
        " the 1st is the class, and a draft id carries no further separator
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `&` ).
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `?` ).
        DATA(lv_off) = find( val = lv_rest
                             sub = `/` ).
        IF lv_off < 0.
          RETURN.
        ENDIF.
        result = z2ui5_cl_ui5_util_context=>c_trim_upper(
            cut_at( iv_val = substring( val = lv_rest
                                        off = lv_off + 1 )
                    iv_sub = `/` ) ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD response_abap_to_json.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                                      ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

        " the action queues are serialized explicitly below - the generic
        " conversion would render each queue row as a { O_JSON, JS } object
        " instead of the bare array/string entry the frontend reads. Only
        " the two scalar fields are taken over - copying the whole struct
        " would copy both queues just to clear them again.
        DATA ls_front LIKE val-s_front.
        ls_front-id  = val-s_front-id.
        ls_front-app = val-s_front-app.

        ajson_result->set( iv_path = `/`
                           iv_val  = ls_front ).
        ajson_result = ajson_result->filter( z2ui5_cl_ui5_util_json_fl=>create_no_empty_values( ) ).

        " AFTER the filter, never before: an action array carries empty
        " strings as positional placeholders, which the no-empty-values
        " filter would silently drop
        actions_serialize( ajson    = ajson_result
                           path     = `/S_ACTION/T_SYSTEM`
                           t_action = val-s_front-s_action-t_system ).
        actions_serialize( ajson    = ajson_result
                           path     = `/S_ACTION/T_CUSTOM`
                           t_action = val-s_front-s_action-t_custom ).

        DATA(lv_frontend) = ajson_result->stringify( ).

        " An unchanged model is not sent at all - the key is left off rather
        " than carrying an empty object. Most round-trips are events that
        " change nothing bound, so this is the common case, and the frontend
        " reads a missing MODEL exactly as it read the empty one.
        result = COND #( WHEN val-model IS INITIAL OR val-model = `{}`
                         THEN |\{"S_FRONT":{ lv_frontend }\}|
                         ELSE |\{"S_FRONT":{ lv_frontend },"MODEL":{ val-model }\}| ).

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    mo_action = NEW z2ui5_cl_ui5_action( me ).

  ENDMETHOD.

  METHOD main.

    " The exception itself only says WHAT went wrong. Which app, which event
    " and which draft it went wrong in is known here and nowhere above, so
    " annotate it on the way out - the top-level catch in
    " z2ui5_cl_ui5_http_handler=>_main renders the whole chain, this frame
    " included, into the 500 body.
    TRY.
        main_begin( ).
        main_loop( ).
      CATCH cx_root INTO DATA(x).
        DATA lv_context TYPE string.
        " belt and braces: an annotation that fails must not replace the
        " error it was meant to describe
        TRY.
            lv_context = request_context_info( ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = lv_context
            previous = x.
    ENDTRY.

    result = VALUE #( body          = mv_response
                      s_stateful    = mo_action->ms_next-s_stateful
                      status_code   = 200
                      status_reason = `success` ).

    " the handler may be sticky and answer the next request too - nothing of
    " this roundtrip's queues and intents may leak into it
    CLEAR mo_action->ms_next.

  ENDMETHOD.

  METHOD request_context_info.

    DATA lv_app   TYPE string.
    DATA lv_event TYPE string.
    DATA lv_draft TYPE string.

    " The request may have died before any of this existed - a bad JSON body
    " leaves the action without an app, an unknown app class leaves the app
    " without an instance. Check every reference before following it: a
    " missing detail must shorten the context line, never replace the
    " original error with a follow-up dump. Nested IFs, not a chained AND -
    " the guard must hold on every target the sources are compiled for.
    IF mo_action IS BOUND.
      lv_event = mo_action->ms_actual-event.

      IF mo_action->mo_app IS BOUND.
        lv_draft = mo_action->mo_app->ms_draft-id_prev.

        IF mo_action->mo_app->mo_app IS BOUND.
          lv_app = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).
        ENDIF.
      ENDIF.
    ENDIF.

    " the url comes from the client - cap it so a crafted request cannot pad
    " the error body with kilobytes of noise
    DATA(lv_url) = ms_request-s_front-pathname && ms_request-s_front-search.
    IF strlen( lv_url ) > 300.
      lv_url = substring( val = lv_url
                          len = 300 ) && `...`.
    ENDIF.

    " app_start is client-controlled and is reflected into the error body:
    " the same class-name-safe strip as z2ui5_cl_ui5_action=>factory_first_start
    " applies, so a crafted value cannot smuggle markup into the response
    DATA(lv_app_start) = ms_request-s_control-app_start.
    REPLACE ALL OCCURRENCES OF REGEX `[^A-Za-z0-9_/]` IN lv_app_start WITH `` ##REGEX_POSIX.

    result = |Request failed| &&
             COND #( WHEN lv_app   IS NOT INITIAL THEN | in app { lv_app }| ) &&
             COND #( WHEN lv_event IS NOT INITIAL THEN |, event { lv_event }|
                     ELSE |, no event (initial rendering)| ) &&
             COND #( WHEN lv_draft IS NOT INITIAL THEN |, draft { lv_draft }| ) &&
             COND #( WHEN lv_app_start IS NOT INITIAL
                     THEN |, app_start { lv_app_start }| ) &&
             COND #( WHEN lv_url IS NOT INITIAL THEN |, url { lv_url }| ).

  ENDMETHOD.

  METHOD main_loop.

    DATA(lv_dispatch_count) = 0.

    DO.
      IF main_process( ).
        RETURN.
      ENDIF.
      lv_dispatch_count = lv_dispatch_count + 1.
      IF lv_dispatch_count >= mv_dispatch_limit.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = |Dispatch limit of { mv_dispatch_limit } app navigations in one request reached - check for an endless nav_app_call/nav_app_leave loop in main( )|.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD main_begin.

    " Reset the static app-load buffer at the start of every request. It is a
    " per-request read cache (repeated db_load of the same draft id within one
    " roundtrip), keyed by draft id. In stateless ICF the class-data resets on
    " its own, but in a stateful/long-lived work process it would otherwise
    " accumulate one dead entry per roundtrip (each roundtrip mints a new draft
    " id, so earlier entries are never read again). Clearing here keeps the
    " intra-request cache while preventing cross-request growth.
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    ms_request = request_json_to_abap( mv_request_json ).

    IF ms_request-s_front-id IS NOT INITIAL.
      mo_action = mo_action->factory_by_frontend( ).

    ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
      NEW z2ui5_cl_ui5_srv_draft( )->cleanup( ).
      mo_action = mo_action->factory_first_start( ).

    ELSE.
      mo_action = mo_action->factory_system_startup( ).
    ENDIF.

    session_merge( ).

  ENDMETHOD.

  METHOD launchpad_derive.

    ms_request-s_control-check_launchpad = xsdbool(
        ms_request-s_front-search CS `scenario=LAUNCHPAD`
        OR ms_request-s_front-pathname CS `/ui2/flp`
        OR ms_request-s_front-pathname CS `test/flpSandbox` ).

  ENDMETHOD.

  METHOD session_merge.

    IF mo_action->mo_app IS NOT BOUND.
      launchpad_derive( ).
      RETURN.
    ENDIF.

    " The page location (origin, pathname, query) is session-constant too,
    " but travels on its own cadence: with every app-start-shaped request
    " (no draft id - the backend parses ?app_start= from SEARCH there) and
    " on the first roundtrip of a page load. Event roundtrips omit it and
    " are answered from the draft. The hash is NOT part of this: it carries
    " the live routing state and stays a per-request field.
    IF ms_request-s_front-origin IS NOT INITIAL.
      mo_action->mo_app->ms_session-origin   = ms_request-s_front-origin.
      mo_action->mo_app->ms_session-pathname = ms_request-s_front-pathname.
      mo_action->mo_app->ms_session-search   = ms_request-s_front-search.
    ELSE.
      ms_request-s_front-origin   = mo_action->mo_app->ms_session-origin.
      ms_request-s_front-pathname = mo_action->mo_app->ms_session-pathname.
      ms_request-s_front-search   = mo_action->mo_app->ms_session-search.
    ENDIF.

    " the launchpad flag comes from the MERGED location - the raw request
    " carries pathname/search only on app-start-shaped requests, and a flag
    " frozen from the raw fields would read abap_false on every event
    " roundtrip inside the FLP
    launchpad_derive( ).

    " A request that CARRIES the block wins: that is the first roundtrip of a
    " page load, and it is also how a draft reopened on a different device
    " gets the new device's data instead of the one that created the draft.
    " Every later roundtrip omits it and is answered from the draft.
    IF ms_request-s_front-s_device-system IS NOT INITIAL
        OR ms_request-s_front-s_ui5-version IS NOT INITIAL.

      " keep the location trio: the block above has already merged it into
      " the request (stored or restored), and the first roundtrip of a page
      " load carries BOTH blocks - rebuilding without it would wipe what was
      " just stored
      " ... and keep the nav_mode_sent latch: block-carrying requests are
      " app-start-shaped today (main_end re-sends the mode anyway), but a
      " wiped latch would cost a redundant ROUTER/sync if that ever changes.
      " comp_data is kept for the same reason as the location trio: the
      " launchpad ComponentData travels on its own session cadence, so a
      " block-carrying request WITHOUT it must not wipe what the draft
      " stored - the IF below only overwrites when the request carries one
      mo_action->mo_app->ms_session = VALUE #( s_ui5         = ms_request-s_front-s_ui5
                                               s_device      = ms_request-s_front-s_device
                                               origin        = ms_request-s_front-origin
                                               pathname      = ms_request-s_front-pathname
                                               search        = ms_request-s_front-search
                                               comp_data     = mo_action->mo_app->ms_session-comp_data
                                               nav_mode_sent = mo_action->mo_app->ms_session-nav_mode_sent ).
      IF ms_request-s_front-o_comp_data IS BOUND.
        TRY.
            mo_action->mo_app->ms_session-comp_data = ms_request-s_front-o_comp_data->stringify( ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
      RETURN.
    ENDIF.

    " Answer this roundtrip from the draft - but let the two device fields
    " that are NOT session-constant win from the request WHEN IT CARRIES
    " them: the window can be resized and a phone rotated while the app
    " runs. The frontend only sends them when they changed since the last
    " send (core/Session.js), so an absent field means "unchanged" - the
    " stored value stays, it is never wiped.
    DATA(ls_device) = mo_action->mo_app->ms_session-s_device.
    IF ms_request-s_front-s_device-orientation IS NOT INITIAL.
      ls_device-orientation = ms_request-s_front-s_device-orientation.
    ENDIF.
    IF ms_request-s_front-s_device-resize-width > 0.
      ls_device-resize = ms_request-s_front-s_device-resize.
    ENDIF.

    " a value that DID arrive is stored back with the draft: the frontend
    " will not repeat it while it stays unchanged, so the merged record is
    " the only place that remembers the rotation/resize
    mo_action->mo_app->ms_session-s_device = ls_device.

    ms_request-s_front-s_device = ls_device.
    ms_request-s_front-s_ui5    = mo_action->mo_app->ms_session-s_ui5.

    " the stored launchpad ComponentData is NOT parsed back into
    " o_comp_data here: its only reader after the merge is
    " z2ui5_cl_ui5_client=>get( ), which parses the session string itself
    " when it needs it - every event roundtrip of an FLP session used to
    " parse a tree nobody looked at (z2ui5_if_ui5_types names the contract)

  ENDMETHOD.

  METHOD actions_serialize.

    IF t_action IS INITIAL.
      RETURN.
    ENDIF.

    ajson->touch_array( path ).
    LOOP AT t_action REFERENCE INTO DATA(lr_action).
      IF lr_action->o_json IS BOUND.
        ajson->push( iv_path = path
                     iv_val  = lr_action->o_json ).
      ELSE.
        ajson->push( iv_path = path
                     iv_val  = lr_action->js ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_end.

    " Hash routing is configured once and then belongs to the app, not to the
    " session: re-send the app's own mode whenever this roundtrip did not set
    " one itself, so an app that queued cs_event-set_nav_routing in check_on_init
    " stays routed in its chosen mode - even after the user visited another
    " app that runs with a different one (see z2ui5_cl_ui5_app_cont->mv_nav_mode).
    " NOT on every roundtrip though: the frontend keeps the mode in session
    " state, so a plain event roundtrip of the SAME app repeats no mode (it
    " would re-queue the ROUTER action for a constant). It has to travel
    " again whenever the frontend may not hold it: an app-start-shaped
    " request (page load, Back/Forward route restore), a navigation hop
    " (check_on_navigated - the previous app may have run another mode), or
    " a mode that differs from what this app last sent.
    IF mo_action->ms_next-s_nav-set_nav_routing IS INITIAL
        AND ( ms_request-s_front-id IS INITIAL
           OR mo_action->ms_actual-check_on_navigated = abap_true
           OR mo_action->mo_app->mv_nav_mode <> mo_action->mo_app->ms_session-nav_mode_sent ).
      mo_action->ms_next-s_nav-set_nav_routing = mo_action->mo_app->mv_nav_mode.
    ENDIF.

    " An app WITHOUT a mode of its own must still turn routing OFF after a
    " navigation hop: its initial mv_nav_mode travels as empty = "no change",
    " so the PREVIOUS app's KEEP/FRESH stayed live and every response here
    " kept writing '#/app/<CLASS>/<DRAFT>' for an app that never opted in
    " (seen live: the samples overview kept its draft route after
    " nav_app_leave from a routed sample). The mode follows the app - like a
    " manifest - so the hop says DEFAULT explicitly; a called app that
    " should keep routing INHERITS the caller's mode before this runs (see
    " z2ui5_cl_ui5_action), and a fresh page load needs nothing because the
    " frontend state starts clean (AppState.reset on component init).
    " Only a HOP says so - a request that carries a draft id. A fresh start
    " (no id: a reload, or Back/Forward under FRESH routing re-creating an
    " app that only INHERITED its mode) sets check_on_navigated as well, and
    " an explicit DEFAULT there switched routing off for the rest of the
    " session: the next event wiped '#/app/<CLASS>' and Back/Forward stopped
    " navigating between the apps. The frontend already is in the mode that
    " produced the route, so a fresh start leaves it alone.
    IF mo_action->ms_next-s_nav-set_nav_routing IS INITIAL
        AND mo_action->mo_app->mv_nav_mode IS INITIAL
        AND mo_action->ms_actual-check_on_navigated = abap_true
        AND ms_request-s_front-id IS NOT INITIAL.
      mo_action->ms_next-s_nav-set_nav_routing = z2ui5_if_client=>cs_nav_mode-default.
    ENDIF.

    IF mo_action->ms_next-s_nav-set_nav_routing IS NOT INITIAL.
      mo_action->mo_app->ms_session-nav_mode_sent = mo_action->ms_next-s_nav-set_nav_routing.
    ENDIF.

    " The app-state hash is the same kind of intent as the routing mode, and
    " needs the same treatment: the frontend syncs the URL on EVERY response
    " (View1 -> Router.sync), and Router reads a missing setAppStateActive as
    " "clear the hash". So a flag that lives only on ms_next - which is
    " per-request - held for exactly one response: opening a bookmarked
    " z2ui5-xapp-state URL restored the draft, and the next event dropped the
    " hash again. Re-assert what the app asked for unless this roundtrip
    " already said something itself.
    IF mo_action->ms_next-s_nav-set_app_state_active = abap_false
        AND mo_action->mo_app->mv_app_state_active = abap_true.
      mo_action->ms_next-s_nav-set_app_state_active = abap_true.
    ENDIF.

    DATA(lo_front) = NEW z2ui5_cl_ui5_frontend( mo_action ).

    " the view-lifecycle calls leave first, in slot order
    lo_front->slots_serialize( ).

    " The model of this roundtrip. A slot that shipped new XML always needs
    " the model with it - all five slots, the nested ones included. Derived
    " from the collected view-lifecycle calls themselves: a display that was
    " later voided by a destroy (slot_reset) counts as no view.
    DATA(lv_model) = `{}`.
    DATA(lv_check_display) = xsdbool( line_exists( mo_action->ms_next-t_action_front[
                                          method = z2ui5_if_ui5_types=>cs_slot_action-display ] ) ). "#EC CI_SORTSEQ
    IF lv_check_display = abap_true.
      lv_model = mo_action->mo_app->model_json_stringify( ).
    ELSEIF mv_model_before_taken = abap_true.
      " automatic model update: main( ) neither displayed nor asked for a
      " push - send the model only when main( ) itself changed it, exactly as
      " an explicit view_model_update( ) would; an unchanged model still
      " responds `{}` as before
      DATA(lv_model_now) = mo_action->mo_app->model_json_stringify( ).
      IF lv_model_now <> mv_model_before.
        lv_model = lv_model_now.
      ENDIF.
    ENDIF.
    " No updateModel action travels with it: a MODEL key in the response IS
    " the push - the frontend pushes into every open model-owning slot after
    " the system actions ran (View1). That covers the nested re-display
    " (inherits the MAIN model by propagation - three-column samples) and a
    " popup left open across a roundtrip that rebuilt no view alike, without
    " spelling a derivable instruction into every model-carrying response.

    " Remember what this response leaves the client holding: a display or a
    " push leaves it on lv_model (a display whose model is `{}` leaves the
    " fresh view's model empty, which `{}` says too), no push leaves it on
    " the before-state. The next roundtrip of this app reads it back as its
    " pre-main( ) snapshot (main_process) instead of serializing the model
    " a second time.
    IF lv_check_display = abap_true OR lv_model <> `{}`.
      mo_action->mo_app->mv_model_client = lv_model.
    ELSEIF mv_model_before_taken = abap_true.
      mo_action->mo_app->mv_model_client = mv_model_before.
    ELSE.
      CLEAR mo_action->mo_app->mv_model_client.
    ENDIF.

    " last of all, so the route reflects everything this roundtrip did - the
    " slots that were built and the model that was pushed into them. Queued
    " only when the roundtrip carries nav intent; the frontend syncs the URL
    " once per response either way (View1 injects the response id).
    lo_front->nav_serialize( ).

    ms_response = VALUE #( s_front-s_action = mo_action->ms_next-s_action
                           s_front-id       = mo_action->mo_app->ms_draft-id
                           s_front-app      = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app )
                           model            = lv_model ).

    mv_response = response_abap_to_json( ms_response ).

    main_end_save( ).

  ENDMETHOD.

  METHOD main_end_save.

    IF mo_action->mo_app->mv_check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ELSEIF mo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep
        OR mo_action->mo_app->mv_app_state_active = abap_true.
      " a sticky app whose route (KEEP) or app-state link carries this
      " draft id: the id is written into the URL and into copied links
      " either way, and without a saved draft every Back/Forward, reload or
      " shared link landed in factory_first_start's CATCH - "bookmarked app
      " state expired" and a fresh app. The draft is saved for exactly
      " these two modes; a sticky app that asked for neither keeps skipping
      " the serialization
      mo_action->mo_app->db_save( ).
    ELSE.
      " a sticky session skips the draft save, but the lifecycle latch must
      " not be skipped with it - db_save is otherwise the only place that
      " sets it, and without it every event roundtrip of a sticky app reads
      " check_on_init( ) = true and re-runs its init block
      mo_action->mo_app->mv_check_initialized = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD main_process.

    DATA(li_client) = CAST z2ui5_if_client( NEW z2ui5_cl_ui5_client( mo_action ) ).
    DATA(li_app)    = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

    " automatic model update: snapshot the model AFTER the incoming client
    " deltas were applied (factory_by_frontend) and BEFORE main( ) runs -
    " what the client already knows must never trigger a push. Taken per
    " dispatch iteration, so after a nav_app_call/leave the snapshot belongs
    " to the app main_end responds for. The app's mv_model_client IS that
    " snapshot whenever it is known: main_end wrote it as exactly what the
    " client was left holding, and factory_by_frontend cleared it when this
    " request's deltas touched the state it describes - so the full model
    " serialization only runs when no stored string can stand in for it.
    "
    " Yes, on a delta roundtrip this is the FIRST of up to two full
    " serializations (main_end runs the second one to compare or to render a
    " display) - and that is the cheaper side of a real trade-off, not an
    " oversight. The snapshot cannot move behind main( ) (it has to be the
    " pre-main state, and whether main( ) will display is unknowable here),
    " and every variant that drops it - keeping the stale stored string, or
    " pushing unconditionally when none exists - turns the saved CPU pass
    " into a FULL-MODEL PUSH on every edit roundtrip whose main( ) changed
    " nothing bound, which is exactly the transfer the compare in main_end
    " exists to suppress. Serializing twice beats shipping the model once.
    IF mo_action->mo_app->mv_model_client IS NOT INITIAL.
      mv_model_before = mo_action->mo_app->mv_model_client.
    ELSE.
      mv_model_before = mo_action->mo_app->model_json_stringify( ).
    ENDIF.
    mv_model_before_taken = abap_true.

    IF mo_action->mo_app->mv_check_sticky = abap_false.
      z2ui5_cl_ui5_util_context=>db_rollback( ).
    ENDIF.

    " exceptions from main( ) are intentionally not caught here - they bubble up
    " to the single top-level catch in z2ui5_cl_ui5_http_handler=>_main( ), which
    " turns them into a 500 response carrying the exception text
    IF mo_action->ms_actual-event = z2ui5_if_ui5_types=>cs_event_nav_app_leave.
      " no popup/popover teardown is queued here: the standalone slots die on
      " every app switch anyway - implicitly on the frontend whenever the
      " response names another app (View1), and through prepare_app_stack for
      " the one hop the frontend cannot see, to another instance of the SAME
      " class. Queuing it here on top only made the back-navigation response
      " carry two destroy actions the frontend had already done itself
      li_client->nav_app_leave( ).
    ELSE.
      li_app->main( li_client ).
    ENDIF.

    IF mo_action->mo_app->mv_check_sticky = abap_false.
      z2ui5_cl_ui5_util_context=>db_rollback( ).
    ENDIF.

    " a ROOT app leaving without a target: nav_app_leave( ) resolves the
    " target through get_app( id_prev_app_stack ), and with nothing on the
    " stack get_app( ) answers the CURRENT app - so the leave went to itself:
    " a second container chained to its own draft (id_prev = its own id),
    " main( ) run once more with check_on_navigated and no event, the draft
    " parsed and saved twice. A leave with nowhere to go is the end of the
    " roundtrip instead; check_app_prev_stack( ) is the question an app with
    " a back button asks first. The intent stays recorded on ms_next (the
    " shipped src/99 popups assert on it), only the hop is not taken
    IF mo_action->ms_next-o_app_leave IS NOT INITIAL
        AND mo_action->ms_next-o_app_leave = mo_action->mo_app->mo_app
        AND mo_action->mo_app->ms_draft-id_prev_app_stack IS INITIAL.
      CLEAR mo_action->ms_next-o_app_leave.
    ENDIF.

    IF mo_action->ms_next-o_app_leave IS NOT INITIAL.
      mo_action = mo_action->factory_stack_leave( ).

    ELSEIF mo_action->ms_next-o_app_call IS NOT INITIAL.
      mo_action = mo_action->factory_stack_call( ).

    ELSE.
      main_end( ).
      check_go_client = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
