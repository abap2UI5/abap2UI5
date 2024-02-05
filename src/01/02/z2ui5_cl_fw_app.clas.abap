CLASS z2ui5_cl_fw_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mo_http_post TYPE REF TO z2ui5_cl_fw_http_post.
    DATA mo_model     TYPE REF TO z2ui5_cl_fw_model.

    DATA ms_actual TYPE z2ui5_if_fw_types=>ty_s_actual.
    DATA ms_next   TYPE z2ui5_if_fw_types=>ty_s_next.
    DATA ms_draft  TYPE z2ui5_if_types=>ty_s_get-s_draft.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_system_error
      IMPORTING
        ix            TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_stack_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_stack_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_fw_http_post.

    METHODS db_load
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS db_save.

  PROTECTED SECTION.

    METHODS app_next_factory
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_app IMPLEMENTATION.


  METHOD app_next_factory.

    app->id_draft = COND string( WHEN app->id_draft IS INITIAL THEN z2ui5_cl_util_func=>uuid_get_c32( ) ELSE app->id_draft ).

    result = NEW #( mo_http_post ).
    result->mo_model->mo_app     = app.
    result->ms_draft-id          = app->id_draft.
    result->ms_draft-id_prev     = ms_draft-id.
    result->ms_draft-id_prev_app = ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set     = ms_next-s_set.

    TRY.
        DATA(lo_app) = db_load( app->id_draft ).
        result->mo_model->mo_app = lo_app->mo_model->mo_app.
        result->mo_model->mt_attri = lo_app->mo_model->mt_attri.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD constructor.

    mo_http_post = val.
    mo_model = NEW #( ).

  ENDMETHOD.


  METHOD factory_by_frontend.

    result = db_load( mo_http_post->ms_request-s_frontend-id ).

    result->ms_draft-id         = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_draft-id_prev    = mo_http_post->ms_request-s_frontend-id.
    result->ms_actual-viewname  = mo_http_post->ms_request-s_frontend-viewname.

    result->mo_model->json_client_parse(
        viewname = mo_http_post->ms_request-s_frontend-viewname
        o_model  = mo_http_post->ms_request-o_model
    ).

    result->ms_actual-event = mo_http_post->ms_request-s_frontend-event.
    result->ms_actual-t_event_arg = mo_http_post->ms_request-s_frontend-t_event_arg.
    result->ms_actual-check_on_navigated = abap_false.

  ENDMETHOD.


  METHOD factory_first_start.

    TRY.
        result = NEW #( mo_http_post ).
        result->ms_draft-id = z2ui5_cl_util_func=>uuid_get_c32( ).

        CREATE OBJECT result->mo_model->mo_app TYPE (mo_http_post->ms_request-s_control-app_start).
        CAST z2ui5_if_app( result->mo_model->mo_app )->id_draft = result->ms_draft-id.
        result->ms_actual-check_on_navigated = abap_true.

      CATCH cx_root.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `App with name ` && mo_http_post->ms_request-s_control-app_start && ` not found...`.
    ENDTRY.

  ENDMETHOD.


  METHOD factory_stack_call.

    result = app_next_factory( ms_next-o_app_call ).
    result->ms_draft-id_prev_app_stack = ms_draft-id.
    db_save( ).

  ENDMETHOD.


  METHOD factory_stack_leave.

    result = app_next_factory( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = NEW z2ui5_cl_fw_hlp_db( )->read(
            id = result->ms_draft-id
            check_load_app = abap_false ).

        result->ms_draft-id_prev_app_stack = ls_draft-id_prev_app_stack.
      CATCH cx_root.
        result->ms_draft-id_prev_app_stack = ms_draft-id_prev_app_stack.
    ENDTRY.

    db_save( ).

  ENDMETHOD.


  METHOD factory_system_error.

    result = NEW #( mo_http_post ).
    result->ms_draft-id = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-o_app_call = z2ui5_cl_fw_app_error=>factory( ix ).
    result = result->factory_stack_call(  ).

  ENDMETHOD.


  METHOD factory_system_startup.

    result = NEW #( mo_http_post ).
    result->ms_draft-id = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_model->mo_app = z2ui5_cl_fw_app_startup=>factory( ).
    CAST z2ui5_if_app( result->mo_model->mo_app )->id_draft = result->ms_draft-id.

  ENDMETHOD.


  METHOD db_load.

    result = NEW #( mo_http_post ).
    DATA(ls_db) = NEW z2ui5_cl_fw_hlp_db( )->load_app( id ).
    result->ms_draft = CORRESPONDING #( ls_db ).
    result->mo_model->xml_db_parse( ls_db-data ).

  ENDMETHOD.


  METHOD db_save.

    CLEAR ms_next.
    IF mo_model->mo_app IS BOUND.
      CAST z2ui5_if_app( mo_model->mo_app )->id_draft = ms_draft-id.
    ENDIF.
    new z2ui5_cl_fw_hlp_db( )->create(
        draft     = ms_draft
        model_xml = mo_model->xml_db_stringify( ) ).

  ENDMETHOD.

ENDCLASS.
