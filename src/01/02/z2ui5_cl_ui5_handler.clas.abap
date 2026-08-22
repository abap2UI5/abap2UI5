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

    METHODS hash_get_app_part
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
        DATA lv_route_class TYPE string.
        DATA x TYPE REF TO cx_root.
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

        lv_route_class = request_app_start_route( result-s_front-hash ).
        IF lv_route_class IS NOT INITIAL.
          result-s_control-app_start       = lv_route_class.
          result-s_control-app_start_draft = request_app_start_route_draft( result-s_front-hash ).
        ELSE.
          result-s_control-app_start       =
            request_app_start( iv_search    = result-s_front-search
                               io_comp_data = result-s_front-o_comp_data ).
          result-s_control-app_start_draft = request_app_start_draft( result-s_front-hash ).
        ENDIF.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD request_parse_body.
    DATA temp31 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp31.
    DATA temp32 TYPE string.
    DATA lv_root LIKE temp32.
    DATA lv_check_arg_object TYPE abap_bool.
    DATA lt_event_arg TYPE string_table.
    DATA lo_config TYPE REF TO z2ui5_if_ajson.
    temp31 ?= z2ui5_cl_ajson=>parse( val ).

    lo_ajson = temp31.

    " standalone requests arrive wrapped as { "value": <payload> } (see
    " app/webapp/core/Server.js), launchpad/gateway proxies may strip the
    " envelope - a keyed lookup detects it, slicing the whole tree only to
    " unwrap it would walk and copy every node of the request

    IF lo_ajson->exists( `/value` ) = abap_true.
      temp32 = `/value`.
    ELSE.
      CLEAR temp32.
    ENDIF.

    lv_root = temp32.

    " the whole view model is transported back under the MODEL container
    " (symmetric to the response); the frontend ships only the edited delta
    result-o_model = lo_ajson->slice( lv_root && `/MODEL` ).
    IF result-o_model IS NOT BOUND.
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
                              IMPORTING ev_check_override = lv_check_arg_object
                                        et_event_arg      = lt_event_arg ).

    lo_ajson->to_abap( EXPORTING iv_corresponding = abap_true
                       IMPORTING ev_container     = result-s_front ).

    IF lv_check_arg_object = abap_true.
      result-s_front-t_event_arg = lt_event_arg.
    ENDIF.

    " slice the small CONFIG subtree once - every slice walks the whole
    " node table of its tree, so the per-section slices below only pay
    " for the CONFIG nodes instead of the full S_FRONT tree each time

    lo_config = lo_ajson->slice( `/CONFIG` ).
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
    DATA lo_slice TYPE REF TO z2ui5_if_ajson.
    lo_slice = io_json->slice( iv_path ).
    IF lo_slice IS BOUND.
      lo_slice->to_abap( EXPORTING iv_corresponding = abap_true
                         IMPORTING ev_container     = cs_data ).
    ENDIF.
  ENDMETHOD.

  METHOD request_parse_event_args.
    DATA lv_arg_index TYPE i.
      DATA lv_arg_path TYPE string.
          DATA temp33 TYPE string.

    " object event arguments arrive as raw JSON - the frontend sends them
    " unserialized so the request body is only encoded once - and to_abap
    " cannot place them in a string table, so they are serialized here and
    " apps keep receiving every argument as a string
    CLEAR: et_event_arg,
           ev_check_override.


    lv_arg_index = 1.
    DO.

      lv_arg_path = |/T_EVENT_ARG/{ lv_arg_index }|.
      CASE io_front->get_node_type( lv_arg_path ).
        WHEN ``.
          EXIT.
        WHEN z2ui5_if_ajson_types=>node_type-object OR z2ui5_if_ajson_types=>node_type-array.
          ev_check_override = abap_true.
          APPEND io_front->slice( lv_arg_path )->stringify( ) TO et_event_arg.
        WHEN z2ui5_if_ajson_types=>node_type-boolean.
          " same result as the to_abap conversion of a boolean node

          temp33 = io_front->get_boolean( lv_arg_path ).
          APPEND temp33 TO et_event_arg.
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
  ENDMETHOD.

  METHOD hash_get_app_part.
    DATA lv_off TYPE i.
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


    lv_off = find( val = result
                         sub = `&/` ).
    IF lv_off < 0.
      RETURN.
    ENDIF.

    result = substring( val = result
                        off = lv_off + 2 ).
  ENDMETHOD.

  METHOD request_app_start_draft.
        DATA lv_hash TYPE string.
    TRY.

        lv_hash = hash_get_app_part( iv_hash ).
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
    DATA lv_hash TYPE string.
    lv_hash = hash_get_app_part( iv_hash ).

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
    DATA lv_off TYPE i.
    result = iv_val.

    lv_off = find( val = iv_val
                         sub = iv_sub ).
    IF lv_off >= 0.
      result = substring( val = iv_val
                          len = lv_off ).
    ENDIF.
  ENDMETHOD.

  METHOD request_app_start_route.
        DATA lv_rest TYPE string.
    " Parse the app class from a hash route '#/app/<CLASS>' (UI5 Router style).
    " Returns empty when the hash carries no app route, so a normal boot or an
    " app that manages its own hash falls through to the '?app_start=' query.
    TRY.

        lv_rest = parse_app_route_rest( iv_hash ).
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
        DATA lv_rest TYPE string.
        DATA lv_off TYPE i.
    " Parse the draft id (app state) from a hash route
    " '#/app/<CLASS>/<DRAFTID>'. Returns empty when the route carries no draft
    " segment (fresh navigation / bookmark without state), so the app starts
    " fresh from <CLASS>.
    TRY.

        lv_rest = parse_app_route_rest( iv_hash ).
        IF lv_rest IS INITIAL.
          RETURN.
        ENDIF.
        " cut off a trailing query / fragment, then take the 2nd path segment -
        " the 1st is the class, and a draft id carries no further separator
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `&` ).
        lv_rest = cut_at( iv_val = lv_rest
                          iv_sub = `?` ).

        lv_off = find( val = lv_rest
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
        DATA temp34 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp34.
        DATA ls_front LIKE val-s_front.
        DATA lv_frontend TYPE string.
        DATA temp35 TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.


        temp34 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).

        ajson_result = temp34.

        " the action queues are serialized explicitly below - the generic
        " conversion would render each queue row as a { O_JSON, JS } object
        " instead of the bare array/string entry the frontend reads. Only
        " the two scalar fields are taken over - copying the whole struct
        " would copy both queues just to clear them again.

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


        lv_frontend = ajson_result->stringify( ).

        " An unchanged model is not sent at all - the key is left off rather
        " than carrying an empty object. Most round-trips are events that
        " change nothing bound, so this is the common case, and the frontend
        " reads a missing MODEL exactly as it read the empty one.

        IF val-model IS INITIAL OR val-model = `{}`.
          temp35 = |\{"S_FRONT":{ lv_frontend }\}|.
        ELSE.
          temp35 = |\{"S_FRONT":{ lv_frontend },"MODEL":{ val-model }\}|.
        ENDIF.
        result = temp35.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    CREATE OBJECT mo_action TYPE z2ui5_cl_ui5_action EXPORTING VAL = me.

  ENDMETHOD.

  METHOD main.
        DATA x TYPE REF TO cx_root.
        DATA lv_context TYPE string.

    " The exception itself only says WHAT went wrong. Which app, which event
    " and which draft it went wrong in is known here and nowhere above, so
    " annotate it on the way out - the top-level catch in
    " z2ui5_cl_ui5_http_handler=>_main renders the whole chain, this frame
    " included, into the 500 body.
    TRY.
        main_begin( ).
        main_loop( ).

      CATCH cx_root INTO x.

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

    CLEAR result.
    result-body = mv_response.
    result-s_stateful = mo_action->ms_next-s_stateful.
    result-status_code = 200.
    result-status_reason = `success`.

    " the handler may be sticky and answer the next request too - nothing of
    " this roundtrip's queues and intents may leak into it
    CLEAR mo_action->ms_next.

  ENDMETHOD.

  METHOD request_context_info.

    DATA lv_app   TYPE string.
    DATA lv_event TYPE string.
    DATA lv_draft TYPE string.
    DATA lv_url TYPE string.
    DATA temp36 TYPE string.
    DATA temp1 TYPE string.
    DATA temp2 TYPE string.
    DATA temp3 TYPE string.
    DATA temp22 TYPE string.

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

    lv_url = ms_request-s_front-pathname && ms_request-s_front-search.
    IF strlen( lv_url ) > 300.
      lv_url = substring( val = lv_url
                          len = 300 ) && `...`.
    ENDIF.


    IF lv_app IS NOT INITIAL.
      temp36 = | in app { lv_app }|.
    ELSE.
      CLEAR temp36.
    ENDIF.

    IF lv_event IS NOT INITIAL.
      temp1 = |, event { lv_event }|.
    ELSE.
      temp1 = |, no event (initial rendering)|.
    ENDIF.

    IF lv_draft IS NOT INITIAL.
      temp2 = |, draft { lv_draft }|.
    ELSE.
      CLEAR temp2.
    ENDIF.

    IF ms_request-s_control-app_start IS NOT INITIAL.
      temp3 = |, app_start { ms_request-s_control-app_start }|.
    ELSE.
      CLEAR temp3.
    ENDIF.

    IF lv_url IS NOT INITIAL.
      temp22 = |, url { lv_url }|.
    ELSE.
      CLEAR temp22.
    ENDIF.
    result = |Request failed| &&
             temp36 &&
             temp1 &&
             temp2 &&
             temp3 &&
             temp22.

  ENDMETHOD.

  METHOD main_loop.

    DATA lv_dispatch_count TYPE i.
    lv_dispatch_count = 0.

    DO.
      IF main_process( ) IS NOT INITIAL.
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
      DATA temp37 TYPE REF TO z2ui5_cl_ui5_srv_draft.

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

      CREATE OBJECT temp37 TYPE z2ui5_cl_ui5_srv_draft.
      temp37->cleanup( ).
      mo_action = mo_action->factory_first_start( ).

    ELSE.
      mo_action = mo_action->factory_system_startup( ).
    ENDIF.

    session_merge( ).

  ENDMETHOD.

  METHOD launchpad_derive.

    DATA temp1 TYPE xsdboolean.
    temp1 = boolc( ms_request-s_front-search CS `scenario=LAUNCHPAD` OR ms_request-s_front-pathname CS `/ui2/flp` OR ms_request-s_front-pathname CS `test/flpSandbox` ).
    ms_request-s_control-check_launchpad = temp1.

  ENDMETHOD.

  METHOD session_merge.
    DATA ls_device LIKE mo_action->mo_app->ms_session-s_device.

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
      " wiped latch would cost a redundant ROUTER/sync if that ever changes
      CLEAR mo_action->mo_app->ms_session.
      mo_action->mo_app->ms_session-s_ui5 = ms_request-s_front-s_ui5.
      mo_action->mo_app->ms_session-s_device = ms_request-s_front-s_device.
      mo_action->mo_app->ms_session-origin = ms_request-s_front-origin.
      mo_action->mo_app->ms_session-pathname = ms_request-s_front-pathname.
      mo_action->mo_app->ms_session-search = ms_request-s_front-search.
      mo_action->mo_app->ms_session-nav_mode_sent = mo_action->mo_app->ms_session-nav_mode_sent.
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

    ls_device = mo_action->mo_app->ms_session-s_device.
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

    IF mo_action->mo_app->ms_session-comp_data IS NOT INITIAL.
      TRY.
          ms_request-s_front-o_comp_data = z2ui5_cl_ajson=>parse( mo_action->mo_app->ms_session-comp_data ).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD actions_serialize.
    DATA temp38 LIKE LINE OF t_action.
    DATA lr_action LIKE REF TO temp38.

    IF t_action IS INITIAL.
      RETURN.
    ENDIF.

    ajson->touch_array( path ).


    LOOP AT t_action REFERENCE INTO lr_action.
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
    DATA lo_front TYPE REF TO z2ui5_cl_ui5_frontend.
    DATA lv_model TYPE string.
    DATA temp39 LIKE sy-subrc.
      DATA lv_model_now TYPE string.

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
    IF mo_action->ms_next-s_nav-set_nav_routing IS NOT INITIAL.
      mo_action->mo_app->ms_session-nav_mode_sent = mo_action->ms_next-s_nav-set_nav_routing.
    ENDIF.


    CREATE OBJECT lo_front TYPE z2ui5_cl_ui5_frontend EXPORTING ACTION = mo_action.

    " the view-lifecycle calls leave first, in slot order
    lo_front->slots_serialize( ).

    " The model of this roundtrip. A slot that shipped new XML always needs
    " the model with it - all five slots, the nested ones included. Derived
    " from the collected view-lifecycle calls themselves: a display that was
    " later voided by a destroy (slot_reset) counts as no view.

    lv_model = `{}`.

    READ TABLE mo_action->ms_next-t_action_front WITH KEY method = z2ui5_if_ui5_types=>cs_slot_action-display TRANSPORTING NO FIELDS.
    temp39 = sy-subrc.
    IF temp39 = 0.
      lv_model = mo_action->mo_app->model_json_stringify( ).
    ELSEIF mv_model_before_taken = abap_true.
      " automatic model update: main( ) neither displayed nor asked for a
      " push - send the model only when main( ) itself changed it, exactly as
      " an explicit view_model_update( ) would; an unchanged model still
      " responds `{}` as before

      lv_model_now = mo_action->mo_app->model_json_stringify( ).
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

    " last of all, so the route reflects everything this roundtrip did - the
    " slots that were built and the model that was pushed into them. Queued
    " only when the roundtrip carries nav intent; the frontend syncs the URL
    " once per response either way (View1 injects the response id).
    lo_front->nav_serialize( ).

    CLEAR ms_response.
    ms_response-s_front-s_action = mo_action->ms_next-s_action.
    ms_response-s_front-id = mo_action->mo_app->ms_draft-id.
    ms_response-s_front-app = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).
    ms_response-model = lv_model.

    mv_response = response_abap_to_json( ms_response ).

    IF mo_action->mo_app->mv_check_sticky = abap_false.
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

    DATA temp40 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp40.
    DATA temp41 TYPE REF TO z2ui5_if_app.
    DATA li_app LIKE temp41.
    CREATE OBJECT temp40 TYPE z2ui5_cl_ui5_client EXPORTING ACTION = mo_action.

    li_client = temp40.

    temp41 ?= mo_action->mo_app->mo_app.

    li_app = temp41.

    " automatic model update: snapshot the model AFTER the incoming client
    " deltas were applied (factory_by_frontend) and BEFORE main( ) runs -
    " what the client already knows must never trigger a push. Taken per
    " dispatch iteration, so after a nav_app_call/leave the snapshot belongs
    " to the app main_end responds for.
    mv_model_before       = mo_action->mo_app->model_json_stringify( ).
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
