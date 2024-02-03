CLASS z2ui5_cl_fw_controller DEFINITION
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

    CLASS-DATA ss_config TYPE z2ui5_if_client=>ty_s_config.
    CLASS-DATA so_body_ajson   TYPE REF TO z2ui5_if_ajson.

    DATA ms_db     TYPE z2ui5_cl_fw_db=>ty_s_db.
    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-METHODS main
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-METHODS request_begin
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_controller.

    METHODS request_end
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS body_read_location.

    CLASS-METHODS app_system_factory
      IMPORTING
        VALUE(ix)     TYPE REF TO cx_root OPTIONAL
        error_text    TYPE string         OPTIONAL
          PREFERRED PARAMETER ix
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_controller.

    METHODS app_next_factory
      IMPORTING
        app             TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_controller.

    METHODS app_client_begin_event.
    METHODS app_client_begin_model.

    CLASS-METHODS app_start_factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_controller.

    CLASS-METHODS app_client_begin_factory
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_controller.

    METHODS app_leave_factory
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_fw_controller.

    METHODS app_call_factory
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_fw_controller.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_controller IMPLEMENTATION.


  METHOD app_call_factory.

    result = app_next_factory( ms_next-o_app_call ).
    result->ms_db-id_prev_app_stack = ms_db-id.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id
                              db = ms_db ).
    ENDIF.

    CLEAR result->ms_db-t_attri.

  ENDMETHOD.


  METHOD app_client_begin_event.
    TRY.

        DATA(ajson) = so_body_ajson->slice( `/ARGUMENTS` ).
        ms_actual-event = ajson->get( `/1/EVENT` ).
        ajson->delete( `/1` ).
        ajson->to_abap(
          IMPORTING
            ev_container     = ms_actual-t_event_arg
        ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD app_client_begin_factory.
    TRY.

        result = NEW #( ).
        result->ms_db         = z2ui5_cl_fw_db=>load_app( id_prev ).
        result->ms_db-id      = z2ui5_cl_util_func=>uuid_get_c32( ).
        result->ms_db-id_prev = id_prev.



        result->ms_actual-viewname = so_body_ajson->get( iv_path = `/VIEWNAME` ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD app_client_begin_model.

    z2ui5_cl_fw_model_ajson=>front_to_back(
       viewname    = ms_actual-viewname
       app         = ms_db-app
       t_attri     = ms_db-t_attri
       ajson_in    = so_body_ajson
   ).

  ENDMETHOD.


  METHOD app_leave_factory.

    result = app_next_factory( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = z2ui5_cl_fw_db=>read( id             = result->ms_db-id
                                               check_load_app = abap_false ).
        result->ms_db-id_prev_app_stack = ls_draft-id_prev_app_stack.
      CATCH cx_root.
        result->ms_db-id_prev_app_stack = ms_db-id_prev_app_stack.
    ENDTRY.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id
                              db = ms_db ).
    ENDIF.

  ENDMETHOD.


  METHOD app_next_factory.

    app->id_draft = COND #( WHEN app->id_draft IS INITIAL THEN z2ui5_cl_util_func=>uuid_get_c32( ) ELSE app->id_draft ).

    r_result = NEW #( ).
    r_result->ms_db-app         = app.
    r_result->ms_db-id          = app->id_draft.
    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_actual-check_launchpad_active = ms_actual-check_launchpad_active.
    r_result->ms_actual-check_on_navigated = abap_true.
    r_result->ms_next-s_set     = ms_next-s_set.

    TRY.
        DATA(ls_db_next) = z2ui5_cl_fw_db=>load_app( app->id_draft ).
        r_result->ms_db-t_attri = ls_db_next-t_attri.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD app_start_factory.

    TRY.
        DATA(lv_classname) = to_upper( so_body_ajson->get( `/APP_START` ) ).
        lv_classname = z2ui5_cl_util_func=>c_trim( lv_classname ).
      CATCH cx_root.
    ENDTRY.

    IF lv_classname IS INITIAL.
      lv_classname = z2ui5_cl_util_func=>url_param_get( val = `app_start`
                                                        url = ss_config-search ).
    ENDIF.


    IF lv_classname IS INITIAL.
      result = app_system_factory( ).
      RETURN.
    ENDIF.

    TRY.
        result = NEW #( ).
        result->ms_db-id = z2ui5_cl_util_func=>uuid_get_c32( ).

        lv_classname = z2ui5_cl_util_func=>c_trim_upper( lv_classname ).
        CREATE OBJECT result->ms_db-app TYPE (lv_classname).
        result->ms_db-app->id_draft = result->ms_db-id.

      CATCH cx_root.
        result = app_system_factory( error_text = `App with name ` && lv_classname && ` not found...` ).
    ENDTRY.

  ENDMETHOD.


  METHOD app_system_factory.

    result = NEW #( ).
    result->ms_db-id = z2ui5_cl_util_func=>uuid_get_c32( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_cx_util_error( val = error_text ).
    ENDIF.

    IF ix IS BOUND.
      result->ms_next-o_app_call = z2ui5_cl_fw_app_error=>factory( ix ).
      result = result->app_call_factory( abap_true ).
      RETURN.
    ENDIF.

    result->ms_db-app = z2ui5_cl_fw_app_startup=>factory( ).
    result->ms_db-app->id_draft = result->ms_db-id.

  ENDMETHOD.


  METHOD body_read_location.
    TRY.

        so_body_ajson->slice( `/OLOCATION` )->to_abap(
            IMPORTING
            ev_container     = ss_config
        ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD main.

    TRY.
        DATA(lo_handler) = request_begin( body ).
      CATCH cx_root INTO DATA(x).
        lo_handler = app_system_factory( x ).
    ENDTRY.

    DO.
      TRY.

          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_handler->ms_db-app )->main( NEW z2ui5_cl_fw_client( lo_handler ) ).
          ROLLBACK WORK.

          IF lo_handler->ms_next-o_app_leave IS NOT INITIAL.
            lo_handler = lo_handler->app_leave_factory( ).
            CONTINUE.
          ENDIF.

          IF lo_handler->ms_next-o_app_call IS NOT INITIAL.
            lo_handler = lo_handler->app_call_factory( ).
            CONTINUE.
          ENDIF.

          result = lo_handler->request_end( ).

        CATCH cx_root INTO x.
          lo_handler = app_system_factory( x ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

  ENDMETHOD.


  METHOD request_begin.
    TRY.

        so_body_ajson = z2ui5_cl_ajson=>parse( body ).
        body_read_location( ).

        DATA(lv_id_prev) = so_body_ajson->get( `/ID` ).
        IF lv_id_prev IS INITIAL.
          result = app_start_factory( ).
          result->ms_actual-check_on_navigated = abap_true.
        ELSE.
          result = app_client_begin_factory( lv_id_prev ).
          result->app_client_begin_model( ).
          result->app_client_begin_event( ).
          result->ms_actual-check_on_navigated = abap_false.
        ENDIF.

        IF ss_config-search CS `scenario=LAUNCHPAD`.
          result->ms_actual-check_launchpad_active = abap_true.
        ENDIF.

        result->ms_db-check_attri = abap_false.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD request_end.
    TRY.

        "todo performance - write all data directly into the target ajson
        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
          ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

        ajson_result->set( iv_path = `/PARAMS` iv_val = ms_next-s_set ).
        ajson_result->set( iv_path = `/ID` iv_val = ms_db-id ).
        ajson_result = ajson_result->filter( NEW z2ui5_cl_fw_model_ajson( ) ).

        DATA(lo_ajson) = z2ui5_cl_fw_model_ajson=>back_to_front(
              app     = ms_db-app
              t_attri = ms_db-t_attri ).

        DESCRIBE TABLE ms_db-t_attri LINES DATA(lt_test).

        ajson_result->set( iv_path = `/OVIEWMODEL` iv_val = lo_ajson ).
        result = ajson_result->stringify( ).

        z2ui5_cl_fw_db=>create( id = ms_db-id db = ms_db ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
