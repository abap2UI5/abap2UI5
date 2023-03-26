CLASS z2ui5_cl_app_demo_21 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz    TYPE abap_bool,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mv_textarea TYPE string.
    DATA mv_stretch_active TYPE abap_bool.

    DATA:
      BEGIN OF ms_popup_input,
        value1          TYPE string,
        value2          TYPE string,
        check_is_active TYPE abap_bool,
        combo_key       TYPE string,
      END OF ms_popup_input.

    DATA t_bapiret TYPE bapirettab.

    DATA check_initialized TYPE abap_bool.

    METHODS view_main
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_decide
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_textarea
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_input
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_table
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_21 IMPLEMENTATION.


  METHOD view_main.

    DATA(page) = client->factory_view( 'MAIN'
        )->page(
                title          = 'abap2UI5 - Popups'
                navbuttonpress = client->_event( 'BACK' )
            )->header_content(
                )->link(
                    text = 'Demo'
                    href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' href = client->get( )-s_request-url_source_code
           )->get_parent( ).

    DATA(grid) = page->grid( 'L8 M12 S12' )->content( 'l' ).

    grid->simple_form( 'Decide' )->content( 'f'
        )->label( '01'
        )->button(
            text  = 'Popup to decide'
            press = client->_event( 'POPUP_TO_DECIDE' ) ).

    grid->simple_form( 'TextArea' )->content( 'f'
        )->label( '01'
        )->button(
            text  = 'Popup with textarea input'
            press = client->_event( 'POPUP_TO_TEXTAREA' )
        )->label( '02'
        )->button(
            text  = 'Popup with textarea input (size)'
            press = client->_event( 'POPUP_TO_TEXTAREA_SIZE' )
        )->label( '03'
        )->button(
            text  = 'Popup with textarea input (stretched)'
            press = client->_event( 'POPUP_TO_TEXTAREA_STRETCH' ) ).

    grid->simple_form( 'Inputs' )->content( 'f'
        )->label( '01'
        )->button(
            text  = 'Popup Get Input Values'
            press = client->_event( 'POPUP_TO_INPUT' ) ).

    grid->simple_form( 'Tables' )->content( 'f'
        )->label( '01'
        )->button(
            text  = 'Show bapiret tab'
            press = client->_event( 'POPUP_BAL' )
        )->label( '02'
        )->button(
            text  = 'Popup to select'
            press = client->_event( 'POPUP_TABLE' ) ).

  ENDMETHOD.


  METHOD view_popup_decide.

    client->factory_view( 'POPUP_TO_DECIDE'
        )->dialog(
                title = 'Title'
                icon = 'sap-icon://question-mark'
            )->content(
                )->vbox( 'sapUiMediumMargin'
                    )->text( 'This is a question, you have to make a decision now, cancel or confirm?'
            )->get_parent( )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'Cancel'
                    press = client->_event( 'BUTTON_CANCEL' )
                )->button(
                    text  = 'Confirm'
                    press = client->_event( 'BUTTON_CONFIRM' )
                    type  = 'Emphasized' ).

  ENDMETHOD.


  METHOD view_popup_input.

    client->factory_view( 'POPUP_TO_INPUT'
        )->dialog(
        contentheight = '500px'
        contentwidth  = '500px'
        title = 'Title'
        )->content(
            )->simple_form(
                )->label( 'Input1'
                )->input( client->_bind( ms_popup_input-value1 )
                )->label( 'Input2'
                )->input( client->_bind( ms_popup_input-value2 )
                )->label( 'Checkbox'
                )->checkbox(
                    selected = client->_bind( ms_popup_input-check_is_active )
                    text     = 'this is a checkbox'
                    enabled  = abap_true
        )->get_parent( )->get_parent(
        )->footer( )->overflow_toolbar(
            )->toolbar_spacer(
            )->button(
                text  = 'Cancel'
                press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
            )->button(
                text  = 'Confirm'
                press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                type  = 'Emphasized' ).

  ENDMETHOD.


  METHOD view_popup_table.

    client->factory_view( 'POPUP_BAL'
        )->dialog( 'abap2ui5 - Popup Message Log'
            )->table( client->_bind( t_bapiret )
                )->columns(
                    )->column( '5rem'
                        )->text( 'Type' )->get_parent(
                    )->column( '5rem'
                        )->text( 'Number' )->get_parent(
                    )->column( '5rem'
                        )->text( 'ID' )->get_parent(
                    )->column(
                        )->text( 'Message' )->get_parent(
                )->get_parent(
                )->items(
                    )->column_list_item(
                        )->cells(
                            )->text( '{TYPE}'
                            )->text( '{NUMBER}'
                            )->text( '{ID}'
                            )->text( '{MESSAGE}'
            )->get_parent( )->get_parent( )->get_parent( )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'close'
                    press = client->_event( 'POPUP_BAL_CLOSE' )
                    type  = 'Emphasized' ).

    client->factory_view( 'POPUP_TABLE'
        )->dialog( 'abap2UI5 - Popup to select entry'
            )->table(
                mode = 'SingleSelectLeft'
                items = client->_bind( t_tab )
                )->columns(
                    )->column( )->text( 'Title' )->get_parent(
                    )->column( )->text( 'Color' )->get_parent(
                    )->column( )->text( 'Info' )->get_parent(
                    )->column( )->text( 'Description' )->get_parent(
                )->get_parent(
                )->items( )->column_list_item( selected = '{SELKZ}'
                    )->cells(
                        )->text( '{TITLE}'
                        )->text( '{VALUE}'
                        )->text( '{INFO}'
                        )->text( '{DESCR}'
            )->get_parent( )->get_parent( )->get_parent( )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'continue'
                    press = client->_event( 'POPUP_TABLE_CONTINUE' )
                    type  = 'Emphasized' ).

  ENDMETHOD.


  METHOD view_popup_textarea.

    client->factory_view( 'POPUP_TO_TEXTAREA'
        )->dialog(
                stretch = mv_stretch_active
                title = 'Title'
                icon = 'sap-icon://edit'
            )->content(
                )->text_area(
                    height = '100%'
                    width  = '100%'
                    value  = client->_bind( mv_textarea )
            )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'Cancel'
                    press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
                )->button(
                    text  = 'Confirm'
                    press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                    type  = 'Emphasized' ).

    client->factory_view( 'POPUP_TO_TEXTAREA_SIZE'
        )->dialog(
                contentheight = '100px'
                contentwidth  = '1200px'
                title         = 'Title'
                icon          = 'sap-icon://edit'
            )->content(
                )->text_area(
                    height = '95%'
                    width  = '99%'
                    value  = client->_bind( mv_textarea )
           )->get_parent(
           )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'Cancel'
                    press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
                )->button(
                    text  = 'Confirm'
                    press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                    type  = 'Emphasized' ).

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          t_bapiret = VALUE #(
            ( message = 'An empty Report field causes an empty XML Message to be sent' type = 'E' id = 'MSG1' number = '001' )
            ( message = 'Check was executed for wrong Scenario' type = 'E' id = 'MSG1' number = '002' )
            ( message = 'Request was handled without errors' type = 'S' id = 'MSG1' number = '003' )
            ( message = 'product activated' type = 'S' id = 'MSG4' number = '375' )
            ( message = 'check the input values' type = 'W' id = 'MSG2' number = '375' )
            ( message = 'product already in use' type = 'I' id = 'MSG2' number = '375' )
             ).

          RETURN.
        ENDIF.


        CASE client->get( )-event.

          WHEN 'POPUP_TO_DECIDE'.
            client->popup_view( 'POPUP_TO_DECIDE' ).

          WHEN 'BUTTON_CONFIRM'.
            client->popup_message_toast( 'confirm pressed' ).

          WHEN 'BUTTON_CANCEL'.
            client->popup_message_toast( 'cancel pressed' ).

          WHEN 'POPUP_TO_TEXTAREA'.
            mv_stretch_active = abap_false.
            client->popup_view( 'POPUP_TO_TEXTAREA' ).

          WHEN 'POPUP_TO_TEXTAREA_STRETCH'.
            client->popup_view( 'POPUP_TO_TEXTAREA' ).
            mv_stretch_active = abap_true.

          WHEN 'POPUP_TO_TEXTAREA_SIZE'.
            client->popup_view( 'POPUP_TO_TEXTAREA_SIZE' ).

          WHEN 'BUTTON_TEXTAREA_CANCEL'.
            client->popup_message_toast( 'textarea deleted' ).
            CLEAR mv_textarea.

          WHEN 'POPUP_TO_INPUT'.
            ms_popup_input-value1 = 'value1'.
            client->popup_view( 'POPUP_TO_INPUT' ).

          WHEN 'POPUP_BAL'.
            client->popup_view( 'POPUP_BAL' ).

          WHEN 'POPUP_TABLE'.
            CLEAR t_tab.
            DO 10 TIMES.
              DATA(ls_row) = VALUE ty_row( title = 'entry_' && sy-index  value = 'red' info = 'completed'  descr = 'this is a description' ).
              INSERT ls_row INTO TABLE t_tab.
            ENDDO.
            client->popup_view( 'POPUP_TABLE' ).

          WHEN 'POPUP_TABLE_CONTINUE'.
            DELETE t_tab WHERE selkz = abap_false.
            client->popup_message_toast( `Entry selected: ` && t_tab[ 1 ]-title ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

        client->show_view( 'MAIN' ).


      WHEN client->cs-lifecycle_method-on_rendering.

        view_main( client ).
        view_popup_decide( client ).
        view_popup_textarea( client ).
        view_popup_input( client ).
        view_popup_table( client ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
