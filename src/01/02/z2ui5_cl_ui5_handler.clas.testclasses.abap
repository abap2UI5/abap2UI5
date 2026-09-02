CLASS ltcl_app_nav_loop DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

" a root app with a back button: leaves without naming a target
CLASS ltcl_app_leave_root DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_main_calls TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_leave_root IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    mv_main_calls = mv_main_calls + 1.
    client->nav_app_leave( ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_nav_loop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    client->nav_app_call( NEW ltcl_app_nav_loop( ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_noop DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA check_init TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_noop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    " deliberately neither displays nor pushes - the auto-model-update tests
    " need a main( ) that returns without touching the response
    check_init = client->check_on_init( ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_sticky DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_init_log TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_sticky IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    " record per roundtrip whether the framework treated it as the init
    " roundtrip - the sticky-latch test asserts the sequence
    IF mv_init_log IS NOT INITIAL.
      mv_init_log = mv_init_log && `|`.
    ENDIF.
    mv_init_log = mv_init_log && COND string( WHEN client->check_on_init( ) = abap_true
                                              THEN `INIT`
                                              ELSE `EVENT` ).
  ENDMETHOD.

ENDCLASS.

" OBSOLETE - ltcl_test_handler_post: its tests moved unchanged, by name, into the
" sections at the end of this file, to be deleted once the mapping is checked:
"   ltcl_01_request: test_constructor, load_startup_app, test_request_parse, test_request_origin, test_request_launchpad, test_parse_body_with_wrapper, test_parse_body_no_wrapper, test_parse_body_model, test_parse_body_model_no_wrap, test_parse_body_config, test_parse_body_no_config, test_parse_body_arg_string, test_parse_body_arg_object, test_request_app_start, test_request_with_id, test_context_info_sanitized, test_app_start_encoded_slash, test_hash_app_part, test_hash_shell_part, test_app_get_url, test_route_standalone, test_route_launchpad, test_route_no_route, test_app_state_hash
"   ltcl_02_response: test_response_json, test_response_no_model, test_response_actions_embedded, test_view_update_flag, test_view_update_popup, test_view_update_none, test_auto_update_push, test_auto_update_same, test_nested_display_push, test_auto_update_snapshot, test_model_client_stored, test_model_client_unchanged, test_snapshot_reuses_client, test_delta_drops_client, test_system_slot_order, test_system_last_wins, test_system_empty, test_system_destroy_only, test_session_stored, test_session_location, test_session_launchpad, test_session_from_draft, test_session_new_device
"   ltcl_03_dispatch: test_dispatch_loop_guard, test_leave_root_ends_roundtrip, test_sticky_keep_saves_draft, test_nav_mode_resent, test_nav_mode_hop_default
"   ltcl_00_base: slot_sequence, system_actions_of


" ---------------------------------------------------------------------------
" nav_app_call to an app that only opens a popup (the z2ui5_cl_pop_* shape):
" the response of the hop belongs to the CALLED app - its class name, its
" model, its popup - and displays no main view. The caller's table view is
" still on screen, and the frontend keeps it out of that model
" (actions/Slots, view1Events.spec). What has to hold on THIS side of the
" wire is pinned here: which app the response names, what its model carries,
" and that a popup app with nothing bound sends no model at all.
" ---------------------------------------------------------------------------

" the popup app with a bound edit buffer
CLASS ltcl_app_popup_bound DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
      END OF ty_s_row.
    DATA ms_row TYPE ty_s_row.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_popup_bound IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      ms_row-name = `edit me`.
      client->popup_display( |<Dialog><Input value="{ client->_bind( ms_row-name ) }"/></Dialog>| ).
    ELSEIF client->check_on_event( `CLOSE` ).
      " the edit is done: close and hand control back (sample 501)
      ms_row-name = `edited`.
      client->popup_destroy( ).
      client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" the popup app that binds nothing (sample 340)
CLASS ltcl_app_popup_silent DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_popup_silent IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      client->popup_display( `<Dialog/>` ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" the caller: a bound table on its main view, a row click that hands over
CLASS ltcl_app_popup_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mt_tab        TYPE ty_t_row.
    " what the popup app handed back (sample 500 reads the edited table
    " out of the popup app with get_app_prev)
    DATA mv_from_popup TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_popup_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA lo_prev TYPE REF TO ltcl_app_popup_bound.
    IF client->check_on_init( ).
      mt_tab = VALUE #( ( name = `one` ) ( name = `two` ) ).
      client->view_display( |<mvc:View><Table items="{ client->_bind( mt_tab ) }"/></mvc:View>| ).
    ELSEIF client->check_on_navigated( ).
      TRY.
          lo_prev ?= client->get_app_prev( ).
          mv_from_popup = lo_prev->ms_row-name.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      client->view_display( |<mvc:View><Table items="{ client->_bind( mt_tab ) }"/>| &&
                            |<Text text="{ client->_bind( mv_from_popup ) }"/></mvc:View>| ).
    ELSEIF client->check_on_event( `ROW_SELECT` ).
      client->nav_app_call( NEW ltcl_app_popup_bound( ) ).
    ELSEIF client->check_on_event( `ROW_SELECT_SILENT` ).
      client->nav_app_call( NEW ltcl_app_popup_silent( ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" OBSOLETE - ltcl_test_popup_call: its tests moved unchanged into ltcl_04_nav
" (popup_app_answers_alone, silent_popup_app_no_model, way_back_reads_popup_app),
" its helpers into ltcl_00_base (event_on, check_display) and ltcl_04_nav
" (caller_started), to be deleted once the mapping is checked


" ===========================================================================
" THE STRUCTURED SUITE - one section per step of a roundtrip through the
" handler:
"
"   ltcl_00_base      the helpers every section reads a response with
"   ltcl_01_request   what the handler makes of the wire
"   ltcl_02_response  what goes back - model rules, slots, session
"   ltcl_03_dispatch  how main_loop runs an app
"   ltcl_04_nav       nav_app_call and the way back
"
" The tests of ltcl_test_handler_post and ltcl_test_popup_call moved here
" unchanged, by name - the map is in the OBSOLETE note where those classes
" stood. What is new is in ltcl_04_nav.
" ===========================================================================

CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_request DEFINITION DEFERRED.
CLASS ltcl_02_response DEFINITION DEFERRED.
CLASS ltcl_03_dispatch DEFINITION DEFERRED.
CLASS ltcl_04_nav DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_handler DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_request ltcl_02_response
                                                  ltcl_03_dispatch ltcl_04_nav.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    "! the slots the serialized actions name, in order, deduplicated
    METHODS slot_sequence
      IMPORTING
        val           TYPE REF TO z2ui5_cl_ui5_handler
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    "! the response's system actions, stringified and pipe-joined - so the
    "! auto-update/nav tests can assert on the queue like on text
    METHODS system_actions_of
      IMPORTING
        val           TYPE REF TO z2ui5_cl_ui5_handler
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    " roundtrip 1: an app's first render, saved as a draft - answers the id
    METHODS started_with
      IMPORTING
        io_app        TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_handler.

    " a later roundtrip: the event on that draft, answered by whoever the
    " hop ends on
    METHODS event_on
      IMPORTING
        iv_id         TYPE string
        iv_event      TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_handler.

    METHODS check_display
      IMPORTING
        io_handler    TYPE REF TO z2ui5_cl_ui5_handler
        iv_slot       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD system_actions_of.

    LOOP AT val->ms_response-s_front-s_action-t_system INTO DATA(ls_queued).
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.
      result = result && COND #( WHEN ls_queued-o_json IS BOUND
                                 THEN ls_queued-o_json->stringify( )
                                 ELSE ls_queued-js ).
    ENDLOOP.

  ENDMETHOD.

  METHOD slot_sequence.

    " the slots named by the serialized actions, in order, each one once -
    " so the assertion reads as the sequence and not as a payload dump
    LOOP AT val->mo_action->ms_next-s_action-t_system INTO DATA(ls_queued).
      DATA(lv_js) = ls_queued-o_json->stringify( ).
      SPLIT lv_js AT `","` INTO TABLE DATA(lt_part).
      DATA(lv_slot) = replace( val  = VALUE string( lt_part[ 3 ] OPTIONAL )
                               sub  = `"]`
                               with = `` ).
      IF result CS lv_slot.
        CONTINUE.
      ENDIF.
      IF result IS NOT INITIAL.
        result = result && `|`.
      ENDIF.
      result = result && lv_slot.
    ENDLOOP.

  ENDMETHOD.

  METHOD started_with.

    result = NEW z2ui5_cl_ui5_handler( val = `` ).
    result->mo_action->mo_app->mo_app      = io_app.
    result->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->main_loop( ).

  ENDMETHOD.

  METHOD event_on.

    DATA(lv_payload) = `{"value":{"S_FRONT":{"ID":"` && iv_id && `","EVENT":"` && iv_event &&
                       `","ORIGIN":"O","PATHNAME":"/","SEARCH":""}}}`.
    result = NEW #( val = lv_payload ).
    result->main_begin( ).
    result->main_loop( ).

  ENDMETHOD.

  METHOD check_display.

    result = xsdbool( line_exists( io_handler->mo_action->ms_next-t_action_front[
                                       slot   = iv_slot
                                       method = z2ui5_if_ui5_types=>cs_slot_action-display ] ) ). "#EC CI_SORTSEQ

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 - the request: what the handler makes of the wire - the JSON body
" (wrapper or bare, model, config, event args), the start of an app from
" the URL, hash and route, the context info
" ---------------------------------------------------------------------------
CLASS ltcl_01_request DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_constructor FOR TESTING RAISING cx_static_check.
    METHODS load_startup_app FOR TESTING RAISING cx_static_check.
    METHODS test_request_parse FOR TESTING RAISING cx_static_check.
    METHODS test_request_origin FOR TESTING RAISING cx_static_check.
    METHODS test_request_launchpad FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_with_wrapper FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_no_wrapper FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_model FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_model_no_wrap FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_config FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_no_config FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_string FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_object FOR TESTING RAISING cx_static_check.
    METHODS test_request_app_start FOR TESTING RAISING cx_static_check.
    METHODS test_request_with_id FOR TESTING RAISING cx_static_check.
    METHODS test_context_info_sanitized FOR TESTING RAISING cx_static_check.
    METHODS test_app_start_encoded_slash FOR TESTING RAISING cx_static_check.
    METHODS test_hash_app_part FOR TESTING RAISING cx_static_check.
    METHODS test_hash_shell_part FOR TESTING RAISING cx_static_check.
    METHODS test_app_get_url FOR TESTING RAISING cx_static_check.
    METHODS test_route_standalone FOR TESTING RAISING cx_static_check.
    METHODS test_route_launchpad FOR TESTING RAISING cx_static_check.
    METHODS test_route_no_route FOR TESTING RAISING cx_static_check.
    METHODS test_app_state_hash FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_request IMPLEMENTATION.

  METHOD test_constructor.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `test payload` ).

    cl_abap_unit_assert=>assert_equals( exp = `test payload`
                                        act = lo_handler->mv_request_json ).
    cl_abap_unit_assert=>assert_bound( lo_handler->mo_action ).

  ENDMETHOD.

  METHOD load_startup_app.
    DATA lv_payload TYPE string.
    DATA lo_post TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_app_start.
    DATA lo_startup LIKE temp1.

    lv_payload = `{"value" : { "S_FRONT":{"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":""}}}`.

    lo_post = NEW #( val = lv_payload ).
    lo_post->main_begin( ).

    cl_abap_unit_assert=>assert_bound( lo_post->mo_action ).

    cl_abap_unit_assert=>assert_equals( exp = `ORIGIN`
                                        act = lo_post->ms_request-s_front-origin ).

    cl_abap_unit_assert=>assert_equals( exp = `PATHNAME`
                                        act = lo_post->ms_request-s_front-pathname ).


    temp1 ?= lo_post->mo_action->mo_app->mo_app.

    lo_startup = temp1.

  ENDMETHOD.

  METHOD test_request_parse.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/sap/test","SEARCH":"?param=1"}}}`.

    lo_handler = NEW #( val = lv_payload ).

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/test`
                                        act = ls_request-s_front-pathname ).
    cl_abap_unit_assert=>assert_equals( exp = `?param=1`
                                        act = ls_request-s_front-search ).

  ENDMETHOD.

  METHOD test_request_origin.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://example.org","PATHNAME":"/app","SEARCH":""}}}`.

    lo_handler = NEW #( val = lv_payload ).

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://example.org`
                                        act = ls_request-s_front-origin ).

  ENDMETHOD.

  METHOD test_request_launchpad.

    " the flag is derived in session_merge from the MERGED location, not in
    " the raw parse - pathname/search only travel on app-start-shaped
    " requests (see test_session_launchpad for the restore cadence)
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}}`.

    lo_handler = NEW #( val = lv_payload ).
    lo_handler->ms_request = lo_handler->request_json_to_abap( lv_payload ).

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->ms_request-s_control-check_launchpad ).

  ENDMETHOD.

  METHOD test_parse_body_with_wrapper.
    " Standalone scenario: frontend wraps body in {"value": ...}
    " This is the standard case when the app runs outside the Fiori Launchpad.
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/sap/bc/z2ui5","SEARCH":""}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = ls_request-s_front-pathname ).
  ENDMETHOD.

  METHOD test_parse_body_no_wrapper.
    " Launchpad/Gateway scenario: FLP proxy strips the {"value": ...} envelope
    " before the request reaches the ABAP ICF handler, so the body arrives
    " as a plain object without the value key.
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ORIGIN":"https://myhost.com","PATHNAME":"/ui2/flp","SEARCH":"?scenario=LAUNCHPAD"}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `https://myhost.com`
                                        act = ls_request-s_front-origin ).

    " the launchpad flag is derived in session_merge from the merged location
    lo_handler->ms_request = ls_request.
    lo_handler->session_merge( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->ms_request-s_control-check_launchpad ).
  ENDMETHOD.

  METHOD test_parse_body_model.
    " the view model is extracted from the request MODEL container and has to
    " stay reachable under /... for main_json_to_attri
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""},"MODEL":{"NAME":"test-value"}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( `/NAME` ) ).
  ENDMETHOD.

  METHOD test_parse_body_model_no_wrap.
    " launchpad/gateway scenario: the model extraction also has to work
    " when the value envelope was stripped by the infrastructure
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""},"MODEL":{"NAME":"test-value"}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( `/NAME` ) ).
  ENDMETHOD.

  METHOD test_parse_body_config.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"ComponentData":{"startupParameters":{}},` &&
                 `"S_DEVICE":{"SYSTEM":"desktop"},` &&
                 `"S_FOCUS":{"ID":"my-input","SELECTION_START":2,"SELECTION_END":5},` &&
                 `"S_SCROLL":{"MAIN":{"ID":"page","X":0,"Y":150}},` &&
                 `"S_UI5":{"VERSION":"1.120.0","BUILDTIMESTAMP":"20240101","GAV":"com.sap.ui:sdk:1.120.0","THEME":"sap_horizon"}}}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_bound( ls_request-s_front-o_comp_data ).
    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = ls_request-s_front-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `my-input`
                                        act = ls_request-s_front-s_focus-id ).
    cl_abap_unit_assert=>assert_equals( exp = 150
                                        act = ls_request-s_front-s_scroll-main-y ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = ls_request-s_front-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `20240101`
                                        act = ls_request-s_front-s_ui5-build_timestamp ).
    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = ls_request-s_front-s_ui5-theme ).

  ENDMETHOD.

  METHOD test_parse_body_no_config.
    " a request without CONFIG section has to parse without errors and
    " leave the config fields initial
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_not_bound( ls_request-s_front-o_comp_data ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_device ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_ui5 ).

  ENDMETHOD.

  METHOD test_parse_body_arg_string.
    " plain string arguments take the unchanged to_abap path
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["first","second"]}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_request-s_front-t_event_arg ) ).
    cl_abap_unit_assert=>assert_equals( exp = `first`
                                        act = ls_request-s_front-t_event_arg[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `second`
                                        act = ls_request-s_front-t_event_arg[ 2 ] ).
  ENDMETHOD.

  METHOD test_parse_body_arg_object.
    " object and array arguments arrive as raw JSON from the frontend and
    " have to reach the app as JSON strings, scalar arguments in the same
    " event keep their previous string form
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["plain",5,true,{"KEY":"val"},[1,2]]}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = lines( ls_request-s_front-t_event_arg ) ).
    cl_abap_unit_assert=>assert_equals( exp = `plain`
                                        act = ls_request-s_front-t_event_arg[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `5`
                                        act = ls_request-s_front-t_event_arg[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = ls_request-s_front-t_event_arg[ 3 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `{"KEY":"val"}`
                                        act = ls_request-s_front-t_event_arg[ 4 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `[1,2]`
                                        act = ls_request-s_front-t_event_arg[ 5 ] ).
  ENDMETHOD.

  METHOD test_request_app_start.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.

    lo_handler = NEW #( val = lv_payload ).

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                        act = ls_request-s_control-app_start ).

  ENDMETHOD.

  METHOD test_request_with_id.

    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":""}}}`.

    lo_handler = NEW #( val = lv_payload ).

    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_front-id ).

  ENDMETHOD.

  METHOD test_context_info_sanitized.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " the 500 body quotes app_start - client-controlled, so markup in it is
    " stripped the way factory_first_start strips it
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_control-app_start = `ZCL_X<script>alert(1)</script>`.

    DATA(lv_info) = lo_handler->request_context_info( ).

    cl_abap_unit_assert=>assert_char_cp( act = lv_info
                                         exp = `*app_start ZCL_Xscriptalert1/script*` ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_info CS `<` ) ).

  ENDMETHOD.

  METHOD test_app_start_encoded_slash.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_no_comp_data TYPE REF TO z2ui5_if_ajson.
    lo_handler = NEW #( val = `` ).

    " a percent-encoded namespace in the query is the class name it spells
    cl_abap_unit_assert=>assert_equals(
        exp = `/NS/ZCL_APP`
        act = lo_handler->request_app_start( iv_search    = `?app_start=%2Fns%2Fzcl_app`
                                             io_comp_data = lo_no_comp_data ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `ZCL_APP`
        act = lo_handler->request_app_start( iv_search    = `?app_start=zcl_app`
                                             io_comp_data = lo_no_comp_data ) ).

  ENDMETHOD.

  METHOD test_hash_app_part.

    " standalone - the whole hash belongs to the app
    cl_abap_unit_assert=>assert_equals( exp = `/app/ZCL_X/D1`
                                        act = z2ui5_cl_ui5_handler=>hash_get_app_part( `#/app/ZCL_X/D1` ) ).

    " launchpad - the shell owns everything before '&/'
    cl_abap_unit_assert=>assert_equals( exp = `app/ZCL_X/D1`
                                        act = z2ui5_cl_ui5_handler=>hash_get_app_part( `#Z2UI5-display&/app/ZCL_X/D1` ) ).

    " ... including a shell hash that carries its own parameters
    cl_abap_unit_assert=>assert_equals( exp = `app/ZCL_X`
                                        act = z2ui5_cl_ui5_handler=>hash_get_app_part( `#Z2UI5-display?a=b&c=d&/app/ZCL_X` ) ).

    " an app hash containing '&/' must not be split
    cl_abap_unit_assert=>assert_equals( exp = `/app/ZCL_X/D1?next=&/y`
                                        act = z2ui5_cl_ui5_handler=>hash_get_app_part( `#/app/ZCL_X/D1?next=&/y` ) ).

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_ui5_handler=>hash_get_app_part( `` ) ).

  ENDMETHOD.

  METHOD test_hash_shell_part.

    " launchpad - the shell part is everything before '&/'
    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5-display`
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `#Z2UI5-display&/app/ZCL_X/D1` ) ).

    " ... including a shell hash that carries its own parameters
    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5-display?a=b&c=d`
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `#Z2UI5-display?a=b&c=d&/app/ZCL_X` ) ).

    " standalone - the whole hash is the app's, so there is no shell part;
    " the leading-'/' guard runs before the '&/' search, so an app hash
    " carrying '&/' in a parameter fabricates no shell part either
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `#/app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `#/app/ZCL_X/D1?next=&/y` ) ).

    " a bare shell hash without an app part keeps nothing - same contract as
    " Router.splitHash, whose shell is only ever cut at '&/'
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `#Z2UI5-display` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part( `` ) ).

    " ... unless the caller declares its input the RAW location hash, where
    " the bare form is a launchpad intent and therefore ALL shell - the one
    " provenance-dependent shape (see the parameter's comment). An app hash
    " stays an app hash even then
    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5-display`
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part(
                  iv_hash             = `#Z2UI5-display`
                  check_bare_is_shell = abap_true ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = z2ui5_cl_ui5_handler=>hash_get_shell_part(
                  iv_hash             = `#/app/ZCL_X/D1`
                  check_bare_is_shell = abap_true ) ).

  ENDMETHOD.

  METHOD test_app_get_url.

    " the app-owned hash (route or app-state, leading `/`) must be dropped -
    " the backend prefers it over app_start, so keeping it would re-open the
    " current app instead of the requested one
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new`
        act = z2ui5_cl_ui5_handler=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#/app/ZCL_OLD/DRAFT1` ) ).

    " inside the FLP the shell part of the hash survives, only the app part
    " after `&/` is cut
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new#Shell-home`
        act = z2ui5_cl_ui5_handler=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#Shell-home&/app/ZCL_OLD/DRAFT1` ) ).

    " a bare intent hash (FLP, no app part yet) is all shell and survives
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new#Shell-home`
        act = z2ui5_cl_ui5_handler=>app_get_url(
                  classname = `ZCL_NEW`
                  origin    = `https://h`
                  pathname  = `/p`
                  search    = ``
                  hash      = `#Shell-home` ) ).

  ENDMETHOD.

  METHOD test_route_standalone.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#/app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `D1`
                                        act = lo_handler->request_app_start_route_draft( `#/app/ZCL_X/D1` ) ).

    " class-only route (routing mode FRESH) carries no draft
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#/app/ZCL_X` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route_draft( `#/app/ZCL_X` ) ).

    " the double-slash form the UI5 HashChanger wrote before navTo stripped
    " its slash (hasher prepends one of its own) - lives on in bookmarks and
    " browser history entries, and Back/Forward sends exactly this
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#//app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `D1`
                                        act = lo_handler->request_app_start_route_draft( `#//app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = lo_handler->request_app_start_route( `#//app/ZCL_X` ) ).

  ENDMETHOD.

  METHOD test_route_launchpad.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    " the same routes, but reached through the launchpad shell hash - the
    " browser Back button inside the FLP sends exactly this
    cl_abap_unit_assert=>assert_equals(
        exp = `ZCL_X`
        act = lo_handler->request_app_start_route( `#Z2UI5-display&/app/ZCL_X/D1` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `D1`
        act = lo_handler->request_app_start_route_draft( `#Z2UI5-display&/app/ZCL_X/D1` ) ).

    " our slash-prefixed routes appended verbatim by older shells
    cl_abap_unit_assert=>assert_equals(
        exp = `ZCL_X`
        act = lo_handler->request_app_start_route( `#Z2UI5-display&//app/ZCL_X/D1` ) ).

  ENDMETHOD.

  METHOD test_route_no_route.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    " no hash at all (normal boot), an app-owned hash, a bare shell hash and
    " an 'app/' occurring mid-hash must all resolve to "no route", so the
    " '?app_start=' query keeps winning
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#/head/pos/42` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#Z2UI5-display` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = lo_handler->request_app_start_route( `#/head/app/ZCL_X` ) ).

  ENDMETHOD.

  METHOD test_app_state_hash.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    " the app-state link format, standalone and inside the launchpad
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#/z2ui5-xapp-state=ABC123` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#Z2UI5-display&/z2ui5-xapp-state=ABC123` ) ).

    " the double-slash form older HashChanger-written live URLs carry
    cl_abap_unit_assert=>assert_equals(
        exp = `ABC123`
        act = lo_handler->request_app_start_draft( `#//z2ui5-xapp-state=ABC123` ) ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 - the response: what goes back - the JSON, the model rules (display,
" auto push, snapshot, client model, delta), the view slots and the system
" actions, the session
" ---------------------------------------------------------------------------
CLASS ltcl_02_response DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_response_json FOR TESTING RAISING cx_static_check.
    METHODS test_response_no_model FOR TESTING RAISING cx_static_check.
    METHODS test_response_actions_embedded FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_flag FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_popup FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_none FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_push FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_same FOR TESTING RAISING cx_static_check.
    METHODS test_nested_display_push FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_snapshot FOR TESTING RAISING cx_static_check.
    METHODS test_model_client_stored FOR TESTING RAISING cx_static_check.
    METHODS test_model_client_unchanged FOR TESTING RAISING cx_static_check.
    METHODS test_snapshot_reuses_client FOR TESTING RAISING cx_static_check.
    METHODS test_delta_drops_client FOR TESTING RAISING cx_static_check.
    METHODS test_system_slot_order FOR TESTING RAISING cx_static_check.
    METHODS test_system_last_wins FOR TESTING RAISING cx_static_check.
    METHODS test_system_empty FOR TESTING RAISING cx_static_check.
    METHODS test_system_destroy_only FOR TESTING RAISING cx_static_check.
    METHODS test_session_stored FOR TESTING RAISING cx_static_check.
    METHODS test_session_location FOR TESTING RAISING cx_static_check.
    METHODS test_session_launchpad FOR TESTING RAISING cx_static_check.
    METHODS test_session_from_draft FOR TESTING RAISING cx_static_check.
    METHODS test_session_new_device FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_response IMPLEMENTATION.

  METHOD test_response_json.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA temp2 TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA ls_response LIKE temp2.
    DATA lv_json TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    lo_handler = NEW #( val = `` ).

    CLEAR temp2.
    temp2-s_front-id = `ID123`.
    temp2-s_front-app = `Z2UI5_CL_UI5_APP_HI_WORLD`.
    temp2-model = `{"name":"test"}`.

    ls_response = temp2.


    lv_json = lo_handler->response_abap_to_json( ls_response ).


    temp1 = xsdbool( lv_json CS `S_FRONT` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp3 = xsdbool( lv_json CS `MODEL` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

    temp4 = xsdbool( lv_json CS `{"name":"test"}` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_response_no_model.

    " a round-trip that changed nothing bound sends no MODEL key at all
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    lo_handler = NEW #( val = `` ).
    ls_response-s_front-id = `ID123`.

    DATA(lv_json) = lo_handler->response_abap_to_json( ls_response ).

    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CS `MODEL` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `S_FRONT` ) ).

    " and an explicitly empty one is treated the same
    ls_response-model = `{}`.
    lv_json = lo_handler->response_abap_to_json( ls_response ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CS `MODEL` ) ).

  ENDMETHOD.

  METHOD test_response_actions_embedded.

    " the action lists leave as REAL nested JSON arrays, not as escaped
    " strings - and an empty-string positional placeholder inside an action
    " survives, because the queues are written AFTER the no-empty-values
    " filter ran
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    lo_handler = NEW #( val = `` ).
    ls_response-s_front-id = `ID123`.
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]` ) )
           INTO TABLE ls_response-s_front-s_action-t_system.
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["SET_FOCUS","id1"]` ) )
           INTO TABLE ls_response-s_front-s_action-t_custom.
    " a legacy raw-JS snippet an app queued keeps riding as a string entry
    INSERT VALUE #( js = `eF('SET_FOCUS','id2')` )
           INTO TABLE ls_response-s_front-s_action-t_custom.

    DATA(lv_json) = lo_handler->response_abap_to_json( ls_response ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_json CS `"T_SYSTEM":[["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]]` ) ).
    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_json CS `"T_CUSTOM":[["SET_FOCUS","id1"],"eF('SET_FOCUS','id2')"]` ) ).

  ENDMETHOD.

  METHOD test_view_update_flag.

    " every slot displays through a system action, and main_end derives
    " `did this roundtrip ship a view?` (the model has to travel with new
    " XML) from exactly those collected calls - no separate flag to keep in
    " sync, no slot of the response read back
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).
    li_client->view_display( `<View/>` ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( line_exists( lo_handler->mo_action->ms_next-t_action_front[ method = `display` ] ) ) ).

  ENDMETHOD.

  METHOD test_view_update_popup.

    " the same holds whichever slot was displayed...
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).
    li_client->popup_display( `<Dialog/>` ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( line_exists( lo_handler->mo_action->ms_next-t_action_front[ method = `display` ] ) ) ).

    " ...and a display a later destroy voided counts as NO view, so the
    " model is not sent for a dialog that never reaches the browser
    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_false(
        xsdbool( line_exists( lo_handler->mo_action->ms_next-t_action_front[ method = `display` ] ) ) ).

  ENDMETHOD.

  METHOD test_view_update_none.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    cl_abap_unit_assert=>assert_false(
        xsdbool( line_exists( lo_handler->mo_action->ms_next-t_action_front[ method = `display` ] ) ) ).

  ENDMETHOD.

  METHOD test_auto_update_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " the snapshot differs from the model after main( ) - the model is sent
    " exactly as an explicit view_model_update( ) would send it, with no app
    " opt-in of any kind: automatic model update is always on
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = `<other model state>`.

    lo_handler->main_end( ).

    " the MODEL key itself IS the push - no updateModel action travels,
    " the frontend pushes into every open slot when a model arrived
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).
    cl_abap_unit_assert=>assert_equals( exp = lo_handler->mo_action->mo_app->model_json_stringify( )
                                        act = lo_handler->ms_response-model ).

  ENDMETHOD.

  METHOD test_auto_update_same.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main( ) changed nothing - the response stays `{}` and no update flag is
    " set, so an idle event round-trip carries no model payload as before
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = lo_handler->mo_action->mo_app->model_json_stringify( ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lo_handler->ms_response-model ).
    " an unchanged model asks for no push at all
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).

  ENDMETHOD.

  METHOD test_nested_display_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.

    " a roundtrip that re-displays a NESTED view without its MAIN view must
    " carry the model: the nested view inherits the MAIN model by UI5
    " propagation, so without the push it would bind against the data of the
    " previous roundtrip (three-column samples 098/104)
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).
    li_client->nest_view_display( val           = `<Nest/>`
                                  id            = `col`
                                  method_insert = `addMidColumnPage` ).

    lo_handler->main_end( ).

    " the model travels with the response - its presence IS the push, the
    " frontend runs it after the displays (View1)
    cl_abap_unit_assert=>assert_equals(
        exp = lo_handler->mo_action->mo_app->model_json_stringify( )
        act = lo_handler->ms_response-model ).
    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).

  ENDMETHOD.

  METHOD test_auto_update_snapshot.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main_process always has a before-main snapshot - taken fresh here,
    " since a fresh app carries no stored client model to reuse
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_process( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->mv_model_before_taken ).

  ENDMETHOD.

  METHOD test_model_client_stored.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " a pushed model is exactly what the client is left holding - main_end
    " stores it on the app, and the next roundtrip of this app reuses it as
    " its pre-main( ) snapshot instead of serializing the model again
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lo_handler->mo_action->mo_app->mt_attri
                                                  app  = lo_app ).
    " main_attri_refresh runs the (private) dissolve pass - on this fresh,
    " unbound model it is a pure dissolve, which is all the test needs
    lo_model->main_attri_refresh( ).
    READ TABLE lo_handler->mo_action->mo_app->mt_attri->* REFERENCE INTO DATA(lr_attri)
         WITH KEY name = `CHECK_INIT`.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>abort( ).
    ENDIF.
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/CHECK_INIT`.

    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = `<other model state>`.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_differs( exp = `{}`
                                         act = lo_handler->ms_response-model ).
    cl_abap_unit_assert=>assert_equals( exp = lo_handler->ms_response-model
                                        act = lo_handler->mo_action->mo_app->mv_model_client ).

  ENDMETHOD.

  METHOD test_model_client_unchanged.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " no push: the client still holds the before-state, so THAT is stored -
    " and an empty model is stored as the known `{}` rather than INITIAL,
    " so the next roundtrip can still skip its snapshot serialization
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mv_model_before       = lo_handler->mo_action->mo_app->model_json_stringify( ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lo_handler->mo_action->mo_app->mv_model_client ).

  ENDMETHOD.

  METHOD test_snapshot_reuses_client.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main_process trusts the stored client model over a fresh serialization
    " - the sentinel can only arrive in the snapshot through the reuse path,
    " a real serialization of the no-op app would produce `{}`
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_model_client = `{"SENTINEL":true}`.

    lo_handler->main_process( ).

    cl_abap_unit_assert=>assert_equals( exp = `{"SENTINEL":true}`
                                        act = lo_handler->mv_model_before ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->mv_model_before_taken ).

  ENDMETHOD.

  METHOD test_delta_drops_client.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " incoming model deltas change the state the stored string describes -
    " the factory drops it, so the snapshot of this roundtrip falls back to
    " a real serialization instead of trusting a stale string
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->mv_model_client = `{"SENTINEL":true}`.
    lo_handler->ms_request-o_model = z2ui5_cl_ajson=>parse( `{"NAME":"changed"}` ).

    DATA(lo_action) = lo_handler->mo_action->factory_by_frontend( ).

    cl_abap_unit_assert=>assert_initial( lo_action->mo_app->mv_model_client ).

  ENDMETHOD.

  METHOD test_system_slot_order.

    " The app displays in whatever order suits it - here nested first, main
    " last. The list that leaves goes MAIN, NEST, NEST2, POPUP, POPOVER: a
    " nested view is inserted INTO the main control tree, so it cannot be
    " built before the page it belongs to exists.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_handler = NEW #( val = `` ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    li_client->popover_display( xml   = `<Popover/>`
                                by_id = `btn` ).
    li_client->nest2_view_display( val           = `<Nest2/>`
                                   id            = `n2`
                                   method_insert = `addEndColumnPage` ).
    li_client->nest_view_display( val           = `<Nest/>`
                                  id            = `n1`
                                  method_insert = `addMidColumnPage` ).
    li_client->popup_display( `<Dialog/>` ).
    li_client->view_display( `<View/>` ).

    NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MAIN|NEST|NEST2|POPUP|POPOVER`
        act = slot_sequence( lo_handler ) ).

  ENDMETHOD.

  METHOD test_system_last_wins.

    " A slot displayed twice is displayed ONCE, with the last XML: the
    " second call drops everything the first queued. No destroy action
    " travels with a display - the frontend tears the slot down implicitly,
    " a display REPLACES the slot.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_handler = NEW #( val = `` ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    li_client->view_display( `<First/>` ).
    li_client->view_display( `<Second/>` ).

    NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( ).

    DATA(lt_js) = lo_handler->mo_action->ms_next-s_action-t_system.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_js ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","display","MAIN","<Second/>"]`
        act = lt_js[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_system_empty.

    " a roundtrip that touches no slot sends no system action at all
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( ).

    cl_abap_unit_assert=>assert_initial(
        lo_handler->mo_action->ms_next-s_action-t_system ).

  ENDMETHOD.

  METHOD test_system_destroy_only.

    " A bare destroy - popup_destroy( ) without a follow-up display - leaves
    " as exactly ["VIEW_SLOTS","destroy","POPUP"]: three entries, no XML
    " argument and no options object ride along
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_handler = NEW #( val = `` ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    li_client->popup_destroy( ).

    NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( ).

    DATA(lt_js) = lo_handler->mo_action->ms_next-s_action-t_system.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_js ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `["VIEW_SLOTS","destroy","POPUP"]`
        act = lt_js[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_session_stored.

    " the first roundtrip of a page load carries the block - it is stored on
    " the app, and therefore in its draft
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-s_device-system   = `desktop`.
    lo_handler->ms_request-s_front-s_device-os-name  = `Windows`.
    lo_handler->ms_request-s_front-s_ui5-version     = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_ui5-version ).

  ENDMETHOD.

  METHOD test_session_location.

    " the page location travels with app-start-shaped requests and is stored
    " with the draft; an event roundtrip omits it and reads it back
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-origin   = `https://host`.
    lo_handler->ms_request-s_front-pathname = `/sap/bc/z2ui5`.
    lo_handler->ms_request-s_front-search   = `?app_start=Z_MY_APP`.
    " the real first roundtrip of a page load carries the device/UI5 block
    " TOO - storing that block must not wipe the location just stored
    lo_handler->ms_request-s_front-s_device-system = `desktop`.
    lo_handler->ms_request-s_front-s_ui5-version   = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host`
                                        act = lo_handler->mo_action->mo_app->ms_session-origin ).

    " ...the follow-up event roundtrip carries none of it
    CLEAR: lo_handler->ms_request-s_front-origin,
           lo_handler->ms_request-s_front-pathname,
           lo_handler->ms_request-s_front-search,
           lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-s_ui5.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `https://host`
                                        act = lo_handler->ms_request-s_front-origin ).
    cl_abap_unit_assert=>assert_equals( exp = `/sap/bc/z2ui5`
                                        act = lo_handler->ms_request-s_front-pathname ).
    cl_abap_unit_assert=>assert_equals( exp = `?app_start=Z_MY_APP`
                                        act = lo_handler->ms_request-s_front-search ).

  ENDMETHOD.

  METHOD test_session_launchpad.

    " the launchpad flag is derived from the MERGED location: the FLP start
    " request carries the pathname once, every later event roundtrip omits
    " it and must still read check_launchpad from the draft-restored value
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-origin   = `https://host`.
    lo_handler->ms_request-s_front-pathname = `/sap/bc/ui2/flp`.
    lo_handler->ms_request-s_front-s_device-system = `desktop`.
    lo_handler->ms_request-s_front-s_ui5-version   = `1.120.0`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_true( lo_handler->ms_request-s_control-check_launchpad ).

    CLEAR: lo_handler->ms_request-s_front-origin,
           lo_handler->ms_request-s_front-pathname,
           lo_handler->ms_request-s_front-search,
           lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-s_ui5,
           lo_handler->ms_request-s_control.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_true( lo_handler->ms_request-s_control-check_launchpad ).

  ENDMETHOD.

  METHOD test_session_from_draft.

    " a later roundtrip sends none of it and is answered from the draft - but
    " orientation and resize are NOT session-constant and win from the request
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->ms_session = VALUE #(
        s_ui5-version         = `1.120.0`
        s_device-system       = `phone`
        s_device-os-name      = `iOS`
        s_device-orientation  = `portrait`
        s_device-resize-width = 400 ).

    lo_handler->ms_request-s_front-s_device-orientation  = `landscape`.
    lo_handler->ms_request-s_front-s_device-resize-width = 900.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `phone`
                                        act = lo_handler->ms_request-s_front-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->ms_request-s_front-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `landscape`
                                        act = lo_handler->ms_request-s_front-s_device-orientation ).
    cl_abap_unit_assert=>assert_equals( exp = 900
                                        act = lo_handler->ms_request-s_front-s_device-resize-width ).

  ENDMETHOD.

  METHOD test_session_new_device.

    " the same draft reopened from ANOTHER browser: its first roundtrip
    " carries a block again, and that block replaces what the draft held
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->ms_session = VALUE #( s_device-system = `phone`
                                                        s_device-os-name = `iOS` ).

    lo_handler->ms_request-s_front-s_device-system  = `desktop`.
    lo_handler->ms_request-s_front-s_device-os-name = `Windows`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `desktop`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `Windows`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-os-name ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 03 - the dispatch: how main_loop runs an app - the loop guard, a root
