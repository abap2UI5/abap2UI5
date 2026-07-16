CLASS z2ui5_cl_app_startup DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_app_startup.



    CONSTANTS:
      BEGIN OF cs_event,
        button_check  TYPE string VALUE `BUTTON_CHECK`,
        button_change TYPE string VALUE `BUTTON_CHANGE`,
        open_debug    TYPE string VALUE `OPEN_DEBUG`,
        open_info     TYPE string VALUE `OPEN_INFO`,
        set_config    TYPE string VALUE `SET_CONFIG`,
        close         TYPE string VALUE `CLOSE`,
      END OF cs_event.

    DATA client TYPE REF TO z2ui5_if_client.

    DATA:
      BEGIN OF ms_home,
        url                    TYPE string,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

    " request handling
    METHODS on_init.
    METHODS on_event.
    METHODS on_event_check.
    METHODS reset_button_state.

    " home page - one method per section
    METHODS render_start.
    METHODS render_header_toolbar
      IMPORTING page TYPE REF TO z2ui5_cl_xml_view.
    METHODS render_quickstart
      IMPORTING form TYPE REF TO z2ui5_cl_xml_view.
    METHODS render_whats_next
      IMPORTING form TYPE REF TO z2ui5_cl_xml_view.
    METHODS render_contribution
      IMPORTING form TYPE REF TO z2ui5_cl_xml_view.
    METHODS render_documentation
      IMPORTING form TYPE REF TO z2ui5_cl_xml_view.
    METHODS render_system_popup.

    " helpers
    METHODS create_layout_form
      IMPORTING
        view          TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.
    METHODS get_app_url
      IMPORTING
        classname     TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
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
      render_start( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_init.

    reset_button_state( ).
    ms_home-classname = z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( NEW z2ui5_cl_app_hello_world( ) ).

  ENDMETHOD.

  METHOD on_event.

    DATA li_app_config TYPE REF TO z2ui5_if_app.

    CASE client->get( )-event.

      WHEN cs_event-set_config.
        CREATE OBJECT li_app_config TYPE (`Z2UI5_CL_APP_ICF_CONFIG`).
        client->nav_app_call( li_app_config ).

      WHEN cs_event-open_debug.
        client->message_box_display( `Press CTRL+F12 to open the debugging tools` ).

      WHEN cs_event-open_info.
        render_system_popup( ).

      WHEN cs_event-close.
        client->popup_destroy( ).

      WHEN cs_event-button_check.
        on_event_check( ).
        render_start( ).

      WHEN cs_event-button_change.
        reset_button_state( ).
        render_start( ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_event_check.

    DATA li_app_test TYPE REF TO z2ui5_if_app.

    TRY.
        ms_home-classname = z2ui5_cl_a2ui5_context=>c_trim_upper( ms_home-classname ).
        CREATE OBJECT li_app_test TYPE (ms_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        ms_home-btn_text          = `Edit`.
        ms_home-btn_event_id      = cs_event-button_change.
        ms_home-btn_icon          = `sap-icon://edit`.
        ms_home-class_value_state = `Success`.
        ms_home-class_editable    = abap_false.
        ms_home-url               = get_app_url( ms_home-classname ).

      CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
        ms_home-class_value_state_text = lx->get_text( ).
        ms_home-class_value_state      = `Warning`.
        client->message_box_display( text = ms_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.

  METHOD reset_button_state.

    ms_home-btn_text       = `Check`.
    ms_home-btn_event_id   = cs_event-button_check.
    ms_home-btn_icon       = `sap-icon://validate`.
    ms_home-class_editable = abap_true.

  ENDMETHOD.

  METHOD render_start.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell( )->page(
                     title         = `abap2UI5 - Building UI5 Apps Purely in ABAP`
                     shownavbutton = abap_false ).

    render_header_toolbar( page ).

    DATA(form) = create_layout_form( page ).
    render_quickstart( form ).
    render_whats_next( form ).
    render_contribution( form ).
    render_documentation( form ).

    client->view_display( page->stringify( ) ).

  ENDMETHOD.

  METHOD render_header_toolbar.

    DATA(toolbar) = page->header_content( ).
    toolbar->toolbar_spacer(
      )->button( text  = `Debugging Tools`
                 icon  = `sap-icon://enablement`
                 press = client->_event( cs_event-open_debug )
      )->button( text  = `System`
                 icon  = `sap-icon://information`
                 press = client->_event( cs_event-open_info ) ).

    IF z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      toolbar->button( text  = `Config`
                       icon  = `sap-icon://settings`
                       press = client->_event( cs_event-set_config ) ).
    ENDIF.

  ENDMETHOD.

  METHOD render_quickstart.

    form->toolbar( )->title( `Quickstart` ).

    form->label( `Step 1`
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

    IF ms_home-class_editable = abap_true.
      form->input( placeholder = `fill in the class name and press 'check'`
                   enabled     = client->_bind( ms_home-class_editable )
                   value       = client->_bind_edit( ms_home-classname )
                   submit      = client->_event( ms_home-btn_event_id )
                   width       = `70%` ).
    ELSE.
      form->text( ms_home-classname ).
    ENDIF.

    form->label( ).
    form->button( press = client->_event( ms_home-btn_event_id )
                  text  = client->_bind( ms_home-btn_text )
                  icon  = client->_bind( ms_home-btn_icon )
                  width = `70%` ).

    form->label( `Step 5`
      )->link( text    = `Link to the Application`
               target  = `_blank`
               href    = client->_bind( ms_home-url )
               enabled = |\{= ${ client->_bind( val = ms_home-class_editable ) } === false \}| ).

  ENDMETHOD.

  METHOD render_whats_next.

    form->toolbar( )->title( `What's next?` ).

    DATA(lv_class_samples) = COND string(
      WHEN z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_sample_app_001` ) THEN `z2ui5_cl_sample_app_001`
      WHEN z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_demo_app_000` ) THEN `z2ui5_cl_demo_app_000` ).

    IF lv_class_samples IS NOT INITIAL.
      form->label( `Start Developing` ).
      form->button( text  = `Explore Code Samples`
                    press = client->_event_client( val   = client->cs_event-open_new_tab
                                                   t_arg = VALUE #( ( get_app_url( lv_class_samples ) ) ) )
                    width = `70%` ).
    ELSE.
      form->label( `Install the sample repository` ).
      form->link( text   = `And explore more than 250 sample apps...`
                  target = `_blank`
                  href   = `https://github.com/abap2UI5/samples` ).
    ENDIF.

  ENDMETHOD.

  METHOD render_contribution.

    form->toolbar( )->title( `Contribution` ).

    form->label( `Open an issue` ).
    form->link( text   = `You have problems, comments or wishes?`
                target = `_blank`
                href   = `https://github.com/abap2UI5/abap2UI5/issues` ).

    form->label( `Open a Pull Request` ).
    form->link( text   = `You added a new feature or fixed a bug?`
                target = `_blank`
                href   = `https://github.com/abap2UI5/abap2UI5/pulls` ).

  ENDMETHOD.

  METHOD render_documentation.

    form->toolbar( )->title( `Documentation` ).
    form->label( ).
    form->link( text   = `abap2UI5.org`
                target = `_blank`
                href   = `https://abap2UI5.org` ).

  ENDMETHOD.

  METHOD render_system_popup.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup(
         )->dialog( title      = `abap2UI5 - System Information`
                    afterclose = client->_event( cs_event-close ) ).

    DATA(form) = create_layout_form( popup->content( ) ).
    DATA(ls_client) = client->get( ).

    form->toolbar( )->title( `Frontend` ).
    form->label( `UI5 Version` ).
    form->text( ls_client-s_ui5-version ).
    form->label( `Launchpad active` ).
    form->checkbox( enabled  = abap_false
                    selected = ls_client-check_launchpad_active ).

    form->toolbar( )->title( `Backend` ).
    form->label( `ABAP for Cloud` ).
    form->checkbox( enabled  = abap_false
                    selected = z2ui5_cl_a2ui5_context=>context_check_abap_cloud( ) ).
    form->label( `User Exit` ).
    form->text( z2ui5_cl_exit=>get_user_exit_class( ) ).

    form->toolbar( )->title( `abap2UI5` ).
    form->label( `Version` ).
    form->text( z2ui5_if_app=>version ).
    form->label( `Draft Entries` ).
    form->text( CONV string( NEW z2ui5_cl_core_srv_draft( )->count_entries( ) ) ).

    popup->end_button( )->button( text  = `Close`
                                  press = client->_event( cs_event-close )
                                  type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD create_layout_form.

    result = view->simple_form( editable                = abap_true
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

  ENDMETHOD.

  METHOD get_app_url.

    DATA(ls_config) = client->get( )-s_config.
    result = z2ui5_cl_a2ui5_context=>app_get_url( classname = classname
                                                  origin    = ls_config-origin
                                                  pathname  = ls_config-pathname
                                                  search    = ls_config-search
                                                  hash      = ls_config-hash ).

  ENDMETHOD.

ENDCLASS.
