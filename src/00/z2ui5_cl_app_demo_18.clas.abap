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

    DATA mt_file      TYPE STANDARD TABLE OF ty_file WITH EMPTY KEY.
    DATA ms_file_edit TYPE ty_file.
    DATA ms_file_prev TYPE ty_file.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'DISPLAY'.
            ms_file_prev = mt_file[ selkz = abap_true ].

          WHEN 'UPLOAD'.
            INSERT VALUE #( name = mv_path data = mv_value size = strlen( mv_value ) format = mv_value+5(5) )   INTO TABLE mt_file.
            CLEAR ms_file_edit.
            CLEAR mv_value.
            CLEAR mv_path.

          WHEN 'TEXTAREA_DESCR_CONFIRM'.
            mt_file[ selkz = abap_true ] = ms_file_edit.
            CLEAR ms_file_edit.

          WHEN 'TEXTAREA_DATA_CONFIRM'.
            CLEAR ms_file_edit.

          WHEN 'POPUP_DESCR'.
            ms_file_edit = mt_file[ selkz = abap_true ].
            client->popup_view( 'POPUP_DESCR' ).

          WHEN 'POPUP_DATA'.
            ms_file_edit = mt_file[ selkz = abap_true ].
            client->popup_view( 'POPUP_DATA' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(page) = client->factory_view( 'VIEW_INPUT'
            )->page(
                title = 'abap2UI5 - File Upload/Download'
                navbuttonpress = client->_event( 'BACK' )
            )->header_content(
                )->toolbar_spacer(
                )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code
            )->get_parent( ).

        page->zz_file_uploader(
            value       = client->_bind( mv_value )
            path        = client->_bind( mv_path )
            placeholder = 'filepath here...'
            upload      = client->_event( 'UPLOAD' ) ).

        DATA(tab) = page->table(
                headertext = 'Table'
                mode = 'SingleSelectLeft'
                items = client->_bind( mt_file )
            )->header_toolbar(
                )->overflow_toolbar(
                    )->title( 'Files'
                    )->toolbar_spacer(
                    )->button(
                        text = 'Edit Description'
                        press = client->_event( 'POPUP_DESCR' )
                    )->button(
                        text = 'Show Base64'
                        press = client->_event( 'POPUP_DATA' )
                    )->button(
                        text = 'display'
                        press = client->_event( 'DISPLAY' )
            )->get_parent( )->get_parent( ).

        tab->columns(
            )->column( '10%' )->get_parent(
            )->column( '10%' )->get_parent(
            )->column( '10%' )->get_parent(
            )->column( ).

        tab->items( )->column_list_item( selected = '{SELKZ}' )->cells(
           )->text( '{NAME}'
           )->text( '{FORMAT}'
           )->text( '{SIZE}'
           )->text( '{DESCR}' ).

        IF ms_file_prev-data IS NOT INITIAL.
          page->zz_html( '<iframe src="' && ms_file_prev-data && '" height="75%" width="98%"/>' ).
          CLEAR mv_value.
        ENDIF.


        client->factory_view( 'POPUP_DESCR'
            )->dialog(
                    title = 'Edit Description'
                    icon = 'sap-icon://edit'
                )->content(
                    )->text_area(
                        height = '99%'
                        width = '99%'
                        value = client->_bind( ms_file_edit-descr )
                )->get_parent(
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'Cancel'
                        press = client->_event( 'TEXTAREA_CANCEL' )
                    )->button(
                        text  = 'Confirm'
                        press = client->_event( 'TEXTAREA_DESCR_CONFIRM' )
                        type  = 'Emphasized' ).


        client->factory_view( 'POPUP_DATA'
            )->dialog(
                    stretch = abap_true
                    title = 'Data:'
                )->content(
                    )->text_area(
                        height = '99%'
                        width = '99%'
                        enabled = abap_false
                        value = client->_bind( ms_file_edit-data )
                )->get_parent(
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'close'
                        press = client->_event( 'TEXTAREA_DATA_CONFIRM' )
                        type  = 'Emphasized' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
