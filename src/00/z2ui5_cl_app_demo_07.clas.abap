CLASS z2ui5_cl_app_demo_07 DEFINITION PUBLIC.

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

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.
    METHODS ui5_on_init.
    METHODS ui5_on_event.

    METHODS ui5_render_view_main
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS ui5_render_view_init
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS ui5_render_popup_descr
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS ui5_render_popup_data
      RETURNING
        VALUE(r_result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_07 IMPLEMENTATION.


  METHOD ui5_on_event.

    CASE client->get( )-event.

      WHEN 'START'.
        app-view_main = 'MAIN'.

      WHEN 'DISPLAY'.
        ms_file_prev = mt_file[ selkz = abap_true ].

      WHEN 'UPLOAD'.
        INSERT VALUE #( name = mv_path data = mv_value size = strlen( mv_value ) format = mv_value+5(5) )   INTO TABLE mt_file.
        CLEAR ms_file_prev.
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
        app-view_popup = 'DESCR'.

      WHEN 'POPUP_DATA'.
        ms_file_edit = mt_file[ selkz = abap_true ].
        app-view_popup = 'DATA'.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD ui5_on_init.

    app-view_main = 'INIT'.
    client->popup_message_toast( 'Custom Control for File Upload loaded' ).

  ENDMETHOD.


  METHOD ui5_render_popup_data.

    DATA(lo_popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    r_result = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD ui5_render_popup_descr.

    DATA(lo_popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
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

    r_result = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD ui5_render_view_init.

    DATA(lo_view) = Z2UI5_CL_XML_VIEW=>factory( VALUE #(
         ( n = `xmlns:mvc` v = `sap.ui.core.mvc` )
         ( n = `xmlns:m` v = `sap.m` )
         ( n = `xmlns:z2ui5` v = `z2ui5` )
         ( n = `xmlns:core` v = `sap.ui.core` )
         ( n = `xmlns` v = `http://www.w3.org/1999/xhtml` )
     ) ).

    DATA(page) = lo_view->_generic( name = 'Shell' ns = 'm' )->page(
           ns             = 'm'
           title          = 'abap2UI5 - File Upload/Download'
           navbuttonpress = client->_event( 'BACK' )
           shownavbutton  = abap_true
       )->header_content( ns = 'm'
           )->toolbar_spacer( ns = 'm'
           )->link( ns = 'm' text = 'Demo'   target = '_blank'     href = 'https://twitter.com/OblomovDev/status/1638487600930357248'
           )->link( ns = 'm'  target = '_blank' text = 'Source_Code' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
       )->get_parent( ).

    page->text( ns = 'm' text = 'Custom Control for File Upload is now loaded.'
        )->button( ns = 'm' text = 'continue' press = client->_event( 'START' )
        )->zz_plain( `  <script>  ` && z2ui5_cl_xml_view=>cc_file_uploader_get_js( ) && ` </script>`
    ).

    r_result = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD ui5_render_view_main.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory(  )->shell( )->page(
            title          = 'abap2UI5 - File Upload/Download'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
        )->header_content(
            )->toolbar_spacer(
            )->link( text = 'Demo'        href = 'https://twitter.com/OblomovDev/status/1638487600930357248'
            )->link( text = 'Source_Code' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent( ).

    page->cc_file_uploader(
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
      page->zz_plain( '<html:iframe src="' && ms_file_prev-data && '" height="75%" width="98%"/>' ).
      CLEAR mv_value.
    ENDIF.

    r_result = page->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      ui5_on_event( ).
    ENDIF.

    CASE app-view_main.
      WHEN 'INIT'.
        app-next-xml_main = ui5_render_view_init( ).
      WHEN 'MAIN'.
        app-next-xml_main = ui5_render_view_main( ).
    ENDCASE.

    CASE app-view_popup.
      WHEN 'DESCR'.
        app-next-xml_popup = ui5_render_popup_descr( ).
      WHEN 'DATA'.
        app-next-xml_popup = ui5_render_popup_data( ).
    ENDCASE.

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.
ENDCLASS.
