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

" binds a value, changes it and leaves through nav_app_call in one main( )
CLASS ltcl_app_change_call DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_change_call IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    client->_bind( name ).
    name = `changed before the hop`.
    client->nav_app_call( NEW ltcl_app_noop( ) ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_noop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    " deliberately neither displays nor pushes - the auto-model-update tests
    " need a main( ) that returns without touching the response
    check_init = client->check_on_init( ).
  ENDMETHOD.

ENDCLASS.


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


" a popup app that is handed its CALLER (the `factory( app = me )` shape of
" the samples) and reads the caller's runtime-built table through that
" reference while the caller sits on the stack - saved a moment ago, its
" generic references detached for the draft and put back
CLASS ltcl_app_dref_caller DEFINITION DEFERRED.

CLASS ltcl_app_dref_popup DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mo_caller      TYPE REF TO ltcl_app_dref_caller.
    DATA mv_from_caller TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_dref_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
      END OF ty_s_row.
    " a table of a line type built at runtime - only S-RTTI carries it
    " through the draft, so the save detaches it and the restore brings it
    " back
    DATA mr_tab TYPE REF TO data.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_dref_popup IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <name> TYPE any.
    IF client->check_on_init( ).
      " the caller was saved by the hop that opened this app - its table
      " has to be there to read
      ASSIGN mo_caller->mr_tab->* TO <tab>.
      ASSIGN <tab>[ 2 ] TO <row>.
      ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
      IF sy-subrc = 0.
        mv_from_caller = <name>.
      ENDIF.
      client->popup_display( |<Dialog><Text text="{ client->_bind( mv_from_caller ) }"/></Dialog>| ).
    ELSEIF client->check_on_event( `CLOSE` ).
      client->popup_destroy( ).
      client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ELSEIF client->check_on_event( `APPEND` ).
      " the popup app writes INTO the caller's table and goes back to the
      " caller it holds - the shape of a popup that edits its caller's data
      ASSIGN mo_caller->mr_tab->* TO <tab>.
      INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
      ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
      IF sy-subrc = 0.
        <name> = `three`.
      ENDIF.
      client->popup_destroy( ).
      client->nav_app_leave( mo_caller ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_dref_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row TYPE ty_s_row.
    IF client->check_on_init( ).
      " an anonymous line type from the components of a known one - what
      " S-RTTI can rebuild without a type name (see ltcl_app_shapes)
      DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_row ) ).
      DATA(lt_comp) = lo_line->get_components( ).
      DATA(lo_struc) = cl_abap_structdescr=>create( lt_comp ).
      DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = lo_struc
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std ).
      CREATE DATA mr_tab TYPE HANDLE lo_tab.
      ASSIGN mr_tab->* TO <tab>.
      ls_row-name = `one`.
      INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
      MOVE-CORRESPONDING ls_row TO <row>.
      ls_row-name = `two`.
      INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
      MOVE-CORRESPONDING ls_row TO <row>.
      client->view_display( |<mvc:View><Table items="{ client->_bind( <tab> ) }"/></mvc:View>| ).
    ELSEIF client->check_on_navigated( ).
      ASSIGN mr_tab->* TO <tab>.
      client->view_display( |<mvc:View><Table items="{ client->_bind( <tab> ) }"/></mvc:View>| ).
    ELSEIF client->check_on_event( `OPEN` ).
      DATA(lo_popup) = NEW ltcl_app_dref_popup( ).
      lo_popup->mo_caller = me.
      client->nav_app_call( lo_popup ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_request DEFINITION DEFERRED.
CLASS ltcl_02_response DEFINITION DEFERRED.
CLASS ltcl_03_dispatch DEFINITION DEFERRED.
CLASS ltcl_04_nav DEFINITION DEFERRED.
CLASS ltcl_05_monitor DEFINITION DEFERRED.
CLASS ltcl_06_draft DEFINITION DEFERRED.
CLASS ltcl_07_timer DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_handler DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_request ltcl_02_response
                                                  ltcl_03_dispatch ltcl_04_nav ltcl_05_monitor
                                                  ltcl_06_draft ltcl_07_timer.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    "! the response's VIEWS and NAV sections as their JSON, pipe-joined - so
    "! the auto-update/nav tests can assert on them like on text
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
        iv_model      TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_handler.

    METHODS check_display
      IMPORTING
        io_handler    TYPE REF TO z2ui5_cl_ui5_handler
        iv_slot       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " a handler on a fresh ltcl_app_noop whose CHECK_INIT is bound - the
    " auto-model-update tests need one attribute the snapshot can see
    METHODS noop_bound
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_handler.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD noop_bound.

    result = NEW #( val = `` ).
    DATA(lo_app) = NEW ltcl_app_noop( ).
    result->mo_action->mo_app->mo_app      = lo_app.
    result->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = result->mo_action->mo_app->mt_attri
                                                  app  = lo_app ).
    " main_attri_refresh runs the (private) dissolve pass - on this fresh,
    " unbound model it is a pure dissolve, which is all the test needs
    lo_model->main_attri_refresh( ).
    ASSIGN result->mo_action->mo_app->mt_attri->*[ name = `CHECK_INIT` ] TO FIELD-SYMBOL(<attri>).
    IF <attri> IS NOT ASSIGNED.
      cl_abap_unit_assert=>abort( ).
      RETURN.
    ENDIF.
    <attri>-bind        = abap_true.
    <attri>-name_client = `/CHECK_INIT`.

  ENDMETHOD.

  METHOD system_actions_of.

    " the two sections of the response that say what the screen is after the
    " roundtrip - VIEWS and NAV - as their JSON, `|` between them. The name
    " is from the time both were action lists
    IF val->ms_response-s_front-o_views IS BOUND.
      result = val->ms_response-s_front-o_views->stringify( ).
    ENDIF.
    result = result && `|`.
    IF val->ms_response-s_front-o_nav IS BOUND.
      result = result && val->ms_response-s_front-o_nav->stringify( ).
    ENDIF.

  ENDMETHOD.

  METHOD started_with.

    result = NEW z2ui5_cl_ui5_handler( val = `` ).
    result->mo_action->mo_app->mo_app      = io_app.
    result->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    result->main_loop( ).

  ENDMETHOD.

  METHOD event_on.

    DATA(lv_payload) = `{"value":{"S_FRONT":{"ID":"` && iv_id && `","EVENT":"` && iv_event &&
                       `","ORIGIN":"O","PATHNAME":"/","SEARCH":""}`.
    IF iv_model IS NOT INITIAL.
      lv_payload = lv_payload && `,"MODEL":` && iv_model.
    ENDIF.
    lv_payload = lv_payload && `}}`.
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
    METHODS test_parse_device_os FOR TESTING RAISING cx_static_check.
    METHODS test_parse_number_too_big FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_no_config FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_string FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_object FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_limit FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_arg_edge FOR TESTING RAISING cx_static_check.
    METHODS test_parse_body_config_leaves FOR TESTING RAISING cx_static_check.
    METHODS test_request_app_start FOR TESTING RAISING cx_static_check.
    METHODS test_start_app_2nd_roundtrip FOR TESTING RAISING cx_static_check.
    METHODS test_request_with_id FOR TESTING RAISING cx_static_check.
    METHODS test_context_info_sanitized FOR TESTING RAISING cx_static_check.
    METHODS test_context_info_stale_action FOR TESTING RAISING cx_static_check.
    METHODS test_request_app_start_ns FOR TESTING RAISING cx_static_check.
    METHODS test_app_start_encoded_slash FOR TESTING RAISING cx_static_check.
    METHODS test_app_start_normalize FOR TESTING RAISING cx_static_check.
    METHODS test_context_info_capped FOR TESTING RAISING cx_static_check.
    METHODS test_context_info_url_safe FOR TESTING RAISING cx_static_check.
    METHODS test_hash_shell_part FOR TESTING RAISING cx_static_check.
    METHODS test_app_get_url FOR TESTING RAISING cx_static_check.
    METHODS test_route_from_request FOR TESTING RAISING cx_static_check.
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
    DATA lo_startup TYPE REF TO z2ui5_cl_ui5_app_start.

    lv_payload = `{"value" : { "S_FRONT":{"ORIGIN":"ORIGIN","PATHNAME":"PATHNAME","SEARCH":""}}}`.

    lo_post = NEW #( val = lv_payload ).
    lo_post->main_begin( ).

    cl_abap_unit_assert=>assert_bound( lo_post->mo_action ).

    cl_abap_unit_assert=>assert_equals( exp = `ORIGIN`
                                        act = lo_post->ms_request-s_front-origin ).

    cl_abap_unit_assert=>assert_equals( exp = `PATHNAME`
                                        act = lo_post->ms_request-s_front-pathname ).

    lo_startup ?= lo_post->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_bound( lo_startup ).

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

    " the request tree itself, read below the path of its MODEL node - no
    " slice (z2ui5_if_ui5_types=>ty_s_request-model_path)
    cl_abap_unit_assert=>assert_bound( ls_request-o_model ).
    cl_abap_unit_assert=>assert_equals( exp = `/value/MODEL`
                                        act = ls_request-model_path ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( ls_request-model_path && `/NAME` ) ).
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
    cl_abap_unit_assert=>assert_equals( exp = `/MODEL`
                                        act = ls_request-model_path ).
    cl_abap_unit_assert=>assert_equals( exp = `test-value`
                                        act = ls_request-o_model->get_string( ls_request-model_path && `/NAME` ) ).
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

  METHOD test_parse_number_too_big.

    " a number type i cannot take, in one of the diagnostic numbers of the
    " CONFIG block, is dropped like a missing one - it raised a conversion
    " error out of the parse and ended the roundtrip in a 500. 1e10 is the
    " overflow a system raises on (the transpiled runtime does not check the
    " range of i, so its value is not asserted here); 1e-7, the way
    " JSON.stringify writes a tiny fraction, is no number for i in the
    " runtime - the case that fails there without the guard
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"S_DEVICE":{"RESIZE":{"WIDTH":1e10,"HEIGHT":800}},` &&
                 `"S_FOCUS":{"ID":"in","SELECTION_START":1e-7,"SELECTION_END":3},` &&
                 `"S_SCROLL":{"MAIN":{"ID":"page","X":1e-7,"Y":1e10}}}}}}`.
    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_front-id ).
    cl_abap_unit_assert=>assert_equals( exp = 800
                                        act = ls_request-s_front-s_device-resize-height ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_focus-selection_start ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = ls_request-s_front-s_focus-selection_end ).
    cl_abap_unit_assert=>assert_equals( exp = `page`
                                        act = ls_request-s_front-s_scroll-main-id ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_scroll-main-x ).

  ENDMETHOD.

  METHOD test_parse_device_os.

    " UI5 reports sap.ui.Device.os.OS.IOS / .ANDROID as `iOS` / `Android`;
    " an app compares with the lower-case constants of cs_device-os, which
    " never matched. Mapped onto the constant; a name that is none of them
    " (sap.ui.Device.os.OS.BLACKBERRY of 1.71) arrives as it was sent
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"S_DEVICE":{"OS":{"NAME":"iOS","VERSION":"17"}}}}}}`.
    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_device-os-ios
                                        act = ls_request-s_front-s_device-os-name ).

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"S_DEVICE":{"OS":{"NAME":"Android","VERSION":"14"}}}}}}`.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_device-os-android
                                        act = ls_request-s_front-s_device-os-name ).

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"S_DEVICE":{"OS":{"NAME":"win","VERSION":"10"}}}}}}`.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_client=>cs_device-os-windows
                                        act = ls_request-s_front-s_device-os-name ).

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"S_DEVICE":{"OS":{"NAME":"bb","VERSION":"10"}}}}}}`.
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_equals( exp = `bb`
                                        act = ls_request-s_front-s_device-os-name ).

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
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":["plain",5,true,{"KEY":"val"},[1,2],false,"true"]}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 7
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
    " the OTHER half of the boolean convention, and the reason this branch
    " exists at all: a handler comparing `= abap_true` has to see a space for
    " false, not the four characters `false`. The suite runs on the
    " TRANSPILED backend, so this is also what pins the open-abap side - the
    " divergence backlog/items/boolean-event-arg-string-in-transpiler.md was
    " filed for is closed HERE, at the boundary, rather than in the runtime
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = ls_request-s_front-t_event_arg[ 6 ] ).
    " ...and a JSON STRING that happens to read `true` keeps the word. The
    " normalization is about the node TYPE; a port transporting the token
    " deliberately (the workaround app 421 carries) must not be rewritten
    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = ls_request-s_front-t_event_arg[ 7 ] ).
  ENDMETHOD.

  METHOD test_parse_body_arg_edge.
    " the edges of the argument list: none at all, a null, an empty string
    " and an empty object keep their positions, and an object argument
    " carrying escapes reaches the app as JSON that still parses to the
    " same text - quote, backslash, line break and a \u escape
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":[]}}}`.
    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-t_event_arg ).
    cl_abap_unit_assert=>assert_equals( exp = `MY_EVENT`
                                        act = ls_request-s_front-event ).

    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":[null,"",{},{"K":"a\"b\\c\nd\u0041"},"last"]}}}`.
    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = lines( ls_request-s_front-t_event_arg ) ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-t_event_arg[ 1 ] ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-t_event_arg[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = ls_request-s_front-t_event_arg[ 3 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `last`
                                        act = ls_request-s_front-t_event_arg[ 5 ] ).
    DATA(lo_arg) = z2ui5_cl_ajson=>parse( ls_request-s_front-t_event_arg[ 4 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `a"b\c` && z2ui5_cl_ui5_util_context=>cv_char_util_newline && `dA`
                                        act = lo_arg->get_string( `/K` ) ).
  ENDMETHOD.

  METHOD test_parse_body_arg_limit.
    " one over the bound of object/array arguments is refused before the
    " quadratic slice( ) per argument can run; the bound itself still parses
    DATA lv_payload TYPE string.
    DATA lv_args    TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.

    DO 99 TIMES.
      lv_args = lv_args && `[],`.
    ENDDO.
    " 101 arguments: the 99 arrays, one more array and a string
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":[` && lv_args && `[],"last"]}}}`.
    lo_handler = NEW #( val = lv_payload ).
    TRY.
        ls_request = lo_handler->request_json_to_abap( lv_payload ).
        cl_abap_unit_assert=>fail( `101 event arguments were accepted` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp( act = lx->get_text( )
                                             exp = `*EVENT_ARG_LIMIT_ERROR*` ).
    ENDTRY.

    " exactly 100 arguments - the bound itself - still parse, the object
    " among them included
    lv_payload = `{"value":{"S_FRONT":{"ID":"ABC123","ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"EVENT":"MY_EVENT","T_EVENT_ARG":[` && lv_args && `{"KEY":"val"}]}}}`.
    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = lines( ls_request-s_front-t_event_arg ) ).
  ENDMETHOD.

  METHOD test_parse_body_config_leaves.
    " every leaf of the CONFIG block is read by its own keyed lookup now
    " (no slice, no to_abap) - so every nested field is pinned here, next to
    " a model delta of a few rows that must not get in the way: the numbers
    " arrive as numbers, the flags as booleans, a slot never scrolled stays
    " initial, and the launchpad data keeps a tree of its own
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"MODEL":{"MT_TAB":{"__delta":{"0":{"COL1":"a"},"1":{"COL1":"b"}}},"MV_STRING":"x"},` &&
                 `"S_FRONT":{"ID":"ABC123","EVENT":"SAVE","HASH":"#/app/X","ORIGIN":"O","PATHNAME":"/p","SEARCH":"?a=1",` &&
                 `"CONFIG":{"ComponentData":{"startupParameters":{"p":["v"]}},` &&
                 `"S_DEVICE":{"SYSTEM":"phone","ORIENTATION":"portrait","BROWSER":{"NAME":"cr","VERSION":"120"},` &&
                 `"OS":{"NAME":"mac","VERSION":"14"},"RESIZE":{"WIDTH":900,"HEIGHT":600},` &&
                 `"SUPPORT":{"TOUCH":true,"POINTER":false,"RETINA":true}},` &&
                 `"S_FOCUS":{"ID":"inp","SELECTION_START":2,"SELECTION_END":5},` &&
                 `"S_SCROLL":{"MAIN":{"ID":"page","X":0,"Y":150},"POPUP":{"ID":"dlg","X":3,"Y":40}},` &&
                 `"S_UI5":{"VERSION":"1.120.0","BUILDTIMESTAMP":"20240101","GAV":"g","THEME":"sap_horizon"}}}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_front-id ).
    cl_abap_unit_assert=>assert_equals( exp = `SAVE`
                                        act = ls_request-s_front-event ).
    cl_abap_unit_assert=>assert_equals( exp = `#/app/X`
                                        act = ls_request-s_front-hash ).
    cl_abap_unit_assert=>assert_equals( exp = `?a=1`
                                        act = ls_request-s_front-search ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-t_event_arg ).

    cl_abap_unit_assert=>assert_equals( exp = `phone`
                                        act = ls_request-s_front-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `portrait`
                                        act = ls_request-s_front-s_device-orientation ).
    cl_abap_unit_assert=>assert_equals( exp = `cr`
                                        act = ls_request-s_front-s_device-browser-name ).
    cl_abap_unit_assert=>assert_equals( exp = `120`
                                        act = ls_request-s_front-s_device-browser-version ).
    cl_abap_unit_assert=>assert_equals( exp = `mac`
                                        act = ls_request-s_front-s_device-os-name ).
    cl_abap_unit_assert=>assert_equals( exp = `14`
                                        act = ls_request-s_front-s_device-os-version ).
    cl_abap_unit_assert=>assert_equals( exp = 900
                                        act = ls_request-s_front-s_device-resize-width ).
    cl_abap_unit_assert=>assert_equals( exp = 600
                                        act = ls_request-s_front-s_device-resize-height ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_request-s_front-s_device-support-touch ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_request-s_front-s_device-support-pointer ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_request-s_front-s_device-support-retina ).

    cl_abap_unit_assert=>assert_equals( exp = `inp`
                                        act = ls_request-s_front-s_focus-id ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_request-s_front-s_focus-selection_start ).
    cl_abap_unit_assert=>assert_equals( exp = 5
                                        act = ls_request-s_front-s_focus-selection_end ).

    cl_abap_unit_assert=>assert_equals( exp = `page`
                                        act = ls_request-s_front-s_scroll-main-id ).
    cl_abap_unit_assert=>assert_equals( exp = 150
                                        act = ls_request-s_front-s_scroll-main-y ).
    cl_abap_unit_assert=>assert_equals( exp = `dlg`
                                        act = ls_request-s_front-s_scroll-popup-id ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = ls_request-s_front-s_scroll-popup-x ).
    cl_abap_unit_assert=>assert_equals( exp = 40
                                        act = ls_request-s_front-s_scroll-popup-y ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_scroll-nest ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-s_scroll-popover ).

    cl_abap_unit_assert=>assert_equals( exp = `g`
                                        act = ls_request-s_front-s_ui5-gav ).

    cl_abap_unit_assert=>assert_bound( ls_request-s_front-o_comp_data ).
    cl_abap_unit_assert=>assert_equals( exp = `v`
                                        act = ls_request-s_front-o_comp_data->get_string( `/startupParameters/p/1` ) ).

    " the model next to it is untouched and still read in place
    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = ls_request-o_model->get_string( ls_request-model_path && `/MV_STRING` ) ).

  ENDMETHOD.

  METHOD test_start_app_2nd_roundtrip.

    " The shipped start app holds its client PUBLIC. Until 2026-09-19 the
    " dissolve walk followed it into the framework graph (300 rows under
    " CLIENT->, one of them the container's own row table), the save
    " detached that table and wrote an empty MT_ATTRI into the draft, and
    " the second roundtrip of the start page - any button on it - had no rows
    " to load. No test drove two roundtrips of the start app, so nothing saw
    " it. This one does: a first start, then an event on the draft it wrote.
    DATA(lo_first) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_START"}}}` ).
    lo_first->main( ).
    DATA(lv_id) = lo_first->mo_action->mo_app->ms_draft-id.
    cl_abap_unit_assert=>assert_not_initial( lv_id ).

    LOOP AT lo_first->mo_action->mo_app->mt_attri->* REFERENCE INTO DATA(lr_attri).
      IF lr_attri->name CP `CLIENT->*`.
        cl_abap_unit_assert=>fail( |the dissolve walk followed the client: { lr_attri->name }| ).
      ENDIF.
    ENDLOOP.

    DATA(lo_second) = event_on( iv_id    = lv_id
                                iv_event = `BUTTON_CHECK` ).
    cl_abap_unit_assert=>assert_bound( lo_second->mo_action->mo_app->mt_attri ).
    cl_abap_unit_assert=>assert_not_initial( lines( lo_second->mo_action->mo_app->mt_attri->* ) ).
    DATA(lo_startup) = CAST z2ui5_cl_ui5_app_start( lo_second->mo_action->mo_app->mo_app ).
    cl_abap_unit_assert=>assert_bound( lo_startup ).

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

  METHOD test_context_info_stale_action.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " a sticky handler whose next body fails to parse still holds the
    " previous roundtrip's action - its event must not annotate the failure
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action = NEW z2ui5_cl_ui5_action( lo_handler ).
    lo_handler->mo_action->ms_actual-event = `PREVIOUS_EVENT`.

    DATA(lv_info) = lo_handler->request_context_info( ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_info CS `PREVIOUS_EVENT` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_info CS `request not parsed` ) ).

    " once the body is parsed the event is this request's
    lo_handler->mv_request_parsed = abap_true.
    lv_info = lo_handler->request_context_info( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_info CS `event PREVIOUS_EVENT` ) ).

  ENDMETHOD.

  METHOD test_request_app_start_ns.

    " a namespaced class in a launchpad startup parameter arrives as
    " `-ns-class` (no slash survives the intent) and is the class it spells
    DATA lv_payload TYPE string.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_request TYPE z2ui5_if_ui5_types=>ty_s_request.
    lv_payload = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"",` &&
                 `"CONFIG":{"ComponentData":{"startupParameters":{"app_start":["-ns-zcl_my_app"]}}}}}}`.

    lo_handler = NEW #( val = lv_payload ).
    ls_request = lo_handler->request_json_to_abap( lv_payload ).

    cl_abap_unit_assert=>assert_equals( exp = `/NS/ZCL_MY_APP`
                                        act = ls_request-s_control-app_start ).

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

  METHOD test_app_start_normalize.

    " the one normalisation of an app class name, shared with the exit
    " context: trimmed and upper-cased, the two namespace spellings a
    " request can carry both spelled back to /ns/class
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_MY_APP`
                                        act = z2ui5_cl_ui5_handler=>app_start_normalize( ` zcl_my_app ` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `/NS/ZCL_MY_APP`
                                        act = z2ui5_cl_ui5_handler=>app_start_normalize( `%2Fns%2Fzcl_my_app` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `/NS/ZCL_MY_APP`
                                        act = z2ui5_cl_ui5_handler=>app_start_normalize( `-ns-zcl_my_app` ) ).
    " a hyphen not in first position is left alone - only the launchpad
    " prefix is spelled back
    cl_abap_unit_assert=>assert_equals( exp = `ZCL-X`
                                        act = z2ui5_cl_ui5_handler=>app_start_normalize( `zcl-x` ) ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_handler=>app_start_normalize( `` ) ).

    " the query path reads the launchpad spelling too now
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_no_comp_data TYPE REF TO z2ui5_if_ajson.
    lo_handler = NEW #( val = `` ).
    cl_abap_unit_assert=>assert_equals(
        exp = `/NS/ZCL_APP`
        act = lo_handler->request_app_start( iv_search    = `?app_start=-ns-zcl_app`
                                             io_comp_data = lo_no_comp_data ) ).

  ENDMETHOD.

  METHOD test_context_info_capped.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lv_long    TYPE string.

    " the event name and the draft id come off the request like the url,
    " and are capped like it - a crafted body cannot pad the error page
    DO 400 TIMES.
      lv_long = lv_long && `E`.
    ENDDO.
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action = NEW z2ui5_cl_ui5_action( lo_handler ).
    lo_handler->mo_action->ms_actual-event = lv_long.
    lo_handler->mo_action->mo_app->ms_draft-id_prev = lv_long.
    lo_handler->mv_request_parsed = abap_true.

    DATA(lv_info) = lo_handler->request_context_info( ).

    cl_abap_unit_assert=>assert_false( xsdbool( lv_info CS lv_long ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_info CS |event { lv_long(300) }...| ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_info CS |draft { lv_long(300) }...| ) ).

  ENDMETHOD.

  METHOD test_context_info_url_safe.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " the url comes off the request and is quoted in the 500 body: markup
    " and quotes a crafted request puts into it do not reach the body
    " (protocol check error.no-reflection), a blank does not either
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-pathname = `/sap/bc/z2ui5`.
    lo_handler->ms_request-s_front-search   = `?app_start=ZCL_X&p=<script>alert("x")</script><img src='y'> z`.

    DATA(lv_info) = lo_handler->request_context_info( ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_info
        exp = `*url /sap/bc/z2ui5?app_start=ZCL_X&p=scriptalertx/scriptimgsrc=yz` ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_info CA `<>"'` ) ).

    " what a browser sends - percent-encoded - passes unchanged
    cl_abap_unit_assert=>assert_equals(
        exp = `/sap/bc/z2ui5?app_start=ZCL_X&q=a%20b%3C+c.d_e-f~g:h`
        act = z2ui5_cl_ui5_handler=>context_info_url_safe( `/sap/bc/z2ui5?app_start=ZCL_X&q=a%20b%3C+c.d_e-f~g:h` ) ).

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

  METHOD test_route_from_request.

    " What the hash asks an app start to restore arrives parsed, as
    " S_FRONT.ROUTE - the frontend's Router is the one reader of the hash
    " (node/tests/router.spec.js has the shapes the backend's own parsers
    " were tested with until protocol 3). A route names the class and the
    " draft, and wins over the query
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    DATA(ls_request) = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"SEARCH":"?app_start=zcl_other","HASH":"#/app/zcl_x/abc123",` &&
        `"ROUTE":{"APP":"zcl_x","DRAFT":"abc123"}}}}` ).
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_X`
                                        act = ls_request-s_control-app_start ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_control-app_start_draft ).
    " a route restore is not the app's opt-in to the app-state hash
    cl_abap_unit_assert=>assert_false( ls_request-s_control-check_app_state ).

    " a namespaced class travels with its slashes
    ls_request = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"ROUTE":{"APP":"/NS/CL_X"}}}}` ).
    cl_abap_unit_assert=>assert_equals( exp = `/NS/CL_X`
                                        act = ls_request-s_control-app_start ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_control-app_start_draft ).

    " an app-state link names the draft only: the app comes from the query
    " (or from nowhere), and the hash stays the app's opt-in
    ls_request = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"SEARCH":"?app_start=zcl_other","ROUTE":{"APP_STATE":"abc123"}}}}` ).
    cl_abap_unit_assert=>assert_equals( exp = `ZCL_OTHER`
                                        act = ls_request-s_control-app_start ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC123`
                                        act = ls_request-s_control-app_start_draft ).
    cl_abap_unit_assert=>assert_true( ls_request-s_control-check_app_state ).

    " the raw hash alone starts nothing - the backend parses none
    ls_request = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"HASH":"#/app/zcl_x/abc123"}}}` ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_control-app_start ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_control-app_start_draft ).

    " ... and an event roundtrip reads no route at all
    ls_request = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"ID":"D1","ROUTE":{"APP":"zcl_x"}}}}` ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_control-app_start ).

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
    METHODS test_response_control_chars FOR TESTING RAISING cx_static_check.
    METHODS test_response_actions_embedded FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_flag FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_popup FOR TESTING RAISING cx_static_check.
    METHODS test_view_update_none FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_push FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_same FOR TESTING RAISING cx_static_check.
    METHODS test_nested_display_push FOR TESTING RAISING cx_static_check.
    METHODS test_auto_update_snapshot FOR TESTING RAISING cx_static_check.
    METHODS test_stale_forces_push FOR TESTING RAISING cx_static_check.
    METHODS test_display_clears_stale FOR TESTING RAISING cx_static_check.
    METHODS test_new_binding_pushes FOR TESTING RAISING cx_static_check.
    METHODS test_nav_call_marks_stale FOR TESTING RAISING cx_static_check.
    METHODS test_system_slot_order FOR TESTING RAISING cx_static_check.
    METHODS test_system_last_wins FOR TESTING RAISING cx_static_check.
    METHODS test_system_empty FOR TESTING RAISING cx_static_check.
    METHODS test_system_destroy_only FOR TESTING RAISING cx_static_check.
    METHODS test_session_stored FOR TESTING RAISING cx_static_check.
    METHODS test_session_location FOR TESTING RAISING cx_static_check.
    METHODS test_session_launchpad FOR TESTING RAISING cx_static_check.
    METHODS test_session_from_draft FOR TESTING RAISING cx_static_check.
    METHODS test_session_new_device FOR TESTING RAISING cx_static_check.
    " the UI5 version info arriving on a later roundtrip, alone
    METHODS test_session_ui5_later FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_response IMPLEMENTATION.

  METHOD test_response_json.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    DATA lv_json TYPE string.
    lo_handler = NEW #( val = `` ).

    ls_response = VALUE #( s_front-id  = `ID123`
                           s_front-app = `Z2UI5_CL_UI5_APP_HI_WORLD`
                           model       = `{"name":"test"}` ).


    lv_json = lo_handler->response_abap_to_json( ls_response ).


    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `S_FRONT` ) ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `MODEL` ) ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `{"name":"test"}` ) ).

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

  METHOD test_response_control_chars.

    " a bound string carrying U+0001 must leave as JSON the browser can
    " parse: JSON.parse refuses a raw control character inside a string,
    " and with it the whole response
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    lo_handler = NEW #( val = `` ).
    DATA(lv_ctrl) = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( CONV xstring( `01` ) ).
    ls_response-s_front-id = `ID123`.
    ls_response-model      = z2ui5_cl_ajson=>create_empty( )->set( iv_path = `/NAME`
                                                                   iv_val  = `a` && lv_ctrl && `b` )->stringify( ).

    DATA(lv_json) = lo_handler->response_abap_to_json( ls_response ).

    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CA lv_ctrl ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"MODEL":{"NAME":"a\u0001b"}` ) ).

  ENDMETHOD.

  METHOD test_response_actions_embedded.

    " the action list and the sections leave as REAL nested JSON, not as
    " escaped strings - and an empty-string positional placeholder inside an
    " action survives, as an empty view does
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA ls_response TYPE z2ui5_if_ui5_types=>ty_s_response.
    lo_handler = NEW #( val = `` ).
    ls_response-s_front-id = `ID123`.
    INSERT VALUE #( o_json = z2ui5_cl_ajson=>parse( `["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]` ) )
           INTO TABLE ls_response-s_front-s_action-t_custom.
    ls_response-s_front-o_views = z2ui5_cl_ajson=>parse( `{"MAIN":{"XML":""},"POPUP":{"DESTROY":true}}` ).
    ls_response-s_front-o_nav   = z2ui5_cl_ajson=>parse( `{"setNavRouting":"KEEP"}` ).

    DATA(lv_json) = lo_handler->response_abap_to_json( ls_response ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_json CS `"ACTIONS":[["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]]` ) ).
    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_json CS `"VIEWS":{"MAIN":{"XML":""},"POPUP":{"DESTROY":true}}` ) ).
    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_json CS `"NAV":{"setNavRouting":"KEEP"}` ) ).
    " a response without a section carries no key for it
    CLEAR: ls_response-s_front-o_views, ls_response-s_front-o_nav.
    lv_json = lo_handler->response_abap_to_json( ls_response ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CS `"VIEWS"` OR lv_json CS `"NAV"` ) ).
    " ... and nothing else of the structure it is built from: the two
    " references used to leave as "O_VIEWS":null,"O_NAV":null
    cl_abap_unit_assert=>assert_equals(
        exp = `{"S_FRONT":{"ACTIONS":[["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]],"ID":"ID123","PROTOCOL":3}}`
        act = lv_json ).

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

    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_handler
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).

  ENDMETHOD.

  METHOD test_view_update_popup.

    " the same holds whichever slot was displayed...
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    DATA li_client TYPE REF TO z2ui5_if_client.
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).
    li_client->popup_display( `<Dialog/>` ).

    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_handler
                                                     iv_slot    = z2ui5_if_client=>cs_view-popup ) ).

    " ...and a display a later destroy voided counts as NO view, so the
    " model is not sent for a dialog that never reaches the browser
    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_false( check_display( io_handler = lo_handler
                                                      iv_slot    = z2ui5_if_client=>cs_view-popup ) ).

  ENDMETHOD.

  METHOD test_view_update_none.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    cl_abap_unit_assert=>assert_false(
        xsdbool( line_exists( lo_handler->mo_action->ms_next-t_action_front[ method = `display` ] ) ) ).

  ENDMETHOD.

  METHOD test_auto_update_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " a bound value differs from its snapshot after main( ) - the model is
    " sent with no app opt-in of any kind: automatic model update is always on
    lo_handler = noop_bound( ).
    lo_handler->mt_model_before       = lo_handler->mo_action->mo_app->model_snapshot( ).
    lo_handler->mv_model_before_taken = abap_true.
    CAST ltcl_app_noop( lo_handler->mo_action->mo_app->mo_app )->check_init = abap_true.

    lo_handler->main_end( ).

    " the MODEL key itself IS the push - no updateModel action travels,
    " the frontend pushes into every open slot when a model arrived
    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).
    cl_abap_unit_assert=>assert_equals( exp = lo_handler->mo_action->mo_app->model_json_stringify( )
                                        act = lo_handler->ms_response-model ).

  ENDMETHOD.

  METHOD test_auto_update_same.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main( ) changed nothing - the response stays `{}` and no update flag is
    " set, so an idle event round-trip carries no model payload as before
    lo_handler = noop_bound( ).
    lo_handler->mt_model_before       = lo_handler->mo_action->mo_app->model_snapshot( ).
    lo_handler->mv_model_before_taken = abap_true.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = lo_handler->ms_response-model ).
    " an unchanged model asks for no push at all
    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).

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
    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `updateModel` ) ).

  ENDMETHOD.

  METHOD test_auto_update_snapshot.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " main_process always takes a before-main snapshot
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_process( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_handler->mv_model_before_taken ).

  ENDMETHOD.

  METHOD test_stale_forces_push.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " a change this app made and never pushed (it left through nav_app_call)
    " is flagged on the app: the roundtrip that brings the user back pushes
    " the model although THIS main( ) changed nothing, and settles the flag
    lo_handler = noop_bound( ).
    lo_handler->mt_model_before       = lo_handler->mo_action->mo_app->model_snapshot( ).
    lo_handler->mv_model_before_taken = abap_true.
    lo_handler->mo_action->mo_app->mv_model_client_stale = abap_true.

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_handler->mo_action->mo_app->model_json_stringify( )
                                        act = lo_handler->ms_response-model ).
    cl_abap_unit_assert=>assert_false( lo_handler->mo_action->mo_app->mv_model_client_stale ).

  ENDMETHOD.

  METHOD test_display_clears_stale.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.

    " a display ships the model with the view - the client holds the current
    " model afterwards, so nothing is left to push
    lo_handler = noop_bound( ).
    lo_handler->mo_action->mo_app->mv_model_client_stale = abap_true.
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).
    li_client->view_display( `<View/>` ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_false( lo_handler->mo_action->mo_app->mv_model_client_stale ).

  ENDMETHOD.

  METHOD test_new_binding_pushes.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " an attribute bound by this main( ) has no snapshot - the client holds
    " no value for it, so it counts as changed and the model travels
    lo_handler = NEW #( val = `` ).
    DATA(lo_app) = NEW ltcl_app_noop( ).
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mt_model_before       = lo_handler->mo_action->mo_app->model_snapshot( ).
    lo_handler->mv_model_before_taken = abap_true.
    cl_abap_unit_assert=>assert_initial( lo_handler->mt_model_before ).

    DATA(li_client) = CAST z2ui5_if_client( NEW z2ui5_cl_ui5_client( lo_handler->mo_action ) ).
    li_client->_bind( lo_app->check_init ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_differs( exp = `{}`
                                         act = lo_handler->ms_response-model ).

  ENDMETHOD.

  METHOD test_nav_call_marks_stale.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " the caller binds and changes a value and hops away in the same main( ):
    " no response of its own carries the change, so the container that
    " prepare_app_stack saved is flagged - its next roundtrip pushes
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_change_call( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    DATA(lo_caller) = lo_handler->mo_action->mo_app.

    lo_handler->main_process( ).

    cl_abap_unit_assert=>assert_true( lo_caller->mv_model_client_stale ).
    " the hop was taken: the handler now answers for the called app
    cl_abap_unit_assert=>assert_false( xsdbool( lo_handler->mo_action->mo_app = lo_caller ) ).
    cl_abap_unit_assert=>assert_false( lo_handler->mo_action->mo_app->mv_model_client_stale ).

  ENDMETHOD.

  METHOD test_system_slot_order.

    " The app displays in whatever order suits it - here nested first, main
    " last. Every slot gets its entry in VIEWS, and none is sorted: the
    " order they are built in - MAIN first, a nested view is inserted INTO
    " the main control tree - is the frontend's (View1._applyViews).
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

    DATA(li_views) = NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<View/>|<Nest/>|<Nest2/>|<Dialog/>|<Popover/>`
        act = |{ li_views->get_string( `/MAIN/XML` ) }\|{ li_views->get_string( `/NEST/XML` ) }\|| &&
              |{ li_views->get_string( `/NEST2/XML` ) }\|{ li_views->get_string( `/POPUP/XML` ) }\|| &&
              |{ li_views->get_string( `/POPOVER/XML` ) }| ).
    " the slot's own extras ride as its options
    cl_abap_unit_assert=>assert_equals( exp = `btn`
                                        act = li_views->get_string( `/POPOVER/OPT/openById` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `addMidColumnPage`
                                        act = li_views->get_string( `/NEST/OPT/methodInsert` ) ).

  ENDMETHOD.

  METHOD test_system_last_wins.

    " A slot displayed twice is displayed ONCE, with the last XML: the
    " second call drops everything the first queued. No teardown travels
    " with a display - a display REPLACES the slot.
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_handler = NEW #( val = `` ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    li_client->view_display( `<First/>` ).
    li_client->view_display( `<Second/>` ).

    cl_abap_unit_assert=>assert_equals(
        exp = `{"MAIN":{"XML":"<Second/>"}}`
        act = NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( )->stringify( ) ).

  ENDMETHOD.

  METHOD test_system_empty.

    " a roundtrip that touches no slot has an empty VIEWS section - and the
    " response then carries none (response_abap_to_json)
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).

    cl_abap_unit_assert=>assert_true(
        NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( )->is_empty( ) ).

  ENDMETHOD.

  METHOD test_system_destroy_only.

    " A bare destroy - popup_destroy( ) without a follow-up display - leaves
    " as the slot's entry with DESTROY and nothing else: no XML, no options
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA li_client TYPE REF TO z2ui5_if_client.
    lo_handler = NEW #( val = `` ).
    li_client = NEW z2ui5_cl_ui5_client( lo_handler->mo_action ).

    li_client->popup_destroy( ).

    cl_abap_unit_assert=>assert_equals(
        exp = `{"POPUP":{"DESTROY":true}}`
        act = NEW z2ui5_cl_ui5_frontend( lo_handler->mo_action )->slots_serialize( )->stringify( ) ).

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

  METHOD test_session_ui5_later.

    " the first roundtrip of a page load carries the device block WITHOUT
    " the version info (loaded asynchronously, the first paint does not
    " wait for it); the roundtrip that brings S_UI5 alone merges it into
    " the stored block - the device profile stays, the live fields merge as
    " on any event roundtrip - and the next one is answered from the draft
    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    lo_handler = NEW #( val = `` ).
    lo_handler->ms_request-s_front-s_device-system      = `phone`.
    lo_handler->ms_request-s_front-s_device-os-name     = `iOS`.
    lo_handler->ms_request-s_front-s_device-orientation = `portrait`.
    lo_handler->ms_request-s_front-origin               = `https://host`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_initial( lo_handler->mo_action->mo_app->ms_session-s_ui5 ).

    CLEAR: lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-origin.
    lo_handler->ms_request-s_front-s_ui5-version         = `1.120.0`.
    lo_handler->ms_request-s_front-s_ui5-theme           = `sap_horizon`.
    lo_handler->ms_request-s_front-s_device-orientation  = `landscape`.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `phone`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-system ).
    cl_abap_unit_assert=>assert_equals( exp = `iOS`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-os-name ).
    cl_abap_unit_assert=>assert_equals( exp = `landscape`
                                        act = lo_handler->mo_action->mo_app->ms_session-s_device-orientation ).
    cl_abap_unit_assert=>assert_equals( exp = `https://host`
                                        act = lo_handler->ms_request-s_front-origin ).
    " this request reads like every other: the merged block
    cl_abap_unit_assert=>assert_equals( exp = `phone`
                                        act = lo_handler->ms_request-s_front-s_device-system ).

    CLEAR: lo_handler->ms_request-s_front-s_device,
           lo_handler->ms_request-s_front-s_ui5.

    lo_handler->session_merge( ).

    cl_abap_unit_assert=>assert_equals( exp = `1.120.0`
                                        act = lo_handler->ms_request-s_front-s_ui5-version ).
    cl_abap_unit_assert=>assert_equals( exp = `sap_horizon`
                                        act = lo_handler->ms_request-s_front-s_ui5-theme ).
    cl_abap_unit_assert=>assert_equals( exp = `landscape`
                                        act = lo_handler->ms_request-s_front-s_device-orientation ).

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
    METHODS test_leave_expired_stack_ends FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_dispatch IMPLEMENTATION.

  METHOD test_dispatch_loop_guard.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    " an app that calls nav_app_call unconditionally in main( ) must not
    " loop the dispatch forever - the handler raises once the limit is hit
    lo_handler = NEW #( val = `` ).
    lo_handler->mv_dispatch_limit = 5.
    lo_handler->mo_action->mo_app->mo_app = NEW ltcl_app_nav_loop( ).
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

  METHOD test_leave_expired_stack_ends.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA lo_app TYPE REF TO ltcl_app_leave_root.

    " the caller's hop-time draft was purged by cleanup( ) while this app
    " stayed in use: the leave has nowhere to go, the stack is dropped, the
    " user is told, and the roundtrip ends on this app - it used to raise
    " NO_DRAFT_ENTRY out of the whole roundtrip for pressing Back
    lo_handler = NEW #( val = `` ).
    lo_app = NEW #( ).
    lo_handler->mo_action->mo_app->mo_app      = lo_app.
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->ms_draft-id_prev_app_stack = `PURGED_HOP_DRAFT_OF_CALLER`.

    cl_abap_unit_assert=>assert_true( lo_handler->main_process( ) ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_app->mv_main_calls ).
    cl_abap_unit_assert=>assert_initial( lo_handler->mo_action->mo_app->ms_draft-id_prev_app_stack ).
    cl_abap_unit_assert=>assert_not_bound( lo_handler->mo_action->ms_next-o_app_leave ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_handler->mo_action->ms_next-s_action-t_custom ) ).
    cl_abap_unit_assert=>assert_char_cp(
        exp = `["MESSAGE_TOAST","show","Previous app state expired*`
        act = lo_handler->mo_action->ms_next-s_action-t_custom[ 1 ]-o_json->stringify( ) ).

  ENDMETHOD.

  METHOD test_sticky_keep_saves_draft.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.
    DATA(lo_draft) = z2ui5_cl_ui5_srv_draft=>get_instance( ).

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
    " ... but the app's id_draft follows the id this roundtrip answers with,
    " as it does where the draft is saved
    cl_abap_unit_assert=>assert_equals(
        exp = lv_id_plain
        act = CAST z2ui5_if_app( lo_handler->mo_action->mo_app->mo_app )->id_draft ).

  ENDMETHOD.

  METHOD test_nav_mode_resent.

    DATA lo_handler TYPE REF TO z2ui5_cl_ui5_handler.

    " An app configures routing ONCE. main_end therefore re-sends the mode the
    " app carries whenever the roundtrip did not set one itself, so a later
    " render of the same app stays routed without queueing set_nav_routing
    " again - and an app that never opted in keeps sending nothing.
    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_handler->mo_action->mo_app->mv_nav_mode = z2ui5_if_client=>cs_nav_mode-keep.

    lo_handler->main_end( ).

    " the mode reaches the frontend as an option of the NAV section, not
    " as a response field of its own
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*"setNavRouting":"KEEP"*`
        act = system_actions_of( lo_handler ) ).

    " a follow-up EVENT roundtrip of the same app repeats no mode - the
    " frontend keeps it in session state, so re-sending it would repeat
    " the NAV section for a constant on every roundtrip
    lo_handler->ms_request-s_front-id = `SOME_DRAFT`.
    CLEAR lo_handler->mo_action->ms_next.
    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `setNavRouting` ) ).

    lo_handler = NEW #( val = `` ).
    lo_handler->mo_action->mo_app->mo_app      = NEW ltcl_app_nav_loop( ).
    lo_handler->mo_action->mo_app->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    lo_handler->main_end( ).

    cl_abap_unit_assert=>assert_false( xsdbool( system_actions_of( lo_handler ) CS `setNavRouting` ) ).

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


" page transitions: a caller that arrives with slide and calls a callee that
" arrives with fade. What has to hold on this side of the wire: the name
" travels with the MAIN display, the way back through nav_app_leave( ) is
" flagged, a leave to a FRESH instance and a plain display are not
CLASS ltcl_app_anim_callee DEFINITION DEFERRED.

CLASS ltcl_app_anim_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_anim_callee DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_anim_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      client->view_display( val        = `<mvc:View><Text text="caller"/></mvc:View>`
                            transition = z2ui5_if_client=>cs_transition-slide ).
    ELSEIF client->check_on_navigated( ).
      client->view_display( val        = `<mvc:View><Text text="caller"/></mvc:View>`
                            transition = z2ui5_if_client=>cs_transition-slide ).
    ELSEIF client->check_on_event( `CALL` ).
      client->nav_app_call( NEW ltcl_app_anim_callee( ) ).
    ELSEIF client->check_on_event( `PREVIOUS` ).
      " a wizard's Previous button: the app's own way back
      client->view_display( val             = `<mvc:View><Text text="step 1"/></mvc:View>`
                            transition      = z2ui5_if_client=>cs_transition-slide
                            transition_back = abap_true ).
    ELSEIF client->check_on_event( `PLAIN` ).
      client->view_display( `<mvc:View><Text text="plain"/></mvc:View>` ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_anim_callee IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_navigated( ).
      client->view_display( val        = `<mvc:View><Text text="callee"/></mvc:View>`
                            transition = z2ui5_if_client=>cs_transition-fade ).
    ELSEIF client->check_on_event( `BACK` ).
      client->nav_app_leave( ).
    ELSEIF client->check_on_event( `REPLACE` ).
      " a leave to a FRESH instance takes this app's place - a forward move
      client->nav_app_leave( NEW ltcl_app_anim_caller( ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" the nav tag: a caller that calls the same callee class for two purposes
" and records, on every main( ), what get_nav_tag( ) answered
CLASS ltcl_app_tag_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_seen TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_tag_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    mv_seen = client->get_nav_tag( ).
    IF client->check_on_navigated( ).
      client->view_display( `<mvc:View><Text text="tag caller"/></mvc:View>` ).
    ELSEIF client->check_on_event( `CALL_TAGGED` ).
      client->nav_app_call( app = NEW ltcl_app_anim_callee( )
                            tag = `PICK_UNIT` ).
    ELSEIF client->check_on_event( `CALL_PLAIN` ).
      client->nav_app_call( NEW ltcl_app_anim_callee( ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 04 - navigation: nav_app_call and the way back - a popup app answers
" alone, a silent one ships no model, the caller reads the popup app back,
" and two instances of ONE class in the stack keep their own state
" ---------------------------------------------------------------------------
" the hop_after_delta_pushes pair: a popup app that closes and leaves, and
" a caller that changes a bound value right before calling it and leaves
" its view standing on the way back
CLASS ltcl_app_hop_popup DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_hop_popup IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      client->popup_display( `<Dialog/>` ).
    ELSEIF client->check_on_event( `CLOSE` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_hop_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_val   TYPE string.
    DATA mv_other TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_hop_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      mv_val = `old`.
      client->view_display( `<mvc:View><Input value="` && client->_bind( mv_val ) &&
                            `"/><Input value="` && client->_bind( mv_other ) && `"/></mvc:View>` ).
    ELSEIF client->check_on_event( `GO` ).
      mv_val = `changed`.
      client->nav_app_call( NEW ltcl_app_hop_popup( ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" nav_app_call( me ): the app calls itself as a new screen and comes back
" with Back - the hop_self_reaches_root case
CLASS ltcl_app_call_self DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_text TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_call_self IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      client->view_display( `<mvc:View><Text text="` && client->_bind( mv_text ) && `"/></mvc:View>` ).
    ELSEIF client->check_on_event( `SELF` ).
      client->nav_app_call( me ).
    ELSEIF client->check_on_event( `BACK` ).
      IF client->check_app_prev_stack( ).
        client->nav_app_leave( ).
      ELSE.
        mv_text = `root`.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


" check_on_nav_back( ): a caller and a callee that record, on every
" main( ), what it answered - the caller reaches the callee, a popup app
" and itself, the callee leaves plain, with messages or to a NEW caller
CLASS ltcl_app_back_caller DEFINITION DEFERRED.

CLASS ltcl_app_back_callee DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_nav_back TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_back_caller DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_nav_back  TYPE abap_bool.
    DATA mv_navigated TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_back_callee IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    mv_nav_back = client->check_on_nav_back( ).
    IF client->check_on_navigated( ).
      client->view_display( `<mvc:View><Text text="back callee"/></mvc:View>` ).
    ELSEIF client->check_on_event( `BACK` ).
      client->nav_app_leave( ).
    ELSEIF client->check_on_event( `BACK_KEEP` ).
      client->message_toast_display( `Saved.` ).
      client->nav_app_leave( keep_messages = abap_true ).
    ELSEIF client->check_on_event( `REPLACE` ).
      client->nav_app_leave( NEW ltcl_app_back_caller( ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_app_back_caller IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    mv_nav_back  = client->check_on_nav_back( ).
    mv_navigated = client->check_on_navigated( ).
    IF client->check_on_navigated( ).
      client->view_display( `<mvc:View><Text text="back caller"/></mvc:View>` ).
    ELSEIF client->check_on_event( `CALL_TAGGED` ).
      client->nav_app_call( app = NEW ltcl_app_back_callee( )
                            tag = `PICK_UNIT` ).
    ELSEIF client->check_on_event( `CALL_PLAIN` ).
      client->nav_app_call( NEW ltcl_app_back_callee( ) ).
    ELSEIF client->check_on_event( `CALL_POPUP` ).
      client->nav_app_call( NEW ltcl_app_hop_popup( ) ).
    ELSEIF client->check_on_event( `CALL_SELF` ).
      client->nav_app_call( me ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_04_nav DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS popup_app_answers_alone FOR TESTING RAISING cx_static_check.
    METHODS silent_popup_app_no_model FOR TESTING RAISING cx_static_check.
    METHODS way_back_reads_popup_app FOR TESTING RAISING cx_static_check.
    " a caller of class X calls an instance of class X: two drafts, two
    " responses, and the way back shows the outer's own values
    METHODS same_class_twice_in_stack FOR TESTING RAISING cx_static_check.
    " a popup app handed its caller reads the caller's runtime-built table
    " while the caller is on the stack
    METHODS popup_reads_caller_table FOR TESTING RAISING cx_static_check.
    " ...and what it writes into that table is what the caller shows on the
    " way back through nav_app_leave( caller )
    METHODS popup_writes_caller_table FOR TESTING RAISING cx_static_check.
    " view_display( transition ) travels with the MAIN display - and a
    " display without one sends exactly what it always sent
    " nav_app_call( tag ) comes back with the screen - on the way back only,
    " and an untagged call clears it
    METHODS nav_tag_comes_back FOR TESTING RAISING cx_static_check.
    " check_on_nav_back( ) is true on the roundtrip a called app returns
    " on - with or without a tag, from a popup app too - and on no other
    METHODS nav_back_only_on_return FOR TESTING RAISING cx_static_check.
    " ... and false where the screen moves forward: nav_app_call( me ) and
    " a leave to a NEW instance
    METHODS nav_back_not_forward FOR TESTING RAISING cx_static_check.
    METHODS transition_travels FOR TESTING RAISING cx_static_check.
    " nav_app_leave( ) back to the caller is a way back, the call is not;
    " the caller keeps its instance through the draft
    METHODS transition_leave_is_back FOR TESTING RAISING cx_static_check.
    " a leave to a FRESH instance replaces the app - a forward move
    METHODS transition_fresh_leave_fwd FOR TESTING RAISING cx_static_check.
    " transition_back = abap_true: an app's own way back between its screens
    METHODS transition_explicit_back FOR TESTING RAISING cx_static_check.
    " the hop request carried a delta and the caller changed a bound value
    " before nav_app_call: the way back pushes it, as without a delta
    METHODS hop_after_delta_pushes FOR TESTING RAISING cx_static_check.
    " nav_app_call( me ) is a new stack entry: one Back is back at the root
    METHODS hop_self_reaches_root FOR TESTING RAISING cx_static_check.

    " roundtrip 1: the popup caller's first render, saved as a draft
    METHODS caller_started
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_04_nav IMPLEMENTATION.

  METHOD popup_app_answers_alone.

    " driven through the public harness (z2ui5_cl_ui5_test) - the browser's
    " view of the same roundtrip: the row click hands over to the popup app
    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_popup_caller( ) )->event( `ROW_SELECT` ).

    " the response names the CALLED app...
    " (a CAST that fails is the assertion - IS INSTANCE OF is not 7.02)
    DATA(lo_popup) = CAST ltcl_app_popup_bound( lo_test->app( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->nav_called( ) = lo_popup ) ).
    " ...opens its popup over the caller's table, which stays on screen...
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->popup_xml( ) CS `/MS_ROW/NAME` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->view_xml( ) CS `/MT_TAB` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lo_test->response( ) CS `"MAIN"` ) ).
    " ...and ships ITS model, which knows nothing of the caller's table -
    " the reason the frontend must not push it into the caller's view
    cl_abap_unit_assert=>assert_equals( exp = `edit me`
                                        act = lo_test->model( `/MS_ROW/NAME` ) ).
    cl_abap_unit_assert=>assert_initial( lo_test->model( `/MT_TAB` ) ).

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
    " response is the CALLER's again: its class, its main view, its model.
    " Driven through the public harness (z2ui5_cl_ui5_test)
    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_popup_caller( )
                                       )->event( `ROW_SELECT`
                                       )->event( `CLOSE` ).

    cl_abap_unit_assert=>assert_bound( CAST ltcl_app_popup_caller( lo_test->app( ) ) ).
    DATA(lo_left) = CAST ltcl_app_popup_bound( lo_test->nav_left( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = lo_left->ms_row-name ).
    cl_abap_unit_assert=>assert_initial( lo_test->nav_called( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->response( ) CS `"MAIN"` ) ).
    cl_abap_unit_assert=>assert_initial( lo_test->popup_xml( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `one`
                                        act = lo_test->model( `/MT_TAB/0/NAME` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = lo_test->model( `/MV_FROM_POPUP` )
                                        msg = `the caller could not read the popup app back` ).

  ENDMETHOD.

  METHOD hop_self_reaches_root.

    " the instance's own draft id used to be reused for the call: the
    " draft's stack pointed at itself, and Back went round forever without
    " check_app_prev_stack( ) ever turning false
    DATA(lo_start) = started_with( NEW ltcl_app_call_self( ) ).
    DATA(lo_self) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `SELF` ).
    cl_abap_unit_assert=>assert_differs( exp = lo_self->ms_response-s_front-id
                                         act = lo_self->mo_action->mo_app->ms_draft-id_prev_app_stack
                                         msg = `the called draft's stack points at itself` ).

    DATA(lo_back) = event_on( iv_id    = lo_self->ms_response-s_front-id
                              iv_event = `BACK` ).
    cl_abap_unit_assert=>assert_initial( act = lo_back->mo_action->mo_app->ms_draft-id_prev_app_stack
                                         msg = `one Back is the root again` ).

    DATA(lo_root) = event_on( iv_id    = lo_back->ms_response-s_front-id
                              iv_event = `BACK` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_root->ms_response-model CS `"root"` )
                                      msg = lo_root->ms_response-model ).

  ENDMETHOD.

  METHOD hop_after_delta_pushes.

    " the caller's view stays on screen across the popup app - nothing is
    " re-displayed on the way back, so only the automatic push can bring
    " the value the caller set before the hop. The delta on the GO request
    " cleared the stored client model, the hop saved the caller without
    " one, and on the way back the caller's own state counted as what the
    " browser shows: `{}`, the browser kept `old`
    DATA(lo_start) = started_with( NEW ltcl_app_hop_caller( ) ).
    DATA(lo_popup) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `GO`
                               iv_model = `{"MV_OTHER":"typed"}` ).
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `CLOSE` ).

    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `HOP_CALLER` ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_back->ms_response-model CS `"changed"` )
                                      msg = |the way back did not push the hop-time change: { lo_back->ms_response-model }| ).

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


  METHOD popup_reads_caller_table.

    DATA(lo_start) = started_with( NEW ltcl_app_dref_caller( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_start->ms_response-model CS `"two"` ) ).

    " the hop saves the caller - its generic reference is detached for the
    " draft and has to be back before the popup app runs
    DATA(lo_popup) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `OPEN` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_popup->ms_response-s_front-app CS `DREF_POPUP` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_popup
                                                     iv_slot    = z2ui5_if_client=>cs_view-popup ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_popup->ms_response-model CS `"MV_FROM_CALLER":"two"` )
                                      msg = `the popup app could not read the caller's table` ).

    " the way back: the caller renders its table again, both rows
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `CLOSE` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `DREF_CALLER` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_back
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-model CS `"one"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-model CS `"two"` ) ).

  ENDMETHOD.

  METHOD popup_writes_caller_table.

    DATA(lo_start) = started_with( NEW ltcl_app_dref_caller( ) ).
    DATA(lo_popup) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `OPEN` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_popup->ms_response-s_front-app CS `DREF_POPUP` ) ).

    " the popup app appends a row to the caller's runtime-built table and
    " leaves to the caller instance it holds: the caller renders three rows
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `APPEND` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `DREF_CALLER` ) ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_back
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-model CS `"one"` ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_back->ms_response-model CS `"three"` )
                                      msg = `the row the popup app appended was lost on the way back` ).

  ENDMETHOD.

  METHOD nav_tag_comes_back.

    DATA lo_caller TYPE REF TO ltcl_app_tag_caller.

    " a first start is a navigation too, and has no tag
    DATA(lo_start) = started_with( NEW ltcl_app_tag_caller( ) ).
    lo_caller ?= lo_start->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_initial( lo_caller->mv_seen ).

    " the called app never sees the tag: it is the caller's
    DATA(lo_callee) = event_on( iv_id    = lo_start->ms_response-s_front-id
                                iv_event = `CALL_TAGGED` ).
    cl_abap_unit_assert=>assert_initial( lo_callee->mo_action->mo_app->mv_nav_tag ).

    " the way back hands it to the caller ...
    DATA(lo_back) = event_on( iv_id    = lo_callee->ms_response-s_front-id
                              iv_event = `BACK` ).
    lo_caller ?= lo_back->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_equals( exp = `PICK_UNIT`
                                        act = lo_caller->mv_seen ).

    " ... on that roundtrip only - a plain event after it reads nothing
    DATA(lo_event) = event_on( iv_id    = lo_back->ms_response-s_front-id
                               iv_event = `NOTHING` ).
    lo_caller ?= lo_event->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_initial( lo_caller->mv_seen ).

    " an untagged call replaces the tag of the earlier one
    lo_callee = event_on( iv_id    = lo_event->ms_response-s_front-id
                          iv_event = `CALL_PLAIN` ).
    lo_back = event_on( iv_id    = lo_callee->ms_response-s_front-id
                        iv_event = `BACK` ).
    lo_caller ?= lo_back->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `TAG_CALLER` ) ).
    cl_abap_unit_assert=>assert_initial( lo_caller->mv_seen ).

  ENDMETHOD.

  METHOD nav_back_only_on_return.

    DATA lo_caller TYPE REF TO ltcl_app_back_caller.
    DATA lo_callee TYPE REF TO ltcl_app_back_callee.

    " a first start is no return
    DATA(lo_start) = started_with( NEW ltcl_app_back_caller( ) ).
    lo_caller ?= lo_start->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_false( lo_caller->mv_nav_back ).

    " the called app's first roundtrip is a navigation, but no return
    DATA(lo_call) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `CALL_TAGGED` ).
    lo_callee ?= lo_call->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_false( lo_callee->mv_nav_back ).

    " the callee leaves: the caller gets the screen back, with the tag
    DATA(lo_back) = event_on( iv_id    = lo_call->ms_response-s_front-id
                              iv_event = `BACK` ).
    lo_caller ?= lo_back->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( lo_caller->mv_nav_back ).
    cl_abap_unit_assert=>assert_true( lo_caller->mv_navigated ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `BACK_CALLER` ) ).

    " a plain event after the return is none
    DATA(lo_event) = event_on( iv_id    = lo_back->ms_response-s_front-id
                               iv_event = `NOTHING` ).
    lo_caller ?= lo_event->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_false( lo_caller->mv_nav_back ).

    " without a tag, and with keep_messages, it is a return all the same
    lo_call = event_on( iv_id    = lo_event->ms_response-s_front-id
                        iv_event = `CALL_PLAIN` ).
    lo_back = event_on( iv_id    = lo_call->ms_response-s_front-id
                        iv_event = `BACK_KEEP` ).
    lo_caller ?= lo_back->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( lo_caller->mv_nav_back ).

    " a popup app that closes and leaves hands the screen back as well
    DATA(lo_popup) = event_on( iv_id    = lo_back->ms_response-s_front-id
                               iv_event = `CALL_POPUP` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_popup->ms_response-s_front-app CS `HOP_POPUP` ) ).
    lo_back = event_on( iv_id    = lo_popup->ms_response-s_front-id
                        iv_event = `CLOSE` ).
    lo_caller ?= lo_back->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( lo_caller->mv_nav_back ).

  ENDMETHOD.

  METHOD nav_back_not_forward.

    DATA lo_caller TYPE REF TO ltcl_app_back_caller.

    " nav_app_call( me ) is a new screen of the same instance
    DATA(lo_start) = started_with( NEW ltcl_app_back_caller( ) ).
    DATA(lo_self) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `CALL_SELF` ).
    lo_caller ?= lo_self->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( lo_caller->mv_navigated ).
    cl_abap_unit_assert=>assert_false( lo_caller->mv_nav_back ).

    " a leave to a NEW instance replaces the callee - a forward move
    DATA(lo_call) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `CALL_PLAIN` ).
    DATA(lo_replace) = event_on( iv_id    = lo_call->ms_response-s_front-id
                                 iv_event = `REPLACE` ).
    lo_caller ?= lo_replace->mo_action->mo_app->mo_app.
    cl_abap_unit_assert=>assert_true( lo_caller->mv_navigated ).
    cl_abap_unit_assert=>assert_false( lo_caller->mv_nav_back ).

  ENDMETHOD.

  METHOD transition_travels.

    DATA(lo_start) = started_with( NEW ltcl_app_anim_caller( ) ).
    DATA(lv_system) = system_actions_of( lo_start ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"transition":"slide"*`
                                         act = lv_system ).
    " the instance the frontend compares before it plays a way back
    cl_abap_unit_assert=>assert_char_cp( exp = `*"appInstance":"*`
                                         act = lv_system ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `transitionBack` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `navBack` ) ).

    " a display without a transition sends what it always sent - no name,
    " no instance, no direction
    DATA(lo_plain) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `PLAIN` ).
    lv_system = system_actions_of( lo_plain ).
    cl_abap_unit_assert=>assert_true( check_display( io_handler = lo_plain
                                                     iv_slot    = z2ui5_if_client=>cs_view-main ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `"transition` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `appInstance` ) ).

  ENDMETHOD.

  METHOD transition_leave_is_back.

    DATA(lo_start) = started_with( NEW ltcl_app_anim_caller( ) ).
    DATA(lv_caller) = substring_before( val = substring_after( val = system_actions_of( lo_start )
                                                               sub = `"appInstance":"` )
                                        sub = `"` ).
    cl_abap_unit_assert=>assert_not_initial( lv_caller ).

    " the call is a forward move: the callee's own transition, no back flag,
    " and an instance of its own
    DATA(lo_callee) = event_on( iv_id    = lo_start->ms_response-s_front-id
                                iv_event = `CALL` ).
    DATA(lv_system) = system_actions_of( lo_callee ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"transition":"fade"*`
                                         act = lv_system ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `navBack` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS lv_caller ) ).

    " the leave returns to the caller restored from the stack - the way back
    DATA(lo_back) = event_on( iv_id    = lo_callee->ms_response-s_front-id
                              iv_event = `BACK` ).
    lv_system = system_actions_of( lo_back ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `ANIM_CALLER` ) ).
    cl_abap_unit_assert=>assert_true( lo_back->mo_action->ms_actual-check_nav_back ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"navBack":true*`
                                         act = lv_system ).
    " ...recognized, not asked for: the app's own transition_back stays off
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `transitionBack` ) ).
    " ...with the caller's own transition - the one it leaves with on ITS
    " way back - and the SAME instance it arrived as: it came out of its
    " draft, so the frontend can tell it from the page being left
    cl_abap_unit_assert=>assert_char_cp( exp = `*"transition":"slide"*`
                                         act = lv_system ).
    cl_abap_unit_assert=>assert_char_cp( exp = |*"appInstance":"{ lv_caller }"*|
                                         act = lv_system ).

  ENDMETHOD.

  METHOD transition_fresh_leave_fwd.

    DATA(lo_start) = started_with( NEW ltcl_app_anim_caller( ) ).
    DATA(lo_callee) = event_on( iv_id    = lo_start->ms_response-s_front-id
                                iv_event = `CALL` ).
    " a leave to a FRESH instance takes the callee's place in the stack - a
    " forward move, played with the new instance's own transition
    DATA(lo_fresh) = event_on( iv_id    = lo_callee->ms_response-s_front-id
                               iv_event = `REPLACE` ).
    DATA(lv_system) = system_actions_of( lo_fresh ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_fresh->ms_response-s_front-app CS `ANIM_CALLER` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"transition":"slide"*`
                                         act = lv_system ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `navBack` ) ).

  ENDMETHOD.

  METHOD transition_explicit_back.

    DATA(lo_start) = started_with( NEW ltcl_app_anim_caller( ) ).
    DATA(lo_prev) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `PREVIOUS` ).
    DATA(lv_system) = system_actions_of( lo_prev ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"transitionBack":true*`
                                         act = lv_system ).
    " an app's own step back is no return from another app
    cl_abap_unit_assert=>assert_false( xsdbool( lv_system CS `navBack` ) ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 05 - the roundtrip monitor (z2ui5_if_ui5_monitor): called once per
" roundtrip through main( ), on success and on failure, filled from the
" request, the response and the exception - and never able to break the
" roundtrip it watches
" ---------------------------------------------------------------------------

" a monitor that records every call - and raises on request, to prove that
" a broken one fails open
CLASS ltcl_monitor DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_monitor.
    DATA mt_calls TYPE STANDARD TABLE OF z2ui5_if_ui5_monitor=>ty_s_roundtrip WITH EMPTY KEY.
    DATA check_raise TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_monitor IMPLEMENTATION.

  METHOD z2ui5_if_ui5_monitor~on_roundtrip.
    INSERT is_roundtrip INTO TABLE mt_calls.
    IF check_raise = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = `MONITOR_BROKEN`.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

" an app that fails on the event BOOM - the root cause the monitor names
CLASS ltcl_app_boom DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_boom IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->get( )-event = `BOOM`.
      RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_05_monitor DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " whatever monitor the SYSTEM has installed, parked for the test's
    " duration like the user exit's tests park the installed exit - the
    " double must be the one the handler finds
    DATA mi_installed TYPE REF TO z2ui5_if_ui5_monitor.
    DATA mo_monitor   TYPE REF TO ltcl_monitor.

    METHODS setup.
    METHODS teardown.

    METHODS start_and_event_reported FOR TESTING RAISING cx_static_check.
    METHODS client_prev_read_safely FOR TESTING RAISING cx_static_check.
    METHODS failure_reported FOR TESTING RAISING cx_static_check.
    METHODS broken_monitor_fails_open FOR TESTING RAISING cx_static_check.
    METHODS durations_per_phase FOR TESTING RAISING cx_static_check.
    METHODS durations_failed_in_main FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_05_monitor IMPLEMENTATION.

  METHOD setup.

    mi_installed = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).
    mo_monitor = NEW #( ).
    z2ui5_cl_ui5_srv_monitor=>set_monitor( mo_monitor ).

  ENDMETHOD.

  METHOD teardown.

    z2ui5_cl_ui5_srv_monitor=>set_monitor( mi_installed ).

  ENDMETHOD.

  METHOD start_and_event_reported.

    " roundtrip 1: an app start - no draft id in, the new one out
    DATA(lv_payload) = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}`.
    DATA(lo_first) = NEW z2ui5_cl_ui5_handler( lv_payload ).
    DATA(ls_res) = lo_first->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_monitor->mt_calls ) ).
    DATA(ls_call) = mo_monitor->mt_calls[ 1 ].
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                        act = ls_call-app ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_call-check_start ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_call-check_error ).
    cl_abap_unit_assert=>assert_initial( ls_call-event ).
    cl_abap_unit_assert=>assert_initial( ls_call-draft_id_prev ).
    cl_abap_unit_assert=>assert_initial( ls_call-error_text ).
    " the id the response carries - read from the body: a handler releases
    " its response structure once the roundtrip is answered (sticky
    " handlers outlive the request)
    cl_abap_unit_assert=>assert_not_initial( ls_call-draft_id ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_res-body CS ls_call-draft_id ) ).
    cl_abap_unit_assert=>assert_initial( lo_first->ms_response ).
    cl_abap_unit_assert=>assert_initial( lo_first->mv_request_json ).
    " ...and the tree the body was parsed into goes with it
    cl_abap_unit_assert=>assert_not_bound( lo_first->ms_request-o_model ).
    cl_abap_unit_assert=>assert_initial( lo_first->ms_request-model_path ).
    cl_abap_unit_assert=>assert_equals( exp = sy-uname
                                        act = ls_call-uname ).
    cl_abap_unit_assert=>assert_not_initial( ls_call-timestampl ).
    cl_abap_unit_assert=>assert_equals( exp = strlen( lv_payload )
                                        act = ls_call-bytes_request ).
    cl_abap_unit_assert=>assert_equals( exp = strlen( ls_res-body )
                                        act = ls_call-bytes_response ).
    " the first render displays a view, so the model travels with it
    cl_abap_unit_assert=>assert_true( xsdbool( ls_call-bytes_model > 0 ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_call-ms_total >= 0 ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_call-ms_total >= ls_call-ms_load ) ).

    " roundtrip 2: an event on the draft it wrote
    DATA(lo_second) = NEW z2ui5_cl_ui5_handler(
        `{"value":{"S_FRONT":{"ID":"` && ls_call-draft_id && `","EVENT":"BUTTON_POST","MS_CLIENT_PREV":312,` &&
        `"ORIGIN":"O","PATHNAME":"/","SEARCH":""}}}` ).
    lo_second->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_monitor->mt_calls ) ).
    ls_call = mo_monitor->mt_calls[ 2 ].
    cl_abap_unit_assert=>assert_equals( exp = `BUTTON_POST`
                                        act = ls_call-event ).
    cl_abap_unit_assert=>assert_equals( exp = mo_monitor->mt_calls[ 1 ]-draft_id
                                        act = ls_call-draft_id_prev ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = ls_call-check_start ).
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_UI5_APP_HI_WORLD`
                                        act = ls_call-app ).
    " the browser's duration of roundtrip 1, carried by roundtrip 2
    cl_abap_unit_assert=>assert_equals( exp = 312
                                        act = ls_call-ms_client_prev ).
    cl_abap_unit_assert=>assert_initial( mo_monitor->mt_calls[ 1 ]-ms_client_prev ).

  ENDMETHOD.

  METHOD client_prev_read_safely.

    " a diagnostic of the browser's - a value that is no non-negative
    " integer reads as 0 and costs the request nothing
    DATA(lo_handler) = NEW z2ui5_cl_ui5_handler( `` ).

    DATA(ls_request) = lo_handler->request_json_to_abap(
        `{"value":{"S_FRONT":{"ID":"A","EVENT":"E","MS_CLIENT_PREV":"soon"}}}` ).
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = ls_request-s_front-event ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-ms_client_prev ).

    ls_request = lo_handler->request_json_to_abap( `{"value":{"S_FRONT":{"ID":"A","MS_CLIENT_PREV":-5}}}` ).
    cl_abap_unit_assert=>assert_initial( ls_request-s_front-ms_client_prev ).

    ls_request = lo_handler->request_json_to_abap( `{"value":{"S_FRONT":{"ID":"A","MS_CLIENT_PREV":48}}}` ).
    cl_abap_unit_assert=>assert_equals( exp = 48
                                        act = ls_request-s_front-ms_client_prev ).

  ENDMETHOD.

  METHOD failure_reported.

    DATA(lo_first) = started_with( NEW ltcl_app_boom( ) ).
    DATA(lv_id) = lo_first->mo_action->mo_app->ms_draft-id.

    DATA(lo_second) = NEW z2ui5_cl_ui5_handler(
        `{"value":{"S_FRONT":{"ID":"` && lv_id && `","EVENT":"BOOM","ORIGIN":"O","PATHNAME":"/","SEARCH":""}}}` ).
    TRY.
        lo_second->main( ).
        cl_abap_unit_assert=>fail( `the app raises on BOOM` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx) ##NO_HANDLER.
    ENDTRY.

    " reported once, on the way out - the exception still travels on to
    " the top-level catch, which renders the same object into the 500 body
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_monitor->mt_calls ) ).
    DATA(ls_call) = mo_monitor->mt_calls[ 1 ].
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = ls_call-check_error ).
    cl_abap_unit_assert=>assert_equals( exp = `CX_SY_ZERODIVIDE`
                                        act = ls_call-error_class ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_call-error_text CS `event BOOM` ) ).
    " the error id the user sees is the one in the log
    cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls_call-error_text CS lx->ms_error-uuid ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( lo_second->mo_action->mo_app->mo_app )
        act = ls_call-app ).
    cl_abap_unit_assert=>assert_not_initial( ls_call-app ).
    cl_abap_unit_assert=>assert_equals( exp = `BOOM`
                                        act = ls_call-event ).
    cl_abap_unit_assert=>assert_equals( exp = lv_id
                                        act = ls_call-draft_id_prev ).
    " no response was built - no new draft, no response sizes
    cl_abap_unit_assert=>assert_initial( ls_call-draft_id ).
    cl_abap_unit_assert=>assert_initial( ls_call-bytes_response ).
    cl_abap_unit_assert=>assert_initial( ls_call-bytes_model ).
    cl_abap_unit_assert=>assert_initial( ls_call-ms_render ).

  ENDMETHOD.

  METHOD broken_monitor_fails_open.

    " a monitor that raises costs its log entry, never the roundtrip
    mo_monitor->check_raise = abap_true.

    DATA(lo_handler) = NEW z2ui5_cl_ui5_handler(
        `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/p","SEARCH":"?app_start=Z2UI5_CL_UI5_APP_HI_WORLD"}}}` ).
    DATA(ls_res) = lo_handler->main( ).

    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = ls_res-status_code ).
    cl_abap_unit_assert=>assert_not_initial( ls_res-body ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_monitor->mt_calls ) ).

  ENDMETHOD.

  METHOD durations_per_phase.

    DATA ls_roundtrip TYPE z2ui5_if_ui5_monitor=>ty_s_roundtrip.

    DATA(lo_handler) = NEW z2ui5_cl_ui5_handler( `` ).
    lo_handler->ms_monitor_time = VALUE #( start        = `20261003101500.0000000`
                                           loaded       = `20261003101500.1000000`
                                           render_start = `20261003101501.0000000`
                                           render_end   = `20261003101501.2500000` ).

    lo_handler->monitor_durations( EXPORTING iv_now       = `20261003101501.3000000`
                                   CHANGING  cs_roundtrip = ls_roundtrip ).

    cl_abap_unit_assert=>assert_equals( exp = 1300
                                        act = ls_roundtrip-ms_total ).
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = ls_roundtrip-ms_load ).
    cl_abap_unit_assert=>assert_equals( exp = 900
                                        act = ls_roundtrip-ms_main ).
    cl_abap_unit_assert=>assert_equals( exp = 250
                                        act = ls_roundtrip-ms_render ).

  ENDMETHOD.

  METHOD durations_failed_in_main.

    " the phase the request failed in ends at the failure, the phases it
    " never reached stay 0
    DATA ls_roundtrip TYPE z2ui5_if_ui5_monitor=>ty_s_roundtrip.

    DATA(lo_handler) = NEW z2ui5_cl_ui5_handler( `` ).
    lo_handler->ms_monitor_time = VALUE #( start  = `20261003101500.0000000`
                                           loaded = `20261003101500.0500000` ).

    lo_handler->monitor_durations( EXPORTING iv_now       = `20261003101500.5500000`
                                   CHANGING  cs_roundtrip = ls_roundtrip ).

    cl_abap_unit_assert=>assert_equals( exp = 550
                                        act = ls_roundtrip-ms_total ).
    cl_abap_unit_assert=>assert_equals( exp = 50
                                        act = ls_roundtrip-ms_load ).
    cl_abap_unit_assert=>assert_equals( exp = 500
                                        act = ls_roundtrip-ms_main ).
    cl_abap_unit_assert=>assert_initial( ls_roundtrip-ms_render ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 06 - the drafts a roundtrip writes: an unchanged timer tick answers with
" the draft it continued (main_end_reuse), and the opt-in pruning of the
" chain (draft_keep_per_chain) keeps the drafts Back and links need
" ---------------------------------------------------------------------------

" counts its events; SHARE hands out an app state link without keeping it
" anywhere bound - a toast, the way an app would show it once
CLASS ltcl_app_count DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_count TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_count IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    CASE client->get( )-event.
      WHEN `EV`.
        mv_count = mv_count + 1.
      WHEN `SHARE`.
        client->message_toast_display( client->app_state_get_href( ) ).
      WHEN `CALL`.
        client->nav_app_call( NEW ltcl_app_count( ) ).
      WHEN `LEAVE`.
        client->nav_app_leave( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

" arms a REPEATING START_TIMER once (its fourth t_arg) and does nothing on
" a tick - the shape a polling app takes once it no longer re-arms the timer
CLASS ltcl_app_poll DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_poll IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_event( `ARM` ).
      client->follow_up_action( val   = client->cs_event-start_timer
                                t_arg = VALUE #( ( `TICK` ) ( `1000` ) ( `` ) ( `X` ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

" an exit that switches the pruning off
CLASS ltcl_exit_keep_all DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_exit_keep_all IMPLEMENTATION.

  METHOD z2ui5_if_ui5_exit~set_config_http_get ##NEEDED.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.
    cs_config-draft_keep_per_chain = 0.
  ENDMETHOD.

ENDCLASS.

" an exit that sets the pruning explicitly
CLASS ltcl_exit_keep DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_exit_keep IMPLEMENTATION.

  METHOD z2ui5_if_ui5_exit~set_config_http_get ##NEEDED.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.
    cs_config-draft_keep_per_chain = 2.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_06_draft DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS teardown.

    " a START_TIMER tick on the draft, as the frontend sends it
    METHODS tick_on
      IMPORTING
        iv_id         TYPE string
        iv_event      TYPE string DEFAULT `TICK`
      RETURNING
        VALUE(result) TYPE string.

    METHODS id_after
      IMPORTING
        iv_id         TYPE string
        iv_event      TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS exists
      IMPORTING
        iv_id         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS tick_unchanged_reuses_id  FOR TESTING RAISING cx_static_check.
    METHODS tick_repeat_reuses_id     FOR TESTING RAISING cx_static_check.
    METHODS tick_changed_new_draft    FOR TESTING RAISING cx_static_check.
    METHODS event_unchanged_new_id    FOR TESTING RAISING cx_static_check.
    METHODS tick_share_writes_draft   FOR TESTING RAISING cx_static_check.
    METHODS prune_off_keeps_chain     FOR TESTING RAISING cx_static_check.
    METHODS prune_keeps_two           FOR TESTING RAISING cx_static_check.
    METHODS prune_default_two         FOR TESTING RAISING cx_static_check.
    METHODS prune_keeps_app_stack     FOR TESTING RAISING cx_static_check.
    METHODS prune_keeps_share_link    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_06_draft IMPLEMENTATION.

  METHOD teardown.

    z2ui5_cl_ui5_user_exit=>set_instance( VALUE #( ) ).

  ENDMETHOD.

  METHOD tick_on.

    DATA(lo_handler) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ID":"` && iv_id && `","EVENT":"` && iv_event && `","TIMER":true}}}` ).
    lo_handler->main_begin( ).
    lo_handler->main_loop( ).
    result = lo_handler->ms_response-s_front-id.

  ENDMETHOD.

  METHOD id_after.

    result = event_on( iv_id    = iv_id
                       iv_event = iv_event )->ms_response-s_front-id.

  ENDMETHOD.

  METHOD exists.

    result = z2ui5_cl_ui5_srv_draft=>get_instance( )->check_exists( iv_id ).

  ENDMETHOD.

  METHOD tick_unchanged_reuses_id.

    DATA(lv_start) = started_with( NEW ltcl_app_noop( ) )->ms_response-s_front-id.
    " the first tick changes the app (check_on_init( ) is false from now on)
    DATA(lv_first) = tick_on( lv_start ).
    cl_abap_unit_assert=>assert_differs( exp = lv_start
                                         act = lv_first ).

    DATA(li_store) = z2ui5_cl_ui5_srv_draft=>get_instance( ).
    DATA(lv_count) = li_store->count_entries( ).

    " the second finds nothing to change: the same id, no row written
    DATA(lv_second) = tick_on( lv_first ).
    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = lv_second
                                        msg = `an unchanged tick answers the draft it continued` ).
    cl_abap_unit_assert=>assert_equals( exp = lv_count
                                        act = li_store->count_entries( )
                                        msg = `an unchanged tick writes no draft` ).

    " and the draft goes on - the next tick continues it
    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = tick_on( lv_second ) ).

  ENDMETHOD.

  METHOD tick_repeat_reuses_id.

    DATA(lv_start) = started_with( NEW ltcl_app_poll( ) )->ms_response-s_front-id.

    " armed once: the repeat travels as the fourth argument, the no-busy
    " slot before it kept empty
    DATA(lo_arm) = event_on( iv_id    = lv_start
                             iv_event = `ARM` ).
    cl_abap_unit_assert=>assert_true(
        act = xsdbool( lo_arm->mv_response CS `["START_TIMER","TICK","1000","","X"]` )
        msg = `the repeating timer is armed with its flag` ).

    " the browser re-arms the tick itself - the app answers a tick with no
    " action at all, and an unchanged one with the draft it continued
    DATA(lv_first) = tick_on( lo_arm->ms_response-s_front-id ).
    DATA(lo_second) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ID":"` && lv_first && `","EVENT":"TICK","TIMER":true}}}` ).
    lo_second->main_begin( ).
    lo_second->main_loop( ).
    cl_abap_unit_assert=>assert_false(
        act = xsdbool( lo_second->mv_response CS `START_TIMER` )
        msg = `a tick of a repeating timer re-arms nothing` ).
    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = lo_second->ms_response-s_front-id
                                        msg = `an unchanged tick answers the draft it continued` ).

  ENDMETHOD.

  METHOD tick_changed_new_draft.

    DATA(lv_start) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lv_first) = tick_on( iv_id    = lv_start
                              iv_event = `EV` ).
    DATA(lv_second) = tick_on( iv_id    = lv_first
                               iv_event = `EV` ).

    cl_abap_unit_assert=>assert_differs( exp = lv_first
                                         act = lv_second ).
    cl_abap_unit_assert=>assert_true( exists( lv_second ) ).

  ENDMETHOD.

  METHOD event_unchanged_new_id.

    DATA(lv_start) = started_with( NEW ltcl_app_noop( ) )->ms_response-s_front-id.
    DATA(lv_first) = id_after( iv_id    = lv_start
                               iv_event = `CLICK` ).

    " the protocol's rule for every request that is not a tick: a new id,
    " also when nothing changed (spec/sessions.md, session.new-id)
    DATA(lv_second) = id_after( iv_id    = lv_first
                                iv_event = `CLICK` ).
    cl_abap_unit_assert=>assert_differs( exp = lv_first
                                         act = lv_second ).
    cl_abap_unit_assert=>assert_true( exists( lv_second ) ).

  ENDMETHOD.

  METHOD tick_share_writes_draft.

    DATA(lv_start) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lv_first) = tick_on( lv_start ).

    " a tick that hands out a link changes nothing bound - but the link
    " names the id this roundtrip answers, and that draft has to exist
    DATA(lv_shared) = tick_on( iv_id    = lv_first
                               iv_event = `SHARE` ).
    cl_abap_unit_assert=>assert_differs( exp = lv_first
                                         act = lv_shared ).
    cl_abap_unit_assert=>assert_true( exists( lv_shared ) ).

  ENDMETHOD.

  METHOD prune_off_keeps_chain.

    z2ui5_cl_ui5_user_exit=>set_instance( NEW ltcl_exit_keep_all( ) ).

    DATA(lv_id) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lt_id) = VALUE string_table( ( lv_id ) ).
    DO 4 TIMES.
      lv_id = id_after( iv_id    = lv_id
                        iv_event = `EV` ).
      INSERT lv_id INTO TABLE lt_id.
    ENDDO.

    " exit sets draft_keep_per_chain 0: every draft stays until its expiry
    LOOP AT lt_id INTO lv_id.
      cl_abap_unit_assert=>assert_true( exists( lv_id ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD prune_keeps_two.

    z2ui5_cl_ui5_user_exit=>set_instance( NEW ltcl_exit_keep( ) ).

    DATA(lv_id) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lt_id) = VALUE string_table( ( lv_id ) ).
    DO 4 TIMES.
      lv_id = id_after( iv_id    = lv_id
                        iv_event = `EV` ).
      INSERT lv_id INTO TABLE lt_id.
    ENDDO.

    cl_abap_unit_assert=>assert_false( exists( lt_id[ 1 ] ) ).
    cl_abap_unit_assert=>assert_false( exists( lt_id[ 2 ] ) ).
    cl_abap_unit_assert=>assert_false( exists( lt_id[ 3 ] ) ).
    cl_abap_unit_assert=>assert_true( exists( lt_id[ 4 ] ) ).
    cl_abap_unit_assert=>assert_true( exists( lt_id[ 5 ] ) ).

  ENDMETHOD.

  METHOD prune_default_two.

    " no exit: the chain is pruned to the minimum by default
    DATA(lv_id) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lt_id) = VALUE string_table( ( lv_id ) ).
    DO 4 TIMES.
      lv_id = id_after( iv_id    = lv_id
                        iv_event = `EV` ).
      INSERT lv_id INTO TABLE lt_id.
    ENDDO.

    cl_abap_unit_assert=>assert_false( exists( lt_id[ 3 ] ) ).
    cl_abap_unit_assert=>assert_true( exists( lt_id[ 4 ] ) ).
    cl_abap_unit_assert=>assert_true( exists( lt_id[ 5 ] ) ).

  ENDMETHOD.

  METHOD prune_keeps_app_stack.

    z2ui5_cl_ui5_user_exit=>set_instance( NEW ltcl_exit_keep( ) ).

    DATA(lv_id) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    lv_id = id_after( iv_id    = lv_id
                      iv_event = `EV` ).

    " the caller calls a second instance; the callee runs a few roundtrips
    DATA(lo_call) = event_on( iv_id    = lv_id
                              iv_event = `CALL` ).
    DATA(lv_callee) = lo_call->ms_response-s_front-id.
    DATA(lv_hop) = z2ui5_cl_ui5_srv_draft=>get_instance( )->read_info( lv_callee )-id_prev_app_stack.
    cl_abap_unit_assert=>assert_not_initial( lv_hop ).
    DO 4 TIMES.
      lv_callee = id_after( iv_id    = lv_callee
                            iv_event = `EV` ).
    ENDDO.

    " the caller's draft is what Back loads - it is still there
    cl_abap_unit_assert=>assert_true( exists( lv_hop ) ).

    " and the leave lands on it, with the caller's count
    DATA(lo_leave) = event_on( iv_id    = lv_callee
                               iv_event = `LEAVE` ).
    cl_abap_unit_assert=>assert_equals( exp = lv_hop
                                        act = lo_leave->ms_response-s_front-id ).
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = CAST ltcl_app_count( lo_leave->mo_action->mo_app->mo_app )->mv_count ).

    " the caller goes on after the leave; its draft chain stays whole
    lv_id = id_after( iv_id    = lv_hop
                      iv_event = `EV` ).
    lv_id = id_after( iv_id    = lv_id
                      iv_event = `EV` ).
    cl_abap_unit_assert=>assert_true( exists( lv_id ) ).

  ENDMETHOD.

  METHOD prune_keeps_share_link.

    z2ui5_cl_ui5_user_exit=>set_instance( NEW ltcl_exit_keep( ) ).

    DATA(lv_id) = started_with( NEW ltcl_app_count( ) )->ms_response-s_front-id.
    DATA(lv_shared) = id_after( iv_id    = lv_id
                                iv_event = `SHARE` ).
    lv_id = lv_shared.
    DO 4 TIMES.
      lv_id = id_after( iv_id    = lv_id
                        iv_event = `EV` ).
    ENDDO.

    cl_abap_unit_assert=>assert_true( act = exists( lv_shared )
                                      msg = `the draft an app state link names survives the pruning` ).

  ENDMETHOD.

