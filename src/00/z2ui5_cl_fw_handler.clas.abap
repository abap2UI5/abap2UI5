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
      BEGIN OF ty_s_attri,
        name            TYPE string,
        type_kind       TYPE string,
        type            TYPE string,
        bind_type       TYPE string,
        data_stringify  TYPE string,
        data_rtti       TYPE string,
        check_temp      TYPE abap_bool,
        check_ready     TYPE abap_bool,
        check_dissolved TYPE abap_bool,
        name_front      TYPE string,
      END OF ty_s_attri.
    TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

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

    METHODS bind
      IMPORTING
        value         TYPE data
        type          TYPE string DEFAULT cs_bind_type-two_way
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind_create
      IMPORTING
        app           TYPE REF TO object
        in            TYPE REF TO data
        bind          TYPE REF TO ty_s_attri
        type          TYPE string
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

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
      CHANGING
        t_attri TYPE ty_t_attri ##NEEDED.

    CLASS-METHODS model_set_frontend
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE ty_t_attri
      RETURNING
        VALUE(result) TYPE string
          ##NEEDED.

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

    app->id = COND #( WHEN app->id IS INITIAL THEN z2ui5_cl_fw_utility=>get_uuid( ) ELSE app->id ).

    r_result = NEW #( ).
    r_result->ms_db-app         = app.
    r_result->ms_db-id          = app->id.
    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_actual-check_launchpad_active = ms_actual-check_launchpad_active.
    r_result->ms_actual-check_on_navigated = abap_true.
    r_result->ms_next-s_set     = ms_next-s_set.

  ENDMETHOD.


  METHOD bind.

    "read input
    DATA(lo_app) = CAST object( ms_db-app ) ##NEEDED.
    DATA lr_in TYPE REF TO data.
    GET REFERENCE OF value INTO lr_in.


    "build t_attri
    IF ms_db-s_bind-t_attri IS INITIAL.

      DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( ms_db-app ) )->attributes.
      LOOP AT lt_attri REFERENCE INTO DATA(lr_attri)
        WHERE visibility = cl_abap_classdescr=>public AND
              is_interface = abap_false.

        DATA(ls_attri) = CORRESPONDING ty_s_attri( lr_attri->* ).
        CASE ls_attri-type_kind.
          WHEN cl_abap_classdescr=>typekind_iref OR cl_abap_classdescr=>typekind_intf.
            CONTINUE.

          WHEN cl_abap_classdescr=>typekind_oref
            OR cl_abap_classdescr=>typekind_dref.

          WHEN cl_abap_classdescr=>typekind_struct2
            OR cl_abap_classdescr=>typekind_struct1.

            ls_attri-check_dissolved = abap_true.
            DATA(lt_attri_struc) = z2ui5_cl_fw_utility=>_get_t_attri_by_struc(
                                         io_app   = ms_db-app
                                         iv_attri = ls_attri-name ).

            LOOP AT lt_attri_struc REFERENCE INTO DATA(lr_struc).
              DATA(ls_attri_struc) = VALUE ty_s_attri( ).
              ls_attri_struc = CORRESPONDING #( lr_struc->* ).
              ls_attri_struc-check_ready = abap_true.
              INSERT ls_attri_struc INTO TABLE ms_db-s_bind-t_attri.
            ENDLOOP.

          WHEN OTHERS.
            ls_attri-check_ready = abap_true.
        ENDCASE.

        INSERT ls_attri INTO TABLE ms_db-s_bind-t_attri.
      ENDLOOP.
    ENDIF.


    " check data and dissolved
    LOOP AT ms_db-s_bind-t_attri REFERENCE INTO DATA(lr_bind)
        WHERE ( bind_type = `` OR bind_type = type ) AND check_ready = abap_true.

      result = bind_create( app = ms_db-app bind = lr_bind type = type in = lr_in ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.

    ENDLOOP.


    " check data refs - dissolve
    DATA(lt_dref_diss_new) = VALUE ty_t_attri( ).

    LOOP AT ms_db-s_bind-t_attri REFERENCE INTO lr_bind WHERE
          type_kind = cl_abap_classdescr=>typekind_dref AND
          check_dissolved = abap_false.


      DATA(lv_name) = `LO_APP->` && lr_bind->name && `->*`.
      FIELD-SYMBOLS <data> TYPE any.
      UNASSIGN <data>.
      ASSIGN (lv_name) TO <data>.
      IF <data> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <data> ).

      CASE lo_descr->type_kind.

        WHEN cl_abap_classdescr=>typekind_struct2
            OR cl_abap_classdescr=>typekind_struct1.

          ls_attri-check_dissolved = abap_true.
          lt_attri_struc = z2ui5_cl_fw_utility=>_get_t_attri_by_struc(
                                       io_app   = ms_db-app
                                       iv_attri = lr_bind->name && `->*` ).

          LOOP AT lt_attri_struc REFERENCE INTO lr_struc.
            DATA(ls_new_struc) = VALUE ty_s_attri( ).
            ls_new_struc = CORRESPONDING #( lr_struc->* ).
            ls_new_struc-name = replace( val = ls_new_struc-name sub = lr_bind->name && `->*-` with = lr_bind->name && `->` ).
            ls_new_struc-check_ready = abap_true.
            ls_new_struc-check_temp = abap_true.
            INSERT ls_new_struc INTO TABLE lt_dref_diss_new.
          ENDLOOP.

        WHEN OTHERS.
          DATA(ls_new_bind) = VALUE ty_s_attri(
             name = lr_bind->name && `->*`
             type_kind = lo_descr->type_kind
             type = lo_descr->get_relative_name(  )
             check_temp = abap_true
             check_ready = abap_true
           ).

          INSERT ls_new_bind INTO TABLE lt_dref_diss_new.
      ENDCASE.

      lr_bind->check_dissolved = abap_true.
    ENDLOOP.


    " check data refs
    LOOP AT lt_dref_diss_new REFERENCE INTO lr_bind
           WHERE bind_type = `` OR bind_type = type.
      result = bind_create( app = ms_db-app bind = lr_bind type = type in = lr_in ).
      IF result IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF result IS NOT INITIAL.
      INSERT LINES OF lt_dref_diss_new INTO TABLE ms_db-s_bind-t_attri.
      RETURN.
    ENDIF.


    " check obj ref - dissolve
    DATA(lt_oref_diss_new) = VALUE ty_t_attri( ).

    LOOP AT ms_db-s_bind-t_attri REFERENCE INTO lr_bind
      WHERE type_kind = cl_abap_classdescr=>typekind_oref AND
        check_dissolved = abap_false.

      FIELD-SYMBOLS <obj> TYPE any.
      UNASSIGN <obj>.
      lv_name = `LO_APP->` && to_upper( lr_bind->name ).
      ASSIGN (lv_name) TO <obj>.
      IF <obj> IS NOT BOUND.
        CONTINUE.
      ENDIF.

      lt_attri = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( <obj> ) )->attributes.
      LOOP AT lt_attri REFERENCE INTO lr_attri
        WHERE visibility = cl_abap_classdescr=>public AND
              is_interface = abap_false.

        ls_attri = VALUE ty_s_attri( ).
        CASE lr_attri->type_kind.
          WHEN cl_abap_classdescr=>typekind_iref OR cl_abap_classdescr=>typekind_intf.
            CONTINUE.

          WHEN cl_abap_classdescr=>typekind_oref
            OR cl_abap_classdescr=>typekind_dref.

          WHEN cl_abap_classdescr=>typekind_struct2
            OR cl_abap_classdescr=>typekind_struct1.

            ls_attri-check_dissolved = abap_true.
            lt_attri_struc = z2ui5_cl_fw_utility=>_get_t_attri_by_struc(
                                         io_app   = ms_db-app
                                         iv_attri = lr_attri->name ).

            LOOP AT lt_attri_struc REFERENCE INTO lr_struc.
              ls_attri_struc = CORRESPONDING #( lr_struc->* ).
              ls_attri_struc-check_ready = abap_true.
              ls_attri_struc-check_temp  = abap_true.
              INSERT ls_attri_struc INTO TABLE lt_oref_diss_new.
            ENDLOOP.

          WHEN OTHERS.
            ls_attri-check_ready = abap_true.
            ls_attri-check_temp  = abap_true.
            INSERT ls_attri_struc INTO TABLE lt_oref_diss_new.
        ENDCASE.

      ENDLOOP.

      lr_bind->check_dissolved = abap_true.
    ENDLOOP.


    " check obj ref
    LOOP AT lt_oref_diss_new REFERENCE INTO lr_bind
           WHERE bind_type = `` OR bind_type = type.
      result = bind_create( app = ms_db-app bind = lr_bind type = type in = lr_in ).
      IF result IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF result IS NOT INITIAL.
      INSERT LINES OF lt_oref_diss_new INTO TABLE ms_db-s_bind-t_attri.
      RETURN.
    ENDIF.


    "one way as one-time
    IF type = cs_bind_type-two_way.
      z2ui5_cl_fw_utility=>raise( `Binding Error - Two way binding used but no attribute found` ).
    ENDIF.

    DATA(lv_id) = z2ui5_cl_fw_utility=>get_uuid( ).
    INSERT VALUE #( name           = lv_id
                    data_stringify = z2ui5_cl_fw_utility=>trans_any_2_json( value )
                    bind_type      = cs_bind_type-one_time )
           INTO TABLE ms_db-s_bind-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.


  METHOD bind_create.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA(lv_name) = `APP->` && to_upper( bind->name ).
    ASSIGN (lv_name) TO <attri>.
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF <attri> INTO lr_ref.

    IF in = lr_ref.
      IF bind->bind_type <> type AND bind->bind_type IS NOT INITIAL.
        z2ui5_cl_fw_utility=>raise(
          `<p>Binding Error - Two different binding types for same attribute used (` && bind->name && `).` ).
      ENDIF.
      IF strlen( bind->name ) > 30.
        z2ui5_cl_fw_utility=>raise(
          `<p>Binding Error - Name of attribute more than 30 characters: ` && bind->name ).
      ENDIF.
      bind->bind_type = type.
      bind->name_front = bind->name.
      bind->name_front = replace( val = bind->name sub = `->*` with = `---` ).
      bind->name_front = replace( val = bind->name_front sub = `->` with = `--` ).
      result = COND #( WHEN type = cs_bind_type-two_way THEN `/` && ss_config-view_model_edit_name && `/` ELSE `/` ) && bind->name_front.
    ENDIF.

  ENDMETHOD.


  METHOD model_set_backend.

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = cs_bind_type-two_way.
      TRY.

          DATA(lv_name_back) = `APP->` && lr_attri->name.

          FIELD-SYMBOLS <backend> TYPE any.
          ASSIGN (lv_name_back) TO <backend>.
          z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          DATA(lv_name_front) = `MODEL->` && lr_attri->name_front.
          FIELD-SYMBOLS <frontend> TYPE any.
          ASSIGN (lv_name_front) TO <frontend>.
          z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          CASE lr_attri->type_kind.

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

    DATA(lr_view_model) = z2ui5_cl_fw_utility_json=>factory( ).
    DATA(lo_update) = lr_view_model->add_attribute_object( ss_config-view_model_edit_name ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = cs_bind_type-one_time.
        lr_view_model->add_attribute( n           = lr_attri->name
                                      v           = lr_attri->data_stringify
                                      apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs_bind_type-one_way THEN lr_view_model
                                ELSE lo_update ).

      DATA(lv_name_back) = `APP->` && lr_attri->name.
      FIELD-SYMBOLS <attribute> TYPE any.
      ASSIGN (lv_name_back) TO <attribute>.
      z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN `h`.
          lo_actual->add_attribute( n           = lr_attri->name_front
                                    v           = z2ui5_cl_fw_utility=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN OTHERS.

          CASE lr_attri->type.

            WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.

              lo_actual->add_attribute( n           = lr_attri->name_front
                                        v           = SWITCH #( <attribute> WHEN abap_true THEN `true` ELSE `false` )
                                        apos_active = abap_false ).

            WHEN OTHERS.

              lo_actual->add_attribute( n           = lr_attri->name_front
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
                                                          t_attri = ms_db-s_bind-t_attri ) ).

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
        model_set_backend( EXPORTING model   = so_body->get_attribute( ss_config-view_model_edit_name )->mr_actual
                           app     = result->ms_db-app
                           CHANGING
                           t_attri = result->ms_db-s_bind-t_attri ).
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
      lv_classname = z2ui5_cl_fw_utility=>url_param_get( val = `app_start` url = ss_config-search ).
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

      CATCH cx_root.
        result = set_app_system( error_text = `App with name ` && lv_classname && ` not found...` ).
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_system.

    result = NEW #( ).
    result->ms_db-id = z2ui5_cl_fw_utility=>get_uuid( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_cl_fw_error( val = error_text ).
    ENDIF.

    IF ix IS BOUND.
      result->ms_next-o_app_call = z2ui5_cl_fw_app=>factory_error( ix ).
      result = result->set_app_call( abap_true ).
      RETURN.
    ENDIF.

    result->ms_db-app = z2ui5_cl_fw_app=>factory_start( ).
*    result->ms_db-t_attri = z2ui5_cl_fw_utility=>get_t_attri_by_ref( result->ms_db-app ).
    result->ms_db-app->id = result->ms_db-id.

  ENDMETHOD.
ENDCLASS.
