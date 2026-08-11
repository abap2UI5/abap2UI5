CLASS z2ui5_cl_core_handler DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_action       TYPE REF TO z2ui5_cl_core_action.
    DATA mv_request_json TYPE string.
    DATA ms_request      TYPE z2ui5_if_core_types=>ty_s_request.
    DATA ms_response     TYPE z2ui5_if_core_types=>ty_s_response.
    DATA mv_response     TYPE string.

    METHODS constructor
      IMPORTING
        val TYPE string.

    METHODS main
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_http_res.

    METHODS request_json_to_abap
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_request.

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
        val           TYPE z2ui5_if_core_types=>ty_s_response
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

    METHODS check_view_update_needed
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS request_parse_body
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_request
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


CLASS z2ui5_cl_core_handler IMPLEMENTATION.

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
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
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

    result-s_control-check_launchpad = xsdbool(
        result-s_front-search CS `scenario=LAUNCHPAD`
        OR result-s_front-pathname CS `/ui2/flp`
        OR result-s_front-pathname CS `test/flpSandbox` ).
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
          result = z2ui5_cl_a2ui5_context=>c_trim_upper(
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

    result = z2ui5_cl_a2ui5_context=>c_trim_upper(
        z2ui5_cl_a2ui5_context=>url_param_get( val = `app_start`
                                               url = iv_search ) ).
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

  METHOD request_app_start_draft.
    TRY.
        DATA(lv_hash) = hash_get_app_part( iv_hash ).
        " strip the leading slashes (see parse_app_route_rest for why they
        " stack); url_param_get matches parameter names verbatim
        SHIFT lv_hash LEFT DELETING LEADING `/`.
        result = z2ui5_cl_a2ui5_context=>c_trim_upper(
            z2ui5_cl_a2ui5_context=>url_param_get( val = `z2ui5-xapp-state`
                                                   url = lv_hash ) ).
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
        result = z2ui5_cl_a2ui5_context=>c_trim_upper( lv_rest ).
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
        result = z2ui5_cl_a2ui5_context=>c_trim_upper(
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

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( z2ui5_cl_a2ui5_json_fltr=>create_no_empty_values( ) ).
        DATA(lv_frontend) = ajson_result->stringify( ).

        DATA(lv_model) = COND string( WHEN val-model IS NOT INITIAL THEN val-model ELSE `{}` ).

        result = |\{"S_FRONT":{ lv_frontend },"MODEL":{ lv_model }\}|.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    mo_action = NEW z2ui5_cl_core_action( me ).

  ENDMETHOD.

  METHOD main.

    " The exception itself only says WHAT went wrong. Which app, which event
    " and which draft it went wrong in is known here and nowhere above, so
    " annotate it on the way out - the top-level catch in
    " z2ui5_cl_http_handler=>_main renders the whole chain, this frame
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
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val      = lv_context
            previous = x.
    ENDTRY.

    result = VALUE #( body          = mv_response
                      s_stateful    = ms_response-s_front-params-s_stateful
                      status_code   = 200
                      status_reason = `success` ).

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
          lv_app = z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).
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

    result = |Request failed| &&
             COND #( WHEN lv_app   IS NOT INITIAL THEN | in app { lv_app }| ) &&
             COND #( WHEN lv_event IS NOT INITIAL THEN |, event { lv_event }|
                     ELSE |, no event (initial rendering)| ) &&
             COND #( WHEN lv_draft IS NOT INITIAL THEN |, draft { lv_draft }| ) &&
             COND #( WHEN ms_request-s_control-app_start IS NOT INITIAL
                     THEN |, app_start { ms_request-s_control-app_start }| ) &&
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
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
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
    z2ui5_cl_core_app=>db_load_buffer_clear( ).

    ms_request = request_json_to_abap( mv_request_json ).

    IF ms_request-s_front-id IS NOT INITIAL.
      mo_action = mo_action->factory_by_frontend( ).

    ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
      NEW z2ui5_cl_core_srv_draft( )->cleanup( ).
      mo_action = mo_action->factory_first_start( ).

    ELSE.
      mo_action = mo_action->factory_system_startup( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_view_update_needed.

    " a slot that ships new XML always needs the model with it - all five slots,
    " the nested ones included
    IF ms_response-s_front-params-s_view-xml       IS NOT INITIAL
        OR ms_response-s_front-params-s_view_nest-xml  IS NOT INITIAL
        OR ms_response-s_front-params-s_view_nest2-xml IS NOT INITIAL
        OR ms_response-s_front-params-s_popup-xml      IS NOT INITIAL
        OR ms_response-s_front-params-s_popover-xml    IS NOT INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    " a data-only roundtrip asks for the model through the flag, which only the
    " three model-owning slots have - see reset_view_update_flags
    IF ms_response-s_front-params-s_view-check_update_model    = abap_true
        OR ms_response-s_front-params-s_popup-check_update_model   = abap_true
        OR ms_response-s_front-params-s_popover-check_update_model = abap_true.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD main_end.

    " Hash routing is configured once and then belongs to the app, not to the
    " session: re-send the app's own mode whenever this roundtrip did not set
    " one itself, so an app that called set_nav_routing( ) in check_on_init
    " stays routed in its chosen mode - even after the user visited another
    " app that runs with a different one (see z2ui5_cl_core_app=>mv_nav_mode).
    IF mo_action->ms_next-s_set-set_nav_routing IS INITIAL.
      mo_action->ms_next-s_set-set_nav_routing = mo_action->mo_app->mv_nav_mode.
    ENDIF.

    ms_response = VALUE #( s_front-params = mo_action->ms_next-s_set
                           s_front-id     = mo_action->mo_app->ms_draft-id
                           s_front-app    = z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ) ).

    IF check_view_update_needed( ).
      ms_response-model = mo_action->mo_app->model_json_stringify( ).
    ELSEIF mv_model_before_taken = abap_true.
      " automatic model update: main( ) neither displayed nor asked for a
      " push - send the model only when main( ) itself changed it, exactly as
      " an explicit view_model_update( ) would (same payload, same frontend
      " flag); an unchanged model still responds `{}` as before
      DATA(lv_model) = mo_action->mo_app->model_json_stringify( ).
      IF lv_model = mv_model_before.
        ms_response-model = `{}`.
      ELSE.
        ms_response-model = lv_model.
        ms_response-s_front-params-s_view-check_update_model = abap_true.
      ENDIF.
    ELSE.
      ms_response-model = `{}`.
    ENDIF.

    IF ms_response-s_front-params-s_popup-xml IS NOT INITIAL.
      ms_response-s_front-params-s_popup-check_update_model = abap_false.
    ENDIF.

    mv_response = response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.

    IF CAST z2ui5_if_app( mo_action->mo_app->mo_app )->check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ENDIF.

  ENDMETHOD.

  METHOD main_process.

    DATA(li_client) = CAST z2ui5_if_client( NEW z2ui5_cl_core_client( mo_action ) ).
    DATA(li_app)    = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

    " automatic model update: snapshot the model AFTER the incoming two-way
    " deltas were applied (factory_by_frontend) and BEFORE main( ) runs -
    " what the client already knows must never trigger a push. Taken per
    " dispatch iteration, so after a nav_app_call/leave the snapshot belongs
    " to the app main_end responds for.
    mv_model_before       = mo_action->mo_app->model_json_stringify( ).
    mv_model_before_taken = abap_true.

    IF li_app->check_sticky = abap_false.
      z2ui5_cl_a2ui5_context=>db_rollback( ).
    ENDIF.

    " exceptions from main( ) are intentionally not caught here - they bubble up
    " to the single top-level catch in z2ui5_cl_http_handler=>_main( ), which
    " turns them into a 500 response carrying the exception text
    IF mo_action->ms_actual-event = z2ui5_if_core_types=>cs_event_nav_app_leave.
      li_client->popup_destroy( ).
      " a popover floats next to the MAIN view exactly like a popup and
      " survives the view replacement the same way - close it too
      li_client->popover_destroy( ).
      li_client->nav_app_leave( ).
    ELSE.
      li_app->main( li_client ).
    ENDIF.

    IF li_app->check_sticky = abap_false.
      z2ui5_cl_a2ui5_context=>db_rollback( ).
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