" that leaves, the sticky latch and the draft it saves, the nav mode
" ---------------------------------------------------------------------------
CLASS ltcl_03_dispatch DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_dispatch_loop_guard FOR TESTING RAISING cx_static_check.
    METHODS test_leave_root_ends_roundtrip FOR TESTING RAISING cx_static_check.
    METHODS test_sticky_keep_saves_draft FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_resent FOR TESTING RAISING cx_static_check.
    METHODS test_nav_mode_hop_default FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_dispatch IMPLEMENTATION.

  METHOD test_dispatch_loop_guard.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_loop_app TYPE REF TO ltcl_app_nav_loop.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    " an app that calls nav_app_call unconditionally in main( ) must not
    " loop the dispatch forever - the handler raises once the limit is hit
    lo_handler = NEW #( val = `` ).
    lo_handler->mv_dispatch_limit = 5.
    lo_loop_app = NEW #( ).
    lo_handler->mo_action->mo_app->mo_app = lo_loop_app.
    " db_save asserts a draft id, normally set by the action factories
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    TRY.
        lo_handler->main_loop( ).
        cl_abap_unit_assert=>fail( `dispatch loop guard did not raise` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( act = lx->get_text( )
                                             exp = `*nav_app_call*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_leave_root_ends_roundtrip.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_app TYPE REF TO ltcl_app_leave_root.

    " nothing on the stack: the leave has nowhere to go and the roundtrip
    " ends with this app - it used to hop to ITSELF (a second container
    " chained to its own draft, main( ) run a second time)
    lo_handler = NEW #( val = `` ).
    lo_app = NEW #( ).
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    DATA(lo_action_before) = lo_handler->mo_action.

    cl_abap_unit_assert=>assert_true( lo_handler->main_process( ) ).

    cl_abap_unit_assert=>assert_equals( exp = lo_action_before
                                        act = lo_handler->mo_action ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_app->mv_main_calls ).
    cl_abap_unit_assert=>assert_not_bound( lo_handler->mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_sticky_keep_saves_draft.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA(lo_draft) = NEW z2ui5_cl_ui5_srv_draft( ).

    " a sticky app under KEEP routing: its draft id goes into the URL, so
    " the draft has to exist for Back/Forward and a bookmark to restore it
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app          = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id     = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_check_sticky = abap_true.
    lo_handler->mo_action->mo_app->mv_nav_mode     = z2ui5_if_client=>cs_nav_mode-keep.
    DATA(lv_id_keep) = lo_handler->mo_action->mo_app->ms_draft-id.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_true( lo_draft->check_exists( lv_id_keep ) ).
    cl_abap_unit_assert=>assert_true( lo_handler->mo_action->mo_app->mv_check_initialized ).

    " a sticky app that asked for neither keeps skipping the serialization
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app          = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id     = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_check_sticky = abap_true.
    DATA(lv_id_plain) = lo_handler->mo_action->mo_app->ms_draft-id.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_false( lo_draft->check_exists( lv_id_plain ) ).
    cl_abap_unit_assert=>assert_true( lo_handler->mo_action->mo_app->mv_check_initialized ).

  ENDMETHOD.

  METHOD test_nav_mode_resent.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_app TYPE REF TO ltcl_app_nav_loop.

    " An app configures routing ONCE. main_end therefore re-sends the mode the
    " app carries whenever the roundtrip did not set one itself, so a later
    " render of the same app stays routed without queueing set_nav_routing
    " again - and an app that never opted in keeps sending nothing.
    lo_handler = NEW #( val = `` ).
    lo_app = NEW #( ).
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    lo_handler->main_end( ).

    " the mode reaches the frontend as the ROUTER/sync option, not as a
    " response field of its own
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*"setNavRouting":"KEEP"*`
        act = system_actions_of( lo_handler ) ).

    " a follow-up EVENT roundtrip of the same app repeats no mode - the
    " frontend keeps it in session state, so re-sending it would re-queue
    " the ROUTER action for a constant on every roundtrip
    lo_handler->ms_request-s_front-id = `SOME_DRAFT`.
    CLEAR lo_handler->mo_action->ms_next.
    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = xsdbool( system_actions_of( lo_handler ) CS `setNavRouting` ) ).

    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals(
        exp = abap_false
        act = xsdbool( system_actions_of( lo_handler ) CS `setNavRouting` ) ).

  ENDMETHOD.

  METHOD test_nav_mode_hop_default.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " A navigation hop into an app WITHOUT a mode of its own says DEFAULT
    " explicitly: the app's initial mode would travel as empty = "no change",
    " and the PREVIOUS app's KEEP/FRESH would keep writing
    " '#/app/<CLASS>/<DRAFT>' for an app that never opted in - seen live on
    " the samples overview after nav_app_leave from a routed sample.
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-id          = `PREV_DRAFT`.
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->ms_actual-check_on_navigated = abap_true.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_char_cp(
        exp = `*"setNavRouting":"DEFAULT"*`
        act = system_actions_of( lo_handler ) ).

    " a FRESH START (no draft id in the request) sets check_on_navigated
    " too - a reload, or Back/Forward under FRESH routing re-creating an app
    " that only inherited its mode - and must NOT switch routing off: the
    " frontend is in the mode that produced the route
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->ms_actual-check_on_navigated = abap_true.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `setNavRouting` ) ).

    " while a hop into an app WITH a mode - its own, or the one a called app
    " inherits from its caller (z2ui5_cl_ui5_action) - still sends that mode
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.
    lo_handler->mo_action->ms_actual-check_on_navigated = abap_true.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_char_cp(
        exp = `*"setNavRouting":"KEEP"*`
        act = system_actions_of( lo_handler ) ).

  ENDMETHOD.

