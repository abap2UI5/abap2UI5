CLASS z2ui5_cl_app_demo_13 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_spfli,
        selkz     TYPE abap_bool,
        carrid    TYPE c LENGTH 3,
        connid    TYPE n LENGTH 4,
        countryfr TYPE c LENGTH 3,
        cityfrom  TYPE c LENGTH 20,
        airpfrom  TYPE c LENGTH 3,
        countryto TYPE c LENGTH 3,
        cityto    TYPE c LENGTH 20,
        airpto    TYPE c LENGTH 3,
      END OF ty_s_spfli.

    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_spfli WITH EMPTY KEY.

    DATA mv_view TYPE string.

    DATA:
      BEGIN OF ms_import,
        t_table     TYPE ty_t_table,
        segment_key TYPE string,
        editor      TYPE string,
      END OF ms_import.

    DATA:
      BEGIN OF ms_export,
        t_table     TYPE ty_t_table,
        segment_key TYPE string,
        editor      TYPE string,
      END OF ms_export.

    DATA:
      BEGIN OF ms_edit,
        t_table      TYPE ty_t_table,
        check_active TYPE abap_bool,
      END OF ms_edit.

    DATA check_initialized TYPE abap_bool.
    "dummy helper - not needed when using db
    DATA st_db TYPE ty_t_table.

  PROTECTED SECTION.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_import
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_edit
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_export
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_13 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.
    "dummy helper - not needed when using db
    lcl_db=>app = me.


    IF check_initialized = abap_false.
      check_initialized = abap_true.

      ms_import-segment_key = 'json'.
      ms_import-editor = lcl_db=>get_test_data_json( ).
      ms_export-segment_key = 'json'.
      mv_view = 'IMPORT_TABLE'.

    ENDIF.

    z2ui5_on_event( client ).

    CASE mv_view.
      WHEN 'IMPORT_TABLE'.
        z2ui5_on_render_view_import( client ).
      WHEN 'EDIT_TABLE'.
        z2ui5_on_render_view_edit( client ).
      WHEN 'EXPORT_TABLE'.
        z2ui5_on_render_view_export( client ).
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'IMPORT_DB'.
        ms_import-t_table = SWITCH #( ms_import-segment_key
          WHEN 'json' THEN lcl_db=>get_table_by_json( ms_import-editor )
          WHEN 'csv'  THEN lcl_db=>get_table_by_csv( ms_import-editor )
          WHEN 'xml'  THEN lcl_db=>get_table_by_xml( ms_import-editor ) ).

        lcl_db=>db_save( ms_import-t_table ).
        client->popup_message_box( 'Table data imported successfully' ).

      WHEN 'EXPORT_DB'.
        ms_export-t_table = lcl_db=>db_read( ).
        ms_export-editor = SWITCH #( ms_export-segment_key
          WHEN 'json' THEN lcl_db=>get_json_by_table( ms_export-t_table )
          WHEN 'csv'  THEN lcl_db=>get_csv_by_table( ms_export-t_table )
          WHEN 'xml'  THEN lcl_db=>get_xml_by_table( ms_export-t_table ) ).

        client->popup_message_box( 'Table data exported successfully' ).

      WHEN 'IMPORT_CLEAR'.
        CLEAR ms_import-editor.

      WHEN 'EDIT_DB_READ'.
        ms_edit-t_table = lcl_db=>db_read( ).
        client->popup_message_box( 'Table read successfully' ).

      WHEN 'EDIT_DB_SAVE'.
        lcl_db=>db_save( ms_edit-t_table ).
        client->popup_message_box( 'Table data saved to database successfully' ).

      WHEN 'EDIT_ROW_DELETE'.
        DELETE ms_edit-t_table WHERE selkz = abap_true.

      WHEN 'EDIT_CHANGE_MODE'.
        ms_edit-check_active = xsdbool( ms_edit-check_active = abap_false ).

      WHEN 'EDIT_ROW_ADD'.
        INSERT VALUE #( ) INTO TABLE ms_edit-t_table.

      WHEN 'BTN_IMPORT'.
        mv_view = 'IMPORT_TABLE'.
      WHEN 'BTN_EDIT'.
        mv_view = 'EDIT_TABLE'.
      WHEN 'BTN_EXPORT'.
        mv_view = 'EXPORT_TABLE'.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_view_edit.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
       )->page(
               title          = 'abap2ui5 - Table Maintenance'
               navbuttonpress = client->_event( 'BACK' )
               shownavbutton  = abap_true
           )->header_content(
               )->link(
                   text = 'Demo' target = '_blank'
                   href = `https://twitter.com/OblomovDev/status/1634206964291911682`
               )->link(
                   text = 'Source_Code' target = '_blank'
                   href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent(
           )->sub_header(
               )->overflow_toolbar(
                   )->button(
                       text    = '(1) Import Data'
                       press   = client->_event( 'BTN_IMPORT' )
                   )->button(
                       text    = '(2) Edit Data'
                       press   = client->_event( 'BTN_EDIT' )
                       enabled = abap_false
                   )->button(
                       text    = '(3) Export Data'
                       press   = client->_event( 'BTN_EXPORT' )
           )->get_parent( )->get_parent( ).

    DATA(grid) = page->grid( 'L7 M7 S7' )->content( 'layout' ).

    grid->simple_form( '2. Edit Data'
         )->content( 'form'
            )->label( 'Table'
            )->input( 'SPFLI' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'layout' ).

    DATA(cont) = grid->simple_form(  )->content( 'form' ).

    cont->overflow_toolbar(
                  )->button(
                      text  = 'Reload'
                      icon  = 'sap-icon://refresh'
                      press = client->_event( 'EDIT_DB_READ' )
                  )->toolbar_spacer(
                  )->button(
                      text  = 'Delete Row'
                      icon  = 'sap-icon://delete'
                      press = client->_event( 'EDIT_ROW_DELETE' )
                  )->button(
                      text  = 'Add Row'
                      icon  = 'sap-icon://add'
                      press = client->_event( 'EDIT_ROW_ADD' ) ).

    DATA(scroll) = cont->scroll_container( vertical = abap_true horizontal = abap_true ).

    DATA(tab) = scroll->table(
                  width = '100rem'
                  items = client->_bind( ms_edit-t_table )
                  mode  = 'MultiSelect' ).

    DATA(lt_fields) = lcl_db=>get_fieldlist_by_table( ms_edit-t_table ).

    DATA(lo_columns) = tab->columns( ).
    LOOP AT lt_fields INTO DATA(lv_field) FROM 2.
      lo_columns->column( )->text( lv_field ).
    ENDLOOP.

    DATA(lo_cells) = tab->items( )->column_list_item( selected = '{SELKZ}' )->cells( ).
    LOOP AT lt_fields INTO lv_field FROM 2.
      lo_cells->input( `{` && lv_field && `}` ).
    ENDLOOP.

    page->footer(
        )->overflow_toolbar(
            )->toolbar_spacer(
            )->button(
                text = 'Save'
                press = client->_event( 'EDIT_DB_SAVE' )
                type = 'Emphasized'
                icon = 'sap-icon://upload-to-cloud' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.


  METHOD z2ui5_on_render_view_export.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory(  )->shell(
    )->page(
            title          = 'abap2ui5 - Table Maintenance'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
        )->header_content(
            )->link(
                text = 'Demo'
                href = `https://twitter.com/OblomovDev/status/1634206964291911682`
            )->link(
                text = 'Source_Code'
                href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent(
        )->sub_header(
            )->overflow_toolbar(
                )->button(
                    text  = '(1) Import Data'
                    press = client->_event( 'BTN_IMPORT' )
                )->button(
                    text  = '(2) Edit Data'
                    press = client->_event( 'BTN_EDIT' )
                )->button(
                    text    = '(3) Export Data'
                    press   = client->_event( 'BTN_EXPORT' )
                    enabled = abap_false
        )->get_parent( )->get_parent( ).

    DATA(grid) = page->grid( 'L7 M7 S7' )->content( 'layout' ).

    grid->simple_form( '3. Export Data'
         )->content( 'form'
            )->label( 'Table'
            )->input( 'SPFLI'
            )->label( 'Format'
            )->segmented_button( client->_bind( ms_export-segment_key )
                )->items(
                    )->segmented_button_item( key = 'json' text = 'json'
                    )->segmented_button_item( key = 'csv'  text = 'csv'
                    )->segmented_button_item( key = 'xml'  text = 'xml' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'layout' ).

    grid->scroll_container( '75%'
        )->code_editor(
             type     = COND #( WHEN ms_export-segment_key = 'csv' THEN |plain_text| ELSE ms_import-segment_key )
             value    = client->_bind( ms_export-editor )
             editable = abap_false ).

    page->footer(
        )->overflow_toolbar(
            )->toolbar_spacer(
            )->button(
                text  = 'Export'
                press = client->_event( 'EXPORT_DB' )
                type  = 'Emphasized'
                icon  = 'sap-icon://download-from-cloud' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.


  METHOD z2ui5_on_render_view_import.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
    )->page(
            title          = 'abap2UI5 - Table Maintenance'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton  = abap_true
        )->header_content(
            )->link(
                text = 'Demo'
                href = `https://twitter.com/OblomovDev/status/1634206964291911682`
            )->link(
                text = 'Source_Code'
                href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent(
        )->sub_header(
            )->overflow_toolbar(
                )->button(
                    text    = '(1) Import Data'
                    press   = client->_event( 'BTN_IMPORT' )
                    enabled = abap_false
                )->button(
                    text  = '(2) Edit Data'
                    press = client->_event( 'BTN_EDIT' )
                )->button(
                    text  = '(3) Export Data'
                    press = client->_event( 'BTN_EXPORT' )
        )->get_parent( )->get_parent( ).

    DATA(grid) = page->grid( 'L7 M12 S12' )->content( 'layout' ).

    grid->simple_form( '1. Import Data'
         )->content( 'form'
            )->label( 'Table'
            )->input( 'SPFLI'
            )->label( 'Format'
            )->segmented_button( client->_bind( ms_import-segment_key ) )->get(
                )->items( )->get(
                    )->segmented_button_item( key = 'json' text = 'json'
                    )->segmented_button_item( key = 'csv'  text = 'csv'
                    )->segmented_button_item( key = 'xml'  text = 'xml' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'layout' ).

    grid->scroll_container( '75%'
        )->code_editor(
            type     = COND #( WHEN ms_import-segment_key = 'csv' THEN |plain_text| ELSE ms_import-segment_key )
            value    = client->_bind( ms_import-editor )
            editable = abap_true ).

    page->footer( )->overflow_toolbar(
        )->button(
            text  = 'Clear'
            press = client->_event( 'IMPORT_CLEAR' )
            icon  = 'sap-icon://delete'
        )->toolbar_spacer(
        )->button(
            text  = 'Import'
            press = client->_event( 'IMPORT_DB' )
            type  = 'Emphasized'
            icon  = 'sap-icon://upload-to-cloud' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
