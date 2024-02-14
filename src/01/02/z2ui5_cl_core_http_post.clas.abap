CLASS z2ui5_cl_core_http_post DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_action       TYPE REF TO z2ui5_cl_core_action.
    DATA mv_request_json TYPE string.
    DATA ms_request      TYPE z2ui5_if_core_types=>ty_s_http_request_post.
    DATA ms_response     TYPE z2ui5_if_core_types=>ty_s_http_response_post.

    METHODS constructor
      IMPORTING
        val TYPE string.

    METHODS main
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS main_begin.

    METHODS main_process
      RETURNING
        VALUE(check_go_client) TYPE abap_bool.

    METHODS main_end
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_http_post IMPLEMENTATION.


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
    result = main_end( ).

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
        s_front-params    = mo_action->ms_next-s_set
        s_front-id        = mo_action->mo_app->ms_draft-id
        s_front-app       = z2ui5_cl_util=>rtti_get_classname_by_ref( mo_action->mo_app->mo_app )
        s_front-app_start = ms_request-s_control-app_start
        model             = mo_action->mo_app->model_json_stringify( ) ).

    DATA(lo_json_mapper) = NEW z2ui5_cl_core_json_srv( ).
    result = lo_json_mapper->response_abap_to_json( ms_response ).

    CLEAR mo_action->ms_next.
    mo_action->mo_app->db_save( ).

  ENDMETHOD.


  METHOD main_process.
    TRY.

        DATA(li_client) = NEW z2ui5_cl_core_client( mo_action ).
        DATA(li_app)    = CAST z2ui5_if_app( mo_action->mo_app->mo_app ).

        ROLLBACK WORK.
        li_app->main( li_client ).
        ROLLBACK WORK.

        IF mo_action->ms_next-o_app_leave IS NOT INITIAL.
          mo_action = mo_action->factory_stack_leave( ).

        ELSEIF mo_action->ms_next-o_app_call IS NOT INITIAL.
          mo_action = mo_action->factory_stack_call( ).

        ELSE.
          check_go_client = abap_true.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        mo_action = mo_action->factory_system_error( x ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
