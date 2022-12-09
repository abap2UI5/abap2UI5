
CLASS z2ui5_lcl_runtime DEFINITION DEFERRED.
CLASS z2ui5_lcl_system_app DEFINITION DEFERRED.

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
        id      TYPE string,
        id_prev TYPE string,
        app     TYPE string,
        screen  TYPE string,
        t_attri TYPE _=>ty-t-attri,
        o_app   TYPE REF TO object,
      END OF ms_db.

    DATA ms_client TYPE z2ui5_cl_http_handler=>ty_S_client.
    DATA mt_after TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.
    DATA mt_screen TYPE STANDARD TABLE OF s_screen.
    DATA mr_screen_actual TYPE REF TO s_screen.
    DATA mo_leave_to_app TYPE REF TO z2ui5_if_app.
    DATA mo_view_model TYPE z2ui5_cl_hlp_tree_json=>ty_o_me.
    DATA mo_ui5_model  TYPE z2ui5_cl_hlp_tree_json=>ty_o_me.

    METHODS constructor.

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
        VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.

    METHODS factory_new
      IMPORTING
        i_app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.

    DATA x TYPE REF TO cx_root.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS z2ui5_lcl_system_app DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory_error
      IMPORTING
        error           TYPE REF TO cx_root
        app             TYPE REF TO z2ui5_if_app OPTIONAL
        kind            TYPE string OPTIONAL
        server          TYPE REF TO z2ui5_lcl_runtime
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_app.

    DATA:
      BEGIN OF ms_error,
        x_error   TYPE REF TO cx_root,
        app       TYPE REF TO z2ui5_if_app,
        classname TYPE string,
        kind      TYPE string,
      END OF ms_error.

    DATA:
      BEGIN OF ms_home,
        is_initialized         TYPE abap_bool,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

  PROTECTED SECTION.

    METHODS on_event_error
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS on_event_home
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS get_app_url
      IMPORTING
        i_view         TYPE REF TO z2ui5_if_view
        app            TYPE string
      RETURNING
        VALUE(rv_link) TYPE string
      RAISING
        cx_abap_context_info_error.

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
        ms_db-id_prev = ms_client-o_body->get_attribute( 'ID' )->get_val( ).

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


    r_result = `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
               `    xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                         `    xmlns="sap.m"> ` &&
                    COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `  <Shell> ` ) &&
                       `  <Page id="page" title="` &&
                       lr_screen->t_controls[ name = 'HEADER' ]-t_property[ n = 'TITLE' ]-v
                       && `" class="sapUiResponsivePadding--header sapUiResponsivePadding--footer sapUiResponsivePadding--floatingFooter">`.

    IF ms_db-app = 'ZZCL_APP_SYSTEM'.
      r_result &&= `          <headerContent>` && |\n|  &&
       `<Text text="abap2ui5  |  version 2212    |" /><Link target = "_blank" href="https://github.com/oblomov-dev/abap2ui5.git" text="GIT" />`   && |\n|  &&
       `      </headerContent>  `.
    ENDIF.
    r_result &&=  `    <content>  ` &&
     `       <VBox class="sapUiSmallMargin">` .

    DATA(LV_is_block_active) = abap_false.

    LOOP AT lr_screen->t_controls REFERENCE INTO DATA(lr_element).

      CASE lr_element->name.
        WHEN 'FOOTER'.
          DATA(lv_footer_active) = abap_true.
          r_result &&=       `          </f:content>` && |\n|  &&
                          `     </f:SimpleForm> ` && |\n|  &&
                   `            </VBox> </content> <footer>` && |\n|  &&
                                 `            <OverflowToolbar id="otbFooter">` && |\n| .

        WHEN 'BEGIN_OF_BLOCK'.

          IF LV_is_block_active = abap_true.
            r_result &&= `</f:content></f:SimpleForm> `.
          ENDIF.

          LV_is_block_active = abap_true.

          r_result &&= `      <f:SimpleForm ` &&
                                `           editable="true"`  &&
                                `           layout="ResponsiveGridLayout"` &&
                                 `           title="` &&  lr_element->t_property[ n = `TITLE` ]-v && `"` &&
                                 `           labelSpanXL="4"` &&
                                                         `          labelSpanL="3"` &&
                                 `                                  labelSpanM="4"` &&
                                 `                                   labelSpanS="12"` &&
                                 `                                   adjustLabelSpan="false"` &&
                                 `                                   emptySpanXL="0"`  &&
                                 `                                   emptySpanL="4"` &&
                                 `                                   emptySpanM="0"` &&
                                 `                                   emptySpanS="0"` &&
                                 `                                   columnsXL="2"` &&
                                 `                                  columnsL="1"` &&
                                 `                                  columnsM="1"` &&
                                 `                                   singleContainerFullSize="false" >` &&
                                 `                                   <f:content>`.


        WHEN 'Input' OR 'Label' OR 'Title' OR 'Text'
            OR 'TextArea' OR 'Label' OR 'Button' OR 'CheckBox' OR 'DateTimePicker'
            OR 'TimePicker' OR 'DatePicker' OR 'ToolbarSpacer' OR 'MessageStripe' OR
            'RadioButtonGroup' OR 'ComboBox' OR 'SegmentedButton' OR 'Link'.
          r_result &&= _=>get_xml_by_control( lr_element->* ).

      ENDCASE.

    ENDLOOP.


    IF lv_footer_active = abaP_true.
      r_result &&=
          `  </OverflowToolbar>` && |\n|  &&
                               `        </footer>`.
    ELSE.
      r_result &&=       `          </f:content>` && |\n|  &&
                        `     </f:SimpleForm> ` && |\n|  &&
                 `            </VBox> </content>`.
    ENDIF.
    r_result &&=      `    </Page> ` &&
                 COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `  </Shell> ` )
                    && |\n|  &&
                   `</mvc:View>`.


    mo_ui5_model->add_attribute( n = `vView` v = r_result ).

    DATA(lo_update) = mo_view_model->add_attribute_object( 'oUpdate' ).
    lo_update->add_attribute( n = 'id' v = ms_db-id ).


    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE check_used = abap_true.

      CASE lr_attri->kind.

        WHEN 'g' OR 'D' OR 'P' OR 'T'.
          lo_update->add_attribute(
            n = lr_attri->name
            v = CONV string( ms_db-o_app->(lr_attri->name) )
          ).

        WHEN 'I'.
          lo_update->add_attribute(
             n = lr_attri->name
             v = CONV string( ms_db-o_app->(lr_attri->name) )
             apos_active = abap_false
           ).

        WHEN 'h'.
          lo_update->add_attribute(
             n = lr_attri->name
             v = _=>trans_any_2_json( ms_db-o_app->(lr_attri->name) )
             apos_active = abap_false
           ).

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

      CASE lr_attri->kind.

        WHEN 'g' OR 'I'. " or 'D' or 'T'.
          DATA(lv_value) = ms_client-o_body->get_attribute( lr_attri->name )->get_val( ).
          DATA(lr_val) = REF #( ms_db-o_app->(lr_attri->name) ).
          lr_val->* = lv_value.

        WHEN 'h'.

          _=>trans_ref_tab_2_tab(
            ir_tab_from = ms_client-o_body->get_attribute( lr_attri->name )->mr_actual
            ir_tab_to   = REF #( ms_db-o_app->(lr_attri->name) )
          ).

      ENDCASE.

    ENDLOOP.


  ENDMETHOD.


  METHOD init_app_new.
    DO.
      TRY.

          ms_client-t_param = VALUE #( LET tab = ms_client-t_param IN FOR row IN tab
            ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).

          TRY.
              ms_db-app = ms_client-t_param[ name = 'APP' ]-value.
            CATCH cx_root.
              CREATE OBJECT ms_db-o_app TYPE z2ui5_lcl_system_app.
              EXIT.
          ENDTRY.

          CREATE OBJECT ms_db-o_app TYPE (ms_db-app).
          EXIT.

        CATCH cx_root.
          DATA(lo_error) = NEW z2ui5_lcl_system_app( ).
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

      DATA(lr_ref) = REF #( ms_db-o_app->(lr_attri->name) ).

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
    r_result->ms_Client = ms_client.
    CLEAR r_result->ms_Client-o_body.
    r_result->mt_after = mt_after.
    r_result->ms_db-t_attri = _=>hlp_get_t_attri( r_result->ms_db-o_app ).

  ENDMETHOD.

  METHOD factory_new_error.

    r_result = factory_new(
             z2ui5_lcl_system_app=>factory_error( server = me error = ix app = CAST #( me->ms_db-o_app ) kind = kind ) ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_app_client IMPLEMENTATION.

  METHOD constructor.

    me->mo_server = i_server.

  ENDMETHOD.

  METHOD z2ui5_if_client_popup~display_message_box.

    INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
      INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD z2ui5_if_client_popup~display_message_toast.

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

  METHOD z2ui5_if_client_controller~get_active_screen.

    r_result = mo_server->ms_db-screen.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~nav_to_screen.

    mo_server->ms_db-screen = name.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~exit_w_logoff.

  ENDMETHOD.

  METHOD z2ui5_if_client_controller~nav_to_app.

    mo_server->mo_leave_to_app = app.

  ENDMETHOD.

  METHOD z2ui5_if_client_event~get_id.
    TRY.

        r_result = mo_server->ms_client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ).

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD z2ui5_if_client_controller~exit_to_home.

    z2ui5_if_client_controller~nav_to_app( NEW z2ui5_lcl_system_app(  ) ).

  ENDMETHOD.

ENDCLASS.


CLASS z2ui5_lcl_system_app IMPLEMENTATION.

  METHOD factory_error.

    r_result = NEW #( ).

    r_result->ms_error-x_error = error.
    r_result->ms_error-app     = app.
    r_result->ms_error-kind    = kind.

  ENDMETHOD.


  METHOD z2ui5_if_app~on_event.

    IF ms_error-x_error IS BOUND.
      on_event_error( client ).
    ELSE.
      on_event_home( client ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_if_app~set_view.

    IF ms_error-x_error IS NOT BOUND.

      DATA(view2) = view->factory_selscreen( name = 'START' title = 'Home'
            )->begin_of_block( 'Welcome to abap2ui5!'
          )->begin_of_group( 'This is an easy way to create ui5 applications with abap only:'
                 )->label( 'Step 1'
                 )->text( 'Create a new global class in the abap system'
                 )->label( 'Step 2'
                 )->text( 'Implement the interface zif_2ui5_selection_screen'
                 )->label( 'Step 3'
                 )->text( 'Define the views in the method set_screen and the behaviour in the method on_event '
                 )->label( 'Step 4' ).

      IF ms_home-class_editable = abap_true.
        view2->input(
                       value          = ms_home-classname
                       placeholder    = 'fill in the classname and press check'
                       value_state      = ms_home-class_value_state
                       value_state_text = ms_home-class_value_state_text
                       editable         = ms_home-class_editable
                  ).
      ELSE.
        view2->text( ms_home-classname ).
      ENDIF.
      view2->button( text = ms_home-btn_text on_press_id = ms_home-btn_event_id  icon = ms_home-btn_icon   "type = view->cs-button-type-
                )->label( 'Step 5' ).

      IF ms_home-class_editable = abap_false.
        view2->link( text = 'Link to the Application'
                href = get_app_url( i_view = view app = ms_home-classname ) " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
             ).
      ENDIF.
      view2->end_of_group(
     )->begin_of_group( 'Demo'
        )->label( 'Example 1'
        )->link( text = 'Link to simple application' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_01' )
        )->label( 'Example 2'
        )->link( text = 'Link to multiple Views and a lot of controls' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_02' )
    )->end_of_group(
  )->end_of_block(
  )->end_of_screen( ).


    ELSE.

      view->factory_selscreen( name = 'ERROR' title = 'abap2ui5 - error'
          )->begin_of_block( SWITCH #(  ms_error-kind
                  WHEN 'USER' THEN 'Application Error - check your code'
                  WHEN 'CUSTOMIZING' THEN 'Customizing Error - check your code in method set_screen'
                  ELSE 'System Error - please restart the framework')
             )->begin_of_group( ms_error-x_error->get_text( )
             )->label( 'Classname'
             )->text( ms_error-classname
            )->end_of_group(
           )->end_of_block(
           )->begin_of_footer(
             )->button( text = 'Home'    on_press_id = 'BUTTON_HOME'     type = 'Reject'
             )->spacer(
             )->button( text = 'Neustart' on_press_id = 'BUTTON_RESTART' type = 'Accept'
           )->end_of_footer(
         )->end_of_screen( ).

    ENDIF.

  ENDMETHOD.


  METHOD on_event_error.

    ms_error-classname = _=>get_classname_by_ref( ms_error-app ).

    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_RESTART'.
        DATA li_app TYPE REF TO z2ui5_if_app.
        CREATE OBJECT li_app TYPE (ms_error-classname).
        client->controller( )->nav_to_app( li_app  ).

      WHEN 'BUTTON_HOME'.
        client->controller( )->exit_to_home( ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_event_home.

    DATA li_app TYPE REF TO z2ui5_if_app.

    IF ms_home-is_initialized = abap_false.
      ms_home-is_initialized = abaP_true.
      ms_home-btn_text = 'check'.
      ms_home-btn_event_id = 'BUTTON_CHECK'.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = 'sap-icon://validate'.
    ENDIF.

    ms_home-class_value_state_text = ''.
    ms_home-class_value_state = ''.

    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_GO'.
        li_app = NEW z2ui5_cl_app_demo_01( ).
        client->popup( )->display_message_box( type = 'warning' text = 'App wird gestartet' ).
        client->controller( )->nav_to_app( li_app  ).


      WHEN 'BUTTON_CHANGE'.
        ms_home-btn_text = 'check'.
        ms_home-btn_event_id = 'BUTTON_CHECK'.
        ms_home-btn_icon = 'sap-icon://validate'.
        ms_home-class_editable = abap_true.

      WHEN 'BUTTON_CHECK'.

        TRY.
            DATA li_app_test TYPE REF TO z2ui5_if_app.
            ms_home-classname = to_upper( ms_home-classname ).
            CREATE OBJECT li_app_test TYPE (ms_home-classname).

            client->popup( )->display_message_toast( 'App is ready to start!' ).
            ms_home-btn_text = 'edit'.
            ms_home-btn_event_id = 'BUTTON_CHANGE'.
            ms_home-btn_icon = 'sap-icon://edit'.
            ms_home-class_value_state = z2ui5_if_view=>cs-input-value_state-success.
            ms_home-class_editable = abap_false.

          CATCH cx_root INTO DATA(lx).
            ms_home-class_value_state_text = lx->get_text( ).
            ms_home-class_value_state = z2ui5_if_view=>cs-input-value_state-warning.
            client->popup( )->display_message_box(
                text = ms_home-class_value_state_text
                type = z2ui5_if_view=>cs-message_box-type-error
                 ).
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD get_app_url.

    DATA(lv_url) = cl_abap_context_info=>get_system_url( ).
    DATA(lv_tenant) = sy-mandt.

    DATA(lo_server) = CAST z2ui5_lcl_app_view( i_view )->mo_server.
    rv_link  = 'https://' && lv_url && lo_server->ms_client-t_header[ name = '~path' ]-value && '?sap-client=' && lv_tenant && '&app=' && app .

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_app_view IMPLEMENTATION.

  METHOD constructor.

    me->mo_server = server.

  ENDMETHOD.

  METHOD  z2ui5_if_view~factory_selscreen.

    r_result = me.

    INSERT VALUE #(
        name = name
     ) INTO TABLE mo_server->mt_screen.

    mo_server->mr_screen_actual = REF #( mo_server->mt_screen[ lines( mo_server->mt_screen ) ] ).

    r_result = me.

    INSERT VALUE #(
      name  = 'HEADER'
      t_property = VALUE #(
        ( n = 'TITLE' v = title )
       ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

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
      ls_control-t_property = value #( base ls_control-t_property
        ( n = 'suggestionItems' v = '{/' && lv_id && '}' )
        ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
        ).

