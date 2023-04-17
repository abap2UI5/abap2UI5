CLASS z2ui5_cl_app_demo_15 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_html_text TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_15 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          mv_html_text = `<h3>subheader</h3><p>link: <a href="https://www.sap.com" style="color:green; font-weight:600;">link to sap.com</a> - links open in ` &&
`a new window.</p><p>paragraph: <strong>strong</strong> and <em>emphasized</em>.</p><p>list:</p><ul` &&
`><li>list item 1</li><li>list item 2<ul><li>sub item 1</li><li>sub item 2</li></ul></li></ul><p>pre:</p><pre>abc    def    ghi</pre><p>code: <code>var el = document.getElementById("myId");</code></p><p>cite: <cite>a reference to a source</cite></p>` &&
`<dl><dt>definition:</dt><dd>definition list of terms and descriptions</dd>`.

        ENDIF.

        CASE client->get( )-event.
          WHEN 'BACK'.
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

        ENDCASE.

        data(view) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Formatted Text'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
            )->header_content(
                )->toolbar_spacer(
                )->link( text = 'Source_Code'  target = '_blank' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent(
            )->vbox( 'sapUiSmallMargin'
                )->link(
                    text = 'Control Documentation - SAP UI5 Formatted Text'
                    href = 'https://sapui5.hana.ondemand.com/#/entity/sap.m.FormattedText/sample/sap.m.sample.FormattedText'
                )->get_parent(
            )->vbox( 'sapUiSmallMargin'
                )->formatted_text( mv_html_text ).

          client->set_next( value #( xml_main = view->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
