CLASS z2ui5_lcl_runtime DEFINITION DEFERRED.
CLASS _ DEFINITION INHERITING FROM z2ui5_cl_hlp_utility.
ENDCLASS.

CLASS z2ui5_lcl_app_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app_client.

    DATA mo_server TYPE REF TO z2ui5_lcl_runtime.

    METHODS constructor
      IMPORTING
        i_server TYPE REF TO z2ui5_lcl_runtime.

ENDCLASS.


CLASS z2ui5_lcl_runtime DEFINITION.

  PUBLIC SECTION.

    INTERFACES:
      z2ui5_if_view_context.

    TYPES:
      BEGIN OF s_screen,
        name          TYPE string,
        check_binding TYPE abap_bool,
        o_parser      TYPE REF TO z2ui5_cl_control_library,
        t_controls    TYPE STANDARD TABLE OF _=>ty-s-control WITH EMPTY KEY,
      END OF s_screen.

    DATA:
      BEGIN OF ms_control,
        event_type TYPE string,
      END OF ms_control.

    DATA:
      BEGIN OF ms_db,
        id           TYPE string,
        id_prev      TYPE string,
        id_prev_app  TYPE string,
        app               TYPE string,
        screen            TYPE string,
        check_no_rerender type abap_bool,
        screen_popup TYPE string,
        t_attri      TYPE _=>ty-t-attri,
        o_app        TYPE REF TO object,
      END OF ms_db.

    DATA mt_after TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.

    DATA mt_screen TYPE STANDARD TABLE OF s_screen.
    DATA mr_screen_actual TYPE REF TO s_screen.
    DATA mr_control_actual TYPE REF TO data.
    DATA mr_control_actual_parent TYPE REF TO data.
    DATA ms_leave_to_app LIKE ms_db.
    DATA mo_view_model TYPE z2ui5_cl_hlp_tree_json=>ty_o_me.
    DATA mo_ui5_model  TYPE z2ui5_cl_hlp_tree_json=>ty_o_me.

    METHODS constructor RAISING cx_uuid_error.

    METHODS db_save.

    METHODS db_load
      IMPORTING
        id              TYPE string
      RETURNING
        VALUE(r_result) LIKE ms_db.

    METHODS _get_name_by_ref
      IMPORTING
        value           TYPE data
        check_update    TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS execute_init
      RETURNING
        VALUE(ro_model) TYPE REF TO z2ui5_lcl_runtime.

    METHODS execute_finish
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS init_app_prev.

    METHODS init_app_new.

    METHODS factory_new_error
      IMPORTING
                kind            TYPE string
                ix              TYPE REF TO cx_root
      RETURNING
                VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime
      RAISING   cx_uuid_error.

    METHODS factory_new
      IMPORTING
                i_app           TYPE REF TO zz2ui5_if_app
      RETURNING
                VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime
      RAISING   cx_uuid_error.

    DATA x TYPE REF TO cx_root.

  PRIVATE SECTION.

ENDCLASS.

