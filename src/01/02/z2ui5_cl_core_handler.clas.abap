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
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD request_parse_body.
    DATA temp1 TYPE REF TO z2ui5_if_ajson.
    DATA lo_ajson LIKE temp1.
    DATA lo_ajson2 TYPE REF TO z2ui5_if_ajson.
    DATA lv_model_edit_name TYPE string.
    DATA lo_model TYPE REF TO z2ui5_if_ajson.
    DATA temp2 TYPE xsdboolean.
    temp1 ?= z2ui5_cl_ajson=>parse( val ).
    
    lo_ajson = temp1.
    
    lo_ajson2 = lo_ajson->slice( `value` ).

    IF lo_ajson2 IS BOUND.
      lo_ajson = lo_ajson2.
    ENDIF.

    
    lv_model_edit_name = |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }|.
    result-o_model = z2ui5_cl_ajson=>create_empty( ).
    
    lo_model = lo_ajson->slice( lv_model_edit_name ).
    result-o_model->set( iv_path = lv_model_edit_name
                         iv_val  = lo_model ).
    lo_ajson->delete( lv_model_edit_name ).

    lo_ajson = lo_ajson->slice( `/S_FRONT` ).
    lo_ajson->to_abap( EXPORTING iv_corresponding = abap_true
                       IMPORTING ev_container     = result-s_front ).
    result-s_front-o_comp_data = lo_ajson->slice( `/CONFIG/ComponentData` ).

    
    temp2 = boolc( result-s_front-search CS `scenario=LAUNCHPAD` OR result-s_front-pathname CS `/ui2/flp` OR result-s_front-pathname CS `test/flpSandbox` ).
    result-s_control-check_launchpad = temp2.
  ENDMETHOD.

  METHOD request_app_start.
    TRY.
        IF io_comp_data IS BOUND.
          result = z2ui5_cl_util=>c_trim_upper(
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

    result = z2ui5_cl_util=>c_trim_upper(
        z2ui5_cl_util=>url_param_get( val = `app_start`
                                      url = iv_search ) ).
  ENDMETHOD.

  METHOD request_app_start_draft.
        DATA lv_hash TYPE string.
    TRY.
        
        lv_hash = substring_after( val = iv_hash
                                         sub = `&/` ).
        IF lv_hash IS INITIAL.
          lv_hash = iv_hash+2.
        ENDIF.
        result = z2ui5_cl_util=>c_trim_upper(
            z2ui5_cl_util=>url_param_get( val = `z2ui5-xapp-state`
                                          url = lv_hash ) ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD response_abap_to_json.
        DATA temp2 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp2.
        DATA lv_frontend TYPE string.
        DATA temp3 TYPE string.
        DATA lv_model LIKE temp3.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp2 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).
        
        ajson_result = temp2.

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( z2ui5_cl_util_json_fltr=>create_no_empty_values( ) ).
        
        lv_frontend = ajson_result->stringify( ).

        
        IF val-model IS NOT INITIAL.
          temp3 = val-model.
        ELSE.
          temp3 = `{}`.
        ENDIF.
        
        lv_model = temp3.

        result = |\{| &&
            |"S_FRONT":{ lv_frontend },| &&
            |"MODEL":{ lv_model }| &&
          |\}|.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    mv_request_json = val.
    CREATE OBJECT mo_action TYPE z2ui5_cl_core_action EXPORTING VAL = me.

  ENDMETHOD.

  METHOD main.

    main_begin( ).
    DO.
      IF main_process( ) IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

    CLEAR result.
    result-body = mv_response.
    result-s_stateful = ms_response-s_front-params-s_stateful.
    result-status_code = 200.
    result-status_reason = `success`.

  ENDMETHOD.

  METHOD main_begin.
      DATA temp4 TYPE REF TO z2ui5_cl_core_srv_draft.

    ms_request = request_json_to_abap( mv_request_json ).

    IF ms_request-s_front-id IS NOT INITIAL.
      mo_action = mo_action->factory_by_frontend( ).

    ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
      
      CREATE OBJECT temp4 TYPE z2ui5_cl_core_srv_draft.
      temp4->cleanup( ).
      mo_action = mo_action->factory_first_start( ).

    ELSE.
      mo_action = mo_action->factory_system_startup( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_view_update_needed.

    DATA temp3 TYPE xsdboolean.
    temp3 = boolc( ms_response-s_front-params-s_view-check_update_model = abap_true OR ms_response-s_front-params-s_view_nest-check_update_model = abap_true OR ms_response-s_front-params-s_view_nest2-check_update_model = abap_true OR ms_response-s_front-params-s_popup-check_update_model = abap_true OR ms_response-s_front-params-s_popover-check_update_model = abap_true OR ms_response-s_front-params-s_view-xml IS NOT INITIAL OR ms_response-s_front-params-s_view_nest-xml IS NOT INITIAL OR ms_response-s_front-params-s_view_nest2-xml IS NOT INITIAL OR ms_response-s_front-params-s_popup-xml IS NOT INITIAL OR ms_response-s_front-params-s_popover-xml IS NOT INITIAL ).
    result = temp3.

  ENDMETHOD.

  METHOD main_end.
    DATA temp5 TYPE REF TO z2ui5_if_app.

    CLEAR ms_response.
    ms_response-s_front-params = mo_action->ms_next-s_set.
    ms_response-s_front-id = mo_action->mo_app->ms_draft-id.
    ms_response-s_front-app = z2ui5_cl_util=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).

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

    
    temp5 ?= mo_action->mo_app->mo_app.
    IF temp5->check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ENDIF.

  ENDMETHOD.

  METHOD main_process.

    DATA temp6 TYPE REF TO z2ui5_if_client.
    DATA li_client LIKE temp6.
    DATA temp7 TYPE REF TO z2ui5_if_app.
    DATA li_app LIKE temp7.
        DATA lx TYPE REF TO cx_root.
        DATA lx2 TYPE REF TO z2ui5_cx_util_error.
    CREATE OBJECT temp6 TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.
    
    li_client = temp6.
    
    temp7 ?= mo_action->mo_app->mo_app.
    
    li_app = temp7.

    IF li_app->check_sticky = abap_false.
      ROLLBACK WORK.
    ENDIF.
    TRY.
        IF li_client->get( )-event = z2ui5_if_core_types=>cs_event_nav_app_leave.
          li_client->popup_destroy( ).
          li_client->nav_app_leave( ).
        ELSE.
          li_app->main( li_client ).
        ENDIF.
        
      CATCH cx_root INTO lx.

        
        CREATE OBJECT lx2 TYPE z2ui5_cx_util_error EXPORTING val = `UNCAUGHT EXCEPTION - Please Restart App:` previous = lx.
        li_client->nav_app_leave( z2ui5_cl_pop_error=>factory( lx2 ) ).
    ENDTRY.
    IF li_app->check_sticky = abap_false.
      ROLLBACK WORK.
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
