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
ENDCLASS.


CLASS z2ui5_cl_core_handler IMPLEMENTATION.

  METHOD request_json_to_abap.
        DATA x TYPE REF TO cx_root.
    TRY.
        result = request_parse_body( val ).

        IF result-s_front-id IS NOT INITIAL.
          RETURN.
        ENDIF.

        result-s_control-app_start =
          request_app_start( iv_search    = result-s_front-search
                             io_comp_data = result-s_front-o_comp_data ).
        result-s_control-app_start_draft =
          request_app_start_draft( result-s_front-hash ).


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD request_parse_body.
    DATA temp16 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp16.
    DATA temp17 TYPE string.
    DATA lv_root LIKE temp17.
    DATA lv_model_edit_name TYPE string.
    DATA lo_model TYPE REF TO z2ui5_if_ajson.
    DATA lv_check_arg_object TYPE abap_bool.
    DATA lt_event_arg TYPE string_table.
    DATA lo_config TYPE REF TO z2ui5_if_ajson.
      DATA lo_device TYPE REF TO z2ui5_if_ajson.
      DATA lo_focus TYPE REF TO z2ui5_if_ajson.
      DATA lo_scroll TYPE REF TO z2ui5_if_ajson.
    DATA temp1 TYPE xsdboolean.
    temp16 ?= z2ui5_cl_ajson=>parse( val ).

    lo_ajson = temp16.

    " standalone requests arrive wrapped as { "value": <payload> } (see
    " app/webapp/core/Server.js), launchpad/gateway proxies may strip the
    " envelope - a keyed lookup detects it, slicing the whole tree only to
    " unwrap it would walk and copy every node of the request

    IF lo_ajson->exists( `/value` ) = abap_true.
      temp17 = `/value`.
    ELSE.
      CLEAR temp17.
    ENDIF.

    lv_root = temp17.


    lv_model_edit_name = |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }|.
    result-o_model = z2ui5_cl_ajson=>create_empty( ).

    lo_model = lo_ajson->slice( lv_root && lv_model_edit_name ).
    result-o_model->set( iv_path = lv_model_edit_name
                         iv_val  = lo_model ).

    lo_ajson = lo_ajson->slice( lv_root && `/S_FRONT` ).



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


      lo_device = lo_config->slice( `/S_DEVICE` ).
      IF lo_device IS BOUND.
        lo_device->to_abap( EXPORTING iv_corresponding = abap_true
                            IMPORTING ev_container     = result-s_front-s_device ).
      ENDIF.

      lo_focus = lo_config->slice( `/S_FOCUS` ).
      IF lo_focus IS BOUND.
        lo_focus->to_abap( EXPORTING iv_corresponding = abap_true
                           IMPORTING ev_container     = result-s_front-s_focus ).
      ENDIF.

      lo_scroll = lo_config->slice( `/S_SCROLL` ).
      IF lo_scroll IS BOUND.
        lo_scroll->to_abap( EXPORTING iv_corresponding = abap_true
                            IMPORTING ev_container     = result-s_front-s_scroll ).
      ENDIF.

      result-s_front-s_ui5-version         = lo_config->get_string( `/S_UI5/VERSION` ).
      result-s_front-s_ui5-build_timestamp = lo_config->get_string( `/S_UI5/BUILDTIMESTAMP` ).
      result-s_front-s_ui5-gav             = lo_config->get_string( `/S_UI5/GAV` ).
      result-s_front-s_ui5-theme           = lo_config->get_string( `/S_UI5/THEME` ).

    ENDIF.


    temp1 = boolc( result-s_front-search CS `scenario=LAUNCHPAD` OR result-s_front-pathname CS `/ui2/flp` OR result-s_front-pathname CS `test/flpSandbox` ).
    result-s_control-check_launchpad = temp1.
  ENDMETHOD.

  METHOD request_parse_event_args.
    DATA lv_arg_index TYPE i.
      DATA lv_arg_path TYPE string.
          DATA temp18 TYPE string.

    " object event arguments arrive as raw JSON - the frontend sends them
    " unserialized so the request body is only encoded once - and to_abap
    " cannot place them in a string table, so they are serialized here and
    " apps keep receiving every argument as a string
    CLEAR et_event_arg.
    CLEAR ev_check_override.


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

          temp18 = io_front->get_boolean( lv_arg_path ).
          APPEND temp18 TO et_event_arg.
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
                                      url          = iv_search ) ).
  ENDMETHOD.

  METHOD request_app_start_draft.
        DATA lv_hash TYPE string.
    TRY.

        lv_hash = substring_after( val = iv_hash
                                         sub = `&/` ).
        IF lv_hash IS INITIAL.
          lv_hash = iv_hash+2.
        ENDIF.
        result = z2ui5_cl_a2ui5_context=>c_trim_upper(
            z2ui5_cl_a2ui5_context=>url_param_get( val = `z2ui5-xapp-state`
                                          url          = lv_hash ) ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD response_abap_to_json.
        DATA temp19 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp19.
        DATA lv_frontend TYPE string.
        DATA temp20 TYPE string.
        DATA lv_model LIKE temp20.
        DATA x TYPE REF TO cx_root.
    TRY.


        temp19 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).

        ajson_result = temp19.

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( z2ui5_cl_a2ui5_json_fltr=>create_no_empty_values( ) ).

        lv_frontend = ajson_result->stringify( ).


        IF val-model IS NOT INITIAL.
          temp20 = val-model.
        ELSE.
          temp20 = `{}`.
        ENDIF.

        lv_model = temp20.

        result = |\{"S_FRONT":{ lv_frontend },"MODEL":{ lv_model }\}|.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    CREATE OBJECT mo_action TYPE z2ui5_cl_core_action EXPORTING VAL = me.

  ENDMETHOD.

  METHOD main.

    main_begin( ).
    main_loop( ).

    CLEAR result.
    result-body = mv_response.
    result-s_stateful = ms_response-s_front-params-s_stateful.
    result-status_code = 200.
    result-status_reason = `success`.

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
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |Dispatch limit of { mv_dispatch_limit } app navigations in one request reached - check for an endless nav_app_call/nav_app_leave loop in main( )|.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD main_begin.
      DATA temp21 TYPE REF TO z2ui5_cl_core_srv_draft.

    ms_request = request_json_to_abap( mv_request_json ).

    IF ms_request-s_front-id IS NOT INITIAL.
      mo_action = mo_action->factory_by_frontend( ).

    ELSEIF ms_request-s_control-app_start IS NOT INITIAL.

      CREATE OBJECT temp21 TYPE z2ui5_cl_core_srv_draft.
      temp21->cleanup( ).
      mo_action = mo_action->factory_first_start( ).

    ELSE.
      mo_action = mo_action->factory_system_startup( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_view_update_needed.

    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_slot TYPE temp1.
    DATA lv_slot LIKE LINE OF lt_slot.
      FIELD-SYMBOLS <slot> TYPE any.
      FIELD-SYMBOLS <check_update_model> TYPE any.
      FIELD-SYMBOLS <xml> TYPE any.
    SPLIT z2ui5_if_core_types=>cs_view_slot_list AT `,` INTO TABLE lt_slot.

    LOOP AT lt_slot INTO lv_slot.

      ASSIGN COMPONENT lv_slot OF STRUCTURE ms_response-s_front-params TO <slot>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = |Internal error - view slot '{ lv_slot }' not found in response params|.
      ENDIF.

      ASSIGN COMPONENT `CHECK_UPDATE_MODEL` OF STRUCTURE <slot> TO <check_update_model>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = |Internal error - CHECK_UPDATE_MODEL missing in view slot '{ lv_slot }'|.
      ENDIF.

      ASSIGN COMPONENT `XML` OF STRUCTURE <slot> TO <xml>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = |Internal error - XML missing in view slot '{ lv_slot }'|.
      ENDIF.
      IF <check_update_model> = abap_true OR <xml> IS NOT INITIAL.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_end.
    DATA temp22 TYPE REF TO z2ui5_if_app.

    CLEAR ms_response.
    ms_response-s_front-params = mo_action->ms_next-s_set.
    ms_response-s_front-id = mo_action->mo_app->ms_draft-id.
    ms_response-s_front-app = z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).

    IF check_view_update_needed( ) IS NOT INITIAL.
      ms_response-model = mo_action->mo_app->model_json_stringify( ).
    ELSE.
      ms_response-model = `{}`.
    ENDIF.

    IF ms_response-s_front-params-s_popup-xml IS NOT INITIAL.
      ms_response-s_front-params-s_popup-check_update_model = abap_false.
    ENDIF.

    mv_response = response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.


    temp22 ?= mo_action->mo_app->mo_app.
    IF temp22->check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ENDIF.

  ENDMETHOD.

  METHOD main_process.

    DATA temp23 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp23.
    DATA temp24 TYPE REF TO z2ui5_if_app.
    DATA li_app LIKE temp24.
    CREATE OBJECT temp23 TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.

    li_client = temp23.

    temp24 ?= mo_action->mo_app->mo_app.

    li_app = temp24.

    IF li_app->check_sticky = abap_false.
      z2ui5_cl_a2ui5_context=>db_rollback( ).
    ENDIF.

    " uncaught exceptions from main( ) are intentionally NOT caught here - they
    " propagate all the way up to the ICF handler and trigger a real ABAP
    " runtime error (ST22 short dump) instead of being turned into an error popup
    IF mo_action->ms_actual-event = z2ui5_if_core_types=>cs_event_nav_app_leave.
      li_client->popup_destroy( ).
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