*      INSERT lines of VALUE #( ( n = 'suggestionItems' v = '{/' && lv_id && '}' ) )  INTO TABLE ls_control-t_property.
*      INSERT VALUE #( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )  INTO TABLE ls_control-t_property.

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
      "ls_property-name = '{' && mo_server->_get_name_by_ref( value ) && '}'.
      ls_property-v = '{' && mo_server->_get_name_by_ref( value ) && '}'.
    ENDIF.
    INSERT ls_property INTO TABLE ls_control-t_property.

    z2ui5_if_selscreen_group~custom_control( ls_control ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~begin_of_group.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control(  VALUE #(
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
      "pruefen ob typ i
    ENDIF.

    APPEND INITIAL LINE TO  mo_server->mr_screen_actual->t_controls REFERENCE INTO DATA(lr_cont).
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

    INSERT VALUE #(
      name  = 'Label'
       t_property = VALUE #(
          ( n = 'text' v = text )
       ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.


  METHOD z2ui5_if_selscreen~begin_of_block.

    r_result = me.

    INSERT VALUE #(
      name  = 'BEGIN_OF_BLOCK'
       t_property = VALUE #(
          ( n = 'TITLE' v = title )
       ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_picker.

    r_result = me.

    INSERT VALUE #(
      name       = 'DatePicker'
      t_property = VALUE #(
          ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
          ( n = 'placeholder' v = placeholder )
       ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~link.

    r_result = me.

    z2ui5_if_selscreen_group~custom_control( VALUE #(
     name  = 'Link'
       t_property = VALUE #(
         ( n = 'text'   v = text )
         ( n = 'target' v = '_blank' )
         ( n = 'href'   v = href )
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

    INSERT VALUE #(
      name  = 'TimePicker'
          t_property = VALUE #(
          ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}'  )
          ( n = 'placeholder'  v = placeholder  )
      ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_time_picker.

    r_result = me.

    INSERT VALUE #(
      name  = 'DateTimePicker'
      t_property = VALUE #(
          ( n = 'value' v = '{' && mo_server->_get_name_by_ref( value ) && '}' )
          ( n = 'placeholder'  v = placeholder  )
       ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

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

    INSERT VALUE #(
      name  = 'FOOTER'
     ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~message_strip.

    r_result = me.

    INSERT VALUE #(
      name  = 'MessageStrip'
      t_property = VALUE #(
          ( n = 'text' v = text )
          ( n = 'type' v = type )
     ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~text_area.

    r_result = me.

    INSERT VALUE #(
      name  = 'TextArea'
        t_property = VALUE #(
          ( n = 'value' v = value )
          ( n = 'rows' v = rows )
      ) ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~end_of_block.

    r_result = me.

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

  METHOD z2ui5_if_selscreen_footer~spacer.

    r_result = me.

    INSERT VALUE #(
      name  = 'ToolbarSpacer'
     ) INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~custom_control.

    DELETE val-t_property WHERE n IS INITIAL.
    INSERT val INTO TABLE mo_server->mr_screen_actual->t_controls.

  ENDMETHOD.

ENDCLASS.
