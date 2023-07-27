
CLASS z2ui5_lcl_fw_handler DEFINITION.

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
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,
        t_attri           TYPE z2ui5_cl_utility=>ty_t_attri,
        o_app             TYPE REF TO z2ui5_if_app,
      END OF ty_s_db.

    CLASS-DATA ss_config TYPE z2ui5_if_client=>ty_s_config.

    DATA ms_db TYPE ty_s_db.

    TYPES:
      BEGIN OF ty_s_next,
        o_app_call  TYPE REF TO z2ui5_if_app,
        o_app_leave TYPE REF TO z2ui5_if_app,
        s_set       TYPE ty_s_next2,
      END OF ty_s_next.

    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-DATA so_body TYPE REF TO z2ui5_lcl_utility_tree_json.

    CLASS-METHODS request_begin
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS request_end
      RETURNING VALUE(result) TYPE string.

    METHODS _create_binding
      IMPORTING value         TYPE data
                type          TYPE string    DEFAULT cs_bind_type-two_way
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS set_app_start
      RETURNING VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    CLASS-METHODS set_app_client
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_leave
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_call
      IMPORTING
        check_no_db_save TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_lcl_fw_handler.

    CLASS-METHODS set_app_system
      IMPORTING VALUE(ix)     TYPE REF TO cx_root OPTIONAL
                error_text    TYPE string         OPTIONAL
                  PREFERRED PARAMETER ix
      RETURNING VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    CLASS-METHODS model_set_backend
      IMPORTING
        model   TYPE REF TO data
        app     TYPE REF TO object
        t_attri TYPE z2ui5_cl_utility=>ty_t_attri.

    CLASS-METHODS model_set_frontend
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE z2ui5_cl_utility=>ty_t_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS app_set_next
      IMPORTING
        app             TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_fw_handler.

ENDCLASS.

CLASS z2ui5_lcl_fw_db DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        id TYPE string
        db TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.