ENDCLASS.


" one class, two instances in the stack: the outer calls an inner of its
" OWN class, both bind an attribute of the same name, the outer reads the
" inner back on the way home. What has to hold: each instance has its own
" draft, the response names the instance the hop ends on, and the outer
" comes back with ITS values - not the inner's, though the rows of
" mt_attri carry the same names for both
CLASS ltcl_app_twice DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_name       TYPE string.
    DATA mv_from_inner TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_twice IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    DATA lo_prev TYPE REF TO ltcl_app_twice.
    IF client->check_on_init( ).
      client->view_display( |<mvc:View><Text text="{ client->_bind( mv_name ) }"/></mvc:View>| ).
    ELSEIF client->check_on_navigated( ).
      lo_prev ?= client->get_app_prev( ).
      mv_from_inner = lo_prev->mv_name.
      client->view_display( |<mvc:View><Text text="{ client->_bind( mv_name ) }"/>| &&
                            |<Text text="{ client->_bind( mv_from_inner ) }"/></mvc:View>| ).
    ELSEIF client->check_on_event( `CALL` ).
      DATA(lo_inner) = NEW ltcl_app_twice( ).
      lo_inner->mv_name = `inner`.
      client->nav_app_call( lo_inner ).
    ELSEIF client->check_on_event( `BACK` ).
      client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 04 - navigation: nav_app_call and the way back - a popup app answers
