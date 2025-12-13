CLASS z2ui5_cl_core_handler DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

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

  PROTECTED SECTION.

    METHODS main_begin.

    METHODS main_process
      RETURNING
        VALUE(check_go_client) TYPE abap_bool.

    METHODS main_end.

    METHODS request_json_to_abap
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_request.

    METHODS response_abap_to_json
      IMPORTING
        val           TYPE z2ui5_if_core_types=>ty_s_response
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_handler IMPLEMENTATION.

  METHOD request_json_to_abap.
        DATA temp2 TYPE REF TO z2ui5_if_ajson.
        DATA lo_ajson LIKE temp2.
        DATA lv_model_edit_name TYPE string.
        DATA lo_model TYPE REF TO z2ui5_if_ajson.
        DATA temp1 TYPE xsdboolean.
              DATA lo_comp LIKE result-s_front-o_comp_data.
              DATA lv_app_start TYPE string.
            DATA lv_hash LIKE result-s_front-hash.
            DATA lv_dummy TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp2 ?= z2ui5_cl_ajson=>parse( val ).
        
        lo_ajson = temp2.
        lo_ajson = lo_ajson->slice( `value` ).

        
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

        
        temp1 = boolc( result-s_front-search CS `scenario=LAUNCHPAD` OR result-s_front-pathname CS `/ui2/flp` OR result-s_front-pathname CS `test/flpSandbox` ).
        result-s_control-check_launchpad = temp1.
        IF result-s_front-id IS NOT INITIAL.
          RETURN.
        ENDIF.

        TRY.
            IF result-s_front-o_comp_data IS BOUND.
              
              lo_comp = result-s_front-o_comp_data.
              
              lv_app_start = lo_comp->get( `/startupParameters/app_start/1` ).
              result-s_control-app_start = lv_app_start.
              result-s_control-app_start = z2ui5_cl_util=>c_trim_upper( result-s_control-app_start ).
            ENDIF.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

        TRY.
            
            lv_hash = result-s_front-hash.

            
            SPLIT lv_hash AT `&/` INTO lv_dummy lv_hash.
            IF lv_hash IS INITIAL.
              lv_hash = result-s_front-hash+2.
            ENDIF.
            result-s_control-app_start_draft = z2ui5_cl_util=>c_trim_upper(
                                                   z2ui5_cl_util=>url_param_get( val = `z2ui5-xapp-state`
                                                                                 url = lv_hash ) ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
        IF result-s_control-app_start IS NOT INITIAL.
          IF result-s_control-app_start(1) = `-`.
            REPLACE FIRST OCCURRENCE OF `-` IN result-s_control-app_start WITH `/`.
            REPLACE FIRST OCCURRENCE OF `-` IN result-s_control-app_start WITH `/`.
          ENDIF.
          RETURN.
        ENDIF.

        result-s_control-app_start = z2ui5_cl_util=>c_trim_upper(
                                         z2ui5_cl_util=>url_param_get( val = `app_start`
                                                                       url = result-s_front-search ) ).

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD response_abap_to_json.
        DATA temp3 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp3.
        DATA lv_frontend TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp3 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).
        
        ajson_result = temp3.

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( me ).
        
        lv_frontend = ajson_result->stringify( ).

        result = |\{| &&
            |"S_FRONT":{ lv_frontend },| &&
            |"MODEL":{ val-model }| &&
          |\}|.

        
      CATCH cx_root INTO x.
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            IF is_node-value = `false`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-number.
            IF is_node-value = `0`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-string.
            IF is_node-value = ``.
              rv_keep = abap_false.
            ENDIF.
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

    ENDCASE.

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

  METHOD main_end.
    DATA temp5 TYPE REF TO z2ui5_if_app.

    CLEAR ms_response.
    ms_response-s_front-params = mo_action->ms_next-s_set.
    ms_response-s_front-id = mo_action->mo_app->ms_draft-id.
    ms_response-s_front-app = z2ui5_cl_util=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app ).

    IF ms_response-s_front-params-s_view-check_update_model        = abap_true
        OR ms_response-s_front-params-s_view_nest-check_update_model   = abap_true
        OR ms_response-s_front-params-s_view_nest2-check_update_model  = abap_true
        OR ms_response-s_front-params-s_popup-check_update_model       = abap_true
        OR ms_response-s_front-params-s_popover-check_update_model     = abap_true
        OR ms_response-s_front-params-s_view-xml IS NOT INITIAL
        OR ms_response-s_front-params-s_view_nest-xml                 IS NOT INITIAL
        OR ms_response-s_front-params-s_view_nest2-xml                IS NOT INITIAL
        OR ms_response-s_front-params-s_popup-xml IS NOT INITIAL
        OR ms_response-s_front-params-s_popover-xml                   IS NOT INITIAL.

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

    DATA li_client TYPE REF TO z2ui5_cl_core_client.
    DATA temp6 TYPE REF TO z2ui5_if_app.
    DATA li_app LIKE temp6.
        DATA temp7 TYPE REF TO z2ui5_if_client.
        DATA li_client2 LIKE temp7.
        DATA lx TYPE REF TO cx_root.
        DATA lx2 TYPE REF TO z2ui5_cx_util_error.
    CREATE OBJECT li_client TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.
    
    temp6 ?= mo_action->mo_app->mo_app.
    
    li_app = temp6.

    IF li_app->check_sticky = abap_false.
      ROLLBACK WORK.
    ENDIF.
    TRY.
        
        temp7 ?= li_client.
        
        li_client2 = temp7.

        IF li_client2->get( )-event = `___ZZZ_NAL`.
          li_client2->popup_destroy( ).
          li_client2->nav_app_leave( ).
        ELSE.
          li_app->main( li_client ).
        ENDIF.
        
      CATCH cx_root INTO lx.

        
        CREATE OBJECT lx2 TYPE z2ui5_cx_util_error EXPORTING val = `UNCAUGHT EXCEPTION - Please Restart App:` previous = lx.
        li_client2->nav_app_leave( z2ui5_cl_pop_error=>factory( lx2 ) ).
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
