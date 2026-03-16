CLASS z2ui5_cl_app_startup DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CONSTANTS:
      BEGIN OF cs_event,
        button_check  TYPE string VALUE `BUTTON_CHECK`,
        button_change TYPE string VALUE `BUTTON_CHANGE`,
        value_help    TYPE string VALUE `VALUE_HELP`,
        open_debug    TYPE string VALUE `OPEN_DEBUG`,
        open_info     TYPE string VALUE `OPEN_INFO`,
        set_config    TYPE string VALUE `SET_CONFIG`,
        close         TYPE string VALUE `CLOSE`,
      END OF cs_event.

    DATA:
      BEGIN OF s_home,
        url                    TYPE string,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF s_home.

    DATA ui5_version TYPE string.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_app_startup.

  PROTECTED SECTION.
    DATA client    TYPE REF TO z2ui5_if_client.
    DATA t_classes TYPE z2ui5_cl_util=>ty_t_classes.

    METHODS on_init.
    METHODS on_navigation.
    METHODS on_event.
    METHODS on_event_button_check.
    METHODS view_display.
    METHODS view_display_popup.
    METHODS reset_button_state.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_startup IMPLEMENTATION.


  METHOD factory.

    result = NEW #( ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.
    IF client->check_on_init( ).
      on_init( ).
    ELSEIF client->check_on_navigated( ).
      on_navigation( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.


  METHOD on_init.

    reset_button_state( ).
    s_home-classname = z2ui5_cl_util=>rtti_get_classname_by_ref( NEW z2ui5_cl_app_hello_world( ) ).

    view_display( ).

  ENDMETHOD.


  METHOD on_navigation.

    TRY.
        DATA(f4)       = CAST z2ui5_cl_pop_to_select( client->get_app_prev( ) ).
        DATA(s_result) = f4->result( ).

        IF s_result-check_confirmed = abap_true.

          ASSIGN s_result-row->* TO FIELD-SYMBOL(<class>).
          s_home = CORRESPONDING #( BASE ( s_home ) <class> ).
          view_display( ).

        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD on_event.

    DATA app     TYPE REF TO z2ui5_if_app.
    DATA app_ref TYPE REF TO z2ui5_if_app.

    CASE client->get( )-event.

      WHEN cs_event-set_config.
        CREATE OBJECT app TYPE (`Z2UI5_CL_APP_ICF_CONFIG`).
        client->nav_app_call( app ).

      WHEN cs_event-close.
        client->popup_destroy( ).

      WHEN cs_event-open_debug.
        client->message_box_display( `Press CTRL+F12 to open the debugging tools` ).

      WHEN cs_event-open_info.
        view_display_popup( ).

      WHEN cs_event-button_check.
        on_event_button_check( ).
        client->view_model_update( ).

      WHEN cs_event-button_change.
        reset_button_state( ).
        client->view_model_update( ).

      WHEN cs_event-value_help.
        TRY.
            t_classes = z2ui5_cl_util=>rtti_get_classes_impl_intf( z2ui5_cl_util=>rtti_get_intfname_by_ref( app_ref ) ).
          CATCH cx_root.
            client->message_box_display( `Unfortunately the value help is not available on your ABAP release!` ).
            RETURN.
        ENDTRY.
        client->nav_app_call( z2ui5_cl_pop_to_select=>factory( t_classes ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_event_button_check.

    DATA app_test TYPE REF TO z2ui5_if_app.

    TRY.
        s_home-classname = z2ui5_cl_util=>c_trim_upper( s_home-classname ).
        CREATE OBJECT app_test TYPE (s_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        s_home-btn_text          = `edit`.
        s_home-btn_event_id      = cs_event-button_change.
        s_home-btn_icon          = `sap-icon://edit`.
        s_home-class_value_state = `Success`.
        s_home-class_editable    = abap_false.

        DATA(s_config) = client->get( )-s_config.
        s_home-url = z2ui5_cl_util=>app_get_url( classname = s_home-classname
                                                  origin   = s_config-origin
                                                  pathname = s_config-pathname
                                                  search   = s_config-search
                                                  hash     = s_config-hash ).
      CATCH cx_root INTO DATA(x) ##CATCH_ALL.
        s_home-class_value_state_text = x->get_text( ).
        s_home-class_value_state      = `Warning`.
        client->message_box_display( text = s_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.


  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).
    DATA(page) = view->shell(
        )->page(
            title         = `abap2UI5 - Developing UI5 Apps Purely in ABAP`
            shownavbutton = abap_false ).

    DATA(toolbar) = page->header_content( ).
    toolbar->toolbar_spacer(
      )->button( text  = `Debugging Tools`
                 icon  = `sap-icon://enablement`
                 press = client->_event( cs_event-open_debug )
      )->button( text  = `System`
                 icon  = `sap-icon://information`
                 press = client->_event( cs_event-open_info ) ).

    IF z2ui5_cl_util=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      toolbar->button( text  = `Config`
                       icon  = `sap-icon://settings`
                       press = client->_event( cs_event-set_config ) ).
    ENDIF.

    DATA(simple_form) = page->simple_form(
        editable                = abap_true
        layout                  = `ResponsiveGridLayout`
        labelspanxl             = `4`
        labelspanl              = `3`
        labelspanm              = `4`
        labelspans              = `12`
        adjustlabelspan         = abap_false
        emptyspanxl             = `0`
        emptyspanl              = `4`
        emptyspanm              = `0`
        emptyspans              = `0`
        columnsxl               = `1`
        columnsl                = `1`
        columnsm                = `1`
        singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form->toolbar( )->title( `Quickstart` ).
    simple_form->label( `Step 1`
      )->text( `Create a new class in your ABAP system`
      )->label( `Step 2`
      )->text( `Add the interface: Z2UI5_IF_APP`
      )->label( `Step 3`
      )->text( `Define the view, implement behavior`
      )->label(
      )->link( text   = `(Example)`
               target = `_blank`
               href   = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_cl_app_hello_world.clas.abap`
      )->label( `Step 4` ).

    IF s_home-class_editable = abap_true.
      simple_form->input( placeholder      = `fill in the class name and press 'check'`
                          enabled          = client->_bind( s_home-class_editable )
                          value            = client->_bind_edit( s_home-classname )
                          submit           = client->_event( s_home-btn_event_id )
                          valuehelprequest = client->_event( cs_event-value_help )
                          showvaluehelp    = abap_true
                          width            = `70%` ).

    ELSE.
      simple_form->text( s_home-classname ).
    ENDIF.

    simple_form->label( ).
    simple_form->button( press = client->_event( s_home-btn_event_id )
                         text  = client->_bind( s_home-btn_text )
                         icon  = client->_bind( s_home-btn_icon )
                         width = `70%` ).
    simple_form->label( `Step 5`
      )->link( text    = `Link to the Application`
               target  = `_blank`
               href    = client->_bind( s_home-url )
               enabled = |\{= ${ client->_bind( val = s_home-class_editable ) } === false \}| ).

    DATA(s_config2)   = client->get( )-s_config.
    DATA(url_samples) = z2ui5_cl_util=>app_get_url( classname = `z2ui5_cl_demo_app_000`
                                                     origin   = s_config2-origin
                                                     pathname = s_config2-pathname
                                                     search   = s_config2-search
                                                     hash     = s_config2-hash ).

    simple_form->toolbar( )->title( `What's next?` ).

    IF z2ui5_cl_util=>rtti_check_class_exists( `z2ui5_cl_demo_app_000` ).
      simple_form->label( `Start Developing` ).
      simple_form->button( text  = `Explore Code Samples`
                           press = client->_event_client( val   = client->cs_event-open_new_tab
                                                          t_arg = VALUE #( ( url_samples ) ) )
                           width = `70%` ).

    ELSE.
      simple_form->label( `Install the sample repository` ).
      simple_form->link( text   = `And explore more than 200 sample apps...`
                         target = `_blank`
                         href   = `https://github.com/abap2UI5/abap2UI5-samples` ).
    ENDIF.

    simple_form->toolbar( )->title( `Contribution` ).

    simple_form->label( `Open an issue` ).
    simple_form->link( text   = `You have problems, comments or wishes?`
                       target = `_blank`
                       href   = `https://github.com/abap2UI5/abap2UI5/issues` ).

    simple_form->label( `Open a Pull Request` ).
    simple_form->link( text   = `You added a new feature or fixed a bug?`
                       target = `_blank`
                       href   = `https://github.com/abap2UI5/abap2UI5/pulls` ).

    simple_form->toolbar( )->title( `Documentation` ).
    simple_form->label( ).
    simple_form->link( text   = `abap2UI5.org`
                       target = `_blank`
                       href   = `https://abap2UI5.org` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD view_display_popup.

    DATA(view) = z2ui5_cl_xml_view=>factory_popup( ).
    DATA(page) = view->dialog( title      = `abap2UI5 - System Information`
                               afterclose = client->_event( cs_event-close ) ).

    DATA(content) = page->content( ).
    content->_z2ui5( )->info_frontend( ui5_version = client->_bind( ui5_version ) ).

    DATA(simple_form) = content->simple_form(
        editable                = abap_true
        layout                  = `ResponsiveGridLayout`
        labelspanxl             = `4`
        labelspanl              = `3`
        labelspanm              = `4`
        labelspans              = `12`
        adjustlabelspan         = abap_false
        emptyspanxl             = `0`
        emptyspanl              = `4`
        emptyspanm              = `0`
        emptyspans              = `0`
        columnsxl               = `1`
        columnsl                = `1`
        columnsm                = `1`
        singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form->toolbar( )->title( `Frontend` ).

    simple_form->label( `UI5 Version` ).
    simple_form->text( client->_bind( ui5_version ) ).
    simple_form->label( `Launchpad active` ).
    simple_form->checkbox( enabled  = abap_false
                           selected = client->get( )-check_launchpad_active ).

    simple_form->toolbar( )->title( `Backend` ).

    simple_form->label( `ABAP for Cloud` ).
    simple_form->checkbox( enabled  = abap_false
                           selected = z2ui5_cl_util=>context_check_abap_cloud( ) ).

    simple_form->label( `Userexit` ).
    simple_form->text( z2ui5_cl_exit=>get_user_exit_class( ) ).

    DATA(count) = CONV string( NEW z2ui5_cl_core_srv_draft( )->count_entries( ) ).
    simple_form->toolbar( )->title( `abap2UI5` ).
    simple_form->label( `Version ` ).
    simple_form->text( z2ui5_if_app=>version ).
    simple_form->label( `Draft Entries ` ).
    simple_form->text( count ).

    page->end_button( )->button( text  = `close`
                                 press = client->_event( cs_event-close )
                                 type  = `Emphasized` ).

    client->popup_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD reset_button_state.

    s_home-btn_text       = `check`.
    s_home-btn_event_id   = cs_event-button_check.
    s_home-btn_icon       = `sap-icon://validate`.
    s_home-class_editable = abap_true.

  ENDMETHOD.

ENDCLASS.
