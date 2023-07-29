CLASS z2ui5_cl_fw_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF cs_bind_type.

    TYPES:
      BEGIN OF ty_s_next2,
        t_scroll   TYPE z2ui5_if_client=>ty_t_name_value,
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
          selectionstart TYPE string,
          selectionend   TYPE string,
        END OF s_cursor,
        BEGIN OF s_timer,
          interval_ms     TYPE string,
          event_finished  TYPE string,
          action_finished TYPE string,
        END OF s_timer,
        BEGIN OF s_msg_box,
          type TYPE string,
          text TYPE string,
        END OF s_msg_box,
        BEGIN OF s_msg_toast,
          text TYPE string,
        END OF s_msg_toast,
        _viewmodel TYPE string,
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

    METHODS _create_binding
      IMPORTING
        value         TYPE data
        type          TYPE string DEFAULT cs_bind_type-two_way
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

    CLASS-METHODS model_set_backend
      IMPORTING
        model   TYPE REF TO data
        app     TYPE REF TO object
        t_attri TYPE z2ui5_cl_fw_utility=>ty_t_attri.

    CLASS-METHODS model_set_frontend
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE z2ui5_cl_fw_utility=>ty_t_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS app_set_next
      IMPORTING
        app             TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_handler.

ENDCLASS.



