CLASS z2ui5_cl_core_http_post DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_action       TYPE REF TO z2ui5_cl_core_action.
    DATA mv_request_json TYPE string.
    DATA ms_request      TYPE z2ui5_if_core_types=>ty_s_http_request_post.
    DATA ms_response     TYPE z2ui5_if_core_types=>ty_s_http_response_post.
    DATA mv_response    TYPE string.

    METHODS constructor
      IMPORTING
        val TYPE string.

    METHODS main
      EXPORTING
        attributes    TYPE z2ui5_if_types=>ty_s_http_handler_attributes
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS main_begin.

    METHODS main_process
      RETURNING
        VALUE(check_go_client) TYPE abap_bool.

    METHODS main_end.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_http_post IMPLEMENTATION.


  METHOD constructor.

    mv_request_json = val.
    mo_action = NEW z2ui5_cl_core_action( me ).

  ENDMETHOD.


  METHOD main.
    CLEAR attributes.

    main_begin( ).
    DO.
      IF main_process( ).
        EXIT.
      ENDIF.
    ENDDO.
    result = mv_response.
    attributes = ms_response-s_front-params-handler_attrs.

  ENDMETHOD.


  METHOD main_begin.
    TRY.

        DATA(lo_json_mapper) = NEW z2ui5_cl_core_json_srv( ).
        ms_request = lo_json_mapper->request_json_to_abap( mv_request_json ).

        IF ms_request-s_front-id IS NOT INITIAL.
          mo_action = mo_action->factory_by_frontend( ).

        ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
          mo_action = mo_action->factory_first_start( ).

        ELSE.
          mo_action = mo_action->factory_system_startup( ).
        ENDIF.

      CATCH cx_root INTO DATA(x).
        mo_action = mo_action->factory_system_error( x ).
    ENDTRY.
  ENDMETHOD.


  METHOD main_end.

    ms_response = VALUE #(
        s_front-params = mo_action->ms_next-s_set
        s_front-id     = mo_action->mo_app->ms_draft-id
        s_front-app    = z2ui5_cl_util=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app )
        ).

    IF ms_response-s_front-params-s_view-check_update_model = abap_true
    OR ms_response-s_front-params-s_view_nest-check_update_model = abap_true
    OR ms_response-s_front-params-s_view_nest2-check_update_model = abap_true
    OR ms_response-s_front-params-s_popup-check_update_model = abap_true
    OR ms_response-s_front-params-s_popover-check_update_model = abap_true
    OR ms_response-s_front-params-s_view-xml IS NOT INITIAL
    OR ms_response-s_front-params-s_view_nest-xml IS NOT INITIAL
    OR ms_response-s_front-params-s_view_nest2-xml IS NOT INITIAL
    OR ms_response-s_front-params-s_popup-xml IS NOT INITIAL
    OR ms_response-s_front-params-s_popover-xml IS NOT INITIAL.

      DATA(lo_model) = NEW z2ui5_cl_core_attri_srv(
       attri = mo_action->mo_app->mt_attri
       app   = mo_action->mo_app->mo_app ).
      lo_model->attri_refs_update( ).
      ms_response-model = mo_action->mo_app->model_json_stringify( ).

    ELSE.
      ms_response-model = `{}`.
    ENDIF.

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_json_srv( ).
    mv_response = lo_json_mapper->response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.
    mo_action->mo_app->db_save( ).

  ENDMETHOD.


  METHOD main_process.
    TRY.
        DATA li_client TYPE REF TO z2ui5_cl_core_client.
        TRY.
            CREATE OBJECT li_client TYPE ('ZCL_2UI5_CUSTOM_CLIENT')
                EXPORTING
                    action = mo_action.
          CATCH cx_root.
            li_client = NEW z2ui5_cl_core_client( mo_action ).
        ENDTRY.
        DATA(li_app)    = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

        ROLLBACK WORK.
        li_app->main( li_client ).
        ROLLBACK WORK.

        IF mo_action->ms_next-o_app_leave IS NOT INITIAL.
          mo_action = mo_action->factory_stack_leave( ).

        ELSEIF mo_action->ms_next-o_app_call IS NOT INITIAL.
          mo_action = mo_action->factory_stack_call( ).

        ELSE.
          main_end( ).
          check_go_client = abap_true.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        mo_action = mo_action->factory_system_error( x ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