CLASS z2ui5_lcl_fw_db IMPLEMENTATION.

  METHOD load_app.

    DATA(ls_db) = read( id ).

    z2ui5_cl_utility=>trans_xml_2_object( EXPORTING xml  = ls_db-data
                                           IMPORTING data = result ).

    LOOP AT result-t_attri TRANSPORTING NO FIELDS WHERE data_rtti <> ``.
      DATA(lv_check_rtti) = abap_true.
    ENDLOOP.
    IF lv_check_rtti = abap_false.
      RETURN.
    ENDIF.

    DATA(lo_app) = CAST object( result-o_app ) ##NEEDED.
    LOOP AT result-t_attri REFERENCE INTO DATA(lr_attri) WHERE check_ref_data = abap_true.

      DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
      FIELD-SYMBOLS <ref> TYPE any.
      ASSIGN (lv_assign) TO <ref>.

      z2ui5_cl_utility=>rtti_set(
        EXPORTING
          rtti_data = lr_attri->data_rtti
         IMPORTING
           e_data   = <ref> ).

      CLEAR lr_attri->data_rtti.

    ENDLOOP.

  ENDMETHOD.

  METHOD create.

    TRY.

        DATA(lv_xml) = z2ui5_cl_utility=>trans_object_2_xml( REF #( db ) ).

      CATCH cx_xslt_serialization_error INTO DATA(x).
        TRY.

            DATA(ls_db) = db.
            DATA(lo_app) = CAST object( ls_db-o_app ).

            IF NOT line_exists( ls_db-t_attri[ check_ref_data = abap_true ] ).
              RAISE EXCEPTION x.
            ENDIF.

            lo_app = CAST object( ls_db-o_app ).
            LOOP AT ls_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE check_ref_data = abap_true.

              DATA(lv_assign) = 'LO_APP->' && lr_attri->name.
              FIELD-SYMBOLS <attri> TYPE any.
              FIELD-SYMBOLS <deref_attri> TYPE any.
              ASSIGN (lv_assign) TO <attri>.
              ASSIGN <attri>->* TO <deref_attri>.

              lr_attri->data_rtti = z2ui5_cl_utility=>rtti_get( <deref_attri> ).
              CLEAR <deref_attri>.
              CLEAR <attri>.

            ENDLOOP.

            lv_xml = z2ui5_cl_utility=>trans_object_2_xml( REF #( ls_db ) ).

          CATCH cx_root INTO DATA(x2).

            RAISE EXCEPTION TYPE z2ui5_cl_utility
              EXPORTING
                val = x->get_text( ) && `<p>` && x->previous->get_text( ) && `<p>` && x2->get_text( ).

        ENDTRY.
    ENDTRY.

    DATA(ls_draft) = VALUE z2ui5_t_draft( uuid                = id
                                          uuid_prev           = db-id_prev
                                          uuid_prev_app       = db-id_prev_app
                                          uuid_prev_app_stack = db-id_prev_app_stack
                                          uname               = z2ui5_cl_utility=>get_user_tech( )
                                          timestampl          = z2ui5_cl_utility=>get_timestampl( )
                                          data                = lv_xml ).

    MODIFY z2ui5_t_draft FROM @ls_draft.
    z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD read.

    IF check_load_app = abap_true.

      SELECT SINGLE *
        FROM z2ui5_t_draft
        WHERE uuid = @id
      INTO @result.

    ELSE.
      SELECT SINGLE uuid, uuid_prev, uuid_prev_app, uuid_prev_app_stack
        FROM z2ui5_t_draft
        WHERE uuid = @id
      INTO CORRESPONDING FIELDS OF @result.
    ENDIF.
    z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

  ENDMETHOD.

  METHOD cleanup.

    DATA(lv_timestampl) = z2ui5_cl_utility=>get_timestampl( ).
    DATA(lv_ts_four_hours_ago) = cl_abap_tstmp=>subtractsecs( tstmp = lv_timestampl
                                                              secs  = 60 * 60 * 4 ).

    DELETE FROM z2ui5_t_draft WHERE timestampl < @lv_ts_four_hours_ago.
    COMMIT WORK.

  ENDMETHOD.


ENDCLASS.


CLASS z2ui5_lcl_fw_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_handler TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS constructor
      IMPORTING handler TYPE REF TO z2ui5_lcl_fw_handler.

ENDCLASS.


CLASS z2ui5_lcl_fw_handler IMPLEMENTATION.

  METHOD request_begin.

    so_body = z2ui5_lcl_utility_tree_json=>factory( body ).

    ss_config = VALUE #( LET location = so_body->get_attribute( `OLOCATION` ) IN
        controller_name      = `z2ui5_controller`
        view_model_edit_name = `oUpdate`
        body                 = body
        origin               = location->get_attribute( `ORIGIN` )->get_val( )
        pathname             = location->get_attribute( `PATHNAME` )->get_val( )
        search               = location->get_attribute( `SEARCH` )->get_val( )
        version              = location->get_attribute( `VERSION` )->get_val( )
     ).

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
        z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
        ASSIGN ('<ANY>->ARGUMENTS') TO <any>.
        z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
        ASSIGN ('<ANY>->*') TO <any>.
        z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg> TYPE STANDARD TABLE.
        ASSIGN <any> TO <arg>.
        z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

        FIELD-SYMBOLS <arg_row> TYPE any.
        LOOP AT <arg> ASSIGNING <arg_row>.

          IF sy-tabix = 1.
            FIELD-SYMBOLS <val> TYPE any.
            ASSIGN  ('<ARG_ROW>->EVENT->*') TO <val>.
            result->ms_actual-event = <val>.
          ELSE.
            ASSIGN  <arg_row>->* TO <val>.
            INSERT <val> INTO TABLE result->ms_actual-t_event_arg.
          ENDIF.

        ENDLOOP.
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_scroll) = so_body->get_attribute( `OSCROLL` ).
        z2ui5_cl_utility=>trans_ref_tab_2_tab(
            EXPORTING ir_tab_from = lo_scroll->mr_actual
            IMPORTING t_result    = result->ms_actual-t_scroll_pos ).

      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_cursor) = so_body->get_attribute( `OCURSOR` ).
        result->ms_actual-s_cursor-id = lo_cursor->get_attribute( `ID` )->get_val( ).