ENDCLASS.


" client->timer_set( ): declares its poll once, in check_on_init, and
" never re-arms it - the shape the declarative timer is for. A QUIET
" instance of the same class declares none
CLASS ltcl_app_timer DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_quiet TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_app_timer IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      IF mv_quiet = abap_false.
        client->timer_set( event    = `REFRESH`
                           delay_ms = 1000 ).
      ENDIF.
      client->view_display( `<mvc:View><Text text="timer"/></mvc:View>` ).
      RETURN.
    ENDIF.
    IF client->check_on_navigated( ).
      client->view_display( `<mvc:View><Text text="timer back"/></mvc:View>` ).
      RETURN.
    ENDIF.
    CASE client->get( )-event.
      WHEN `SAME`.
        client->timer_set( event    = `REFRESH`
                           delay_ms = 1000 ).
      WHEN `FASTER`.
        client->timer_set( event    = `REFRESH`
                           delay_ms = 500
                           no_busy  = abap_true ).
      WHEN `STOP`.
        client->timer_stop( ).
      WHEN `ZERO`.
        client->timer_set( event    = `REFRESH`
                           delay_ms = 0 ).
      WHEN `RESTART`.
        client->timer_set( event    = `REFRESH`
                           delay_ms = 1000 ).
      WHEN `EXPLICIT`.
        client->follow_up_action( val   = client->cs_event-start_timer
                                  t_arg = VALUE #( ( `ONCE` ) ( `200` ) ) ).
      WHEN `CALL_POPUP`.
        client->nav_app_call( NEW ltcl_app_hop_popup( ) ).
      WHEN `CALL_QUIET`.
        DATA(lo_quiet) = NEW ltcl_app_timer( ).
        lo_quiet->mv_quiet = abap_true.
        client->nav_app_call( lo_quiet ).
      WHEN `CALL_SELF`.
        client->nav_app_call( me ).
      WHEN `LEAVE`.
        client->nav_app_leave( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_07_timer DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    CONSTANTS c_armed TYPE string VALUE `["START_TIMER","REFRESH","1000","","X"]`.
    CONSTANTS c_stop  TYPE string VALUE `["STOP_TIMER"]`.
    " count_in( ) of either timer action - not a substring: the class name
    " LTCL_APP_TIMER is in every response, so a bare _TIMER would count it
    CONSTANTS c_any   TYPE string VALUE `*`.

    " the declared timer goes out with the first display, as a repeating
    " START_TIMER, and an unchanged one that runs is not sent again
    METHODS armed_once                FOR TESTING RAISING cx_static_check.
    " other values replace it, timer_stop( ) stops it once, a zero delay is
    " a stop, and a new declaration arms it again
    METHODS changed_and_stopped       FOR TESTING RAISING cx_static_check.
    " a popup app ends it, its close arms it again
    METHODS rearmed_after_popup_app   FOR TESTING RAISING cx_static_check.
    " a called instance of the same class without a timer stops it - the
    " browser cannot tell the hop - and the way back arms it again
    METHODS stopped_for_same_class    FOR TESTING RAISING cx_static_check.
    " nav_app_call( me ) keeps the declaration of the instance
    METHODS kept_on_call_self         FOR TESTING RAISING cx_static_check.
    " a Back/Forward restore or an app-state link of the draft arms it
    METHODS rearmed_on_restore        FOR TESTING RAISING cx_static_check.
    " a START_TIMER the app queues itself takes the slot over
    METHODS explicit_action_wins      FOR TESTING RAISING cx_static_check.
    " an unchanged tick of the declared timer still answers the draft it
    " continued
    METHODS tick_reuses_draft         FOR TESTING RAISING cx_static_check.

    METHODS count_in
      IMPORTING
        iv_text       TYPE string
        iv_sub        TYPE string
      RETURNING
        VALUE(result) TYPE i.
ENDCLASS.


CLASS ltcl_07_timer IMPLEMENTATION.

  METHOD count_in.

    IF iv_sub = c_any.
      result = count( val = iv_text
                      sub = `["START_TIMER"` ) + count( val = iv_text
                                                       sub  = `["STOP_TIMER"` ).
      RETURN.
    ENDIF.
    result = count( val = iv_text
                    sub = iv_sub ).

  ENDMETHOD.

  METHOD armed_once.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_start->mv_response
                                                        iv_sub  = c_armed )
                                        msg = `the first display arms the declared timer, repeating` ).

    " a plain event: the timer runs, nothing is sent
    DATA(lo_event) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `NOTHING` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_event->mv_response
                                                        iv_sub  = c_any ) ).

    " the same declaration again - idempotent
    DATA(lo_same) = event_on( iv_id    = lo_event->ms_response-s_front-id
                              iv_event = `SAME` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_same->mv_response
                                                        iv_sub  = c_any )
                                        msg = `an unchanged running timer is not sent again` ).

  ENDMETHOD.

  METHOD changed_and_stopped.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).

    DATA(lo_faster) = event_on( iv_id    = lo_start->ms_response-s_front-id
                                iv_event = `FASTER` ).
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = count_in( iv_text = lo_faster->mv_response
                        iv_sub  = `["START_TIMER","REFRESH","500","X","X"]` )
        msg = `other values replace the timer` ).

    DATA(lo_stop) = event_on( iv_id    = lo_faster->ms_response-s_front-id
                              iv_event = `STOP` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_stop->mv_response
                                                        iv_sub  = c_stop ) ).

    " stopped: a second stop and a zero delay send nothing
    DATA(lo_again) = event_on( iv_id    = lo_stop->ms_response-s_front-id
                               iv_event = `STOP` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_again->mv_response
                                                        iv_sub  = c_any ) ).
    DATA(lo_zero) = event_on( iv_id    = lo_again->ms_response-s_front-id
                              iv_event = `ZERO` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_zero->mv_response
                                                        iv_sub  = c_any ) ).

    " declared again: armed again
    DATA(lo_restart) = event_on( iv_id    = lo_zero->ms_response-s_front-id
                                 iv_event = `RESTART` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_restart->mv_response
                                                        iv_sub  = c_armed ) ).

    " and a zero delay on a running timer stops it
    DATA(lo_zero_run) = event_on( iv_id    = lo_restart->ms_response-s_front-id
                                  iv_event = `ZERO` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_zero_run->mv_response
                                                        iv_sub  = c_stop ) ).

  ENDMETHOD.

  METHOD rearmed_after_popup_app.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).

    " the popup app answers: the caller's timer stops with the hop
    DATA(lo_popup) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `CALL_POPUP` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_popup->ms_response-s_front-app CS `HOP_POPUP` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_popup->mv_response
                                                        iv_sub  = c_stop ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_popup->mv_response
                                                        iv_sub  = `["START_TIMER"` ) ).

    " the popup closes: the caller gets the screen and its timer back,
    " without a line of its own for it
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `CLOSE` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back->ms_response-s_front-app CS `APP_TIMER` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_back->mv_response
                                                        iv_sub  = c_armed ) ).

    " and runs on unchanged
    DATA(lo_event) = event_on( iv_id    = lo_back->ms_response-s_front-id
                               iv_event = `NOTHING` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_event->mv_response
                                                        iv_sub  = c_any ) ).

  ENDMETHOD.

  METHOD stopped_for_same_class.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).

    DATA(lo_quiet) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `CALL_QUIET` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_quiet->mv_response
                                                        iv_sub  = c_stop )
                                        msg = `the hop stops the timer the browser would keep for the same class` ).

    DATA(lo_back) = event_on( iv_id    = lo_quiet->ms_response-s_front-id
                              iv_event = `LEAVE` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_back->mv_response
                                                        iv_sub  = c_armed ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_back->mv_response
                                                        iv_sub  = c_stop ) ).

  ENDMETHOD.

  METHOD kept_on_call_self.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).
    DATA(lo_self) = event_on( iv_id    = lo_start->ms_response-s_front-id
                              iv_event = `CALL_SELF` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_self->mv_response
                                                        iv_sub  = c_armed ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_self->mv_response
                                                        iv_sub  = c_stop ) ).

  ENDMETHOD.

  METHOD rearmed_on_restore.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).
    DATA(lo_event) = event_on( iv_id    = lo_start->ms_response-s_front-id
                               iv_event = `NOTHING` ).

    " the page of a Back/Forward restore or of an app-state link holds no
    " timer: the request names no draft id, only the draft to restore
    DATA(lo_restore) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ORIGIN":"O","PATHNAME":"/","SEARCH":"",` &&
              `"ROUTE":{"APP_STATE":"` && lo_event->ms_response-s_front-id && `"}}}}` ).
    lo_restore->main_begin( ).
    lo_restore->main_loop( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_restore->ms_response-s_front-app CS `APP_TIMER` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_restore->mv_response
                                                        iv_sub  = c_armed ) ).

  ENDMETHOD.

  METHOD explicit_action_wins.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).

    " the app's own START_TIMER takes the slot: no stop in front of it
    DATA(lo_explicit) = event_on( iv_id    = lo_start->ms_response-s_front-id
                                  iv_event = `EXPLICIT` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_explicit->mv_response
                                                        iv_sub  = `["START_TIMER","ONCE","200"]` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_explicit->mv_response
                                                        iv_sub  = c_stop ) ).

    " the declaration is gone: a hop away and back arms nothing
    DATA(lo_popup) = event_on( iv_id    = lo_explicit->ms_response-s_front-id
                               iv_event = `CALL_POPUP` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_popup->mv_response
                                                        iv_sub  = c_any ) ).
    DATA(lo_back) = event_on( iv_id    = lo_popup->ms_response-s_front-id
                              iv_event = `CLOSE` ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_back->mv_response
                                                        iv_sub  = c_any ) ).

    " timer_set( ) hands it back
    DATA(lo_restart) = event_on( iv_id    = lo_back->ms_response-s_front-id
                                 iv_event = `RESTART` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = count_in( iv_text = lo_restart->mv_response
                                                        iv_sub  = c_armed ) ).

  ENDMETHOD.

  METHOD tick_reuses_draft.

    DATA(lo_start) = started_with( NEW ltcl_app_timer( ) ).
    " the first tick still changes the app (check_on_init( ) is false from
    " now on); the second changes nothing
    DATA(lo_first) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ID":"` && lo_start->ms_response-s_front-id &&
              `","EVENT":"REFRESH","TIMER":true}}}` ).
    lo_first->main_begin( ).
    lo_first->main_loop( ).
    DATA(lv_first) = lo_first->ms_response-s_front-id.

    DATA(lo_second) = NEW z2ui5_cl_ui5_handler(
        val = `{"value":{"S_FRONT":{"ID":"` && lv_first && `","EVENT":"REFRESH","TIMER":true}}}` ).
    lo_second->main_begin( ).
    lo_second->main_loop( ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = count_in( iv_text = lo_second->mv_response
                                                        iv_sub  = c_any ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = lo_second->ms_response-s_front-id
                                        msg = `an unchanged tick answers the draft it continued` ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 08 - the public test harness z2ui5_cl_ui5_test on what it promises: user
" input as a model delta (a table cell included), the reload from a draft,
" the timer tick, a called app and its way back, the stateful session.
" It drives the handler through its public members only, so this class
" needs no friendship
" ---------------------------------------------------------------------------
CLASS ltcl_app_harness DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mt_tab      TYPE ty_t_row.
    DATA mv_count    TYPE i.
    DATA mv_flag     TYPE abap_bool.
    DATA mv_restored TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS view_display
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
ENDCLASS.

CLASS ltcl_app_harness IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
    IF client->check_on_init( ).
      mt_tab = VALUE #( ( name = `one` ) ( name = `two` ) ).
      view_display( client ).
    ELSEIF client->check_on_navigated( ).
      mv_restored = abap_true.
      view_display( client ).
    ELSE.
      on_event( client ).
    ENDIF.
  ENDMETHOD.

  METHOD view_display.
    client->view_display( |<mvc:View><Table items="{ client->_bind( mt_tab ) }"/>| &&
                          |<CheckBox selected="{ client->_bind( mv_flag ) }"/>| &&
                          |<Button press="{ client->_event( `COUNT` ) }"/></mvc:View>| ).
  ENDMETHOD.

  METHOD on_event.
    CASE client->get_event( ).
      WHEN `COUNT` OR `TICK`.
        mv_count = mv_count + 1.
        client->message_toast_display( |{ mv_count }: { mt_tab[ 2 ]-name }| ).
      WHEN `TIMER_ON`.
        client->follow_up_action( val   = client->cs_event-start_timer
                                  t_arg = VALUE #( ( `TICK` ) ( `1000` ) ) ).
      WHEN `ARG`.
        client->message_box_display( text  = client->get_event_arg( 1 )
                                     type  = `error`
                                     title = `T` ).
      WHEN `STICKY`.
        client->set_session_stateful( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_08_harness DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS cell_edit_reaches_app FOR TESTING RAISING cx_static_check.
    METHODS bool_edit_and_args FOR TESTING RAISING cx_static_check.
    METHODS restore_from_draft FOR TESTING RAISING cx_static_check.
    METHODS timer_tick_one_shot FOR TESTING RAISING cx_static_check.
    METHODS timer_set_repeats FOR TESTING RAISING cx_static_check.
    METHODS called_app_leaves FOR TESTING RAISING cx_static_check.
    METHODS sticky_keeps_instance FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_08_harness IMPLEMENTATION.

  METHOD cell_edit_reaches_app.

    " the first start renders the table, the model carries its rows
    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_harness( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->view_xml( ) CS `/MT_TAB` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `two`
                                        act = lo_test->model( `/MT_TAB/1/NAME` ) ).

    " a cell typed into travels as the row delta and lands in the row
    lo_test->set_model( path = `/MT_TAB/1/NAME`
                        val  = `zwei` )->event( `COUNT` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->response( ) NS `"MAIN"` ) ).
    DATA(lo_app) = CAST ltcl_app_harness( lo_test->app( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `zwei`
                                        act = lo_app->mt_tab[ 2 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `one`
                                        act = lo_app->mt_tab[ 1 ]-name ).
    DATA(lt_message) = lo_test->messages( ).
    cl_abap_unit_assert=>assert_equals( exp = `toast`
                                        act = lt_message[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals( exp = `1: zwei`
                                        act = lt_message[ 1 ]-text ).
    " the view stays on screen, and the browser's model keeps the edit
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->view_xml( ) CS `COUNT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `zwei`
                                        act = lo_test->model( `/MT_TAB/1/NAME` ) ).

  ENDMETHOD.

  METHOD bool_edit_and_args.

    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_harness( ) ).
    lo_test->set_model( path = `/MV_FLAG`
                        val  = abap_true
               )->event( val   = `ARG`
                         t_arg = VALUE #( ( `from the view` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = CAST ltcl_app_harness( lo_test->app( ) )->mv_flag ).
    DATA(lt_message) = lo_test->messages( ).
    cl_abap_unit_assert=>assert_equals( exp = `error`
                                        act = lt_message[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals( exp = `from the view`
                                        act = lt_message[ 1 ]-text ).
    cl_abap_unit_assert=>assert_equals( exp = `T`
                                        act = lt_message[ 1 ]-title ).
    DATA(lt_action) = lo_test->actions( ).
    cl_abap_unit_assert=>assert_equals( exp = `MESSAGE_BOX`
                                        act = lt_action[ 1 ]-name ).

  ENDMETHOD.

  METHOD restore_from_draft.

    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_harness( ) )->event( `COUNT` ).
    lo_test->restore( ).

    " a reload: the app comes back from its draft, navigated and not new
    DATA(lo_app) = CAST ltcl_app_harness( lo_test->app( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_app->mv_count ).
    cl_abap_unit_assert=>assert_true( lo_app->mv_restored ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->view_xml( ) CS `/MT_TAB` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `two`
                                        act = lo_test->model( `/MT_TAB/1/NAME` ) ).

  ENDMETHOD.

  METHOD timer_tick_one_shot.

    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_harness( ) )->event( `TIMER_ON` ).
    cl_abap_unit_assert=>assert_equals( exp = `TICK`
                                        act = lo_test->timer_event( ) ).

    lo_test->timer( ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = CAST ltcl_app_harness( lo_test->app( ) )->mv_count ).
    " a one-shot timer is spent by the roundtrip that did not arm it again
    cl_abap_unit_assert=>assert_initial( lo_test->timer_event( ) ).
    TRY.
        lo_test->timer( ).
        cl_abap_unit_assert=>fail( `no timer is armed` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD timer_set_repeats.

    " client->timer_set( ) in check_on_init: the declared timer is armed
    " once and keeps ticking - every tick is a roundtrip for its event
    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_timer( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `REFRESH`
                                        act = lo_test->timer_event( ) ).
    lo_test->timer( )->timer( ).
    cl_abap_unit_assert=>assert_equals( exp = `REFRESH`
                                        act = lo_test->timer_event( ) ).

    lo_test->event( `STOP` ).
    cl_abap_unit_assert=>assert_initial( lo_test->timer_event( ) ).

  ENDMETHOD.

  METHOD called_app_leaves.

    " the popup app as the target of a call - its leave goes back
    DATA(lo_test) = z2ui5_cl_ui5_test=>start_called( NEW ltcl_app_popup_bound( ) ).
    cl_abap_unit_assert=>assert_bound( CAST ltcl_app_popup_bound( lo_test->nav_called( ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->popup_xml( ) CS `<Dialog>` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `edit me`
                                        act = lo_test->model( `/MS_ROW/NAME` ) ).

    lo_test->event( `CLOSE` ).
    cl_abap_unit_assert=>assert_initial( lo_test->popup_xml( ) ).
    DATA(lo_left) = CAST ltcl_app_popup_bound( lo_test->nav_left( ) ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = lo_left->ms_row-name ).

  ENDMETHOD.

  METHOD sticky_keeps_instance.

    DATA(lo_test) = z2ui5_cl_ui5_test=>start( NEW ltcl_app_harness( ) ).
    DATA(li_first) = lo_test->event( `COUNT` )->app( ).
    " a stateless app is restored from its draft - a new instance
    DATA(li_sticky) = lo_test->event( `STICKY` )->app( ).
    cl_abap_unit_assert=>assert_false( xsdbool( li_sticky = li_first ) ).
    " a stateful one keeps it, as the session keeps the handler
    cl_abap_unit_assert=>assert_true( xsdbool( lo_test->event( `COUNT` )->app( ) = li_sticky ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = CAST ltcl_app_harness( lo_test->app( ) )->mv_count ).

  ENDMETHOD.

ENDCLASS.
