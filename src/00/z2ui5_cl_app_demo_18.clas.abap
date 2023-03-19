CLASS z2ui5_cl_app_demo_18 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_path TYPE string.
    DATA mv_value TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
*        mv_path = '../../demo/text'.
*        mv_type = 'plain_text'.
*
      WHEN client->cs-lifecycle_method-on_event.
*
        CASE client->get( )-event.
*
*          WHEN 'DB_LOAD'.
*
*            mv_editor = COND #(
*                WHEN mv_path CS 'abap' THEN lcl_mime_api=>read_abap( )
*                WHEN mv_path CS 'json' THEN lcl_mime_api=>read_json( )
*                WHEN mv_path CS 'yaml' THEN lcl_mime_api=>read_yaml( )
*                WHEN mv_path CS 'text' THEN lcl_mime_api=>read_text( ) ).
*            client->display_message_toast( 'Download successfull').
*
*          WHEN 'DB_SAVE'.
*            lcl_mime_api=>save_data( mv_editor ).
*            client->display_message_box( text = 'Upload successfull. File saved!' type = 'success' ).
*
*          WHEN 'EDIT'.
*            mv_check_editable = xsdbool( mv_check_editable = abap_False ).
*          WHEN 'CLEAR'.
*            mv_editor = ``.

          WHEN 'UPLOAD'.
            DATA(lv_dummy) = ''.
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'VIEW_INPUT' ).
        DATA(page) = view->page( title = 'abap2UI5 - Upload/Download Files' navbuttontap = view->_event( 'BACK' ) ).
        "  DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'l' ).

      DATA(lv_html_text) = `<h3>subheader</h3><p>link: <a href="//www.sap.com" style="color:green; font-weight:600;">link to sap.com</a> - links open in a new window.</p><p>paragraph: <strong>strong</strong> and <em>emphasized</em>.</p><p>list:</p><ul` &&
  `><li>list item 1</li><li>list item 2<ul><li>sub item 1</li><li>sub item 2</li></ul></li></ul><p>pre:</p><pre>abc    def    ghi</pre><p>code: <code>var el = document.getElementById("myId");</code></p><p>cite: <cite>a reference to a source</cite></p>` &&
  `<dl><dt>definition:</dt><dd>definition list of terms and descriptions</dd>`.

        page->vbox( 'sapUiSmallMargin' )->formatted_text( htmltext = lv_html_text ).

        page->zz_file_uploader(
            value       = view->_bind( mv_value )
            path        = view->_bind( mv_path )
            placeholder = 'filepath here...'
            upload      = view->_event( 'UPLOAD' )
        ).

        IF mv_value IS NOT INITIAL.
          page->zz_html( '<iframe src="' && mv_value && '" height="90%" width="98%"/>' ).
          CLEAR mv_value.
        ENDIF.
        RETURN.

        " mv_editor = escape( val = mv_editor format = cl_abap_format=>e_json_string ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
