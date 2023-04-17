CLASS z2ui5_cl_app_demo_19 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz TYPE abap_bool,
        title TYPE string,
        value TYPE string,
        descr TYPE string,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA t_tab_sel TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA mv_sel_mode TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_19 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          mv_sel_mode = 'None'.
          t_tab = VALUE #( descr = 'this is a description'
              (  title = 'title_01'  value = 'value_01' )
              (  title = 'title_02'  value = 'value_02' )
              (  title = 'title_03'  value = 'value_03' )
              (  title = 'title_04'  value = 'value_04' )
              (  title = 'title_05'  value = 'value_05' ) ).

        ENDIF.

        CASE client->get( )-event.
          WHEN 'BUTTON_SEGMENT_CHANGE'.
            client->popup_message_toast( `Selection Mode changed` ).

          WHEN 'BUTTON_READ_SEL'.
            t_tab_sel = t_tab.
            DELETE t_tab_sel WHERE selkz <> abap_true.

          WHEN 'BACK'.
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

        ENDCASE.

        DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
            )->page(
                title          = 'abap2UI5 - Table with different Selection Modes'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
                )->header_content(
                    )->link(
                        text = 'Demo' target = '_blank'
                        href = 'https://twitter.com/OblomovDev/status/1637852441671528448'
                    )->link(
                        text = 'Source_Code' target = '_blank'
                        href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
                )->get_parent( ).

        page->segmented_button(
            selected_key     = client->_bind( mv_sel_mode )
            selection_change = client->_event( 'BUTTON_SEGMENT_CHANGE' ) )->get(
                )->items( )->get(
                    )->segmented_button_item(
                        key  = 'None'
                        text = 'None'
                    )->segmented_button_item(
                        key  = 'SingleSelect'
                        text = 'SingleSelect'
                    )->segmented_button_item(
                        key  = 'SingleSelectLeft'
                        text = 'SingleSelectLeft'
                    )->segmented_button_item(
                        key  = 'SingleSelectMaster'
                        text = 'SingleSelectMaster'
                    )->segmented_button_item(
                        key = 'MultiSelect'
                        text = 'MultiSelect' ).

        page->table(
            headertext = 'Table'
            mode = mv_sel_mode
            items = client->_bind( t_tab )
            )->columns(
                )->column( )->text( 'Title' )->get_parent(
                )->column( )->text( 'Value' )->get_parent(
                )->column( )->text( 'Description'
            )->get_parent( )->get_parent(
            )->items(
                )->column_list_item( selected = '{SELKZ}'
                    )->cells(
                        )->text( '{TITLE}'
                        )->text( '{VALUE}'
                        )->text( '{DESCR}' ).

        page->table( client->_bind_one( t_tab_sel )
            )->header_toolbar(
                )->overflow_toolbar(
                    )->title( 'Selected Entries'
                    )->button(
                        icon = 'sap-icon://pull-down'
                        text = 'copy selected entries'
                        press = client->_event( 'BUTTON_READ_SEL' )
          )->get_parent( )->get_parent(
          )->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Value' )->get_parent(
            )->column( )->text( 'Description'
            )->get_parent( )->get_parent(
            )->items( )->column_list_item( )->cells(
                )->text( '{TITLE}'
                )->text( '{VALUE}'
                )->text( '{DESCR}' ).

  client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
