CLASS z2ui5_cl_app_demo_18 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_path TYPE string.
    DATA mv_value TYPE string.

    TYPES:
      BEGIN OF ty_file,
        selkz  TYPE abap_bool,
        name   TYPE string,
        format TYPE string,
        size   TYPE string,
        descr  TYPE string,
        data   TYPE string,
      END OF ty_file.

    DATA mt_file TYPE STANDARD TABLE OF ty_file WITH EMPTY KEY.
    DATA ms_file TYPE ty_file.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'DISPLAY'.
            ms_file = mt_file[ selkz = abap_true ].

          WHEN 'UPLOAD'.
            INSERT VALUE #( name = mv_path data = mv_value size = strlen( mv_value ) format = mv_value+5(5) )   INTO TABLE mt_file.

          WHEN 'TEXTAREA_CONFIRM'.
            mt_file[ name = ms_file-name ] = ms_file.
            CLEAR ms_file.

          WHEN 'POPUP_DESCR'.
            ms_file = mt_file[ selkz = abap_true ].
            client->popup_view( 'POPUP_DESCR' ).

          WHEN 'POPUP_DATA'.
            ms_file = mt_file[ selkz = abap_true ].
            client->popup_view( 'POPUP_DATA' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'VIEW_INPUT' ).
        DATA(page) = view->page( title = 'abap2UI5 - Upload/Download Files' navbuttonpress = client->_event( 'BACK' ) ).

        page->zz_file_uploader(
            value       = client->_bind( mv_value )
            path        = client->_bind( mv_path )
            placeholder = 'filepath here...'
            upload      = client->_event( 'UPLOAD' ) ).


        DATA(tab) = page->table(
                 headertext = 'Table'
                 mode = 'SingleSelectLeft'
                 items = client->_bind( mt_file ) ).

        "set toolbar
        tab->header_toolbar( )->overflow_toolbar(
            )->title( 'Files'
             )->toolbar_spacer(
             )->button( text = 'Edit Description' press = client->_event( 'POPUP_DESCR' )
             )->button( text = 'Show Base64' press = client->_event( 'POPUP_DATA' )
             )->button( text = 'display' press = client->_event( 'DISPLAY' )
             ).

        tab->columns(
            )->column( '10%'
              "  )->text( 'Title'
                 )->get_parent(
            )->column( '10%'
               "  )->text( 'Value'
                  )->get_parent(
            )->column( '10%'
               "  )->text( 'Value'
                  )->get_parent(
            )->column(
               "  )->text( 'Description'
                 ).

        tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
           )->text( '{NAME}'
           )->text( '{FORMAT}'
           )->text( '{SIZE}'
           )->text( '{DESCR}' ).


        IF ms_file-data IS NOT INITIAL.
          page->zz_html( '<iframe src="' && ms_file-data && '" height="75%" width="98%"/>' ).
          CLEAR mv_value.
        ENDIF.


        view = client->factory_view( 'POPUP_DESCR' ).
        DATA(popup) = view->dialog( title = 'Edit Description' icon = 'sap-icon://edit' ).

        popup->content(
             )->text_area(
                height = '100%'
                width = '100%'
                value = client->_bind( ms_file-descr ) ).

        popup->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Cancel'
                  press = client->_event( 'TEXTAREA_CANCEL' )
              )->button(
                  text  = 'Confirm'
                  press = client->_event( 'TEXTAREA_CONFIRM' )
                  type  = 'Emphasized' ).

        view = client->factory_view( 'POPUP_DATA' ).
        popup = view->dialog( stretch = abap_true title = 'Data:' ).

        popup->content(
             )->text_area(
                height = '99%'
                width = '99%'
                enabled = abap_false
                value = client->_bind( ms_file-data ) ).

        popup->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'close'
                  press = client->_event( 'TEXTAREA_CONFIRM' )
                  type  = 'Emphasized' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
