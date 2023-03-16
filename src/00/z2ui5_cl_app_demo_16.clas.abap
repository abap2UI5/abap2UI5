CLASS z2ui5_cl_app_demo_16 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_type TYPE string.
    DATA mv_path TYPE string.
    DATA mv_editor TYPE string.
    DATA mv_check_editable TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_16 IMPLEMENTATION.


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
                WHEN mv_path CS 'text' THEN lcl_mime_api=>read_text( ) ).
            client->popup_message_toast( 'Download successfull' ).

          WHEN 'DB_SAVE'.
            lcl_mime_api=>save_data( mv_editor ).
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
        DATA(page) = view->page( title = 'abap2UI5 - Visualization with Charts' nav_button_tap = view->_event( 'BACK' ) ).
            page->header_content(
                ")->link( text = 'Demo' href = `https://twitter.com/OblomovDev/status/1634206964291911682`
                )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code
                ).


        DATA(container) = page->tab_container( ).

        DATA(tab) = container->tab( 'Donut Chart' ).

        DATA(grid) = tab->grid( 'L12 M12 S12' )->content( 'l' ).

        grid->simple_form( 'File' )->content( 'f'
             )->label( 'path'
             )->input( view->_bind( mv_path )
             )->label( 'Option'
             )->input( value = view->_bind( mv_type ) suggestion_items = view->_bind_one_way( lcl_mime_api=>get_editor_type( ) )
                   )->get( )->suggestion_items( )->get(
                                 )->list_item( text = '{NAME}' additional_text = '{VALUE}' )->get_parent( )->get_parent(
             )->button( text = 'Download' press = view->_event( 'DB_LOAD' ) icon = 'sap-icon://download-from-cloud' ).

        grid->simple_form( 'Editor' )->content( 'f'
                )->code_editor(
                        type  = mv_type
                        editable = mv_check_editable
                        value = view->_bind( mv_editor ) ).

      tab = container->tab( 'Bar Chart' ).
      tab = container->tab( 'Interactive Line Chart' ).
      tab = container->tab( 'Radial Micro Chart' ).


        page->footer( )->overflow_toolbar(
            )->overflow_toolbar_button(
                 text = 'Delete'
                 icon  = 'sap-icon://delete'
            )->toolbar_spacer(
            )->overflow_toolbar_button(
                text  = 'Edit'
                icon = 'sap-icon://edit'
            )->overflow_toolbar_button(
                text  = 'Upload'
                type  = 'Emphasized'
                icon = 'sap-icon://upload-to-cloud' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
