CLASS z2ui5_cl_fw_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_next2,
        t_scroll   TYPE z2ui5_if_client=>ty_t_name_value_int,
        title      TYPE string,
        search     TYPE string,
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
        BEGIN OF s_cursor,
          id             TYPE string,
          cursorpos      TYPE string,
          selectionstart TYPE i,
          selectionend   TYPE i,
        END OF s_cursor,
        BEGIN OF s_timer,
          interval_ms    TYPE i,
          event_finished TYPE string,
        END OF s_timer,
        BEGIN OF s_msg_box,
          type TYPE string,
          text TYPE string,
        END OF s_msg_box,
        BEGIN OF s_msg_toast,
          text TYPE string,
        END OF s_msg_toast,
        BEGIN OF s_message_manager,
          t_message   TYPE z2ui5_if_client=>ty_t_message_manager,
          check_clear TYPE abap_bool,
        END OF s_message_manager,
*        _viewmodel TYPE string,
      END OF ty_s_next2.

    TYPES:
      BEGIN OF ty_s_next,
        o_app_call  TYPE REF TO z2ui5_if_app,
        o_app_leave TYPE REF TO z2ui5_if_app,
        s_set       TYPE ty_s_next2,
      END OF ty_s_next.

    CLASS-DATA ss_config TYPE z2ui5_if_client=>ty_s_config.
    CLASS-DATA so_body   TYPE REF TO z2ui5_cl_fw_utility_json.

    DATA ms_db     TYPE z2ui5_cl_fw_db=>ty_s_db.
    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-METHODS request_begin
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_handler.

    METHODS request_end
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS set_app_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_handler.

    CLASS-METHODS set_app_client
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_handler.

    METHODS set_app_leave
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_fw_handler.

    METHODS set_app_call
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_fw_handler.

    CLASS-METHODS set_app_system
      IMPORTING
        VALUE(ix)     TYPE REF TO cx_root OPTIONAL
        error_text    TYPE string         OPTIONAL
          PREFERRED PARAMETER ix
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_handler.

    METHODS app_set_next
      IMPORTING
        app             TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_handler.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_handler IMPLEMENTATION.


  METHOD app_set_next.

    app->id = COND #( WHEN app->id IS INITIAL THEN z2ui5_cl_fw_utility=>func_get_uuid_32( ) ELSE app->id ).

    r_result = NEW #( ).
    r_result->ms_db-app         = app.
    r_result->ms_db-id          = app->id.
    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_actual-check_launchpad_active = ms_actual-check_launchpad_active.
    r_result->ms_actual-check_on_navigated = abap_true.
    r_result->ms_next-s_set     = ms_next-s_set.

    TRY.
        DATA(ls_db_next) = z2ui5_cl_fw_db=>load_app( id = app->id ).
        r_result->ms_db-t_attri = ls_db_next-t_attri.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD request_begin.

    so_body = z2ui5_cl_fw_utility_json=>factory( body ).

    TRY.
        DATA(location)     = so_body->get_attribute( `OLOCATION` ).
        ss_config-body     = body.

        TRY.
            ss_config-search   = location->get_attribute( `SEARCH` )->get_val( ).
          CATCH cx_root.
        ENDTRY.

        TRY.
            ss_config-origin   = location->get_attribute( `ORIGIN` )->get_val( ).
          CATCH cx_root.
        ENDTRY.

        TRY.
            ss_config-pathname = location->get_attribute( `PATHNAME` )->get_val( ).
          CATCH cx_root.
        ENDTRY.

        TRY.
            ss_config-version  = location->get_attribute( `VERSION` )->get_val( ).
          CATCH cx_root.
        ENDTRY.

        TRY.
            ss_config-check_launchpad_active  = location->get_attribute( `CHECK_LAUNCHPAD_ACTIVE` )->get_val( ).
          CATCH cx_root.
        ENDTRY.

        TRY.
            FIELD-SYMBOLS <struc> TYPE any.
            DATA(ls_params)  = location->get_attribute( `STARTUP_PARAMETERS` )->get_val_ref( ).
            ASSIGN ls_params->* TO <struc>.

            DATA(lt_comp) = z2ui5_cl_fw_utility=>rtti_get_t_comp_by_struc( <struc> ).

            LOOP AT lt_comp INTO DATA(ls_comp).

              FIELD-SYMBOLS <val_ref> TYPE REF TO data.
              FIELD-SYMBOLS <tab> TYPE table.
              FIELD-SYMBOLS <val2> TYPE data.
              ASSIGN COMPONENT ls_comp-name OF STRUCTURE <struc> TO <val_ref>.
              ASSIGN <val_ref>->* TO <tab>.
              ASSIGN <tab>[ 1 ] TO <val_ref>.
              ASSIGN <val_ref>->* TO <val2>.

              INSERT VALUE #( n = ls_comp-name v = <val2> ) INTO TABLE ss_config-t_startup_params.

            ENDLOOP.
          CATCH cx_root.
        ENDTRY.

      CATCH cx_root.
    ENDTRY.
    ss_config-view_model_edit_name = z2ui5_cl_fw_binding=>cv_model_edit_name.


    TRY.
        DATA(lv_id_prev) = so_body->get_attribute( `ID` )->get_val( ).
      CATCH cx_root.
    ENDTRY.
    IF lv_id_prev IS INITIAL.
      result = set_app_start( ).
      result->ms_actual-check_on_navigated = abap_true.
    ELSE.
      result = set_app_client( lv_id_prev ).
      result->ms_actual-check_on_navigated = abap_false.
    ENDIF.

    result->ms_db-check_attri = abap_false.

    TRY.

        FIELD-SYMBOLS <any> TYPE any.
        ASSIGN (`SO_BODY->MR_ACTUAL`) TO <any>.
        z2ui5_cl_fw_utility=>x_check_raise( xsdbool( sy-subrc <> 0 ) ).
        ASSIGN (`<ANY>->ARGUMENTS`) TO <any>.
        z2ui5_cl_fw_utility=>x_check_raise( xsdbool( sy-subrc <> 0 ) ).
        ASSIGN (`<ANY>->*`) TO <any>.
        z2ui5_cl_fw_utility=>x_check_raise( xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg> TYPE STANDARD TABLE.
        ASSIGN <any> TO <arg>.
        z2ui5_cl_fw_utility=>x_check_raise( xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg_row> TYPE any.
        LOOP AT <arg> ASSIGNING <arg_row>.

          IF sy-tabix = 1.
            FIELD-SYMBOLS <val> TYPE any.
            ASSIGN (`<ARG_ROW>->EVENT->*`) TO <val>.
            result->ms_actual-event = <val>.
          ELSE.
            ASSIGN <arg_row>->* TO <val>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            INSERT CONV string( <val> ) INTO TABLE result->ms_actual-t_event_arg.
          ENDIF.

        ENDLOOP.
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_message) = so_body->get_attribute( `OMESSAGEMANAGER` ).
        z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
            EXPORTING
                ir_tab_from = lo_message->mr_actual
            IMPORTING
                t_result    = result->ms_actual-t_message_manager ).
      CATCH cx_root.
    ENDTRY.

