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
    DATA mv_popup_name TYPE string.
    DATA mv_main_xml TYPE string.
    DATA mv_popup_xml TYPE string.
    METHODS view_main
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_decide
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS view_popup_textarea_size
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

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - Popups'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Demo' target = '_blank'
                    href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' target = '_blank' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent( ).

    DATA(grid) = page->grid( 'L8 M12 S12' )->content( 'layout' ).

    grid->simple_form( 'Decide' )->content( 'form'
        )->label( '01'
        )->button(
            text  = 'Popup to decide'
            press = client->_event( 'POPUP_TO_DECIDE' ) ).

    grid->simple_form( 'TextArea' )->content( 'form'
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

    grid->simple_form( 'Inputs' )->content( 'form'
        )->label( '01'
        )->button(
            text  = 'Popup Get Input Values'
            press = client->_event( 'POPUP_TO_INPUT' ) ).

    grid->simple_form( 'Tables' )->content( 'form'
        )->label( '02'
        )->button(
            text  = 'Popup to select'
            press = client->_event( 'POPUP_TABLE' ) ).

    mv_main_xml = page->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_decide.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_input.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_table.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_textarea.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_textarea_size.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

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

    ENDIF.

    mv_popup_name = ''.


    CASE client->get( )-event.

      WHEN 'POPUP_TO_DECIDE'.
        mv_popup_name = 'POPUP_TO_DECIDE'.

      WHEN 'BUTTON_CONFIRM'.
        client->popup_message_toast( 'confirm pressed' ).

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( 'cancel pressed' ).

      WHEN 'POPUP_TO_TEXTAREA'.
        mv_popup_name = 'POPUP_TO_TEXTAREA'.
        mv_stretch_active = abap_false.

      WHEN 'POPUP_TO_TEXTAREA_STRETCH'.
        mv_popup_name = 'POPUP_TO_TEXTAREA'.
        mv_stretch_active = abap_true.

      WHEN 'POPUP_TO_TEXTAREA_SIZE'.
        mv_popup_name = 'POPUP_TO_TEXTAREA_SIZE'.

      WHEN 'BUTTON_TEXTAREA_CANCEL'.
        client->popup_message_toast( 'textarea deleted' ).
        CLEAR mv_textarea.

      WHEN 'POPUP_TO_INPUT'.
        ms_popup_input-value1 = 'value1'.
        mv_popup_name =  'POPUP_TO_INPUT'.

      WHEN 'POPUP_BAL'.
        mv_popup_name =  'POPUP_BAL'.

      WHEN 'POPUP_TABLE'.
        CLEAR t_tab.
        DO 10 TIMES.
          DATA(ls_row) = VALUE ty_row( title = 'entry_' && sy-index  value = 'red' info = 'completed'  descr = 'this is a description' ).
          INSERT ls_row INTO TABLE t_tab.
        ENDDO.
        mv_popup_name = 'POPUP_TABLE'.

      WHEN 'POPUP_TABLE_CONTINUE'.
        DELETE t_tab WHERE selkz = abap_false.
        client->popup_message_toast( `Entry selected: ` && VALUE #( t_tab[ 1 ]-title DEFAULT `no entry selected` )  ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

    view_main( client ).

    CASE mv_popup_name.

      WHEN 'POPUP_TO_DECIDE'.
        view_popup_decide( client ).
      WHEN 'POPUP_TO_TEXTAREA'.
        view_popup_textarea( client ).
      WHEN 'POPUP_TO_TEXTAREA_SIZE'.
        view_popup_textarea_size( client ).
      WHEN 'POPUP_TO_INPUT'.
        view_popup_input( client ).
      WHEN 'POPUP_TABLE'.
        view_popup_table( client ).

    ENDCASE.

    client->set_next( VALUE #( xml_main = mv_main_xml xml_popup = mv_popup_xml ) ).
    CLEAR: mv_main_xml, mv_popup_xml.
  ENDMETHOD.
ENDCLASS.