CLASS z2ui5_lcl_runtime IMPLEMENTATION.

  METHOD constructor.

    ms_db-id = _=>get_uuid( ).

  ENDMETHOD.

  METHOD db_load.

    SELECT SINGLE FROM z2ui5_t_draft
        FIELDS
            data
       WHERE uuid = @id
      INTO @DATA(lv_data).

    _=>trans_xml_2_object(
      EXPORTING
        xml    = lv_data
       IMPORTING
        data   = r_result
    ).

  ENDMETHOD.

  METHOD db_save.

    MODIFY z2ui5_t_draft FROM @( VALUE #(
      uuid  = ms_db-id
      uname = _=>get_user_tech( ) "cl_abap_context_info=>get_user_technical_name( )
      timestampl = _=>get_timestampl( )
      data  = _=>trans_object_2_xml( REF #( ms_db ) )
      ) ).

    COMMIT WORK.

  ENDMETHOD.


  METHOD execute_init.

    TRY.
        ms_db-id_prev = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'ID' )->get_val( ).

      CATCH cx_root.
    ENDTRY.

    IF ms_db-id_prev IS INITIAL.
      init_app_new( ).
    ELSE.
      init_app_prev( ).
    ENDIF.

  ENDMETHOD.


  METHOD execute_finish.

    x = COND #( WHEN lines( mt_screen ) = 0 THEN THROW _( 'no view defined in method set_view' ) ).

    IF ms_db-screen IS INITIAL.
      DATA(lr_screen) = REF #( mt_screen[ 1 ] ).
      ms_db-screen = lr_screen->name.
    ELSE.
      lr_screen = REF #( mt_screen[ name = ms_db-screen ] ).
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " define ui5 model
    if ms_db-check_no_rerender = abap_false.
    mo_ui5_model->add_attribute( n = `vView` v = lr_screen->o_parser->get_view(  ) ).
    endif.

    IF ms_db-screen_popup IS NOT INITIAL.
      lr_screen = REF #( mt_screen[ name = ms_db-screen_popup ] ).
      mo_ui5_model->add_attribute( n = `vViewPopup` v = lr_screen->o_parser->get_view( check_popup_active = abap_true ) ).
    ENDIF.


    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
      WHERE check_used = abap_true AND check_update = abap_false.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.

      CASE lr_attri->kind.

        WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.

          mo_view_model->add_attribute( n = lr_attri->name
                                    v = _=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'I'.
          mo_view_model->add_attribute( n = lr_attri->name
                                     v = CONV string( <attribute> )
                                     apos_active = abap_false ).

        WHEN 'h'.
          mo_view_model->add_attribute( n = lr_attri->name
                                    v = _=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

      ENDCASE.

    ENDLOOP.

    DATA(lo_update) = mo_view_model->add_attribute_object( 'oUpdate' ).
    lo_update->add_attribute( n = 'id' v = ms_db-id ).

    LOOP AT ms_db-t_attri REFERENCE INTO lr_attri
      WHERE check_used = abap_true AND check_update = abap_true.

      " FIELD-SYMBOLS <attribute> TYPE any.
      lv_name = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.

      CASE lr_attri->kind.

        WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.

          lo_update->add_attribute( n = lr_attri->name
                                    v = _=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'I'.
          lo_update->add_attribute( n = lr_attri->name
                                    v = CONV string( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'h'.
          lo_update->add_attribute( n = lr_attri->name
                                    v = _=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

      ENDCASE.

    ENDLOOP.


    mo_ui5_model = mo_ui5_model->get_root( ).

    mo_view_model->add_attribute( n = 'debug' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-debug_mode_on )  apos_active = abap_false ).

    IF mt_after IS NOT INITIAL.
      DATA(lo_list) = mo_ui5_model->add_attribute_list( 'oAfter' ).
      LOOP AT mt_after REFERENCE INTO DATA(lr_after).
        DATA(lo_list2) = lo_list->add_list_list(  ).
        LOOP AT lr_after->* REFERENCE INTO DATA(lr_con).
          lo_list2->add_list_val( lr_con->* ).
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    r_result = mo_ui5_model->get_root( )->write_result( ).
    db_save( ).




    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " define ui5 view

*    r_result = `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
*               `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
*                         ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
*                  COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` ).
*
*    LOOP AT lr_screen->t_controls REFERENCE INTO DATA(lr_element).
*      r_result &&= _=>get_xml_by_control( lr_element->* ).
*    ENDLOOP.
*
*    r_result &&= COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`.


*    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    " define ui5 model
*
*    mo_ui5_model->add_attribute( n = `vView` v = r_result ).
*
*    DATA(lo_update) = mo_view_model->add_attribute_object( 'oUpdate' ).
*    lo_update->add_attribute( n = 'id' v = ms_db-id ).
*
*
*    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
*      WHERE check_used = abap_true.
*
*      FIELD-SYMBOLS <attribute> TYPE any.
*      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
*      ASSIGN (lv_name) TO <attribute>.
*
*      CASE lr_attri->kind.
*
*        WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.
*
*          lo_update->add_attribute( n = lr_attri->name
*                                    v = _=>get_abap_2_json( <attribute> )
*                                    apos_active = abap_false ).
*
*        WHEN 'I'.
*          lo_update->add_attribute( n = lr_attri->name
*                                    v = CONV string( <attribute> )
*                                    apos_active = abap_false ).
*
*        WHEN 'h'.
*          lo_update->add_attribute( n = lr_attri->name
*                                    v = _=>trans_any_2_json( <attribute> )
*                                    apos_active = abap_false ).
*
*      ENDCASE.
*
*    ENDLOOP.
*
*
*    mo_ui5_model = mo_ui5_model->get_root( ).
*
*    mo_view_model->add_attribute( n = 'debug' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-debug_mode_on )  apos_active = abap_false ).
*
*    IF mt_after IS NOT INITIAL.
*      DATA(lo_list) = mo_ui5_model->add_attribute_list( 'oAfter' ).
*      LOOP AT mt_after REFERENCE INTO DATA(lr_after).
*        DATA(lo_list2) = lo_list->add_list_list(  ).
*        LOOP AT lr_after->* REFERENCE INTO DATA(lr_con).
*          lo_list2->add_list_val( lr_con->* ).
*        ENDLOOP.
*      ENDLOOP.
*    ENDIF.
*
*    r_result = mo_ui5_model->get_root( )->write_result( ).
*    db_save( ).

  ENDMETHOD.


  METHOD init_app_prev.

    ms_db = CORRESPONDING #( BASE ( ms_db ) db_load( ms_db-id_prev ) EXCEPT id id_prev ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE check_used = abap_true AND check_update = abap_true.

      lr_attri->check_used = abap_false.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.

      CASE lr_attri->kind.

        WHEN 'g' OR 'I' OR 'C'. " or 'D' or 'T'.
          DATA(lv_value) = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->get_val( ).
          <attribute> = lv_value.

          "  when 'C'.
          ""   lv_value = ss_client-o_body->get_attribute( lr_attri->name )->get_val( ).
          "   lr_val = REF #( ms_db-o_app->(lr_attri->name) ).
          "  lr_val->* = switch string( lv_value when 'true' then 'X' else '' ).

        WHEN 'h'.

          _=>trans_ref_tab_2_tab(
                     ir_tab_from = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->mr_actual
                     ir_tab_to   = REF #( <attribute> )          ).

      ENDCASE.

    ENDLOOP.

    ms_control-event_type = zz2ui5_if_app_client=>lifecycle_method-on_event.
  ENDMETHOD.


  METHOD init_app_new.
    DO.
      TRY.

          z2ui5_cl_http_handler=>client-t_param = VALUE #( LET tab = z2ui5_cl_http_handler=>client-t_param IN FOR row IN tab
            ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).

          TRY.
              ms_db-app = z2ui5_cl_http_handler=>client-t_param[ name = 'APP' ]-value.
            CATCH cx_root.
              ms_db-o_app = NEW z2ui5_cl_app_system( ).
              EXIT.
          ENDTRY.

          CREATE OBJECT ms_db-o_app TYPE (ms_db-app).
          EXIT.

        CATCH cx_root.
          DATA(lo_error) = NEW z2ui5_cl_app_system( ).
          lo_error->ms_error-x_error = NEW _( val = `Class with name ` && ms_db-app && ` not found. Please check your repository.` ).
          ms_db-o_app = CAST #( lo_error ).
          EXIT.
      ENDTRY.
    ENDDO.

    ms_db-app     = _=>get_classname_by_ref( ms_db-o_app ).
    ms_db-t_attri = _=>hlp_get_t_attri( ms_db-o_app ).

    ms_control-event_type = zz2ui5_if_app_client=>lifecycle_method-on_init.

  ENDMETHOD.

  METHOD _get_name_by_ref.

    DATA(lr_in) = REF #( value ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.
      DATA(lr_ref) = REF #( <attribute> ).

      IF lr_in = lr_ref.
        lr_attri->check_used   = abap_true.
        lr_attri->check_update = check_update.

        r_result = COND #( WHEN check_update = abap_true THEN '/oUpdate/' && lr_attri->name
                                   ELSE '/' && lr_attri->name ).
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD factory_new.

    r_result = NEW z2ui5_lcl_runtime( ).
    r_result->ms_db-o_app = i_app.
    r_result->ms_db-app = _=>get_classname_by_ref( i_app ).
    CLEAR z2ui5_cl_http_handler=>client-o_body.
    r_result->mt_after = mt_after.
    r_result->ms_db-t_attri = _=>hlp_get_t_attri( r_result->ms_db-o_app ).

  ENDMETHOD.

  METHOD factory_new_error.

    r_result = factory_new(
             z2ui5_cl_app_system=>factory_error( error = ix app = CAST #( me->ms_db-o_app ) kind = kind ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view_context~get_attr_name_by_ref.

    result = _get_name_by_ref(
         value    = ref
         check_update = check_update
*          RECEIVING
*            r_result =
     ).


  ENDMETHOD.

  METHOD z2ui5_if_view_context~get_event_method.

    result = |onEventBackend({ event_object })|.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_app_client IMPLEMENTATION.

  METHOD constructor.

    me->mo_server = i_server.

  ENDMETHOD.


  METHOD zz2ui5_if_app_client~display_message_toast.

    INSERT VALUE #( ( `MessageToast` ) ( `show` ) ( text ) )
         INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~display_popup_inform.

    INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
      INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~display_view.

    mo_server->ms_db-screen = val.
    mo_server->ms_db-check_no_rerender = check_no_rerender.

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~factory_view.

    result = z2ui5_cl_control_library=>factory( context = mo_server ).
    INSERT VALUE #( name = name o_parser = result ) INTO TABLE mo_server->mt_screen.

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~nav_to_home.

    " zz2ui5_if_app_client~nav_to_app( NEW z2ui5_cl_app_system( ) ).

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~get.

    result = VALUE #(
        lifecycle_method = mo_server->ms_control-event_type

        check_call_satck = xsdbool( mo_server->ms_db-id_prev_app IS NOT INITIAL )
        screen_active = mo_server->ms_db-screen
    ).


    TRY.
        result-event_id = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~get_app_called.

    DATA(x) = COND i( WHEN mo_server->ms_db-id_prev_app IS INITIAL THEN THROW _('CX_STACK_EMPTY - NO CALLING APP FOUND') ).
    result = CAST #( mo_server->db_load( mo_server->ms_db-id_prev_app )-o_app ).

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~nav_to_app.

    mo_server->ms_leave_to_app = VALUE #( o_app = app ).

  ENDMETHOD.

  METHOD zz2ui5_if_app_client~display_popup.

    mo_server->ms_db-screen_popup = name.

  ENDMETHOD.

ENDCLASS.
