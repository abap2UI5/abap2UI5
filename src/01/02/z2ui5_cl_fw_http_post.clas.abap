CLASS z2ui5_cl_fw_http_post DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mv_request_plain  TYPE string.
    DATA ms_request        TYPE z2ui5_if_client=>ty_s_http_request_post.
    DATA ms_response       TYPE z2ui5_if_client=>ty_s_http_response_post.

    CLASS-METHODS factory
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_http_post.

    METHODS main
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    CLASS-DATA mo_http_mapper TYPE REF TO z2ui5_cl_fw_http_mapper.
    DATA mo_app        TYPE REF TO z2ui5_cl_fw_app.

    METHODS main_begin.
    METHODS main_process
      RETURNING
        VALUE(check_go_frontend) TYPE abap_bool.
    METHODS main_end
      RETURNING
        VALUE(result) TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_http_post IMPLEMENTATION.


  METHOD factory.

    result = NEW #( ).
    result->mv_request_plain = val.
    mo_http_mapper = NEW z2ui5_cl_fw_http_mapper( ).
    result->mo_app = NEW z2ui5_cl_fw_app( result ).

  ENDMETHOD.


  METHOD main_begin.

    ms_request = mo_http_mapper->request_json_to_abap( mv_request_plain ).

    TRY.
        IF ms_request-s_frontend-id IS NOT INITIAL.
          mo_app = mo_app->factory_by_frontend( ).
        ELSEIF ms_request-s_control-app_start IS NOT INITIAL.
          mo_app = mo_app->factory_first_start( ).
        ELSE.
          mo_app = mo_app->factory_system_startup( ).
        ENDIF.
      CATCH cx_root INTO DATA(x).
        mo_app = mo_app->factory_system_error( x ).
    ENDTRY.
  ENDMETHOD.


  METHOD main_end.
    TRY.
        DATA(lo_ajson) = NEW z2ui5_cl_fw_http_mapper( )->model_back_to_front(
                app     = mo_app->ms_db-app
              t_attri = mo_app->ms_db-t_attri ).
        z2ui5_cl_fw_draft=>create( id = mo_app->ms_db-id db = mo_app->ms_db ).
        ms_response-s_frontend-params = mo_app->ms_next-s_set.
        ms_response-s_frontend-id = mo_app->ms_db-id.
        ms_response-oviewmodel = lo_ajson.
      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.

    result = mo_http_mapper->response_abap_to_json( ms_response ).

  ENDMETHOD.


  METHOD main_process.
    TRY.

        DATA(li_client) = NEW z2ui5_cl_fw_client( mo_app ).
        DATA(li_app) = CAST z2ui5_if_app( mo_app->ms_db-app ).

        ROLLBACK WORK.
        li_app->main( li_client ).
        ROLLBACK WORK.

        IF mo_app->ms_next-o_app_leave IS NOT INITIAL.
          mo_app = mo_app->factory_app_leave( ).
        ELSEIF mo_app->ms_next-o_app_call IS NOT INITIAL.
          mo_app = mo_app->factory_app_call( ).
        ELSE.
          check_go_frontend = abap_true.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        mo_app = mo_app->factory_system_error( x ).
    ENDTRY.
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
ENDCLASS.
