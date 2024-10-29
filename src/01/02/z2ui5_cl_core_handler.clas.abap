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
    mo_action = NEW z2ui5_cl_core_action( me ).

  ENDMETHOD.

  METHOD main.

    main_begin( ).
    DO.
      IF main_process( ).
        EXIT.
      ENDIF.
    ENDDO.

    result = VALUE #( body       = mv_response
                      s_stateful = ms_response-s_front-params-s_stateful
    ).

  ENDMETHOD.

  METHOD main_begin.
    TRY.

        DATA(lo_json_mapper) = NEW z2ui5_cl_core_srv_json( ).
        ms_request = lo_json_mapper->request_json_to_abap( mv_request_json ).

        IF ms_request-s_front-id IS NOT INITIAL.
          mo_action = mo_action->factory_by_frontend( ).

        ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
          NEW z2ui5_cl_core_srv_draft( )->cleanup( ).
          mo_action = mo_action->factory_first_start( ).

        ELSE.
          mo_action = mo_action->factory_system_startup( ).
        ENDIF.

      CATCH cx_root INTO DATA(x).
        ASSERT x->get_text( ) = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD main_end.

    ms_response = VALUE #( s_front-params = mo_action->ms_next-s_set
                           s_front-id     = mo_action->mo_app->ms_draft-id
                           s_front-app    = z2ui5_cl_util=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app )
        ).

    IF    ms_response-s_front-params-s_view-check_update_model        = abap_true
       OR ms_response-s_front-params-s_view_nest-check_update_model   = abap_true
       OR ms_response-s_front-params-s_view_nest2-check_update_model  = abap_true
       OR ms_response-s_front-params-s_popup-check_update_model       = abap_true
       OR ms_response-s_front-params-s_popover-check_update_model     = abap_true
       OR ms_response-s_front-params-s_view-xml IS NOT INITIAL
       OR ms_response-s_front-params-s_view_nest-xml                 IS NOT INITIAL
       OR ms_response-s_front-params-s_view_nest2-xml                IS NOT INITIAL
       OR ms_response-s_front-params-s_popup-xml IS NOT INITIAL
       OR ms_response-s_front-params-s_popover-xml                   IS NOT INITIAL.

      DATA(lo_model) = NEW z2ui5_cl_core_srv_attri( attri = mo_action->mo_app->mt_attri
                                                    app   = mo_action->mo_app->mo_app ).
      lo_model->attri_refs_update( ).
      ms_response-model = mo_action->mo_app->model_json_stringify( ).

    ELSE.
      ms_response-model = `{}`.
    ENDIF.

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_srv_json( ).
    mv_response = lo_json_mapper->response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.

    IF CAST z2ui5_if_app( mo_action->mo_app->mo_app )->check_sticky = abap_false.
      mo_action->mo_app->db_save( ).
    ENDIF.

  ENDMETHOD.

  METHOD main_process.
    TRY.

        DATA(li_client) = NEW z2ui5_cl_core_client( mo_action ).
        DATA(li_app)    = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

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

      CATCH cx_root INTO DATA(x).
        ASSERT x->get_text( ) = 1.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