*    TRY.
*        DATA(lo_scroll) = so_body->get_attribute( `OSCROLL` ).
*        z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
*            EXPORTING
*                ir_tab_from = lo_scroll->mr_actual
*            IMPORTING
*                t_result    = result->ms_actual-t_scroll_pos ).
*      CATCH cx_root.
*    ENDTRY.

    TRY.
        DATA(lo_cursor) = so_body->get_attribute( `OCURSOR` ).
        result->ms_actual-s_cursor-id = lo_cursor->get_attribute( `ID` )->get_val( ).

      CATCH cx_root.
    ENDTRY.

    IF ss_config-search CS `scenario=LAUNCHPAD`.
      result->ms_actual-check_launchpad_active = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD request_end.

    DATA(lo_resp) = z2ui5_cl_fw_utility_json=>factory( ).

    DATA(lo_binder) = z2ui5_cl_fw_model=>factory(
        viewname = ms_actual-viewname
        app      = ms_db-app
        attri    = ms_db-t_attri ).

    DATA(lv_viewmodel) = lo_binder->main_set_frontend( ).

    lo_resp->add_attribute( n           = `OVIEWMODEL`
                            v           = lv_viewmodel
                            apos_active = abap_false ).

    lo_resp->add_attribute( n           = `PARAMS`
                            v           = z2ui5_cl_fw_utility=>trans_json_any_2( ms_next-s_set )
                            apos_active = abap_false ).

    lo_resp->add_attribute( n = `ID`
                            v = ms_db-id ).

    IF ms_next-s_set-search IS INITIAL.
      lo_resp->add_attribute( n = `SEARCH`
                              v = ms_actual-s_config-search ).
    ELSE.
      lo_resp->add_attribute( n = `SEARCH`
                              v = ms_next-s_set-search ).
    ENDIF.

    result = lo_resp->mo_root->stringify( ).
    z2ui5_cl_fw_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.


  METHOD set_app_call.

    result = app_set_next( ms_next-o_app_call ).
    result->ms_db-id_prev_app_stack = ms_db-id.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

    CLEAR result->ms_db-t_attri.

  ENDMETHOD.


  METHOD set_app_client.

    result = NEW #( ).
    result->ms_db         = z2ui5_cl_fw_db=>load_app( id_prev ).
    result->ms_db-id      = z2ui5_cl_fw_utility=>func_get_uuid_32( ).
    result->ms_db-id_prev = id_prev.

    TRY.
        result->ms_actual-viewname = so_body->get_attribute( `VIEWNAME` )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_model) = z2ui5_cl_fw_model=>factory(
        viewname = result->ms_actual-viewname
        app      = result->ms_db-app
        attri    = result->ms_db-t_attri ).

        lo_model->main_set_backend(
            so_body->get_attribute( ss_config-view_model_edit_name )->mr_actual  ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_leave.

    result = app_set_next( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = z2ui5_cl_fw_db=>read( id = result->ms_db-id check_load_app = abap_false ).
        result->ms_db-id_prev_app_stack = ls_draft-uuid_prev_app_stack.
      CATCH cx_root.
        result->ms_db-id_prev_app_stack = ms_db-id_prev_app_stack.
    ENDTRY.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

*    CLEAR result->ms_db-t_attri.

  ENDMETHOD.


  METHOD set_app_start.

    TRY.
        DATA(lv_classname) = to_upper( so_body->get_attribute( `APP_START` )->get_val( ) ).
        lv_classname = shift_left( val = lv_classname
                                   sub = cl_abap_char_utilities=>horizontal_tab ).
        lv_classname = shift_right( val = lv_classname
                                    sub = cl_abap_char_utilities=>horizontal_tab ).
      CATCH cx_root.
    ENDTRY.

    IF lv_classname IS INITIAL.
      lv_classname = z2ui5_cl_fw_utility=>url_param_get( val = `app_start` url = ss_config-search ).
    ENDIF.

    IF lv_classname IS INITIAL.
      result = set_app_system( ).
      RETURN.
    ENDIF.

    TRY.
        result = NEW #( ).
        result->ms_db-id = z2ui5_cl_fw_utility=>func_get_uuid_32( ).

        lv_classname = z2ui5_cl_fw_utility=>c_trim_upper( lv_classname ).
        CREATE OBJECT result->ms_db-app TYPE (lv_classname).
        result->ms_db-app->id = result->ms_db-id.

      CATCH cx_root.
        result = set_app_system( error_text = `App with name ` && lv_classname && ` not found...` ).
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_system.

    result = NEW #( ).
    result->ms_db-id = z2ui5_cl_fw_utility=>func_get_uuid_32( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_cx_fw_error( val = error_text ).
    ENDIF.

    IF ix IS BOUND.
      result->ms_next-o_app_call = z2ui5_cl_fw_app=>factory_error( ix ).
      result = result->set_app_call( abap_true ).
      RETURN.
    ENDIF.

    result->ms_db-app = z2ui5_cl_fw_app=>factory_start( ).
    result->ms_db-app->id = result->ms_db-id.

  ENDMETHOD.
ENDCLASS.
