CLASS z2ui5_cl_core_handler DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

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

  PROTECTED SECTION.

    METHODS main_begin.

    METHODS main_process
      RETURNING
        VALUE(check_go_client) TYPE abap_bool.

    METHODS main_end.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_handler IMPLEMENTATION.

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

  ENDMETHOD.

  METHOD main_begin.
        DATA lo_json_mapper TYPE REF TO z2ui5_cl_core_srv_json.
          DATA temp1 TYPE REF TO z2ui5_cl_core_srv_draft.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        CREATE OBJECT lo_json_mapper TYPE z2ui5_cl_core_srv_json.
        ms_request = lo_json_mapper->request_json_to_abap( mv_request_json ).

        IF ms_request-s_front-id IS NOT INITIAL.
          mo_action = mo_action->factory_by_frontend( ).

        ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
          
          CREATE OBJECT temp1 TYPE z2ui5_cl_core_srv_draft.
          temp1->cleanup( ).
          mo_action = mo_action->factory_first_start( ).

        ELSE.
          mo_action = mo_action->factory_system_startup( ).
        ENDIF.

        
      CATCH cx_root INTO x.
        ASSERT x->get_text( ) = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD main_end.
      DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    DATA lo_json_mapper TYPE REF TO z2ui5_cl_core_srv_json.
    DATA temp2 TYPE REF TO z2ui5_if_app.

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

      
      CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = mo_action->mo_app->mt_attri app = mo_action->mo_app->mo_app.
      lo_model->attri_refs_update( ).
      ms_response-model = mo_action->mo_app->model_json_stringify( ).

    ELSE.
      ms_response-model = `{}`.
    ENDIF.

    
    CREATE OBJECT lo_json_mapper TYPE z2ui5_cl_core_srv_json.
    mv_response = lo_json_mapper->response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.

    
    temp2 ?= mo_action->mo_app->mo_app.
    IF temp2->check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ENDIF.

  ENDMETHOD.

  METHOD main_process.
        DATA li_client TYPE REF TO z2ui5_cl_core_client.
        DATA temp3 TYPE REF TO z2ui5_if_app.
        DATA li_app LIKE temp3.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        CREATE OBJECT li_client TYPE z2ui5_cl_core_client EXPORTING ACTION = mo_action.
        
        temp3 ?= mo_action->mo_app->mo_app.
        
        li_app = temp3.

        IF li_app->check_sticky = abap_false.
          ROLLBACK WORK.
        ENDIF.
        li_app->main( li_client ).
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

        
      CATCH cx_root INTO x.
        ASSERT x->get_text( ) = 1.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
