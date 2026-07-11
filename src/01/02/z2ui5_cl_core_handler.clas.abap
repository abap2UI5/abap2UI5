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

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_abap2ui5_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD request_parse_body.
    DATA(lo_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( val ) ).
    DATA(lo_ajson2) = lo_ajson->slice( `value` ).

    IF lo_ajson2 IS BOUND.
      lo_ajson = lo_ajson2.
    ENDIF.

    DATA(lv_model_edit_name) = |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }|.
    result-o_model = z2ui5_cl_ajson=>create_empty( ).
    DATA(lo_model) = lo_ajson->slice( lv_model_edit_name ).
    result-o_model->set( iv_path = lv_model_edit_name
                         iv_val  = lo_model ).
    lo_ajson->delete( lv_model_edit_name ).

    lo_ajson = lo_ajson->slice( `/S_FRONT` ).
    lo_ajson->to_abap( EXPORTING iv_corresponding = abap_true
                       IMPORTING ev_container     = result-s_front ).
    result-s_front-o_comp_data = lo_ajson->slice( `/CONFIG/ComponentData` ).

    DATA(lo_device) = lo_ajson->slice( `/CONFIG/S_DEVICE` ).
    IF lo_device IS BOUND.
      lo_device->to_abap( EXPORTING iv_corresponding = abap_true
                          IMPORTING ev_container     = result-s_front-s_device ).
    ENDIF.
    DATA(lo_focus) = lo_ajson->slice( `/CONFIG/S_FOCUS` ).
    IF lo_focus IS BOUND.
      lo_focus->to_abap( EXPORTING iv_corresponding = abap_true
                         IMPORTING ev_container     = result-s_front-s_focus ).
    ENDIF.
    DATA(lo_scroll) = lo_ajson->slice( `/CONFIG/S_SCROLL` ).
    IF lo_scroll IS BOUND.
      lo_scroll->to_abap( EXPORTING iv_corresponding = abap_true
                          IMPORTING ev_container     = result-s_front-s_scroll ).
    ENDIF.

    result-s_front-s_ui5-version         = lo_ajson->get_string( `/CONFIG/S_UI5/VERSION` ).
    result-s_front-s_ui5-build_timestamp = lo_ajson->get_string( `/CONFIG/S_UI5/BUILDTIMESTAMP` ).
    result-s_front-s_ui5-gav             = lo_ajson->get_string( `/CONFIG/S_UI5/GAV` ).
    result-s_front-s_ui5-theme           = lo_ajson->get_string( `/CONFIG/S_UI5/THEME` ).

    result-s_control-check_launchpad = xsdbool(
        result-s_front-search   CS `scenario=LAUNCHPAD`
        OR result-s_front-pathname CS `/ui2/flp`
        OR result-s_front-pathname CS `test/flpSandbox` ).
  ENDMETHOD.

  METHOD request_app_start.
    TRY.
        IF io_comp_data IS BOUND.
          result = z2ui5_cl_abap2ui5_context=>c_trim_upper(
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

    result = z2ui5_cl_abap2ui5_context=>c_trim_upper(
        z2ui5_cl_abap2ui5_context=>url_param_get( val = `app_start`
                                      url             = iv_search ) ).
  ENDMETHOD.

  METHOD request_app_start_draft.
    TRY.
        DATA(lv_hash) = substring_after( val = iv_hash
                                         sub = `&/` ).
        IF lv_hash IS INITIAL.
          lv_hash = iv_hash+2.
        ENDIF.
        result = z2ui5_cl_abap2ui5_context=>c_trim_upper(
            z2ui5_cl_abap2ui5_context=>url_param_get( val = `z2ui5-xapp-state`
                                          url             = lv_hash ) ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD response_abap_to_json.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                                      ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( z2ui5_cl_abap2ui5_json_fltr=>create_no_empty_values( ) ).
        DATA(lv_frontend) = ajson_result->stringify( ).

        DATA(lv_model) = COND string( WHEN val-model IS NOT INITIAL THEN val-model ELSE `{}` ).

        result = |\{"S_FRONT":{ lv_frontend },"MODEL":{ lv_model }\}|.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_abap2ui5_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    mo_action = NEW z2ui5_cl_core_action( me ).

  ENDMETHOD.

  METHOD main.

    main_begin( ).
    main_loop( ).

    result = VALUE #( body          = mv_response
                      s_stateful    = ms_response-s_front-params-s_stateful
                      status_code   = 200
                      status_reason = `success` ).

  ENDMETHOD.

  METHOD main_loop.

    DATA(lv_dispatch_count) = 0.

    DO.
      IF main_process( ).
        RETURN.
      ENDIF.
      lv_dispatch_count = lv_dispatch_count + 1.
      IF lv_dispatch_count >= mv_dispatch_limit.
        RAISE EXCEPTION TYPE z2ui5_cx_abap2ui5_error
          EXPORTING
            val = |Dispatch limit of { mv_dispatch_limit } app navigations in one request reached - check for an endless nav_app_call/nav_app_leave loop in main( )|.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD main_begin.

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

    SPLIT z2ui5_if_core_types=>cs_view_slot_list AT `,` INTO TABLE DATA(lt_slot).
    LOOP AT lt_slot INTO DATA(lv_slot).
      ASSIGN COMPONENT lv_slot OF STRUCTURE ms_response-s_front-params TO FIELD-SYMBOL(<slot>).
      ASSERT sy-subrc = 0.
      ASSIGN COMPONENT `CHECK_UPDATE_MODEL` OF STRUCTURE <slot> TO FIELD-SYMBOL(<check_update_model>).
      ASSERT sy-subrc = 0.
      ASSIGN COMPONENT `XML` OF STRUCTURE <slot> TO FIELD-SYMBOL(<xml>).
      ASSERT sy-subrc = 0.
      IF <check_update_model> = abap_true OR <xml> IS NOT INITIAL.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_end.

    ms_response = VALUE #( s_front-params = mo_action->ms_next-s_set
                           s_front-id     = mo_action->mo_app->ms_draft-id
                           s_front-app    = z2ui5_cl_abap2ui5_context=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ) ).

    IF check_view_update_needed( ).
      ms_response-model = mo_action->mo_app->model_json_stringify( ).
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

    IF li_app->check_sticky = abap_false.
      z2ui5_cl_abap2ui5_context=>db_rollback( ).
    ENDIF.
    TRY.
        IF mo_action->ms_actual-event = z2ui5_if_core_types=>cs_event_nav_app_leave.
          li_client->popup_destroy( ).
          li_client->nav_app_leave( ).
        ELSE.
          li_app->main( li_client ).
        ENDIF.
      CATCH cx_root INTO DATA(lx).

        DATA(lx2) = NEW z2ui5_cx_abap2ui5_error( val  = `UNCAUGHT EXCEPTION - Please Restart App:`
                                             previous = lx ).
        li_client->nav_app_leave( z2ui5_cl_pop_error=>factory( lx2 ) ).
    ENDTRY.
    IF li_app->check_sticky = abap_false.
      z2ui5_cl_abap2ui5_context=>db_rollback( ).
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
