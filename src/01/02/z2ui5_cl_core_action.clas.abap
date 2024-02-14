CLASS z2ui5_cl_core_action DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mo_http_post TYPE REF TO z2ui5_cl_core_http_post.
    DATA mo_app       TYPE REF TO z2ui5_cl_core_app.

    DATA ms_actual TYPE z2ui5_if_core_types=>ty_s_actual.
    DATA ms_next   TYPE z2ui5_if_core_types=>ty_s_next.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_system_error
      IMPORTING
        ix            TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_core_http_post.

  PROTECTED SECTION.

    METHODS prepare_app_stack
      IMPORTING
        val           TYPE z2ui5_if_core_types=>ty_s_next-o_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_action IMPLEMENTATION.


  METHOD constructor.

    mo_http_post = val.
    mo_app = NEW #( ).

  ENDMETHOD.


  METHOD factory_by_frontend.

    result = NEW #( mo_http_post ).
    result->mo_app = z2ui5_cl_core_app=>db_load( mo_http_post->ms_request-s_front-id ).

    result->mo_app->ms_draft-id      = z2ui5_cl_util=>uuid_get_c32( ).
    result->mo_app->ms_draft-id_prev = mo_http_post->ms_request-s_front-id.
    result->ms_actual-view           = mo_http_post->ms_request-s_front-view.

    result->mo_app->model_json_parse(
        iv_view  = mo_http_post->ms_request-s_front-view
        io_model = mo_http_post->ms_request-o_model ).

    result->ms_actual-event              = mo_http_post->ms_request-s_front-event.
    result->ms_actual-t_event_arg        = mo_http_post->ms_request-s_front-t_event_arg.
    result->ms_actual-check_on_navigated = abap_false.

  ENDMETHOD.


  METHOD factory_first_start.

    TRY.
        result = NEW #( mo_http_post ).
        result->mo_app->ms_draft-id = z2ui5_cl_util=>uuid_get_c32( ).

        CREATE OBJECT result->mo_app->mo_app TYPE (mo_http_post->ms_request-s_control-app_start).

        DATA(li_app) = CAST z2ui5_if_app( result->mo_app->mo_app ).
        li_app->id_draft = result->mo_app->ms_draft-id.

        result->ms_actual-check_on_navigated = abap_true.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val      = `App with name ` && mo_http_post->ms_request-s_control-app_start && ` not found...`
            previous = x.
    ENDTRY.

  ENDMETHOD.


  METHOD factory_stack_call.

    result = prepare_app_stack( ms_next-o_app_call ).
    result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id.

  ENDMETHOD.


  METHOD factory_stack_leave.

    result = prepare_app_stack( ms_next-o_app_leave ).

  ENDMETHOD.


  METHOD factory_system_error.

    result = NEW #( mo_http_post ).

    result->mo_app->ms_draft-id          = z2ui5_cl_util=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-o_app_call           = z2ui5_cl_core_app_error=>factory( ix ).

    result = result->factory_stack_call( ).

  ENDMETHOD.


  METHOD factory_system_startup.

    result = NEW #( mo_http_post ).

    result->mo_app->ms_draft-id          = z2ui5_cl_util=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_app->mo_app               = z2ui5_cl_core_app_startup=>factory( ).

    DATA(li_app) = CAST z2ui5_if_app( result->mo_app->mo_app ).
    li_app->id_draft = result->mo_app->ms_draft-id.

  ENDMETHOD.

  METHOD prepare_app_stack.

    mo_app->db_save( ).

    val->id_draft = COND string( WHEN val->id_draft IS INITIAL
        THEN z2ui5_cl_util=>uuid_get_c32( )
        ELSE ms_next-o_app_leave->id_draft ).

    result = NEW #( mo_http_post ).
    TRY.
        result->mo_app = z2ui5_cl_core_app=>db_load_by_app( val ).
      CATCH cx_root.
        result->mo_app->mo_app = val.
    ENDTRY.
    result->mo_app->ms_draft-id          = val->id_draft.

    result->mo_app->ms_draft-id_prev     = mo_app->ms_draft-id.
    result->mo_app->ms_draft-id_prev_app = mo_app->ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set                = ms_next-s_set.

  ENDMETHOD.

ENDCLASS.