*        result->ms_actual-s_cursor-cursorpos = lo_cursor->get_attribute( `CURSORPOS` )->get_val( ).
*        result->ms_actual-s_cursor-selectionend = lo_cursor->get_attribute( `SELECTIONEND` )->get_val( ).
*        result->ms_actual-s_cursor-selectionstart = lo_cursor->get_attribute( `SELECTIONSTART` )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    IF ss_config-search CS `scenario=LAUNCHPAD`.
      result->ms_actual-check_launchpad_active = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD request_end.

    DATA(lo_resp) = z2ui5_lcl_utility_tree_json=>factory( ).

    DATA(lv_viewmodel) = COND #( WHEN ms_next-s_set-_viewmodel IS NOT INITIAL
                                 THEN ms_next-s_set-_viewmodel
                                 ELSE model_set_frontend( app = ms_db-o_app t_attri = ms_db-t_attri ) ).

    lo_resp->add_attribute( n = `OVIEWMODEL` v = lv_viewmodel apos_active = abap_false ).
    lo_resp->add_attribute( n = `PARAMS`     v = z2ui5_cl_utility=>trans_any_2_json( ms_next-s_set ) apos_active = abap_false ).
    lo_resp->add_attribute( n = `ID`         v = ms_db-id ).

    IF ms_next-s_set-search IS INITIAL.
      lo_resp->add_attribute( n = `SEARCH` v = ms_actual-s_config-search ).
    ELSE.
      lo_resp->add_attribute( n = `SEARCH` v = ms_next-s_set-search ).
    ENDIF.

    result = lo_resp->mo_root->stringify( ).
    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.

  METHOD model_set_backend.

    DATA(lo_app)   = CAST object( app ) ##NEEDED.
    DATA(lr_model) = CAST data( model ) ##NEEDED.

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
         WHERE bind_type = cs_bind_type-two_way.

      DATA(lv_type_kind) = lr_attri->type_kind.
      TRY.
          FIELD-SYMBOLS <backend> TYPE any.
          DATA(lv_name) = `LO_APP->` && lr_attri->name.
          ASSIGN (lv_name) TO <backend>.
          z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          FIELD-SYMBOLS <frontend> TYPE any.
          lv_name = `LR_MODEL->` && replace( val = lr_attri->name sub = `-` with = `_` occ = 0 ).
          ASSIGN (lv_name) TO <frontend>.
          z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

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
              z2ui5_cl_utility=>trans_ref_tab_2_tab( EXPORTING ir_tab_from = <frontend>
                                                      IMPORTING t_result    = <backend> ).

            WHEN OTHERS.

              ASSIGN <frontend>->* TO <frontend>.
              CASE lr_attri->type_kind.
                WHEN 'D' OR 'T'.
                  /ui2/cl_json=>deserialize( EXPORTING json = `"` && <frontend> && `"`
                                             CHANGING  data = <backend> ).
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
    DATA(lr_view_model) = z2ui5_lcl_utility_tree_json=>factory( ).
    DATA(lo_update) = lr_view_model->add_attribute_object( ss_config-view_model_edit_name ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = cs_bind_type-one_time.
        lr_view_model->add_attribute( n = lr_attri->name v = lr_attri->data_stringify apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs_bind_type-one_way
                                THEN lr_view_model
                                ELSE lo_update ).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = `LO_APP->` && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN `h`.
          lo_actual->add_attribute( n           = lr_attri->name
                                    v           = z2ui5_cl_utility=>trans_any_2_json( <attribute> )
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

  METHOD set_app_client.

    result = NEW #( ).
    result->ms_db         = z2ui5_lcl_fw_db=>load_app( id_prev ).
    result->ms_db-id      = z2ui5_cl_utility=>get_uuid( ).
    result->ms_db-id_prev = id_prev.

    TRY.
        model_set_backend( model = so_body->get_attribute( ss_config-view_model_edit_name )->mr_actual
                           app   = result->ms_db-o_app
                           t_attri  = result->ms_db-t_attri ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD set_app_start.

    TRY.
        DATA(lv_classname) = to_upper( so_body->get_attribute( 'APP_START' )->get_val( ) ).
        SHIFT lv_classname LEFT DELETING LEADING cl_abap_char_utilities=>horizontal_tab.
        SHIFT lv_classname RIGHT DELETING TRAILING cl_abap_char_utilities=>horizontal_tab.
      CATCH cx_root.
    ENDTRY.

    IF lv_classname IS INITIAL.
      lv_classname = z2ui5_cl_xml_view=>factory( NEW z2ui5_lcl_fw_client( NEW #( ) ) )->hlp_get_url_param( `app_start` ).
    ENDIF.

    IF lv_classname IS INITIAL.
      result = set_app_system( ).
      RETURN.
    ENDIF.

    TRY.
        result = NEW #( ).
        result->ms_db-id = z2ui5_cl_utility=>get_uuid( ).

        lv_classname = z2ui5_cl_utility=>get_trim_upper( lv_classname ).
        CREATE OBJECT result->ms_db-o_app TYPE (lv_classname).
        result->ms_db-o_app->id = result->ms_db-id.
        result->ms_db-t_attri   = z2ui5_cl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).

      CATCH cx_root.
        result = set_app_system( error_text = `App with name ` && lv_classname && ` not found...` ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_app_leave.

    result = app_set_next( ms_next-o_app_leave ).

    TRY.
        DATA(ls_draft) = z2ui5_lcl_fw_db=>read( id = result->ms_db-id check_load_app = abap_false ).
        result->ms_db-id_prev_app_stack = ls_draft-uuid_prev_app_stack.
      CATCH cx_root.
        result->ms_db-id_prev_app_stack = ms_db-id_prev_app_stack.
    ENDTRY.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

  ENDMETHOD.

  METHOD set_app_call.

    result = app_set_next( ms_next-o_app_call ).

    result->ms_db-id_prev_app_stack = ms_db-id.

    CLEAR ms_next.
    IF check_no_db_save = abap_false.
      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

  ENDMETHOD.

  METHOD _create_binding.

    DATA(lo_app) = CAST object( ms_db-o_app ) ##NEEDED.

*    IF type = cs_bind_type-one_time.
*      DATA(lv_id) = z2ui5_cl_utility=>get_uuid( ).
*      INSERT VALUE #( name           = lv_id
*                      data_stringify = z2ui5_cl_utility=>trans_any_2_json( value )
*                      bind_type      = type )
*             INTO TABLE ms_db-t_attri.
*      result = |/{ lv_id }|.
*      RETURN.
*    ENDIF.

    DATA lr_in TYPE REF TO data.
    GET REFERENCE OF value INTO lr_in.

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
         WHERE bind_type <> cs_bind_type-one_time.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = `LO_APP->` && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_cl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).
      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_attri->check_ref_data IS NOT INITIAL.

        FIELD-SYMBOLS <field> TYPE any.
        ASSIGN lr_ref->* TO <field>.
        lr_ref = CAST data( <field> ).

      ENDIF.

      IF lr_in = lr_ref.
        IF lr_attri->bind_type IS NOT INITIAL AND lr_attri->bind_type <> type.
          z2ui5_cl_utility=>raise( `<p>Binding Error - Two different binding types for same attribute used (` && lr_attri->name
          && `).` ).
        ENDIF.
        IF strlen( lr_attri->name ) > 30.
          z2ui5_cl_utility=>raise( `<p>Binding Error - Name of attribute more than 30 characters: ` && lr_attri->name ).
        ENDIF.
        lr_attri->bind_type = type.
        result = COND #( WHEN type = cs_bind_type-two_way THEN `/` && ss_config-view_model_edit_name && `/` ELSE `/` ) && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    IF type = cs_bind_type-two_way.
      z2ui5_cl_utility=>raise( `Binding Error - Two way binding used but no attribute found` ).
    ENDIF.

    "one time when not global class attribute
    DATA(lv_id) = z2ui5_cl_utility=>get_uuid( ).
    INSERT VALUE #( name           = lv_id
                    data_stringify = z2ui5_cl_utility=>trans_any_2_json( value )
                    bind_type      = cs_bind_type-one_time )
           INTO TABLE ms_db-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.

  METHOD set_app_system.

    result = NEW #( ).
    result->ms_db-id = z2ui5_cl_utility=>get_uuid( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_cl_utility( val = error_text ).
    ENDIF.

    IF ix IS BOUND.
      result->ms_next-o_app_call = z2ui5_lcl_fw_app=>factory_error( error = ix ).

      result = result->set_app_call( check_no_db_save = abap_true ).
      RETURN.

    ELSE.
      result->ms_db-o_app = NEW z2ui5_lcl_fw_app( ).
    ENDIF.

    result->ms_db-t_attri = z2ui5_cl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_db-o_app->id = result->ms_db-id.
  ENDMETHOD.


  METHOD app_set_next.

    app->id = COND #( WHEN app->id IS INITIAL
        THEN z2ui5_cl_utility=>get_uuid( )
        ELSE app->id  ).

    r_result = NEW #( ).

    r_result->ms_db-o_app       = app.
    r_result->ms_db-id          = app->id.

    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_db-t_attri     = z2ui5_cl_utility=>get_t_attri_by_ref( app ).

    r_result->ms_actual-check_launchpad_active = ms_actual-check_launchpad_active.
    r_result->ms_actual-check_on_navigated = abap_true.

    r_result->ms_next-s_set = ms_next-s_set.

  ENDMETHOD.

ENDCLASS.


CLASS z2ui5_lcl_fw_client IMPLEMENTATION.

  METHOD constructor.
    mo_handler = handler.
  ENDMETHOD.

  METHOD z2ui5_if_client~message_toast_display.

    mo_handler->ms_next-s_set-s_msg_toast = VALUE #( text = text ).

  ENDMETHOD.

  METHOD z2ui5_if_client~message_box_display.

    mo_handler->ms_next-s_set-s_msg_box = VALUE #(
          text = text
          type = type ).

  ENDMETHOD.

  METHOD z2ui5_if_client~get.

    result = VALUE #( BASE CORRESPONDING #( mo_handler->ms_db )
                      event                  = mo_handler->ms_actual-event
                      check_launchpad_active = mo_handler->ms_actual-check_launchpad_active
                      t_event_arg            = mo_handler->ms_actual-t_event_arg
                      t_scroll_pos           = mo_handler->ms_actual-t_scroll_pos
                      s_draft                = CORRESPONDING #( mo_handler->ms_db )
                      check_on_navigated     = mo_handler->ms_actual-check_on_navigated
                      s_config               = z2ui5_lcl_fw_handler=>ss_config ).
    result-s_draft-app = mo_handler->ms_db-o_app.
  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.
    mo_handler->ms_next-o_app_call = app.
  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.
    mo_handler->ms_next-o_app_leave = app.
  ENDMETHOD.

  METHOD z2ui5_if_client~get_app.
    result = CAST #( z2ui5_lcl_fw_db=>load_app( id )-o_app ).
  ENDMETHOD.


  METHOD z2ui5_if_client~popup_display.

    mo_handler->ms_next-s_set-s_popup-check_destroy = abap_false.
    mo_handler->ms_next-s_set-s_popup-xml = val.


  ENDMETHOD.

  METHOD z2ui5_if_client~view_display.

    mo_handler->ms_next-s_set-s_view-xml = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_destroy.

    mo_handler->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_model_update.

    mo_handler->ms_next-s_set-s_view_nest-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~nest_view_display.

    mo_handler->ms_next-s_set-s_view_nest-xml = val.
    mo_handler->ms_next-s_set-s_view_nest-id = id.
    mo_handler->ms_next-s_set-s_view_nest-method_destroy = method_destroy.
    mo_handler->ms_next-s_set-s_view_nest-method_insert = method_insert.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    result = mo_handler->_create_binding( value = val type = z2ui5_lcl_fw_handler=>cs_bind_type-one_way ).

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_edit.

    result = mo_handler->_create_binding( value  = val type = z2ui5_lcl_fw_handler=>cs_bind_type-two_way ).

    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_client.

    result = `onEventFrontend( { 'EVENT' : '` && action && `'`.

    IF t_arg IS NOT INITIAL.
      result = result && `, 'T_ARG' : [`.

      LOOP AT t_arg REFERENCE INTO DATA(lr_arg).
        IF sy-tabix <> 1.
          result = result && `,`.
        ENDIF.
        result = result &&  `'`  && lr_arg->* &&  `'`.
      ENDLOOP.

      result = result && `]`.
    ENDIF.

    result = result && `})`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' , 'CHECK_VIEW_DESTROY' : ` && z2ui5_cl_utility=>get_json_boolean( check_view_destroy ) && ` }`.

    LOOP AT t_arg REFERENCE INTO DATA(lr_arg).
      result = result && `, ` && lr_arg->*.
    ENDLOOP.

    result = result &&  ` )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~cursor_set.

    mo_handler->ms_next-s_set-s_cursor = VALUE #(
     id = id
     cursorpos = cursorpos
     selectionend = selectionend
     selectionstart = selectionstart
     ).

  ENDMETHOD.

  METHOD z2ui5_if_client~scroll_position_set.

    mo_handler->ms_next-s_set-t_scroll = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_destroy.

    mo_handler->ms_next-s_set-s_popover-check_destroy = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_display.

    mo_handler->ms_next-s_set-s_popover-check_destroy = abap_false.
    mo_handler->ms_next-s_set-s_popover-xml = xml.
    mo_handler->ms_next-s_set-s_popover-open_by_id = by_id.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_destroy.

    mo_handler->ms_next-s_set-s_popup-check_destroy = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_destroy.

    mo_handler->ms_next-s_set-s_view-check_destroy = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~timer_set.

    mo_handler->ms_next-s_set-s_timer-interval_ms     = interval_ms.
    mo_handler->ms_next-s_set-s_timer-event_finished  = event_finished.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_model_update.

    mo_handler->ms_next-s_set-s_view-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popover_model_update.

    mo_handler->ms_next-s_set-s_popover-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_model_update.

    mo_handler->ms_next-s_set-s_popup-check_update_model = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~url_param_set.

    mo_handler->ms_next-s_set-search = val.
    mo_handler->ms_actual-s_config-search = val.

  ENDMETHOD.

ENDCLASS.
