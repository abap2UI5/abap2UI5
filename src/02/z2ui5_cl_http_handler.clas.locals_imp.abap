CLASS z2ui5_lcl_runtime DEFINITION DEFERRED.
CLASS _ DEFINITION INHERITING FROM z2ui5_cl_hlp_utility.
ENDCLASS.

CLASS z2ui5_lcl_app_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.
    INTERFACES z2ui5_if_client_controller.
    INTERFACES z2ui5_if_client_event.
    INTERFACES z2ui5_if_client_popup.

    DATA mo_server TYPE REF TO z2ui5_lcl_runtime.

    METHODS constructor
      IMPORTING
        i_server TYPE REF TO z2ui5_lcl_runtime.

ENDCLASS.

CLASS z2ui5_lcl_app_view DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_view.
    INTERFACES z2ui5_if_selscreen.
    INTERFACES z2ui5_if_selscreen_block.
    INTERFACES z2ui5_if_selscreen_group.
    INTERFACES z2ui5_if_selscreen_footer.

    DATA mo_server TYPE REF TO z2ui5_lcl_runtime.

    METHODS constructor
      IMPORTING
        server TYPE REF TO z2ui5_lcl_runtime.

ENDCLASS.

CLASS z2ui5_lcl_runtime DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF s_screen,
        name          TYPE string,
        check_binding TYPE abap_bool,
        t_controls    TYPE STANDARD TABLE OF _=>ty-s-control WITH EMPTY KEY,
      END OF s_screen.

    DATA:
      BEGIN OF ms_db,
        id          TYPE string,
        id_prev     TYPE string,
        id_prev_app TYPE string,
        app         TYPE string,
        screen      TYPE string,
        t_attri     TYPE _=>ty-t-attri,
        o_app       TYPE REF TO object,
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
                i_app           TYPE REF TO z2ui5_if_app
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

    SELECT SINGLE FROM z2ui5_t_001
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

    MODIFY z2ui5_t_001 FROM @( VALUE #(
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
    " define ui5 view

    r_result = `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
               `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                         ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
                  COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` ).

    LOOP AT lr_screen->t_controls REFERENCE INTO DATA(lr_element).
      r_result &&= _=>get_xml_by_control( lr_element->* ).
    ENDLOOP.

    r_result &&= COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`.


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " define ui5 model

    mo_ui5_model->add_attribute( n = `vView` v = r_result ).

    DATA(lo_update) = mo_view_model->add_attribute_object( 'oUpdate' ).
    lo_update->add_attribute( n = 'id' v = ms_db-id ).


    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
      WHERE check_used = abap_true.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
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

  ENDMETHOD.


  METHOD init_app_prev.

    ms_db = CORRESPONDING #( BASE ( ms_db ) db_load( ms_db-id_prev ) EXCEPT id id_prev ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE check_used = abap_true.

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

  ENDMETHOD.

  METHOD _get_name_by_ref.

    DATA(lr_in) = REF #( value ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.
      DATA(lr_ref) = REF #( <attribute> ).

      IF lr_in = lr_ref.
        r_result = '/oUpdate/' && lr_attri->name.
        lr_attri->check_used = abap_true.
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

ENDCLASS.

CLASS z2ui5_lcl_app_client IMPLEMENTATION.

  METHOD constructor.

    me->mo_server = i_server.

  ENDMETHOD.

  METHOD z2ui5_if_client_popup~message_box.

    INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
      INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD z2ui5_if_client_popup~message_toast.

    INSERT VALUE #( ( `MessageToast` ) ( `show` ) ( text ) )
         INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~event.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_client~controller.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~get_active_page.

    r_result = mo_server->ms_db-screen.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~nav_to_page.

    mo_server->ms_db-screen = name.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~exit_w_logoff.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~nav_to_app.

    mo_server->ms_leave_to_app = VALUE #( o_app = app ).

  ENDMETHOD.

  METHOD z2ui5_if_client_event~get_id.
    TRY.
        r_result = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD z2ui5_if_client_controller~exit_to_home.

    z2ui5_if_client_controller~nav_to_app( NEW z2ui5_cl_app_system( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~nav_to_app_called.

    DATA(x) = COND i( WHEN mo_server->ms_db-id_prev_app IS INITIAL THEN THROW _('CX_STACK_EMPTY - NO CALLING APP FOUND') ).
    mo_server->ms_leave_to_app = mo_server->db_load( mo_server->ms_db-id_prev_app ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_app_view IMPLEMENTATION.

  METHOD constructor.

    me->mo_server = server.

  ENDMETHOD.

  METHOD  z2ui5_if_view~factory_selscreen_page.

    r_result = me.

    INSERT VALUE #(
        name = name
     ) INTO TABLE mo_server->mt_screen.

    mo_server->mr_screen_actual = REF #( mo_server->mt_screen[ lines( mo_server->mt_screen ) ] ).

    r_result = me.

    APPEND INITIAL LINE TO mo_server->mr_screen_actual->t_controls REFERENCE INTO DATA(lr_control).
    lr_control->name = 'Page'.
    lr_control->t_property = VALUE #(
     ( n = 'title' v = title )
     ( n = 'showNavButton' v = COND #( WHEN event_nav_back_id = '' THEN 'false' ELSE 'true' ) )
     ( n = 'navButtonTap' v = `onEventBackend({ 'ID' : '` && event_nav_back_id && `' })` )
     ).

    DATA lr_cont TYPE REF TO _=>ty-s-control.
    lr_cont = NEW #( name = 'content'
                     parent = REF #( lr_control->* ) ).
    APPEND lr_cont TO lr_control->t_child.

    mo_server->mr_control_actual_parent = lr_cont.
    mo_server->mr_control_actual = REF #( lr_cont->t_child ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~button.

    r_result = me.

    DATA(ls_control) =  VALUE _=>ty-s-control(
          name  = 'Button'
          t_property = VALUE #(
            ( n = 'press' v = `onEventBackend({ 'ID' : '` && on_press_id && `' })` )
            ( n = 'text'  v = text )
            ( n = 'icon' v = icon )
            ( COND #( WHEN type IS NOT INITIAL THEN VALUE #( n = 'type'  v = type ) ) )
       ) ).

    IF enabled IS SUPPLIED.
      INSERT VALUE #(
         n = 'enabled' v = _=>get_abap_2_json( enabled )
      ) INTO TABLE ls_control-t_property.
    ENDIF.

    z2ui5_if_selscreen_group~custom_control( ls_control ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~text.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control(  VALUE #(
      name  = 'Text'
      t_property = VALUE #( ( n = 'text' v = text ) )
     ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~input.

    r_result = me.

    DATA(ls_control) = VALUE _=>ty-s-control( ).
    ls_control-name = 'Input'.
    ls_control-t_property = VALUE #(
            ( n = 'placeholder'    v = placeholder )
            ( n = 'type'           v = type )
            ( n = 'showClearIcon'  v = _=>get_abap_2_json( show_clear_icon ) )
            ( COND #( WHEN description IS SUPPLIED THEN VALUE #( n = 'description' v = description ) ) )
            ( COND #( WHEN editable IS SUPPLIED THEN VALUE #(    n = 'editable'    v = _=>get_abap_2_json( editable ) ) ) )
            ( n = 'valueState'     v = value_state )
            ( n = 'valueStateText' v = value_state_text )
         ).

    DELETE ls_control-t_property WHERE v IS INITIAL.


    IF suggestion_items IS NOT INITIAL.

      DATA(lv_id) = _=>get_uuid_session( ).
      ls_control-t_property = VALUE #( BASE ls_control-t_property
        ( n = 'suggestionItems' v = '{/' && lv_id && '}' )
        ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
        ).

      mo_server->mo_view_model->add_attribute(
           n = lv_id
           v = _=>trans_any_2_json( suggestion_items  )
        apos_active = abap_false
      ).

      APPEND INITIAL LINE TO ls_control-t_child REFERENCE INTO DATA(lr_data).
      CREATE DATA lr_data->* TYPE _=>ty-s-control.
      DATA(lr_cont) = CAST _=>ty-s-control( lr_data->* ).
      lr_cont->name = 'suggestionItems'.
      lr_cont->parent = REF #( ls_control ).

      APPEND INITIAL LINE TO lr_cont->t_child REFERENCE INTO lr_data.
      CREATE DATA lr_data->* TYPE _=>ty-s-control.
      lr_cont = CAST _=>ty-s-control( lr_data->* ).
      lr_cont->name = 'ListItem'.
      lr_cont->ns = 'core'.

      lr_cont->t_property = VALUE #(
              ( n = 'text' v = '{VALUE}' )
              ( n = 'additionalText' v = '{DESCR}' )
       ).

    ENDIF.

    "spezial - input
    DATA(ls_property) = VALUE  _=>ty-s-property(  ).
    ls_property-n = 'value'.
    IF editable IS SUPPLIED AND editable = abap_false.
      ls_property-v = value.
    ELSE.
      ls_property-v = '{' && mo_server->_get_name_by_ref( value ) && '}'.
    ENDIF.
    INSERT ls_property INTO TABLE ls_control-t_property.

    z2ui5_if_selscreen_group~custom_control( ls_control ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~begin_of_group.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
         name  = 'Title'
         ns = 'core'
         t_property = VALUE #(
             ( n = 'text' v = title ) )
        ) ).

  ENDMETHOD.


  METHOD z2ui5_if_selscreen_group~checkbox.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
           name  = 'CheckBox'
           t_property = VALUE #(
              ( n = 'text'  v = text )
              ( n = 'selected' v = '{' && mo_server->_get_name_by_ref( selected ) && '}' )
      ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~radiobutton_group.

    r_result = me.

    IF selected_index IS SUPPLIED.
      "test if type 1
    ENDIF.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_server->mr_control_actual->* TO <tab>.

    DATA lr_cont TYPE REF TO _=>ty-s-control.
    CREATE DATA lr_cont.
    APPEND lr_cont TO <tab>.

    lr_cont->name = 'RadioButtonGroup'.
    lr_cont->t_property = VALUE #(
             ( n = 'columns' v = lines( t_prop ) )
             ( n = 'selectedIndex' v = '{' && mo_server->_get_name_by_ref( selected_index ) && '}'  )
             ).
    DATA(lr_parent) = lr_cont.

    LOOP AT t_prop REFERENCE INTO DATA(lr_prop).
      DATA(lv_tabix) = sy-tabix - 1.

      APPEND INITIAL LINE TO lr_parent->t_child REFERENCE INTO DATA(lr_data).
      CREATE DATA lr_data->* TYPE _=>ty-s-control. "zif_2ui5_screen_group=>s_control.
      lr_cont = CAST #( lr_data->* ).
      lr_cont->name = 'RadioButton'.
      lr_cont->parent = lr_parent.
      lr_cont->t_property = VALUE #(
                ( n = 'text' v = lr_prop->* )
       ).

    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_selscreen_group~label.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
       name  = 'Label'
        t_property = VALUE #(
           ( n = 'text' v = text )
        ) ) ).

  ENDMETHOD.


  METHOD z2ui5_if_selscreen~begin_of_block.

    r_result = me.

    DATA lr_cont2 TYPE REF TO _=>ty-s-control. " get_new_control( ).

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_server->mr_control_actual->* TO <tab>.

    CREATE DATA lr_cont2.
    APPEND lr_cont2 TO <tab>.

    lr_cont2->name = 'VBox'.
    lr_cont2->t_property = VALUE #( ( n = 'class' v = 'sapUiSmallMargin' ) ).
    lr_cont2->parent = REF #( lr_cont2->* ).

    APPEND INITIAL LINE TO lr_cont2->t_child REFERENCE INTO DATA(lr_data2).
    CREATE DATA lr_data2->* TYPE _=>ty-s-control.
    DATA(lr_control) = CAST _=>ty-s-control( lr_data2->* ).
    lr_control->name = 'SimpleForm'.
    lr_control->ns = 'f'.
    lr_control->parent = mo_server->mr_control_actual_parent.
    lr_control->t_property = VALUE #(
          ( n = 'title' v = title )
        ( n = 'editable' v = 'true' )
        ( n = 'layout' v = 'ResponsiveGridLayout' )
        ( n = 'labelSpanXL' v = '4' )
        ( n = 'labelSpanL' v = '3' )
        ( n = 'labelSpanM' v = '4' )
        ( n = 'labelSpanS' v = '12' )
        ( n = 'emptySpanXL' v = '0' )
        ( n = 'emptySpanL' v = '4' )
        ( n = 'emptySpanM' v = '0' )
        ( n = 'emptySpanS' v = '0' )
        ( n = 'columnsL' v = '1' )
        ( n = 'columnsM' v = '1' )
        ( n = 'singleContainerFullSize' v = 'false' )
        ( n = 'adjustLabelSpan' v = 'false' )
     ).

    APPEND INITIAL LINE TO lr_control->t_child REFERENCE INTO DATA(lr_data3).
    CREATE DATA lr_data3->* TYPE _=>ty-s-control.
    DATA(lr_cont) = CAST _=>ty-s-control( lr_data3->* ).
    lr_cont->name = 'content'.
    lr_cont->ns = 'f'.
    lr_cont->parent = REF #( lr_control->* ).

    mo_server->mr_control_actual ?= REF #( lr_cont->t_child ).


  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_picker.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
      name       = 'DatePicker'
      t_property = VALUE #(
          ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
          ( n = 'placeholder' v = placeholder )
       ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~link.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
     name  = 'Link'
       t_property = VALUE #(
         ( n = 'text'   v = text )
         ( n = 'target' v = '_blank' )
         ( n = 'href'   v = href )
         ( n = 'enabled'   v = _=>get_abap_2_json( enabled ) )
       ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~segmented_button.

    r_result = me.

    DATA(lv_id) = _=>get_uuid_session( ).

    DATA(ls_control) = VALUE _=>ty-s-control( ).
    ls_control = VALUE #(
      name  = 'SegmentedButton'
      t_property = VALUE #(
       (  n = 'selectedKey' v =  '{' && mo_server->_get_name_by_ref( selected_key ) && '}' )
     ) ).

    DATA(ls_Parent) = REF #( ls_control ).

    APPEND INITIAL LINE TO ls_control-t_child REFERENCE INTO DATA(lr_data).
    CREATE DATA lr_data->* TYPE _=>ty-s-control.
    DATA(lr_cont) = CAST _=>ty-s-control( lr_data->* ).
    lr_cont->name = 'items'.
    DATA(ls_item) = REF #( lr_cont->* ).

    LOOP AT t_button REFERENCE INTO DATA(lr_btn).

      APPEND INITIAL LINE TO ls_item->t_child REFERENCE INTO lr_data.
      CREATE DATA lr_data->* TYPE _=>ty-s-control.
      lr_cont = CAST _=>ty-s-control( lr_data->* ).
      lr_cont->name = 'SegmentedButtonItem'.
      lr_cont->t_property = VALUE #(
        ( n = 'icon'  v = lr_btn->icon  )
        ( n = 'key'   v = lr_btn->key )
        ( n = 'text'  v = lr_btn->text )
       ).
      CLEAR lr_cont->t_child.
      lr_cont->parent = ls_item.

    ENDLOOP.

    z2ui5_if_selscreen_group~custom_control( ls_parent->* ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~time_picker.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
      name  = 'TimePicker'
          t_property = VALUE #(
          ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}'  )
          ( n = 'placeholder'  v = placeholder  )
      ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_time_picker.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'DateTimePicker'
        t_property = VALUE #(
            ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
            ( n = 'placeholder'  v = placeholder  )
         ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~combobox.

    r_result = me.

    DATA(lv_id) = _=>get_uuid_session( ).

    DATA(ls_control) = VALUE _=>ty-s-control( ).
    ls_control = VALUE #(
      name  = 'ComboBox'
      t_property = VALUE #(
       (  n = 'showClearIcon' v = _=>get_abap_2_json( show_clear_icon ) )
       (  n = 'selectedKey'   v =  '{' && mo_server->_get_name_by_ref( selectedkey ) && '}' )
       (  n = 'items' v = '{/' && lv_id && '}' )
      ) ).

    APPEND INITIAL LINE TO ls_control-t_child REFERENCE INTO DATA(lr_data).
    CREATE DATA lr_data->* TYPE _=>ty-s-control.
    DATA(lr_cont) = CAST _=>ty-s-control( lr_data->* ).
    lr_cont->name = 'Item'.
    lr_cont->ns = 'core'.
    lr_cont->t_property = VALUE #(
      ( n = 'key'  v ='{KEY}'  )
      ( n = 'text' v = '{TEXT}' )
     ).
    lr_cont->parent = REF #( ls_control ).


    mo_server->mo_view_model->add_attribute(
      n           = lv_id
      v           = _=>trans_any_2_json( t_item )
      apos_active = abap_false
     ).

    z2ui5_if_selscreen_group~custom_control( ls_control ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~begin_of_footer.

    r_result = me.

    DATA lr_cont TYPE REF TO _=>ty-s-control.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_server->mr_control_actual->* TO <tab>.


    lr_cont = NEW #( name = 'footer' ).
    APPEND lr_cont TO <tab>.

    mo_server->mr_control_actual ?= REF #( lr_cont->t_child ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~message_strip.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
       name  = 'MessageStrip'
       t_property = VALUE #(
           ( n = 'text' v = text )
           ( n = 'type' v = type )
      ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~text_area.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
         name  = 'TextArea'
           t_property = VALUE #(
             ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
             ( n = 'rows' v = rows )
             ( n = 'height' v = height )
             ( n = 'width' v = width )
         ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~end_of_block.

    r_result = me.

    DATA(lr_control) = CAST _=>ty-s-control( mo_server->mr_control_actual_parent ).
    lr_control = CAST #( lr_control->parent ).
    mo_server->mr_control_actual_parent = lr_control.
    mo_server->mr_control_actual = REF #( lr_control->t_child ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~end_of_group.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~end_of_screen.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~button.

    IF enabled IS SUPPLIED.

      r_result = CAST #( z2ui5_if_selscreen_group~button(
           text        = text
           on_press_id = on_press_id
           type        = type
           enabled     = enabled
           icon = icon
       ) ).

    ELSE.

      r_result = CAST #( z2ui5_if_selscreen_group~button(
      text        = text
      on_press_id = on_press_id
      type        = type
      icon = icon
        ) ).

    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~end_of_footer.

    r_result = me.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~Toolbar_spacer.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'ToolbarSpacer'
          ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~custom_control.

    r_result = me.

    DELETE val-t_property WHERE n IS INITIAL.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_server->mr_control_actual->* TO <tab>.

    DATA lr_field TYPE REF TO z2ui5_cl_hlp_utility=>ty-s-control.
    CREATE DATA lr_field.
    APPEND lr_field TO <tab>.
    lr_field->* = val.
  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~code_editor.

    r_result = z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'CodeEditor'
        ns = 'editor'
        t_property = VALUE #(
            ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
            ( n = 'type'  v = type )
            ( n = 'height'  v = '600px' )
         ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~html.

    "todo
    DATA(lv_html) = replace( val = val sub = '</' with = '#+´"?' occ   =   0 ).
    lv_html = replace( val = lv_html sub = '<' with = '<html:' occ   =   0 ).
    lv_html = replace( val = lv_html sub = '#+´"?' with = '</html:' occ   =   0 ).

    lv_html = '<VBox>' && lv_html && '</VBox>'.

    r_result ?= z2ui5_if_selscreen_group~custom_control(  VALUE #(
        name  = 'ZZHTML'
        t_property = VALUE #( ( n = 'VALUE' v = lv_html ) )
    ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~Begin_of_overflow_toolbar.


    r_result = me.

    DATA lr_cont TYPE REF TO _=>ty-s-control.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mo_server->mr_control_actual->* TO <tab>.

    lr_cont = NEW #( name = 'OverflowToolbar' ).
    APPEND lr_cont TO <tab>.

    mo_server->mr_control_actual ?= REF #( lr_cont->t_child ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~switch.

  r_result = z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'Switch'
        t_property = VALUE #(
           ( n = 'type'           v = type           )
           ( n = 'enabled'        v = _=>get_abap_2_json( enabled  )      )
           ( n = 'state'          v = '{' && mo_server->_get_name_by_ref( state ) && '}' )
           ( n = 'customTextOff'  v = customtextoff  )
           ( n = 'customTextOn'   v = customtexton   )
    ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~end_of_overflow_toolbar.

    r_result = me.

    DATA lr_control TYPE REF TO _=>ty-s-control.

    lr_control = CAST #( mo_server->mr_control_actual_parent ).
    lr_control = CAST #( lr_control->parent ).
    mo_server->mr_control_actual_parent = lr_control.
    mo_server->mr_control_actual = REF #( lr_control->t_child ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~progress_indicator.

   r_result = z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'ProgressIndicator'
        t_property = VALUE #(
           ( n = 'percentValue' v = '{' && mo_server->_get_name_by_ref( percent_value ) && '}' )
           ( n = 'displayValue' v = display_Value )
           ( n = 'showValue'    v = _=>get_abap_2_json( show_value  )      )
           ( n = 'state'        v = state  )
    ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~step_input.

   r_result = z2ui5_if_selscreen_group~custom_control( VALUE #(
        name  = 'StepInput'
        t_property = VALUE #(
           ( n = 'max'  v = max  )
           ( n = 'min'  v = min  )
           ( n = 'step' v = step )
           ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
    ) ) ).

  ENDMETHOD.

ENDCLASS.
