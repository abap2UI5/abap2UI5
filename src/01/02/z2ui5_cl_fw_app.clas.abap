CLASS z2ui5_cl_fw_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_next2,
        BEGIN OF s_view,
          xml                TYPE string,
          check_destroy      TYPE abap_bool,
          check_update_model TYPE abap_bool,
        END OF s_view,
        BEGIN OF s_view_nest,
          xml                TYPE string,
          id                 TYPE string,
          method_insert      TYPE string,
          method_destroy     TYPE string,
          check_destroy      TYPE abap_bool,
          check_update_model TYPE abap_bool,
        END OF s_view_nest,
        BEGIN OF s_view_nest2,
          xml                TYPE string,
          id                 TYPE string,
          method_insert      TYPE string,
          method_destroy     TYPE string,
          check_destroy      TYPE abap_bool,
          check_update_model TYPE abap_bool,
        END OF s_view_nest2,
        BEGIN OF s_popup,
          xml                TYPE string,
          id                 TYPE string,
          check_destroy      TYPE abap_bool,
          check_update_model TYPE abap_bool,
        END OF s_popup,
        BEGIN OF s_popover,
          xml                TYPE string,
          id                 TYPE string,
          open_by_id         TYPE string,
          check_destroy      TYPE abap_bool,
          check_update_model TYPE abap_bool,
        END OF s_popover,
        BEGIN OF s_msg_box,
          type TYPE string,
          text TYPE string,
        END OF s_msg_box,
        BEGIN OF s_msg_toast,
          text TYPE string,
        END OF s_msg_toast,
      END OF ty_s_next2.

    TYPES:
      BEGIN OF ty_s_next,
        o_app_call  TYPE REF TO z2ui5_if_app,
        o_app_leave TYPE REF TO z2ui5_if_app,
        s_set       TYPE ty_s_next2,
      END OF ty_s_next.

    DATA mo_http_post TYPE REF TO z2ui5_cl_fw_http_post.

    DATA ms_db     TYPE z2ui5_cl_fw_draft=>ty_s_db.
    DATA ms_actual TYPE z2ui5_if_client=>ty_s_actual.
    DATA ms_next   TYPE ty_s_next.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_system_error
      IMPORTING
        ix     TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS factory_app_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_fw_http_post.

  PROTECTED SECTION.


    METHODS app_next_factory
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.


  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_APP IMPLEMENTATION.


  METHOD app_next_factory.

    app->id_draft = COND #( WHEN app->id_draft IS INITIAL THEN z2ui5_cl_util_func=>uuid_get_c32( ) ELSE app->id_draft ).

    result = NEW #( mo_http_post ).

    result->ms_db-app         = app.
    result->ms_db-id          = app->id_draft.
    result->ms_db-id_prev     = ms_db-id.
    result->ms_db-id_prev_app = ms_db-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set     = ms_next-s_set.

    TRY.
        DATA(ls_db_next) = z2ui5_cl_fw_draft=>load_app( app->id_draft ).
        result->ms_db-t_attri = ls_db_next-t_attri.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD constructor.

    mo_http_post = val.

  ENDMETHOD.


  METHOD factory_app_call.

    result = app_next_factory( ms_next-o_app_call ).
    result->ms_db-id_prev_app_stack = ms_db-id.

    CLEAR ms_next.
    IF ms_db-app IS BOUND.
      z2ui5_cl_fw_draft=>create( id = ms_db-id db = ms_db ).
    ENDIF.

    CLEAR result->ms_db-t_attri.

  ENDMETHOD.


  METHOD factory_app_leave.

    result = app_next_factory( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = z2ui5_cl_fw_draft=>read( id = result->ms_db-id check_load_app = abap_false ).
        result->ms_db-id_prev_app_stack = ls_draft-id_prev_app_stack.
      CATCH cx_root.
        result->ms_db-id_prev_app_stack = ms_db-id_prev_app_stack.
    ENDTRY.

    CLEAR ms_next.
    z2ui5_cl_fw_draft=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.


  METHOD factory_by_frontend.

    result = NEW #( mo_http_post ).
    result->ms_db         = z2ui5_cl_fw_draft=>load_app( mo_http_post->ms_request-s_frontend-id ).
    result->ms_db-id      = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_db-id_prev =  mo_http_post->ms_request-s_frontend-id.
    result->ms_actual-viewname = mo_http_post->ms_request-s_frontend-viewname.

    NEW z2ui5_cl_fw_http_mapper( )->model_front_to_back(
         viewname    = mo_http_post->ms_request-s_frontend-viewname
         app         = result->ms_db-app
         t_attri     = result->ms_db-t_attri
         ajson_in    = mo_http_post->ms_request-model
     ).

    result->ms_actual-event = mo_http_post->ms_request-s_control-event.
    result->ms_actual-t_event_arg = mo_http_post->ms_request-s_control-t_event_arg.
    result->ms_actual-check_on_navigated = abap_false.
    result->ms_db-check_attri = abap_false.
  ENDMETHOD.


  METHOD factory_first_start.

    TRY.
        result = NEW #( mo_http_post ).
        result->ms_db-id = z2ui5_cl_util_func=>uuid_get_c32( ).

        CREATE OBJECT result->ms_db-app TYPE (mo_http_post->ms_request-s_control-app_start).
        result->ms_db-app->id_draft = result->ms_db-id.
        result->ms_actual-check_on_navigated = abap_true.

      CATCH cx_root.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `App with name ` && mo_http_post->ms_request-s_control-app_start && ` not found...`.
    ENDTRY.

  ENDMETHOD.


  METHOD factory_system_error.

    result = NEW #( mo_http_post ).
    result->ms_db-id = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-o_app_call = z2ui5_cl_fw_app_error=>factory( ix ).
    result = result->factory_app_call(  ).

  ENDMETHOD.


  METHOD factory_system_startup.

    result = NEW #( mo_http_post ).
    result->ms_db-id = z2ui5_cl_util_func=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_db-app = z2ui5_cl_fw_app_startup=>factory( ).
    result->ms_db-app->id_draft = result->ms_db-id.

  ENDMETHOD.
ENDCLASS.