" alone, a silent one ships no model, the caller reads the popup app back,
" and two instances of ONE class in the stack keep their own state
" ---------------------------------------------------------------------------
CLASS ltcl_04_nav DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS popup_app_answers_alone FOR TESTING RAISING cx_static_check.
    METHODS silent_popup_app_no_model FOR TESTING RAISING cx_static_check.
    METHODS way_back_reads_popup_app FOR TESTING RAISING cx_static_check.
    " a caller of class X calls an instance of class X: two drafts, two
    " responses, and the way back shows the outer's own values
    METHODS same_class_twice_in_stack FOR TESTING RAISING cx_static_check.

    " roundtrip 1: the popup caller's first render, saved as a draft
    METHODS caller_started
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_04_nav IMPLEMENTATION.

  METHOD popup_app_answers_alone.

    DATA(lv_id) = caller_started( ).
    DATA(lo_handler) = event_on( iv_id    = lv_id
                                 iv_event = `ROW_SELECT` ).

    " the response names the CALLED app...
    DATA(lv_app) = lo_handler->ms_response-s_front-app.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_app CS `POPUP_BOUND` )
                                      msg = |the response names { lv_app }, not the popup app| ).
    " ...displays its popup and no main view...
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_handler
                                                     iv_slot    = z2ui5_if_client=>cs_view-popup ) ).
    cl_abap_unit_assert=>assert_false( check_display( io_handler = lo_handler
                                                      iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    " ...and ships ITS model, which knows nothing of the caller's table -
    " the reason the frontend must not push it into the caller's view
    cl_abap_unit_assert=>assert_true( xsdbool( lo_handler->ms_response-model CS `"MS_ROW"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_handler->ms_response-model CS `"edit me"` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lo_handler->ms_response-model CS `"MT_TAB"` ) ).

  ENDMETHOD.

  METHOD silent_popup_app_no_model.

    DATA(lv_id) = caller_started( ).
    DATA(lo_handler) = event_on( iv_id    = lv_id
                                 iv_event = `ROW_SELECT_SILENT` ).

    " a popup app with nothing bound: the popup opens, and no MODEL key
    " travels at all - the caller's view keeps what it has
    cl_abap_unit_assert=>assert_true( xsdbool( lo_handler->ms_response-s_front-app CS `POPUP_SILENT` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_handler
                                                     iv_slot    = z2ui5_if_client=>cs_view-popup ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lo_handler->mv_response CS `"MODEL"` ) ).

  ENDMETHOD.

  METHOD way_back_reads_popup_app.

    " samples 500/501: the popup app closes and leaves, the caller comes
    " back with check_on_navigated, reads the edit out of the popup app
    " (get_app_prev) and re-displays its table - one roundtrip, and the
    " response is the CALLER's again: its class, its main view, its model
    DATA(lv_id) = caller_started( ).
    DATA(lo_popup) = event_on( iv_id    = lv_id
                               iv_event = `ROW_SELECT` ).
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `CLOSE` ).

    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `POPUP_CALLER` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_back
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-model CS `"MT_TAB"` ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_back->ms_response-model CS `"edited"` )
                                      msg = `the caller could not read the popup app back` ).

  ENDMETHOD.

  METHOD same_class_twice_in_stack.

    DATA(lo_outer) = NEW ltcl_app_twice( ).
    lo_outer->mv_name = `outer`.
    DATA(lo_start) = started_with( lo_outer ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_start->ms_response-model CS `"outer"` ) ).

    " the hop: the inner instance answers, with ITS value under the same
    " attribute name
    DATA(lo_inner) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `CALL` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_inner->ms_response-s_front-app CS `APP_TWICE` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_inner
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_inner->ms_response-model CS `"inner"` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lo_inner->ms_response-model CS `"outer"` ) ).
    " two drafts, not one overwritten
    cl_abap_unit_assert=>assert_differs( exp = lo_start->ms_response-s_front-id
                                         act = lo_inner->ms_response-s_front-id ).

    " the way back: the OUTER instance again, its own value, and what it
    " read out of the inner
    DATA(lo_back) = event_on( iv_id    = lo_inner->ms_response-s_front-id
                              iv_event = `BACK` ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_back
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-model CS `"MV_NAME":"outer"` ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_back->ms_response-model CS `"MV_FROM_INNER":"inner"` )
                                      msg = `the outer could not read the inner back` ).

  ENDMETHOD.

  METHOD caller_started.

    DATA(lo_handler) = started_with( NEW ltcl_app_popup_caller( ) ).

    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_handler
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_handler->ms_response-model CS `"MT_TAB"` ) ).
    result = lo_handler->ms_response-s_front-id.

  ENDMETHOD.

ENDCLASS.