CLASS Z2UI5_CL_FW_HANDLER IMPLEMENTATION.


  METHOD app_set_next.

    app->id = COND #( WHEN app->id IS INITIAL THEN z2ui5_cl_fw_utility=>get_uuid( ) ELSE app->id ).

    r_result = NEW #( ).
    r_result->ms_db-app         = app.
    r_result->ms_db-id          = app->id.
    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_db-t_attri     = z2ui5_cl_fw_utility=>get_t_attri_by_ref( app ).
    r_result->ms_actual-check_launchpad_active = ms_actual-check_launchpad_active.
    r_result->ms_actual-check_on_navigated = abap_true.
    r_result->ms_next-s_set     = ms_next-s_set.

  ENDMETHOD.


  METHOD model_set_backend.

    DATA(lo_app)   = CAST object( app ) ##NEEDED.
    DATA(lr_model) = CAST data( model ) ##NEEDED.

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type = cs_bind_type-two_way.
      TRY.
          DATA(lv_type_kind) = lr_attri->type_kind.

          FIELD-SYMBOLS <backend> TYPE any.
          DATA(lv_name) = `LO_APP->` && lr_attri->name.
          ASSIGN (lv_name) TO <backend>.
          z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          FIELD-SYMBOLS <frontend> TYPE any.
          lv_name = `LR_MODEL->` && replace( val  = lr_attri->name
                                             sub  = `-`
                                             with = `_`
                                             occ  = 0 ).
          ASSIGN (lv_name) TO <frontend>.
          z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          IF lr_attri->check_ref_data IS NOT INITIAL.
            ASSIGN <backend>->* TO <backend>.
            TRY.
                DATA(lo_tab)  = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( <backend> ) ) ##NEEDED.
                lv_type_kind = `h`.
              CATCH cx_root.
            ENDTRY.
          ENDIF.

          CASE lv_type_kind.

            WHEN `h`.
              z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
                EXPORTING
                    ir_tab_from = <frontend>
                IMPORTING
                    t_result    = <backend> ).

            WHEN OTHERS.

              ASSIGN <frontend>->* TO <frontend>.
              CASE lr_attri->type_kind.
                WHEN 'D' OR 'T'.
                  /ui2/cl_json=>deserialize(
                    EXPORTING
                        json = `"` && <frontend> && `"`
                    CHANGING
                        data = <backend> ).
                WHEN OTHERS.
                  <backend> = <frontend>.
              ENDCASE.

          ENDCASE.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD model_set_frontend.

    DATA(lo_app) = CAST object( app ) ##NEEDED.
    DATA(lr_view_model) = z2ui5_cl_fw_utility_json=>factory( ).
    DATA(lo_update) = lr_view_model->add_attribute_object( ss_config-view_model_edit_name ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = cs_bind_type-one_time.
        lr_view_model->add_attribute( n           = lr_attri->name
                                      v           = lr_attri->data_stringify
                                      apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs_bind_type-one_way
                                THEN lr_view_model
                                ELSE lo_update ).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = `LO_APP->` && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN `h`.
          lo_actual->add_attribute( n           = lr_attri->name
                                    v           = z2ui5_cl_fw_utility=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN OTHERS.

          CASE lr_attri->type.

            WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.

              lo_actual->add_attribute( n           = lr_attri->name
                                        v           = SWITCH #( <attribute>
                                                                WHEN abap_true THEN `true` ELSE `false` )
                                        apos_active = abap_false ).

            WHEN OTHERS.

              lo_actual->add_attribute( n           = lr_attri->name
                                        v           = /ui2/cl_json=>serialize( <attribute> )
                                        apos_active = abap_false ).
          ENDCASE.
      ENDCASE.
    ENDLOOP.

    result = lr_view_model->stringify( ).

  ENDMETHOD.


  METHOD request_begin.

    so_body = z2ui5_cl_fw_utility_json=>factory( body ).

    TRY.
        DATA(location)     = so_body->get_attribute( `OLOCATION` ).
        ss_config-body     = body.
        ss_config-search   = location->get_attribute( `SEARCH` )->get_val( ).
        ss_config-origin   = location->get_attribute( `ORIGIN` )->get_val( ).
        ss_config-pathname = location->get_attribute( `PATHNAME` )->get_val( ).
        ss_config-version  = location->get_attribute( `VERSION` )->get_val( ).
      CATCH cx_root.
    ENDTRY.
    ss_config-view_model_edit_name = `oUpdate`.

    TRY.
        DATA(lv_id_prev) = so_body->get_attribute( `ID` )->get_val( ).
        result = set_app_client( lv_id_prev ).
        result->ms_actual-check_on_navigated = abap_false.
      CATCH cx_root.
        result = set_app_start( ).
        result->ms_actual-check_on_navigated = abap_true.
    ENDTRY.

    TRY.

        FIELD-SYMBOLS <any> TYPE any.
        ASSIGN ('SO_BODY->MR_ACTUAL') TO <any>.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
        ASSIGN ('<ANY>->ARGUMENTS') TO <any>.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
        ASSIGN ('<ANY>->*') TO <any>.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg> TYPE STANDARD TABLE.
        ASSIGN <any> TO <arg>.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg_row> TYPE any.
        LOOP AT <arg> ASSIGNING <arg_row>.

          IF sy-tabix = 1.
            FIELD-SYMBOLS <val> TYPE any.
            ASSIGN ('<ARG_ROW>->EVENT->*') TO <val>.
            result->ms_actual-event = <val>.
          ELSE.
            ASSIGN <arg_row>->* TO <val>.
            INSERT <val> INTO TABLE result->ms_actual-t_event_arg.
          ENDIF.

        ENDLOOP.
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_scroll) = so_body->get_attribute( `OSCROLL` ).
        z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
            EXPORTING
                ir_tab_from = lo_scroll->mr_actual
            IMPORTING
                t_result    = result->ms_actual-t_scroll_pos ).
      CATCH cx_root.
    ENDTRY.

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

    DATA(lv_viewmodel) = COND #( WHEN ms_next-s_set-_viewmodel IS NOT INITIAL
                                 THEN ms_next-s_set-_viewmodel
                                 ELSE model_set_frontend( app     = ms_db-app
                                                          t_attri = ms_db-t_attri ) ).

    lo_resp->add_attribute( n           = `OVIEWMODEL`
                            v           = lv_viewmodel
                            apos_active = abap_false ).
    lo_resp->add_attribute( n           = `PARAMS`
                            v           = z2ui5_cl_fw_utility=>trans_any_2_json( ms_next-s_set )
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
    z2ui5_cl_fw_db=>create( id = ms_db-id
                            db = ms_db ).

  ENDMETHOD.


  METHOD set_app_call.

    result = app_set_next( ms_next-o_app_call ).
    result->ms_db-id_prev_app_stack = ms_db-id.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id
                              db = ms_db ).
    ENDIF.

  ENDMETHOD.


  METHOD set_app_client.

    result = NEW #( ).
    result->ms_db         = z2ui5_cl_fw_db=>load_app( id_prev ).
    result->ms_db-id      = z2ui5_cl_fw_utility=>get_uuid( ).
    result->ms_db-id_prev = id_prev.

    TRY.
        model_set_backend( model   = so_body->get_attribute( ss_config-view_model_edit_name )->mr_actual
                           app     = result->ms_db-app
                           t_attri = result->ms_db-t_attri ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_leave.

    result = app_set_next( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = z2ui5_cl_fw_db=>read( id             = result->ms_db-id
                                               check_load_app = abap_false ).
        result->ms_db-id_prev_app_stack = ls_draft-uuid_prev_app_stack.
      CATCH cx_root.
        result->ms_db-id_prev_app_stack = ms_db-id_prev_app_stack.
    ENDTRY.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_cl_fw_db=>create( id = ms_db-id
                              db = ms_db ).
    ENDIF.

  ENDMETHOD.


  METHOD set_app_start.

    TRY.
        DATA(lv_classname) = to_upper( so_body->get_attribute( 'APP_START' )->get_val( ) ).
        lv_classname = shift_left( val = lv_classname
                                   sub = cl_abap_char_utilities=>horizontal_tab ).
        lv_classname = shift_right( val = lv_classname
                                    sub = cl_abap_char_utilities=>horizontal_tab ).
      CATCH cx_root.
    ENDTRY.

    IF lv_classname IS INITIAL.
      lv_classname = z2ui5_cl_fw_utility=>url_param_get( val = `app_start`
                                                         url = ss_config-search ).
    ENDIF.

    IF lv_classname IS INITIAL.
      result = set_app_system( ).
      RETURN.
    ENDIF.

    TRY.
        result = NEW #( ).
        result->ms_db-id = z2ui5_cl_fw_utility=>get_uuid( ).

        lv_classname = z2ui5_cl_fw_utility=>get_trim_upper( lv_classname ).
        CREATE OBJECT result->ms_db-app TYPE (lv_classname).
        result->ms_db-app->id = result->ms_db-id.
        result->ms_db-t_attri = z2ui5_cl_fw_utility=>get_t_attri_by_ref( result->ms_db-app ).

      CATCH cx_root.
        result = set_app_system( error_text = `App with name ` && lv_classname && ` not found...` ).
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_system.

    result = NEW #( ).
    result->ms_db-id = z2ui5_cl_fw_utility=>get_uuid( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_cl_fw_utility( val = error_text ).
    ENDIF.

    IF ix IS BOUND.
      result->ms_next-o_app_call = z2ui5_cl_fw_app=>factory_error( ix ).
      result = result->set_app_call( abap_true ).
      RETURN.
    ENDIF.

    result->ms_db-app = z2ui5_cl_fw_app=>factory_start( ).
    result->ms_db-t_attri = z2ui5_cl_fw_utility=>get_t_attri_by_ref( result->ms_db-app ).
    result->ms_db-app->id = result->ms_db-id.

  ENDMETHOD.


  METHOD _create_binding.

    DATA(lo_app) = CAST object( ms_db-app ) ##NEEDED.

    DATA lr_in TYPE REF TO data.
    GET REFERENCE OF value INTO lr_in.

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
         WHERE bind_type <> cs_bind_type-one_time.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = `LO_APP->` && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 )
                                  v    = `Attribute in App with name ` && lv_name && ` not found` ).
      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_attri->check_ref_data IS NOT INITIAL.
        FIELD-SYMBOLS <field> TYPE any.
        ASSIGN lr_ref->* TO <field>.
        lr_ref = CAST data( <field> ).
      ENDIF.

      IF lr_in = lr_ref.
        IF lr_attri->bind_type IS NOT INITIAL AND lr_attri->bind_type <> type.
          z2ui5_cl_fw_utility=>raise(
            `<p>Binding Error - Two different binding types for same attribute used (` && lr_attri->name && `).` ).
        ENDIF.
        IF strlen( lr_attri->name ) > 30.
          z2ui5_cl_fw_utility=>raise(
            `<p>Binding Error - Name of attribute more than 30 characters: ` && lr_attri->name ).
        ENDIF.
        lr_attri->bind_type = type.
        result = COND #( WHEN type = cs_bind_type-two_way THEN `/` && ss_config-view_model_edit_name && `/` ELSE `/` ) && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    IF type = cs_bind_type-two_way.
      z2ui5_cl_fw_utility=>raise( `Binding Error - Two way binding used but no attribute found` ).
    ENDIF.

    DATA(lv_id) = z2ui5_cl_fw_utility=>get_uuid( ).
    INSERT VALUE #( name           = lv_id
                    data_stringify = z2ui5_cl_fw_utility=>trans_any_2_json( value )
                    bind_type      = cs_bind_type-one_time )
           INTO TABLE ms_db-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.
ENDCLASS.
