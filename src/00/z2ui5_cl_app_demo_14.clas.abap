CLASS z2ui5_cl_app_demo_14 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_type TYPE string.
    DATA mv_path TYPE string.
    DATA mv_editor TYPE string.
    DATA mv_check_editable TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_14 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        mv_path = '../../demo/text'.
        mv_type = 'plain_text'.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'DB_LOAD'.

            mv_editor = COND #(
                WHEN mv_path CS 'abap' THEN lcl_mime_api=>read_abap( )
                WHEN mv_path CS 'json' THEN lcl_mime_api=>read_json( )
                WHEN mv_path CS 'yaml' THEN lcl_mime_api=>read_yaml( )
                WHEN mv_path CS 'text' THEN lcl_mime_api=>read_text( )
                WHEN mv_path CS 'js'   THEN lcl_mime_api=>read_js( )
                ).
            client->popup_message_toast( 'Download successfull' ).

          WHEN 'DB_SAVE'.
            lcl_mime_api=>save_data( ).
            client->popup_message_box( text = 'Upload successfull. File saved!' type = 'success' ).

          WHEN 'EDIT'.
            mv_check_editable = xsdbool( mv_check_editable = abap_False ).
          WHEN 'CLEAR'.
            mv_editor = ``.
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'VIEW_INPUT' ).
        DATA(page) = view->page( title = 'abap2UI5 - MIME Editor' navbuttontap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Demo' href = 'https://twitter.com/OblomovDev/status/1631562906570575875'
                              )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code ).

        DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'l' ).

        grid->simple_form( 'File' )->content( 'f'
             )->label( 'path'
             )->input( view->_bind( mv_path )
             )->label( 'Option'
             )->input( value = view->_bind( mv_type ) suggestionitems = view->_bind_one_way( lcl_mime_api=>get_editor_type( ) )
                   )->get( )->suggestion_items( )->get(
                                 )->list_item( text = '{NAME}' additionalText = '{VALUE}' )->get_parent( )->get_parent(
             )->button( text = 'Download' press = view->_event( 'DB_LOAD' ) icon = 'sap-icon://download-from-cloud' ).

        grid->simple_form( 'Editor' )->content( 'f'
                )->scroll_container( '75%' )->code_editor(
                        type  = mv_type
                        editable = mv_check_editable
                        value = view->_bind( mv_editor ) ).

        page->footer( )->overflow_toolbar(
            )->button(
                 text = 'Clear'
                 press = view->_event( 'CLEAR' )
                 icon  = 'sap-icon://delete'
            )->toolbar_spacer(
            )->button(
                text  = 'Edit'
                press = view->_event( 'EDIT' )
                icon = 'sap-icon://edit'
            )->button(
                text  = 'Upload'
                press = view->_event( 'DB_SAVE' )
                type  = 'Emphasized'
                icon = 'sap-icon://upload-to-cloud'
                enabled = xsdbool( mv_editor IS NOT INITIAL ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
